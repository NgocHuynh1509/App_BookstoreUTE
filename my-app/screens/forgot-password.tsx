import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Alert,
  StyleSheet,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StatusBar,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import api from "../services/api";

// ─── Palette UTE BookStore (Tone Đỏ & Vàng Ấm) ──────────────────────────────────
const C = {
  // Màu đỏ đậm thương hiệu - Mạnh mẽ, uy tín
  primary:     "#B8001A",

  // Màu đỏ sáng hơn - Dùng cho các nút bấm khi được nhấn (Active)
  primaryMid:  "#D0001F",

  // Màu nền đỏ cực nhạt - Thay thế cho màu xanh nhạt cũ
  primarySoft: "#FFF5F5",

  // Màu hồng nhạt - Dùng để highlight các lựa chọn hoặc viền nhẹ
  primaryTint: "#FFDADA",

  // Nền ứng dụng: Trắng sứ pha chút ấm (Tránh mỏi mắt hơn trắng xanh cũ)
  bg:          "#FFFBFB",

  // Bề mặt các thẻ (Card), khung trắng tinh
  surface:     "#FFFFFF",

  // Viền: Màu hồng xám nhạt (Đồng bộ với tone nóng)
  border:      "#FEE2E2",

  // Viền khi focus vào ô nhập liệu
  borderFocus: "#B8001A",

  // Văn bản chính: Nâu đen đậm (Hợp với đỏ hơn là xanh đen cũ)
  text1:       "#2D0A0A",

  // Văn bản phụ: Xám đỏ trung tính
  text2:       "#6D5B5B",

  // Văn bản mờ, ghi chú hoặc icon nền
  text3:       "#AFA0A0",

  // Chữ gợi ý trong ô input
  placeholder: "#D1C4C4",

  // Màu lỗi: Đỏ tươi đặc trưng
  error:       "#E53935",

  // Màu xanh lá (Dùng cho thông báo thành công) - Chỉnh lại tone ấm hơn
  green:       "#286B2C",
};

function InputField({
                      label,
                      icon,
                      value,
                      onChangeText,
                      placeholder,
                      keyboardType,
                      autoCapitalize = "sentences",
                      editable = true,
                      maxLength,
                    }: any) {
  const [focused, setFocused] = useState(false);

  return (
      <View style={s.fieldWrap}>
        <View style={s.fieldLabelRow}>
          <Ionicons name={icon} size={13} color={C.primaryMid} />
          <Text style={s.fieldLabel}>{label}</Text>
        </View>

        <View style={[s.inputWrap, focused && s.inputWrapFocused]}>
          <TextInput
              style={s.input}
              value={value}
              onChangeText={onChangeText}
              placeholder={placeholder}
              placeholderTextColor={C.placeholder}
              keyboardType={keyboardType}
              autoCapitalize={autoCapitalize}
              editable={editable}
              maxLength={maxLength}
              onFocus={() => setFocused(true)}
              onBlur={() => setFocused(false)}
          />
        </View>
      </View>
  );
}

function PasswordField({
                         label,
                         icon,
                         value,
                         onChangeText,
                         placeholder,
                         editable = true,
                       }: any) {
  const [focused, setFocused] = useState(false);
  const [shown, setShown] = useState(false);

  return (
      <View style={s.fieldWrap}>
        <View style={s.fieldLabelRow}>
          <Ionicons name={icon} size={13} color={C.primaryMid} />
          <Text style={s.fieldLabel}>{label}</Text>
        </View>

        <View style={[s.inputWrap, focused && s.inputWrapFocused]}>
          <TextInput
              style={s.input}
              value={value}
              onChangeText={onChangeText}
              placeholder={placeholder}
              placeholderTextColor={C.placeholder}
              secureTextEntry={!shown}
              autoCapitalize="none"
              editable={editable}
              onFocus={() => setFocused(true)}
              onBlur={() => setFocused(false)}
          />
          <TouchableOpacity onPress={() => setShown((v: boolean) => !v)} style={{ paddingLeft: 8 }}>
            <Ionicons
                name={shown ? "eye-off-outline" : "eye-outline"}
                size={18}
                color={C.text3}
            />
          </TouchableOpacity>
        </View>
      </View>
  );
}

function StepItem({
                    number,
                    label,
                    active,
                    done,
                  }: {
  number: number;
  label: string;
  active: boolean;
  done: boolean;
}) {
  return (
      <View style={s.stepItem}>
        <View
            style={[
              s.stepCircle,
              done && s.stepCircleDone,
              active && s.stepCircleActive,
            ]}
        >
          <Text style={[s.stepCircleTxt, (done || active) && { color: "#FFF" }]}>
            {done ? "✓" : number}
          </Text>
        </View>
        <Text
            style={[
              s.stepLabel,
              active && s.stepLabelActive,
              done && s.stepLabelDone,
            ]}
        >
          {label}
        </Text>
      </View>
  );
}

export default function ForgotPasswordScreen({ navigation }: any) {
  const [step, setStep] = useState(1);
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const strength = (() => {
    if (!newPassword) return 0;
    let score = 0;
    if (newPassword.length >= 8) score++;
    if (/[A-Z]/.test(newPassword)) score++;
    if (/[0-9]/.test(newPassword)) score++;
    if (/[^A-Za-z0-9]/.test(newPassword)) score++;
    return score;
  })();

  const strengthLabel = ["", "Yếu", "Trung bình", "Khá mạnh", "Mạnh"][strength];
  const strengthColor = ["", C.error, "#FF8C00", "#FFC107", C.green][strength];

  const passwordsMatch =
      confirmPassword.length > 0 && newPassword === confirmPassword;
  const mismatch =
      confirmPassword.length > 0 && newPassword !== confirmPassword;

  const handleSendOTP = async () => {
    if (!email.trim()) {
      Alert.alert("Thông báo", "Vui lòng nhập email");
      return;
    }

    setLoading(true);
    try {
      const res = await api.post("/forgot-password/send-otp", { email: email.trim() });
      Alert.alert("Thành công", res.data.message || "Mã OTP đã được gửi");
      setStep(2);
    } catch (err: any) {
      Alert.alert(
          "Lỗi",
          err?.response?.data?.message || "Không thể gửi OTP. Vui lòng thử lại."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async () => {
    if (!otp || otp.length !== 6) {
      Alert.alert("Thông báo", "Vui lòng nhập mã OTP 6 chữ số");
      return;
    }

    if (!newPassword) {
      Alert.alert("Thông báo", "Vui lòng nhập mật khẩu mới");
      return;
    }

    if (newPassword.length < 6) {
      Alert.alert("Thông báo", "Mật khẩu phải có ít nhất 6 ký tự");
      return;
    }

    if (newPassword !== confirmPassword) {
      Alert.alert("Thông báo", "Mật khẩu xác nhận không khớp");
      return;
    }

    setLoading(true);
    try {
      const res = await api.post("/forgot-password/reset-password", {
        email: email.trim(),
        otp,
        newPassword,
      });

      Alert.alert(
          "Thành công",
          res.data.message || "Đặt lại mật khẩu thành công",
          [
            {
              text: "OK",
              onPress: () => navigation.replace("Login"),
            },
          ]
      );
    } catch (err: any) {
      Alert.alert(
          "Lỗi",
          err?.response?.data?.message ||
          "Không thể đặt lại mật khẩu. Vui lòng thử lại."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleResendOTP = async () => {
    setLoading(true);
    try {
      await api.post("/forgot-password/send-otp", { email: email.trim() });
      Alert.alert("Thành công", "Mã OTP mới đã được gửi");
    } catch (err: any) {
      Alert.alert(
          "Lỗi",
          err?.response?.data?.message || "Không thể gửi lại OTP"
      );
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    if (step === 2) {
      setStep(1);
      setOtp("");
      setNewPassword("");
      setConfirmPassword("");
    } else {
      navigation.replace("Login");
    }
  };

  const canStep1 = email.trim().length > 0 && !loading;
  const canStep2 =
      otp.length === 6 &&
      newPassword.length >= 6 &&
      confirmPassword.length > 0 &&
      newPassword === confirmPassword &&
      !loading;

  return (
      <KeyboardAvoidingView
          style={{ flex: 1, backgroundColor: C.bg }}
          behavior={Platform.OS === "ios" ? "padding" : "height"}
      >
        <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

        <View style={s.topBar}>
          <View style={s.topBarBlob} />
          <TouchableOpacity style={s.backBtn} onPress={handleBack}>
            <Ionicons name="chevron-back" size={22} color="#FFF" />
          </TouchableOpacity>
          <Text style={s.topBarTitle}>Quên mật khẩu</Text>
          <View style={{ width: 38 }} />
        </View>

        <ScrollView
            contentContainerStyle={s.scroll}
            keyboardShouldPersistTaps="handled"
            showsVerticalScrollIndicator={false}
        >
          <View style={s.stepRow}>
            <StepItem number={1} label="Email" active={step === 1} done={step > 1} />
            <View style={[s.stepLine, step > 1 && s.stepLineDone]} />
            <StepItem number={2} label="OTP & mật khẩu" active={step === 2} done={false} />
          </View>

          <View style={s.card}>
            <View style={s.cardIcon}>
              <Ionicons
                  name={step === 1 ? "mail-outline" : "shield-checkmark-outline"}
                  size={28}
                  color={C.primaryMid}
              />
            </View>

            <Text style={s.cardTitle}>
              {step === 1 ? "Xác minh email" : "Đặt lại mật khẩu"}
            </Text>

            <Text style={s.cardSub}>
              {step === 1
                  ? "Nhập email tài khoản để nhận mã OTP đặt lại mật khẩu"
                  : "Nhập mã OTP vừa nhận và tạo mật khẩu mới cho tài khoản"}
            </Text>

            {step === 1 ? (
                <>
                  <InputField
                      label="Email"
                      icon="mail-outline"
                      value={email}
                      onChangeText={setEmail}
                      placeholder="Nhập email của bạn"
                      keyboardType="email-address"
                      autoCapitalize="none"
                      editable={!loading}
                  />
                </>
            ) : (
                <>
                  <View style={s.emailInfoBox}>
                    <Ionicons name="mail-outline" size={18} color={C.primaryMid} />
                    <View style={{ flex: 1 }}>
                      <Text style={s.emailInfoLabel}>Email đang xác thực</Text>
                      <Text style={s.emailInfoValue}>{email}</Text>
                    </View>
                  </View>

                  <InputField
                      label="Mã OTP"
                      icon="key-outline"
                      value={otp}
                      onChangeText={setOtp}
                      placeholder="Nhập mã OTP 6 số"
                      keyboardType="number-pad"
                      maxLength={6}
                      editable={!loading}
                  />

                  <PasswordField
                      label="Mật khẩu mới"
                      icon="lock-closed-outline"
                      value={newPassword}
                      onChangeText={setNewPassword}
                      placeholder="Tối thiểu 6 ký tự"
                      editable={!loading}
                  />

                  {newPassword.length > 0 && (
                      <View style={s.strengthWrap}>
                        <View style={s.strengthBar}>
                          {[1, 2, 3, 4].map((i) => (
                              <View
                                  key={i}
                                  style={[
                                    s.strengthSegment,
                                    {
                                      backgroundColor: i <= strength ? strengthColor : C.border,
                                    },
                                  ]}
                              />
                          ))}
                        </View>
                        <Text style={[s.strengthLabel, { color: strengthColor }]}>
                          {strengthLabel}
                        </Text>
                      </View>
                  )}

                  <PasswordField
                      label="Xác nhận mật khẩu mới"
                      icon="shield-checkmark-outline"
                      value={confirmPassword}
                      onChangeText={setConfirmPassword}
                      placeholder="Nhập lại mật khẩu mới"
                      editable={!loading}
                  />

                  {passwordsMatch && (
                      <View style={s.matchRow}>
                        <Ionicons name="checkmark-circle-outline" size={15} color={C.green} />
                        <Text style={[s.matchTxt, { color: C.green }]}>Mật khẩu khớp</Text>
                      </View>
                  )}

                  {mismatch && (
                      <View style={s.matchRow}>
                        <Ionicons name="close-circle-outline" size={15} color={C.error} />
                        <Text style={[s.matchTxt, { color: C.error }]}>Mật khẩu không khớp</Text>
                      </View>
                  )}

                  <TouchableOpacity
                      style={s.resendButton}
                      onPress={handleResendOTP}
                      disabled={loading}
                  >
                    <Text style={s.resendText}>Gửi lại mã OTP</Text>
                  </TouchableOpacity>
                </>
            )}
          </View>

          <View style={s.tipsCard}>
            <Text style={s.tipsTitle}>💡 Lưu ý:</Text>
            {(step === 1
                    ? [
                      "Email phải đúng với tài khoản đã đăng ký",
                      "Bạn sẽ nhận OTP qua email để xác minh",
                    ]
                    : [
                      "OTP thường gồm 6 chữ số",
                      "Mật khẩu mới nên khác mật khẩu cũ",
                      "Nên dùng chữ hoa, số và ký tự đặc biệt để tăng bảo mật",
                    ]
            ).map((t, i) => (
                <View key={i} style={s.tipRow}>
                  <View style={s.tipDot} />
                  <Text style={s.tipTxt}>{t}</Text>
                </View>
            ))}
          </View>

          <TouchableOpacity
              style={[s.btn, !(step === 1 ? canStep1 : canStep2) && s.btnDisabled]}
              onPress={step === 1 ? handleSendOTP : handleResetPassword}
              disabled={!(step === 1 ? canStep1 : canStep2)}
              activeOpacity={0.85}
          >
            {loading ? (
                <ActivityIndicator color="#FFF" />
            ) : (
                <>
                  <Ionicons
                      name={step === 1 ? "mail-open-outline" : "checkmark-circle-outline"}
                      size={19}
                      color="#FFF"
                  />
                  <Text style={s.btnTxt}>
                    {step === 1 ? "Gửi mã OTP" : "Đặt lại mật khẩu"}
                  </Text>
                </>
            )}
          </TouchableOpacity>

          <TouchableOpacity style={s.bottomLink} onPress={handleBack}>
            <Text style={s.bottomLinkTxt}>
              {step === 1 ? "Quay lại đăng nhập" : "Quay lại bước nhập email"}
            </Text>
          </TouchableOpacity>

          <View style={{ height: 20 }} />
        </ScrollView>
      </KeyboardAvoidingView>
  );
}

const s = StyleSheet.create({
  topBar: {
    backgroundColor: C.primaryMid,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingTop: Platform.OS === "android" ? (StatusBar.currentHeight || 0) + 10 : 10,
    paddingBottom: 16,
    paddingHorizontal: 14,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
    overflow: "hidden",
  },
  topBarBlob: {
    position: "absolute",
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: "rgba(255,255,255,0.08)",
    top: -50,
    right: -30,
  },
  backBtn: {
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: "rgba(255,255,255,0.18)",
    justifyContent: "center",
    alignItems: "center",
  },
  topBarTitle: {
    fontSize: 17,
    fontWeight: "800",
    color: "#FFF",
  },

  scroll: {
    padding: 16,
    gap: 14,
    paddingBottom: 20,
  },

  stepRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 10,
    marginTop: 2,
  },
  stepItem: {
    alignItems: "center",
    width: 90,
  },
  stepCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: C.surface,
    borderWidth: 2,
    borderColor: C.border,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 6,
  },
  stepCircleActive: {
    backgroundColor: C.primaryMid,
    borderColor: C.primaryMid,
  },
  stepCircleDone: {
    backgroundColor: C.green,
    borderColor: C.green,
  },
  stepCircleTxt: {
    color: C.text2,
    fontWeight: "800",
    fontSize: 13,
  },
  stepLabel: {
    fontSize: 12,
    color: C.text3,
    fontWeight: "600",
    textAlign: "center",
  },
  stepLabelActive: {
    color: C.primaryMid,
  },
  stepLabelDone: {
    color: C.green,
  },
  stepLine: {
    flex: 1,
    height: 2,
    backgroundColor: C.border,
    marginHorizontal: 8,
    marginBottom: 22,
  },
  stepLineDone: {
    backgroundColor: C.green,
  },

  card: {
    backgroundColor: C.surface,
    borderRadius: 24,
    padding: 24,
    elevation: 2,
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 10,
    gap: 14,
  },
  cardIcon: {
    width: 56,
    height: 56,
    borderRadius: 18,
    backgroundColor: C.primarySoft,
    justifyContent: "center",
    alignItems: "center",
    alignSelf: "center",
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: "900",
    color: C.text1,
    textAlign: "center",
  },
  cardSub: {
    fontSize: 14,
    color: C.text3,
    textAlign: "center",
  },

  fieldWrap: { gap: 7 },
  fieldLabelRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 5,
  },
  fieldLabel: {
    fontSize: 12,
    fontWeight: "700",
    color: C.text2,
    textTransform: "uppercase",
    letterSpacing: 0.6,
  },

  inputWrap: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: C.bg,
    borderWidth: 1.5,
    borderColor: C.border,
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 2,
  },
  inputWrapFocused: {
    borderColor: C.borderFocus,
    backgroundColor: C.primarySoft,
  },
  input: {
    flex: 1,
    fontSize: 15,
    color: C.text1,
    paddingVertical: 12,
  },

  emailInfoBox: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    backgroundColor: C.primarySoft,
    borderWidth: 1,
    borderColor: C.primaryTint,
    borderRadius: 14,
    padding: 14,
  },
  emailInfoLabel: {
    fontSize: 12,
    color: C.text2,
    fontWeight: "700",
    marginBottom: 2,
  },
  emailInfoValue: {
    fontSize: 14,
    color: C.primaryMid,
    fontWeight: "800",
  },

  strengthWrap: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  strengthBar: {
    flex: 1,
    flexDirection: "row",
    gap: 4,
  },
  strengthSegment: {
    flex: 1,
    height: 5,
    borderRadius: 3,
  },
  strengthLabel: {
    fontSize: 12,
    fontWeight: "700",
    width: 70,
  },

  matchRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  matchTxt: {
    fontSize: 13,
    fontWeight: "600",
  },

  resendButton: {
    alignItems: "center",
    marginTop: 4,
  },
  resendText: {
    color: C.primaryMid,
    fontSize: 14,
    fontWeight: "700",
  },

  tipsCard: {
    backgroundColor: C.surface,
    borderRadius: 18,
    padding: 16,
    gap: 8,
    borderWidth: 1,
    borderColor: C.border,
  },
  tipsTitle: {
    fontSize: 13,
    fontWeight: "700",
    color: C.text2,
  },
  tipRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  tipDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: C.primaryMid,
    flexShrink: 0,
  },
  tipTxt: {
    fontSize: 13,
    color: C.text3,
  },

  btn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    backgroundColor: C.primaryMid,
    borderRadius: 16,
    paddingVertical: 17,
    elevation: 5,
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.3,
    shadowRadius: 12,
  },
  btnDisabled: {
    backgroundColor: C.text3,
    elevation: 0,
    shadowOpacity: 0,
  },
  btnTxt: {
    color: "#FFF",
    fontSize: 16,
    fontWeight: "800",
  },

  bottomLink: {
    alignItems: "center",
    marginTop: 6,
  },
  bottomLinkTxt: {
    color: C.text2,
    fontSize: 14,
    fontWeight: "600",
  },
});