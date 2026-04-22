import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
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
                         hint,
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

        {hint ? <Text style={s.fieldHint}>{hint}</Text> : null}
      </View>
  );
}

export default function RegisterScreen({ navigation }: any) {
  const [step, setStep] = useState(1);

  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [userName, setUserName] = useState("");
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");
  const [dateOfBirth, setDateOfBirth] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const strength = (() => {
    if (!password) return 0;
    let score = 0;
    if (password.length >= 8) score++;
    if (/[A-Z]/.test(password)) score++;
    if (/[0-9]/.test(password)) score++;
    if (/[^A-Za-z0-9]/.test(password)) score++;
    return score;
  })();

  const strengthLabel = ["", "Yếu", "Trung bình", "Khá mạnh", "Mạnh"][strength];
  const strengthColor = ["", C.error, "#FF8C00", "#FFC107", C.green][strength];

  const passwordsMatch =
      confirmPassword.length > 0 && password === confirmPassword;
  const mismatch =
      confirmPassword.length > 0 && password !== confirmPassword;

  const handleRegister = async () => {
    if (!userName || !fullName || !email || !phone || !address || !password) {
      Alert.alert("Lỗi", "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (password.length < 6) {
      Alert.alert("Lỗi", "Mật khẩu phải có ít nhất 6 ký tự");
      return;
    }

    if (password !== confirmPassword) {
      Alert.alert("Lỗi", "Mật khẩu xác nhận không khớp");
      return;
    }

    setLoading(true);
    try {
      const res = await api.post("/auth/register", {
        userName,
        password,
        fullName,
        email,
        phone,
        address,
        dateOfBirth,
      });

      Alert.alert("Thành công", res.data.message || "OTP đã được gửi về email");
      setStep(2);
    } catch (err: any) {
      Alert.alert(
          "Lỗi",
          err?.response?.data?.message || "Đăng ký thất bại"
      );
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async () => {
    if (!otp || otp.length !== 6) {
      Alert.alert("Lỗi", "Vui lòng nhập mã OTP 6 số");
      return;
    }

    setLoading(true);
    try {
      const res = await api.post("/auth/verify-register-otp", {
        email,
        otp,
        otpType: "REGISTER",
      });

      Alert.alert(
          "Thành công",
          res.data.message || "Xác thực email thành công",
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
          err?.response?.data?.message || "Xác thực OTP thất bại"
      );
    } finally {
      setLoading(false);
    }
  };

  const handleResendOtp = async () => {
    setLoading(true);
    try {
      const res = await api.post(
          `/auth/resend-otp?email=${encodeURIComponent(email)}&otpType=REGISTER`
      );
      Alert.alert("Thành công", res.data.message || "OTP mới đã được gửi");
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
    } else {
      navigation.replace("Login");
    }
  };

  const canSubmitStep1 =
      userName &&
      fullName &&
      email &&
      phone &&
      address &&
      password &&
      confirmPassword &&
      password === confirmPassword &&
      !loading;

  const canSubmitStep2 = otp.length === 6 && !loading;

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
          <Text style={s.topBarTitle}>
            {step === 1 ? "Đăng ký tài khoản" : "Xác thực OTP"}
          </Text>
          <View style={{ width: 38 }} />
        </View>

        <ScrollView
            contentContainerStyle={s.scroll}
            keyboardShouldPersistTaps="handled"
            showsVerticalScrollIndicator={false}
        >
          <View style={s.card}>
            <View style={s.cardIcon}>
              <Ionicons
                  name={step === 1 ? "person-add-outline" : "mail-open-outline"}
                  size={28}
                  color={C.primaryMid}
              />
            </View>

            <Text style={s.cardTitle}>
              {step === 1 ? "Tạo tài khoản mới" : "Kiểm tra email của bạn"}
            </Text>

            <Text style={s.cardSub}>
              {step === 1
                  ? "Điền đầy đủ thông tin để bắt đầu đăng ký"
                  : "Nhập mã OTP 6 số đã được gửi đến email"}
            </Text>

            {step === 1 ? (
                <>
                  <InputField
                      label="Tên đăng nhập"
                      icon="person-outline"
                      value={userName}
                      onChangeText={setUserName}
                      placeholder="Nhập username"
                      autoCapitalize="none"
                      editable={!loading}
                  />

                  <InputField
                      label="Họ và tên"
                      icon="id-card-outline"
                      value={fullName}
                      onChangeText={setFullName}
                      placeholder="Nhập họ và tên"
                      editable={!loading}
                  />

                  <InputField
                      label="Email"
                      icon="mail-outline"
                      value={email}
                      onChangeText={setEmail}
                      placeholder="Nhập email"
                      keyboardType="email-address"
                      autoCapitalize="none"
                      editable={!loading}
                  />

                  <InputField
                      label="Số điện thoại"
                      icon="call-outline"
                      value={phone}
                      onChangeText={setPhone}
                      placeholder="Nhập số điện thoại"
                      keyboardType="phone-pad"
                      editable={!loading}
                  />

                  <InputField
                      label="Địa chỉ"
                      icon="location-outline"
                      value={address}
                      onChangeText={setAddress}
                      placeholder="Nhập địa chỉ"
                      editable={!loading}
                  />

                  <InputField
                      label="Ngày sinh"
                      icon="calendar-outline"
                      value={dateOfBirth}
                      onChangeText={setDateOfBirth}
                      placeholder="yyyy-MM-dd"
                      editable={!loading}
                  />

                  <PasswordField
                      label="Mật khẩu"
                      icon="lock-closed-outline"
                      value={password}
                      onChangeText={setPassword}
                      placeholder="Tối thiểu 6 ký tự"
                      hint="Nên dùng chữ hoa, số và ký tự đặc biệt"
                      editable={!loading}
                  />

                  {password.length > 0 && (
                      <View style={s.strengthWrap}>
                        <View style={s.strengthBar}>
                          {[1, 2, 3, 4].map((i) => (
                              <View
                                  key={i}
                                  style={[
                                    s.strengthSegment,
                                    {
                                      backgroundColor:
                                          i <= strength ? strengthColor : C.border,
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
                      label="Xác nhận mật khẩu"
                      icon="shield-checkmark-outline"
                      value={confirmPassword}
                      onChangeText={setConfirmPassword}
                      placeholder="Nhập lại mật khẩu"
                      editable={!loading}
                  />

                  {passwordsMatch && (
                      <View style={s.matchRow}>
                        <Ionicons
                            name="checkmark-circle-outline"
                            size={15}
                            color={C.green}
                        />
                        <Text style={[s.matchTxt, { color: C.green }]}>
                          Mật khẩu khớp
                        </Text>
                      </View>
                  )}

                  {mismatch && (
                      <View style={s.matchRow}>
                        <Ionicons
                            name="close-circle-outline"
                            size={15}
                            color={C.error}
                        />
                        <Text style={[s.matchTxt, { color: C.error }]}>
                          Mật khẩu không khớp
                        </Text>
                      </View>
                  )}
                </>
            ) : (
                <>
                  <View style={s.emailInfoBox}>
                    <Ionicons name="mail-outline" size={18} color={C.primaryMid} />
                    <View style={{ flex: 1 }}>
                      <Text style={s.emailInfoLabel}>Email xác thực</Text>
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
                      editable={!loading}
                  />

                  <TouchableOpacity
                      style={s.resendButton}
                      onPress={handleResendOtp}
                      disabled={loading}
                  >
                    <Text style={s.resendText}>Gửi lại mã OTP</Text>
                  </TouchableOpacity>
                </>
            )}
          </View>

          {step === 1 && (
              <View style={s.tipsCard}>
                <Text style={s.tipsTitle}>💡 Lưu ý khi đăng ký:</Text>
                {[
                  "Email phải đang hoạt động để nhận mã OTP",
                  "Mật khẩu nên có ít nhất 6 ký tự",
                  "Thông tin cá nhân nên nhập chính xác",
                ].map((t, i) => (
                    <View key={i} style={s.tipRow}>
                      <View style={s.tipDot} />
                      <Text style={s.tipTxt}>{t}</Text>
                    </View>
                ))}
              </View>
          )}

          <TouchableOpacity
              style={[
                s.btn,
                !(
                    step === 1 ? canSubmitStep1 : canSubmitStep2
                ) && s.btnDisabled,
              ]}
              onPress={step === 1 ? handleRegister : handleVerifyOtp}
              disabled={!(step === 1 ? canSubmitStep1 : canSubmitStep2)}
              activeOpacity={0.85}
          >
            {loading ? (
                <ActivityIndicator color="#FFF" />
            ) : (
                <>
                  <Ionicons
                      name={
                        step === 1
                            ? "person-add-outline"
                            : "checkmark-circle-outline"
                      }
                      size={19}
                      color="#FFF"
                  />
                  <Text style={s.btnTxt}>
                    {step === 1 ? "Đăng ký" : "Xác thực OTP"}
                  </Text>
                </>
            )}
          </TouchableOpacity>

          <TouchableOpacity style={s.bottomLink} onPress={handleBack}>
            <Text style={s.bottomLinkTxt}>
              {step === 1 ? "Đã có tài khoản? Đăng nhập" : "Quay lại bước đăng ký"}
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
  fieldHint: {
    fontSize: 11,
    color: C.text3,
    marginTop: 2,
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