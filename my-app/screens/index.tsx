import React, { useState, useRef, useEffect } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Alert,
  StyleSheet,
  StatusBar,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Animated,
  Easing,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import api from "../services/api";
import { useAuth } from "../hooks/useAuth";
import { useNotification } from "../contexts/NotificationContext";

const C = {
  primary:      "#1565C0",
  primaryMid:   "#1E88E5",
  primaryLight: "#42A5F5",
  primarySoft:  "#E3F2FD",
  primaryTint:  "#BBDEFB",
  bg:           "#F0F6FF",
  surface:      "#FFFFFF",
  border:       "#DDEEFF",
  text1:        "#0D1B3E",
  text2:        "#4A5980",
  text3:        "#9AA8C8",
  orange:       "#FF8A00",
};

// ─── Stagger helper ───────────────────────────────────────────────────────────
function useStaggeredEntry(count: number, baseDelay = 80, startDelay = 350) {
  const anims = useRef(
      Array.from({ length: count }, () => ({
        opacity:    new Animated.Value(0),
        translateX: new Animated.Value(-20),
      }))
  ).current;

  useEffect(() => {
    const animations = anims.map((a, i) =>
        Animated.parallel([
          Animated.timing(a.opacity, {
            toValue: 1, duration: 380,
            delay: startDelay + i * baseDelay,
            easing: Easing.out(Easing.cubic),
            useNativeDriver: true,
          }),
          Animated.spring(a.translateX, {
            toValue: 0, tension: 80, friction: 10,
            delay: startDelay + i * baseDelay,
            useNativeDriver: true,
          }),
        ])
    );
    Animated.parallel(animations).start();
  }, []);

  return anims;
}

export default function LoginScreen({ navigation }: any) {
  const [email, setEmail]       = useState("");
  const [password, setPassword] = useState("");
  const [secure, setSecure]     = useState(true);
  const [loading, setLoading]   = useState(false);
  const { saveUser }            = useAuth();
  const { refresh } = useNotification();

  // ── Header: slide down ──────────────────────────────────────────────────────
  const headerY  = useRef(new Animated.Value(-50)).current;
  const headerOp = useRef(new Animated.Value(0)).current;

  // ── Brand text: fade up ─────────────────────────────────────────────────────
  const brandY  = useRef(new Animated.Value(14)).current;
  const brandOp = useRef(new Animated.Value(0)).current;

  // ── Card: spring up ─────────────────────────────────────────────────────────
  const cardY     = useRef(new Animated.Value(52)).current;
  const cardOp    = useRef(new Animated.Value(0)).current;
  const cardScale = useRef(new Animated.Value(0.96)).current;

  // ── Form rows: stagger slide-in from left ───────────────────────────────────
  // indices: 0=title, 1=sub, 2=email, 3=password, 4=forgot, 5=btn+rest
  const fields = useStaggeredEntry(6, 80, 420);

  // ── Button press scale ──────────────────────────────────────────────────────
  const btnScale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    // 1. Header drops in
    Animated.parallel([
      Animated.timing(headerY, {
        toValue: 0, duration: 550,
        easing: Easing.out(Easing.back(1.5)),
        useNativeDriver: true,
      }),
      Animated.timing(headerOp, {
        toValue: 1, duration: 450,
        useNativeDriver: true,
      }),
    ]).start();

    // 2. Brand fades up (200 ms delay)
    Animated.parallel([
      Animated.timing(brandY, {
        toValue: 0, duration: 400, delay: 200,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(brandOp, {
        toValue: 1, duration: 400, delay: 200,
        useNativeDriver: true,
      }),
    ]).start();

    // 3. Card springs up
    Animated.parallel([
      Animated.spring(cardY, {
        toValue: 0, tension: 60, friction: 9,
        delay: 320, useNativeDriver: true,
      }),
      Animated.timing(cardScale, {
        toValue: 1, duration: 480, delay: 320,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(cardOp, {
        toValue: 1, duration: 380, delay: 300,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  // ── Button press feedback ───────────────────────────────────────────────────
  const onPressIn = () =>
      Animated.spring(btnScale, {
        toValue: 0.96, tension: 200, friction: 12, useNativeDriver: true,
      }).start();

  const onPressOut = () =>
      Animated.spring(btnScale, {
        toValue: 1, tension: 200, friction: 12, useNativeDriver: true,
      }).start();

  // ── Login logic ─────────────────────────────────────────────────────────────
  const login = async () => {
    if (!email || !password) {
      Alert.alert("Thông báo", "Vui lòng nhập email và mật khẩu");
      return;
    }

    try {
      setLoading(true);
      const res = await api.post("/auth/login", { email, password });

      await saveUser({
        id: res.data.userId,
        username: res.data.userName,
        role: res.data.role,
        token: res.data.token,
      });

      navigation.replace("MainTabs");

      setTimeout(() => {
        refresh();
      }, 300);

    } catch (err: any) {
      const msg =
          err?.response?.data?.message ||
          err?.message ||
          "Không kết nối được server";

      Alert.alert("Đăng nhập thất bại", msg);
    } finally {
      setLoading(false);
    }
  };

  // ── Reusable style factory ──────────────────────────────────────────────────
  const fieldStyle = (i: number) => ({
    opacity:   fields[i].opacity,
    transform: [{ translateX: fields[i].translateX }],
  });

  return (
      <View style={s.container}>
        <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

        {/* ── HEADER ────────────────────────────────────────────────────────── */}
        <Animated.View
            style={[
              s.header,
              { opacity: headerOp, transform: [{ translateY: headerY }] },
            ]}
        >
          <View style={s.blob1} />
          <View style={s.blob2} />
          <View style={s.blob3} />

          <Animated.View
              style={{ opacity: brandOp, transform: [{ translateY: brandY }] }}
          >
            <Text style={s.brandTitle}>
              <Text style={{ color: C.orange }}>UTE</Text>
              <Text style={{ color: "#FFF" }}>BookStore</Text>
            </Text>
            <Text style={s.brandSub}>Mua sách nhanh chóng và tiện lợi</Text>
          </Animated.View>
        </Animated.View>

        {/* ── FORM CARD ─────────────────────────────────────────────────────── */}
        <KeyboardAvoidingView
            style={{ flex: 1 }}
            behavior={Platform.OS === "ios" ? "padding" : "height"}
            keyboardVerticalOffset={0}
        >
          <ScrollView
              contentContainerStyle={s.scroll}
              keyboardShouldPersistTaps="handled"
              showsVerticalScrollIndicator={false}
          >
            <Animated.View
                style={[
                  s.card,
                  {
                    opacity:   cardOp,
                    transform: [{ translateY: cardY }, { scale: cardScale }],
                  },
                ]}
            >
              {/* Title */}
              <Animated.Text style={[s.title, fieldStyle(0)]}>
                Đăng nhập
              </Animated.Text>

              {/* Subtitle */}
              <Animated.Text style={[s.subtitle, fieldStyle(1)]}>
                Chào mừng bạn quay trở lại với UTEBookStore
              </Animated.Text>

              {/* Email */}
              <Animated.View style={[s.inputWrap, fieldStyle(2)]}>
                <Ionicons
                    name="mail-outline"
                    size={20}
                    color={C.text3}
                    style={s.icon}
                />
                <TextInput
                    placeholder="Nhập email"
                    placeholderTextColor={C.text3}
                    style={s.input}
                    keyboardType="email-address"
                    autoCapitalize="none"
                    value={email}
                    onChangeText={setEmail}
                />
              </Animated.View>

              {/* Password */}
              <Animated.View style={[s.inputWrap, fieldStyle(3)]}>
                <Ionicons
                    name="lock-closed-outline"
                    size={20}
                    color={C.text3}
                    style={s.icon}
                />
                <TextInput
                    placeholder="Nhập mật khẩu"
                    placeholderTextColor={C.text3}
                    secureTextEntry={secure}
                    style={s.input}
                    value={password}
                    onChangeText={setPassword}
                />
                <TouchableOpacity
                    onPress={() => setSecure(!secure)}
                    hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                >
                  <Ionicons
                      name={secure ? "eye-off-outline" : "eye-outline"}
                      size={20}
                      color={C.text3}
                  />
                </TouchableOpacity>
              </Animated.View>

              {/* Forgot password */}
              <Animated.View style={fieldStyle(4)}>
                <TouchableOpacity
                    onPress={() => navigation.navigate("ForgotPassword")}
                >
                  <Text style={s.forgotText}>Quên mật khẩu?</Text>
                </TouchableOpacity>
              </Animated.View>

              {/* Login button with press-scale */}
              <Animated.View
                  style={[
                    fieldStyle(5),
                    { transform: [{ scale: btnScale }] },
                  ]}
              >
                <TouchableOpacity
                    style={[s.button, loading && s.buttonDisabled]}
                    onPress={login}
                    onPressIn={onPressIn}
                    onPressOut={onPressOut}
                    disabled={loading}
                    activeOpacity={1}
                >
                  <Text style={s.buttonText}>
                    {loading ? "Đang đăng nhập..." : "Đăng nhập"}
                  </Text>
                </TouchableOpacity>
              </Animated.View>

              {/* Divider */}
              <Animated.View style={[s.dividerRow, fieldStyle(5)]}>
                <View style={s.divider} />
                <Text style={s.dividerText}>hoặc</Text>
                <View style={s.divider} />
              </Animated.View>

              {/* Register link */}
              <Animated.Text style={[s.footerText, fieldStyle(5)]}>
                Chưa có tài khoản?{" "}
                <Text
                    style={s.link}
                    onPress={() => navigation.navigate("Register")}
                >
                  Đăng ký ngay
                </Text>
              </Animated.Text>
            </Animated.View>
          </ScrollView>
        </KeyboardAvoidingView>
      </View>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },

  // ── Header ──────────────────────────────────────────────────────────────────
  header: {
    backgroundColor: C.primaryMid,
    paddingTop: 56,
    paddingBottom: 56,
    paddingHorizontal: 24,
    borderBottomLeftRadius: 36,
    borderBottomRightRadius: 36,
    overflow: "hidden",
    alignItems: "center",
  },
  blob1: {
    position: "absolute", width: 220, height: 220,
    borderRadius: 110, backgroundColor: "rgba(255,255,255,0.09)",
    top: -80, right: -60,
  },
  blob2: {
    position: "absolute", width: 140, height: 140,
    borderRadius: 70, backgroundColor: "rgba(255,255,255,0.06)",
    bottom: -30, left: -20,
  },
  blob3: {
    position: "absolute", width: 90, height: 90,
    borderRadius: 45, backgroundColor: "rgba(255,138,0,0.10)",
    top: 28, left: 36,
  },
  brandTitle: {
    fontSize: 34, fontWeight: "900",
    textAlign: "center", letterSpacing: -0.5,
  },
  brandSub: {
    textAlign: "center", color: "rgba(255,255,255,0.82)",
    marginTop: 10, fontSize: 14, fontWeight: "600",
  },

  // ── Scroll / card ───────────────────────────────────────────────────────────
  scroll: {
    flexGrow: 1,
    paddingHorizontal: 20,
    marginTop: -28,
    paddingBottom: 24,
    justifyContent: "flex-start",
  },
  card: {
    backgroundColor: C.surface,
    borderRadius: 26,
    padding: 24,
    shadowColor: C.primary,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.12,
    shadowRadius: 18,
    elevation: 8,
    borderWidth: 1,
    borderColor: C.border,
  },

  // ── Typography ──────────────────────────────────────────────────────────────
  title: {
    fontSize: 26, fontWeight: "800",
    color: C.text1, marginBottom: 6,
    textAlign: "center",
  },
  subtitle: {
    color: C.text2, fontSize: 14,
    marginBottom: 24, lineHeight: 20, fontWeight: "600",
    textAlign: "center",
  },

  // ── Inputs ──────────────────────────────────────────────────────────────────
  inputWrap: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: C.primarySoft,
    borderRadius: 14,
    paddingHorizontal: 14,
    borderWidth: 1,
    borderColor: C.primaryTint,
    marginBottom: 14,
    height: 52,
  },
  icon: { marginRight: 10 },
  input: {
    flex: 1, fontSize: 15, color: C.text1, fontWeight: "600",
  },

  // ── Forgot ──────────────────────────────────────────────────────────────────
  forgotText: {
    textAlign: "right", color: C.primaryMid,
    fontSize: 13, fontWeight: "700", marginBottom: 20,
  },

  // ── Button ──────────────────────────────────────────────────────────────────
  button: {
    backgroundColor: C.primaryMid,
    paddingVertical: 15,
    borderRadius: 14,
    alignItems: "center",
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.28,
    shadowRadius: 12,
    elevation: 5,
  },
  buttonDisabled: { opacity: 0.65 },
  buttonText: { color: "#fff", fontSize: 16, fontWeight: "800" },

  // ── Divider ─────────────────────────────────────────────────────────────────
  dividerRow: {
    flexDirection: "row", alignItems: "center",
    marginVertical: 22, gap: 10,
  },
  divider: { flex: 1, height: 1, backgroundColor: C.border },
  dividerText: { color: C.text3, fontSize: 12, fontWeight: "600" },

  // ── Footer ──────────────────────────────────────────────────────────────────
  footerText: {
    textAlign: "center", color: C.text2,
    fontSize: 14, fontWeight: "600",
  },
  link: { color: C.primaryMid, fontWeight: "800" },
});