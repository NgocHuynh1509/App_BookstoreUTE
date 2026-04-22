import React, { useEffect, useState } from "react";
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, ScrollView, Image,
  StatusBar, Platform, Alert,
} from "react-native";
import api from "../../services/api";
import { useNavigation } from "@react-navigation/native";
import * as ImagePicker from "expo-image-picker";
import { useAuth } from "../../hooks/useAuth";
import { Ionicons } from "@expo/vector-icons";
import Constants from "expo-constants";
import AsyncStorage from "@react-native-async-storage/async-storage";

const BASE_URL = Constants.expoConfig?.extra?.API_URL;

// ─── Palette UTE BookStore (Tone Đỏ & Vàng Ấm) ──────────────────────────────────
const C = {
  // Màu đỏ chính (Màu cờ/Logo) - Mạnh mẽ và uy tín
  primary:     "#B8001A",

  // Màu đỏ sáng hơn cho các trạng thái nhấn (Active)
  primaryMid:  "#D0001F",

  // Nền đỏ cực nhạt cho các thông báo nhạt (thay cho màu xanh nhạt)
  primarySoft: "#FFF5F5",

  // Màu hồng nhạt để highlight các vùng chọn
  primaryTint: "#FFDADA",

  // Nền ứng dụng: Trắng sứ ấm áp (tạo cảm giác cao cấp hơn trắng xanh)
  bg:          "#FFFBFB",

  // Bề mặt các thẻ, khung nội dung trắng tinh
  surface:     "#FFFFFF",

  // Viền: Màu xám hồng nhạt để đồng bộ với tone nóng
  border:      "#FEE2E2",

  // Viền khi người dùng nhấn vào ô nhập liệu (Focus)
  borderFocus: "#B8001A",

  // Văn bản chính: Nâu đen đậm (Hợp với màu đỏ hơn là xanh đen)
  text1:       "#2D0A0A",

  // Văn bản phụ: Xám đỏ trung tính
  text2:       "#6D5B5B",

  // Văn bản mờ, ghi chú
  text3:       "#AFA0A0",

  // Gợi ý trong ô nhập liệu
  placeholder: "#D1C4C4",
};

// ─── Field wrapper ────────────────────────────────────────────────────────────
function Field({ label, icon, children }: any) {
  return (
    <View style={s.fieldWrap}>
      <View style={s.fieldLabelRow}>
        <Ionicons name={icon} size={13} color={C.primaryMid} />
        <Text style={s.fieldLabel}>{label}</Text>
      </View>
      {children}
    </View>
  );
}

// ─── Styled input ─────────────────────────────────────────────────────────────
function SInput({ value, onChangeText, placeholder, keyboardType = "default",
  editable = true, multiline = false, style = {} }: any) {
  const [focused, setFocused] = useState(false);
  return (
    <TextInput
      style={[
        s.input,
        focused && editable && s.inputFocused,
        !editable && s.inputDisabled,
        multiline && { height: 80, textAlignVertical: "top" },
        style,
      ]}
      value={value}
      onChangeText={onChangeText}
      placeholder={placeholder}
      placeholderTextColor={C.placeholder}
      keyboardType={keyboardType}
      editable={editable}
      multiline={multiline}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
    />
  );
}

// ─── Section header ───────────────────────────────────────────────────────────
function SectionHeader({ icon, title }: { icon: string; title: string }) {
  return (
    <View style={s.sectionHeader}>
      <View style={s.sectionIconWrap}>
        <Ionicons name={icon as any} size={15} color={C.primaryMid} />
      </View>
      <Text style={s.sectionTitle}>{title}</Text>
    </View>
  );
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────
export default function EditInfoScreen() {
  const navigation = useNavigation<any>();
  const { loadUser } = useAuth();

  const [fullName, setFullName] = useState("");
  const [username, setUsername] = useState("");
  const [email, setEmail]       = useState("");
  const [address, setAddress]   = useState("");
  const [phone, setPhone]       = useState("");
  const [avatar, setAvatar]     = useState("");

  // Email change flow
  const [step, setStep]         = useState("none");
  const [newEmail, setNewEmail] = useState("");
  const [otp, setOtp]           = useState("");
  const [otpServer, setOtpServer] = useState("");

  // ==========================
  // API LOGIC (all unchanged)
  // ==========================
  useEffect(() => {
    const loadProfile = async () => {
      try {
        const token = await AsyncStorage.getItem("token");
        console.log("EDIT PROFILE TOKEN:", token);
        console.log("EDIT PROFILE URL:", `${api.defaults.baseURL}/profile`);

        if (!token) {
          Alert.alert("Thông báo", "Bạn chưa đăng nhập");
          return;
        }

        const res = await api.get("/profile", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        const data = res.data;
        console.log("PROFILE DATA:", data);

        setFullName(data.full_name ?? data.fullName ?? "");
        setUsername(data.username ?? "");
        setEmail(data.email ?? "");
        setAddress(data.address ?? "");
        setPhone(data.phone ?? "");
        setAvatar(data.avatar ? `${BASE_URL}/uploads/${data.avatar}` : "");
      } catch (error: any) {
        console.log("LOAD PROFILE STATUS:", error?.response?.status);
        console.log("LOAD PROFILE DATA:", error?.response?.data);
        console.log("Lỗi load profile:", error);
        Alert.alert("Lỗi", "Không tải được thông tin cá nhân");
      }
    };
    loadProfile();
  }, []);

  const pickImage = async () => {
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true, quality: 1,
    });
    if (!result.canceled) uploadAvatar(result.assets[0]);
  };

  const uploadAvatar = async (image: any) => {
    try {
      const token = await AsyncStorage.getItem("token");
      console.log("UPLOAD TOKEN:", token);

      const formData = new FormData();
      formData.append("avatar", {
        uri: image.uri,
        name: "avatar.jpg",
        type: "image/jpeg",
      } as any);

      const res = await api.put("/profile/avatar", formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "multipart/form-data",
          Accept: "application/json",
        },
        transformRequest: () => formData,
      });

      setAvatar(`${BASE_URL}/uploads/${res.data.avatar}`);
      alert("Đổi avatar thành công!");
    } catch (error: any) {
      console.log("UPLOAD STATUS:", error?.response?.status);
      console.log("UPLOAD DATA:", error?.response?.data);
      console.log("UPLOAD ERROR:", error);
      alert(error?.response?.data?.message || "Không thể upload avatar!");
    }
  };

  const sendOTP = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      console.log("SEND OTP TOKEN:", token);
      console.log("SEND OTP URL:", `${api.defaults.baseURL}/profile/send-otp`);
      console.log("NEW EMAIL:", newEmail);

      if (!token) {
        Alert.alert("Thông báo", "Bạn chưa đăng nhập");
        return;
      }

      const res = await api.post(
          "/profile/send-otp",
          { new_email: newEmail },
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
      );

      console.log("SEND OTP RESPONSE:", res.data);

      setOtpServer(res.data.otp);
      Alert.alert("Thành công", "Đã gửi OTP đến email mới!");
      setStep("verify");
    } catch (error: any) {
      console.log("SEND OTP STATUS:", error?.response?.status);
      console.log("SEND OTP DATA:", error?.response?.data);
      console.log("SEND OTP ERROR:", error);

      Alert.alert(
          "Lỗi",
          error?.response?.data?.message || "Không thể gửi OTP"
      );
    }
  };

  const verifyOTP = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      if (!token) {
        Alert.alert("Thông báo", "Bạn chưa đăng nhập");
        return;
      }

      const res = await api.post(
          "/profile/verify-otp",
          {
            otp_client: otp,
            otp_server: otpServer,
            new_email: newEmail,
          },
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
      );

      await AsyncStorage.setItem("token", res.data.token);
      await loadUser();

      Alert.alert("Thành công", "Đổi email thành công!");
      setEmail(newEmail);
      setStep("none");
      setNewEmail("");
      setOtp("");
      setOtpServer("");
    } catch (error: any) {
      console.log("VERIFY OTP STATUS:", error?.response?.status);
      console.log("VERIFY OTP DATA:", error?.response?.data);
      Alert.alert("Lỗi", error?.response?.data?.message || "OTP không chính xác!");
    }
  };

  const saveInfo = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      console.log("SAVE INFO TOKEN:", token);
      console.log("SAVE INFO URL:", `${api.defaults.baseURL}/profile/info`);

      if (!token) {
        Alert.alert("Thông báo", "Bạn chưa đăng nhập");
        return;
      }

      const res = await api.put(
          "/profile/info",
          {
            full_name: fullName,
            address,
            phone,
          },
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
      );

      console.log("SAVE INFO RESPONSE:", res.data);
      Alert.alert("Thành công", res.data.message);

      await loadUser();
      navigation.goBack();
    } catch (error: any) {
      console.log("SAVE INFO STATUS:", error?.response?.status);
      console.log("SAVE INFO DATA:", error?.response?.data);
      console.log("SAVE INFO ERROR:", error);

      Alert.alert(
          "Lỗi",
          error?.response?.data?.message || "Không thể cập nhật thông tin. Vui lòng thử lại!"
      );
    }
  };

  return (
    <View style={s.container}>
      <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

      {/* ── TOP BAR ────────────────────────────────────────────── */}
      <View style={s.topBar}>
        <View style={s.topBarBlob} />
        <TouchableOpacity style={s.backBtn} onPress={() => navigation.goBack()}>
          <Ionicons name="chevron-back" size={22} color="#FFF" />
        </TouchableOpacity>
        <Text style={s.topBarTitle}>Chỉnh sửa hồ sơ</Text>
        <View style={{ width: 38 }} />
      </View>

      <ScrollView
        contentContainerStyle={s.scroll}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        {/* ── AVATAR ──────────────────────────────────────────── */}
        <View style={s.avatarSection}>
          <TouchableOpacity onPress={pickImage} activeOpacity={0.85} style={s.avatarWrap}>
            {avatar ? (
              <Image source={{ uri: avatar }} style={s.avatarImg} />
            ) : (
              <View style={s.avatarPlaceholder}>
                <Text style={s.avatarLetter}>
                  {fullName ? fullName.charAt(0).toUpperCase() : "U"}
                </Text>
              </View>
            )}
            {/* Camera overlay */}
            <View style={s.cameraOverlay}>
              <Ionicons name="camera-outline" size={16} color="#FFF" />
            </View>
          </TouchableOpacity>
          <Text style={s.avatarHint}>Nhấn để đổi ảnh đại diện</Text>
        </View>

        {/* ── PERSONAL INFO CARD ──────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="person-outline" title="Thông tin cá nhân" />

          <Field label="Họ và tên" icon="text-outline">
            <SInput value={fullName} onChangeText={setFullName} placeholder="Nguyễn Văn A" />
          </Field>

          <Field label="Tên đăng nhập" icon="at-outline">
            <View style={s.readonlyWrap}>
              <SInput value={username} editable={false} />
              <View style={s.readonlyBadge}>
                <Ionicons name="lock-closed-outline" size={12} color={C.text3} />
                <Text style={s.readonlyBadgeTxt}>Không đổi được</Text>
              </View>
            </View>
          </Field>

          <Field label="Email hiện tại" icon="mail-outline">
            <View style={s.readonlyWrap}>
              <SInput value={email} editable={false} />
            </View>
          </Field>
        </View>

        {/* ── CHANGE EMAIL CARD ────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="mail-outline" title="Đổi địa chỉ Email" />

          {step === "none" && (
            <TouchableOpacity style={s.outlineBtn} onPress={() => setStep("change")} activeOpacity={0.8}>
              <Ionicons name="swap-horizontal-outline" size={16} color={C.primaryMid} />
              <Text style={s.outlineBtnTxt}>Bắt đầu đổi email</Text>
            </TouchableOpacity>
          )}

          {step === "change" && (
            <View style={{ gap: 12 }}>
              <Field label="Email mới" icon="mail-outline">
                <SInput
                  value={newEmail}
                  onChangeText={setNewEmail}
                  placeholder="email_moi@example.com"
                  keyboardType="email-address"
                />
              </Field>
              <View style={{ flexDirection: "row", gap: 10 }}>
                <TouchableOpacity
                  style={[s.outlineBtn, { flex: 1 }]}
                  onPress={() => { setStep("none"); setNewEmail(""); }}
                >
                  <Text style={s.outlineBtnTxt}>Hủy</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[s.solidBtn, { flex: 2 }]} onPress={sendOTP} activeOpacity={0.85}>
                  <Ionicons name="send-outline" size={15} color="#FFF" />
                  <Text style={s.solidBtnTxt}>Gửi OTP</Text>
                </TouchableOpacity>
              </View>
            </View>
          )}

          {step === "verify" && (
            <View style={{ gap: 12 }}>
              {/* Email info pill */}
              <View style={s.emailPill}>
                <Ionicons name="mail-outline" size={14} color={C.primaryMid} />
                <Text style={s.emailPillTxt} numberOfLines={1}>{newEmail}</Text>
              </View>
              <Field label="Mã OTP (6 số)" icon="keypad-outline">
                <SInput
                  value={otp}
                  onChangeText={setOtp}
                  placeholder="● ● ● ● ● ●"
                  keyboardType="numeric"
                />
              </Field>
              <View style={{ flexDirection: "row", gap: 10 }}>
                <TouchableOpacity
                  style={[s.outlineBtn, { flex: 1 }]}
                  onPress={() => setStep("change")}
                >
                  <Text style={s.outlineBtnTxt}>Quay lại</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[s.solidBtn, { flex: 2 }]} onPress={verifyOTP} activeOpacity={0.85}>
                  <Ionicons name="checkmark-circle-outline" size={15} color="#FFF" />
                  <Text style={s.solidBtnTxt}>Xác nhận OTP</Text>
                </TouchableOpacity>
              </View>
            </View>
          )}
        </View>

        {/* ── CONTACT INFO CARD ────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="call-outline" title="Thông tin liên hệ" />

          <Field label="Số điện thoại" icon="call-outline">
            <SInput
              value={phone}
              onChangeText={setPhone}
              placeholder="0901234567"
              keyboardType="numeric"
            />
          </Field>

          <Field label="Địa chỉ" icon="location-outline">
            <SInput
              value={address}
              onChangeText={setAddress}
              placeholder="Số nhà, đường, quận, thành phố..."
              multiline
            />
          </Field>
        </View>

        {/* ── SAVE BUTTON ─────────────────────────────────────── */}
        <TouchableOpacity style={s.saveBtn} onPress={saveInfo} activeOpacity={0.85}>
          <Ionicons name="checkmark-circle-outline" size={20} color="#FFF" />
          <Text style={s.saveBtnTxt}>Lưu thay đổi</Text>
        </TouchableOpacity>

        <View style={{ height: 30 }} />
      </ScrollView>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },

  // ── Top bar
  topBar: {
    backgroundColor: C.primaryMid,
    flexDirection: "row", alignItems: "center",
    justifyContent: "space-between",
    paddingTop: Platform.OS === "android" ? (StatusBar.currentHeight || 0) + 10 : 10,
    paddingBottom: 16, paddingHorizontal: 14,
    borderBottomLeftRadius: 28, borderBottomRightRadius: 28,
    overflow: "hidden",
  },
  topBarBlob: {
    position: "absolute", width: 150, height: 150, borderRadius: 75,
    backgroundColor: "rgba(255,255,255,0.08)", top: -50, right: -30,
  },
  backBtn: {
    width: 38, height: 38, borderRadius: 19,
    backgroundColor: "rgba(255,255,255,0.18)",
    justifyContent: "center", alignItems: "center",
  },
  topBarTitle: { fontSize: 17, fontWeight: "800", color: "#FFF" },

  scroll: { padding: 16, gap: 14, paddingBottom: 20 },

  // ── Avatar
  avatarSection: { alignItems: "center", gap: 8, paddingVertical: 6 },
  avatarWrap:    { position: "relative" },
  avatarImg: {
    width: 96, height: 96, borderRadius: 48,
    borderWidth: 3, borderColor: C.primaryTint,
  },
  avatarPlaceholder: {
    width: 96, height: 96, borderRadius: 48,
    backgroundColor: C.primaryMid,
    justifyContent: "center", alignItems: "center",
    borderWidth: 3, borderColor: C.primaryTint,
  },
  avatarLetter: { fontSize: 38, fontWeight: "900", color: "#FFF" },
  cameraOverlay: {
    position: "absolute", bottom: 2, right: 2,
    width: 30, height: 30, borderRadius: 15,
    backgroundColor: C.primary,
    justifyContent: "center", alignItems: "center",
    borderWidth: 2, borderColor: "#FFF",
    elevation: 3,
  },
  avatarHint: { fontSize: 13, color: C.text3, fontWeight: "500" },

  // ── Card
  card: {
    backgroundColor: C.surface, borderRadius: 20, padding: 18,
    elevation: 2,
    shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08, shadowRadius: 8,
    gap: 14,
  },
  sectionHeader: { flexDirection: "row", alignItems: "center", gap: 8 },
  sectionIconWrap: {
    width: 30, height: 30, borderRadius: 10,
    backgroundColor: C.primarySoft,
    justifyContent: "center", alignItems: "center",
  },
  sectionTitle: { fontSize: 15, fontWeight: "800", color: C.text1 },

  // ── Field
  fieldWrap: { gap: 6 },
  fieldLabelRow: { flexDirection: "row", alignItems: "center", gap: 5 },
  fieldLabel: {
    fontSize: 12, fontWeight: "700", color: C.text2,
    textTransform: "uppercase", letterSpacing: 0.6,
  },

  input: {
    backgroundColor: C.bg,
    borderWidth: 1.5, borderColor: C.border,
    borderRadius: 12, paddingHorizontal: 14, paddingVertical: 12,
    fontSize: 15, color: C.text1,
  },
  inputFocused:  { borderColor: C.borderFocus, backgroundColor: C.primarySoft },
  inputDisabled: { opacity: 0.65 },

  readonlyWrap: { gap: 5 },
  readonlyBadge: {
    flexDirection: "row", alignItems: "center", gap: 4,
    alignSelf: "flex-start",
    backgroundColor: C.bg, borderRadius: 8,
    paddingHorizontal: 8, paddingVertical: 3,
    borderWidth: 1, borderColor: C.border,
  },
  readonlyBadgeTxt: { fontSize: 11, color: C.text3 },

  // Email pill
  emailPill: {
    flexDirection: "row", alignItems: "center", gap: 8,
    backgroundColor: C.primarySoft, borderRadius: 10,
    paddingHorizontal: 12, paddingVertical: 8,
    borderWidth: 1, borderColor: C.primaryTint,
  },
  emailPillTxt: { flex: 1, fontSize: 13, color: C.primaryMid, fontWeight: "600" },

  // Buttons
  outlineBtn: {
    flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 6,
    borderWidth: 1.5, borderColor: C.primaryTint,
    borderRadius: 14, paddingVertical: 12,
    backgroundColor: C.primarySoft,
  },
  outlineBtnTxt: { fontSize: 14, color: C.primaryMid, fontWeight: "700" },

  solidBtn: {
    flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 6,
    backgroundColor: C.primaryMid, borderRadius: 14, paddingVertical: 12,
    elevation: 3,
    shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.25, shadowRadius: 8,
  },
  solidBtnTxt: { color: "#FFF", fontSize: 14, fontWeight: "700" },

  // Save
  saveBtn: {
    flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8,
    backgroundColor: C.primaryMid, borderRadius: 16, paddingVertical: 17,
    elevation: 5,
    shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.30, shadowRadius: 12,
  },
  saveBtnTxt: { color: "#FFF", fontSize: 16, fontWeight: "800" },
});