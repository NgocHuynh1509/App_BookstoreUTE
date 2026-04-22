import React, { useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  StatusBar,
  Animated,
  Dimensions,
  Easing,
} from "react-native";
import Svg, { Path, Rect, Defs, LinearGradient, Stop, Circle,G } from "react-native-svg";

const { width, height } = Dimensions.get("window");

// ─── Helpers ──────────────────────────────────────────────────────────────
function starPath(cx: number, cy: number, R: number, r: number): string {
  const pts: string[] = [];
  for (let i = 0; i < 10; i++) {
    const radius = i % 2 === 0 ? R : r;
    const angle = (Math.PI / 5) * i - Math.PI / 2;
    pts.push(`${i === 0 ? "M" : "L"}${(cx + radius * Math.cos(angle)).toFixed(3)},${(cy + radius * Math.sin(angle)).toFixed(3)}`);
  }
  return pts.join(" ") + " Z";
}

function StarSVG({ size, color }: { size: number; color: string }) {
  const R = size / 2, r = R * 0.382, c = size / 2;
  return (
    <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <Path d={starPath(c, c, R, r)} fill={color} />
    </Svg>
  );
}

// ─── Firework burst — flash trung tâm + nhiều tia ─────────────────────────
const BURSTS = [
  { id: 0, cx: width * 0.14, cy: height * 0.10, colors: ["#FFD700","#FF6B35","#FFFFFF"], count: 9, dist: 66, delay: 180  },
  { id: 1, cx: width * 0.86, cy: height * 0.08, colors: ["#FFD700","#FF4FA3","#FFFFFF"], count: 9, dist: 62, delay: 530  },
  { id: 2, cx: width * 0.58, cy: height * 0.18, colors: ["#FFD700","#80FFEA","#FFFFFF"], count: 7, dist: 50, delay: 880  },
  { id: 3, cx: width * 0.24, cy: height * 0.29, colors: ["#FFD700","#FF6B35","#FFFFFF"], count: 7, dist: 44, delay: 1230 },
  { id: 4, cx: width * 0.76, cy: height * 0.23, colors: ["#FFD700","#B2FF59","#FFFFFF"], count: 8, dist: 55, delay: 1580 },
];

function FireworkBurst({ cx, cy, colors, count, dist, delay }: (typeof BURSTS)[0]) {
  const flash = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(Animated.sequence([
      Animated.delay(delay),
      Animated.timing(flash, { toValue: 1, duration: 80, useNativeDriver: true }),
      Animated.timing(flash, { toValue: 0, duration: 320, useNativeDriver: true }),
      Animated.delay(2600),
    ])).start();
  }, []);

  const sparks = Array.from({ length: count }, (_, i) => {
    const angle = (360 / count) * i + (Math.random() * 15 - 7);
    const color = colors[i % colors.length];
    const anim    = useRef(new Animated.Value(0)).current;
    const opacity = useRef(new Animated.Value(0)).current;

    useEffect(() => {
      Animated.loop(Animated.sequence([
        Animated.delay(delay + i * 25),
        Animated.parallel([
          Animated.timing(anim, { toValue: 1, duration: 680, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
          Animated.sequence([
            Animated.timing(opacity, { toValue: 1, duration: 110, useNativeDriver: true }),
            Animated.timing(opacity, { toValue: 0, duration: 570, useNativeDriver: true }),
          ]),
        ]),
        Animated.parallel([
          Animated.timing(anim,    { toValue: 0, duration: 0, useNativeDriver: true }),
          Animated.timing(opacity, { toValue: 0, duration: 0, useNativeDriver: true }),
        ]),
        Animated.delay(2320),
      ])).start();
    }, []);

    const rad = (angle * Math.PI) / 180;
    const tx    = anim.interpolate({ inputRange: [0, 1], outputRange: [0, Math.cos(rad) * dist] });
    const ty    = anim.interpolate({ inputRange: [0, 1], outputRange: [0, Math.sin(rad) * dist] });
    const scale = anim.interpolate({ inputRange: [0, 0.15, 1], outputRange: [0.2, 1.4, 0.3] });

    return (
      <Animated.View key={i} style={{
        position: "absolute",
        left: cx - 3, top: cy - 3,
        width: 6, height: 6, borderRadius: 3,
        backgroundColor: color,
        opacity, transform: [{ translateX: tx }, { translateY: ty }, { scale }],
        shadowColor: color, shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 1, shadowRadius: 6, elevation: 6,
      }} />
    );
  });

  return (
    <>
      {sparks}
      <Animated.View style={{
        position: "absolute",
        left: cx - 12, top: cy - 12,
        width: 24, height: 24, borderRadius: 12,
        backgroundColor: "#FFFDE0",
        opacity: flash,
        shadowColor: "#FFD700", shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 1, shadowRadius: 20, elevation: 10,
      }} />
    </>
  );
}

// ─── Particle nhỏ bay lên nền ─────────────────────────────────────────────
function FloatingParticle({ x, startY, size, color, duration, delay }: {
  x: number; startY: number; size: number; color: string; duration: number; delay: number;
}) {
  const y       = useRef(new Animated.Value(startY)).current;
  const opacity = useRef(new Animated.Value(0)).current;
  const drift   = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.loop(Animated.sequence([
      Animated.delay(delay),
      Animated.parallel([
        Animated.timing(y,       { toValue: startY - height * 0.75, duration, easing: Easing.linear, useNativeDriver: true }),
        Animated.timing(drift,   { toValue: (Math.random() > 0.5 ? 1 : -1) * 18, duration, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
        Animated.sequence([
          Animated.timing(opacity, { toValue: 0.75, duration: 500, useNativeDriver: true }),
          Animated.timing(opacity, { toValue: 0, duration: duration - 500, useNativeDriver: true }),
        ]),
      ]),
      Animated.parallel([
        Animated.timing(y,     { toValue: startY, duration: 0, useNativeDriver: true }),
        Animated.timing(drift, { toValue: 0, duration: 0, useNativeDriver: true }),
      ]),
    ])).start();
  }, []);

  return (
    <Animated.View style={{
      position: "absolute", left: x,
      width: size, height: size, borderRadius: size / 2,
      backgroundColor: color, opacity,
      transform: [{ translateY: y }, { translateX: drift }],
    }} />
  );
}

const PARTICLES = Array.from({ length: 32 }, (_, i) => ({
  id: i,
  x: (width / 32) * i + Math.random() * (width / 32),
  startY: height * (0.48 + Math.random() * 0.52),
  size: 1.5 + Math.random() * 3.5,
  color: ["#FFD700","rgba(255,107,53,0.85)","rgba(255,255,255,0.55)","rgba(255,200,0,0.7)"][i % 4],
  duration: 3200 + Math.random() * 3200,
  delay: Math.random() * 3500,
}));

// ─── Vòng quay dot xung quanh logo ───────────────────────────────────────
function RotatingHalo({ size }: { size: number }) {
  const rot = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.loop(
      Animated.timing(rot, { toValue: 1, duration: 9000, easing: Easing.linear, useNativeDriver: true })
    ).start();
  }, []);
  const rotate = rot.interpolate({ inputRange: [0, 1], outputRange: ["0deg", "360deg"] });
  const r = size / 2 - 5;

  return (
    <Animated.View style={{ position: "absolute", width: size, height: size, transform: [{ rotate }] }}>
      {Array.from({ length: 14 }, (_, i) => {
        const a = ((360 / 14) * i * Math.PI) / 180;
        const x = size / 2 + r * Math.cos(a) - (i % 4 === 0 ? 3 : 2);
        const y = size / 2 + r * Math.sin(a) - (i % 4 === 0 ? 3 : 2);
        return (
          <View key={i} style={{
            position: "absolute", left: x, top: y,
            width: i % 4 === 0 ? 6 : 3,
            height: i % 4 === 0 ? 6 : 3,
            borderRadius: 3,
            backgroundColor: i % 4 === 0 ? "#FFD700" : "rgba(255,215,0,0.35)",
          }} />
        );
      })}
    </Animated.View>
  );
}

// ─── Logo UteBookStore ────────────────────────────────────────────────────
function UTEBookStoreLogo({ size = 84 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 84 84">
      <Defs>
        <LinearGradient id="spineGrad" x1="0" y1="0" x2="1" y2="1">
          <Stop offset="0" stopColor="#FFE566" />
          <Stop offset="1" stopColor="#FFA500" />
        </LinearGradient>
        <LinearGradient id="coverGrad" x1="0" y1="0" x2="0" y2="1">
          <Stop offset="0" stopColor="#FF9A00" />
          <Stop offset="1" stopColor="#D94800" />
        </LinearGradient>
        <LinearGradient id="pageGrad" x1="0" y1="0" x2="1" y2="0">
          <Stop offset="0" stopColor="#FFF9F0" />
          <Stop offset="1" stopColor="#FFE8CC" />
        </LinearGradient>
      </Defs>

      {/* Trang trái */}
      <Path d="M7,15 Q7,11 11,11 L41,11 L41,70 L11,70 Q7,70 7,66 Z"
        fill="url(#pageGrad)" stroke="#FFD700" strokeWidth="1.5" />
      {/* Đường kẻ trang */}
      {[22, 30, 38, 46, 54].map((yy, i) => (
        <Path key={i} d={`M13,${yy} L${i === 4 ? 33 : 38},${yy}`}
          stroke="#FFCC66" strokeWidth="1.1" strokeLinecap="round" />
      ))}
      {/* Bookmark đỏ trên trang */}
      <Path d="M30,11 L38,11 L38,23 L34,20 L30,23 Z" fill="#C8001E" />

      {/* Bìa phải */}
      <Path d="M43,11 L73,11 Q77,11 77,15 L77,66 Q77,70 73,70 L43,70 Z"
        fill="url(#coverGrad)" stroke="#FFD700" strokeWidth="1.5" />
      {/* Highlight bìa */}
      <Path d="M43,11 L56,11 L50,70 L43,70 Z" fill="rgba(255,255,255,0.08)" />

      {/* Chữ "UTE" trên bìa - Đã chỉnh nhỏ và nằm cùng 1 hàng */}
      <G transform="translate(48, 22) scale(0.8)">
        {/* Chữ U */}
        <Path
          d="M0,0 L0,6 Q0,9 3,9 Q6,9 6,6 L6,0"
          stroke="#FFD700" strokeWidth="2.5" fill="none" strokeLinecap="round"
        />
        {/* Chữ T */}
        <Path
          d="M9,0 L17,0 M13,0 L13,9"
          stroke="#FFD700" strokeWidth="2.5" fill="none" strokeLinecap="round"
        />
        {/* Chữ E */}
        <Path
          d="M20,0 L20,9 M20,0 L26,0 M20,4.5 L25,4.5 M20,9 L26,9"
          stroke="#FFD700" strokeWidth="2.5" fill="none" strokeLinecap="round"
        />
      </G>

      {/* Ngôi sao nhỏ - Dời xuống dưới chữ UTE để bố cục đẹp hơn */}
      <Path d={starPath(60, 48, 8, 8 * 0.382)} fill="#FFD700" />

      {/* Gáy sách */}
      <Rect x="40" y="11" width="4" height="59" fill="url(#spineGrad)" rx="1" />
      {/* Highlight gáy */}
      <Rect x="40.5" y="11" width="1.2" height="59" fill="rgba(255,255,255,0.35)" rx="0.6" />
    </Svg>
  );
}

// ─── Lá cờ Việt Nam — Đã chỉnh lại 1 màu đỏ chuẩn ─────────────────────────
function VietnamFlag() {
  const FLAG_W = width * 0.78;
  const FLAG_H = FLAG_W * (2 / 3);
  const STAR_SIZE = FLAG_H * 0.54;

  const starGlow = useRef(new Animated.Value(0.6)).current;
  useEffect(() => {
    Animated.loop(Animated.sequence([
      Animated.timing(starGlow, { toValue: 1, duration: 1400, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
      Animated.timing(starGlow, { toValue: 0.6, duration: 1400, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
    ])).start();
  }, []);

  return (
    <View style={{
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 12 },
      shadowOpacity: 0.4,
      shadowRadius: 15,
      elevation: 12
    }}>
      {/* Viền sáng nhẹ bên ngoài lá cờ để tách nền đỏ khỏi nền tối */}
      <View style={{
        position: "absolute", top: -2, left: -2, right: -2, bottom: -2,
        borderRadius: 6, borderWidth: 1, borderColor: "rgba(255,215,0,0.3)"
      }} />

      <View style={{
        width: FLAG_W,
        height: FLAG_H,
        backgroundColor: "#D0001F", // Đỏ chuẩn duy nhất
        borderRadius: 4,
        overflow: "hidden",
        borderWidth: 1,
        borderColor: "rgba(255,215,0,0.4)"
      }}>
        {/* Layer chứa Ngôi sao */}
        <View style={{
          position: "absolute",
          width: FLAG_W,
          height: FLAG_H,
          alignItems: "center",
          justifyContent: "center"
        }}>
          {/* Vầng sáng phía sau ngôi sao (có thể giữ hoặc xóa tùy ý) */}
          <Animated.View style={{
            position: "absolute",
            width: STAR_SIZE * 1.2,
            height: STAR_SIZE * 1.2,
            borderRadius: STAR_SIZE * 0.6,
            backgroundColor: "rgba(255,215,0,0.15)",
            opacity: starGlow
          }} />

          <StarSVG size={STAR_SIZE} color="#FFD700" />
        </View>

        {/* Một lớp phủ cực mỏng để tạo cảm giác chất liệu vải (không làm đổi màu) */}
        <View style={{
          position: "absolute",
          top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: "rgba(255,255,255,0.02)"
        }} />
      </View>
    </View>
  );
}

// ─── Shimmer sweep trên CTA ───────────────────────────────────────────────
function CTAShimmer() {
  const x = useRef(new Animated.Value(-120)).current;
  useEffect(() => {
    Animated.loop(Animated.sequence([
      Animated.delay(2000),
      Animated.timing(x, { toValue: width, duration: 900, easing: Easing.inOut(Easing.quad), useNativeDriver: true }),
      Animated.timing(x, { toValue: -120, duration: 0, useNativeDriver: true }),
    ])).start();
  }, []);
  return (
    <Animated.View style={{
      position: "absolute", top: 0, bottom: 0, width: 80,
      backgroundColor: "rgba(255,255,255,0.22)",
      transform: [{ translateX: x }, { skewX: "-18deg" }],
    }} />
  );
}

// ─── Main Screen ───────────────────────────────────────────────────────────
export default function WelcomeScreen({ navigation }: any) {
  const curtainTop    = useRef(new Animated.Value(0)).current;
  const curtainBot    = useRef(new Animated.Value(0)).current;
  const logoScale     = useRef(new Animated.Value(0)).current;
  const logoOpacity   = useRef(new Animated.Value(0)).current;
  const logoRotate    = useRef(new Animated.Value(-20)).current;
  const haloPulse     = useRef(new Animated.Value(1)).current;
  const brandOpacity  = useRef(new Animated.Value(0)).current;
  const brandSlide    = useRef(new Animated.Value(28)).current;
  const brandScale    = useRef(new Animated.Value(0.88)).current;
  const dateOpacity   = useRef(new Animated.Value(0)).current;
  const dateSlide     = useRef(new Animated.Value(18)).current;
  const tagOpacity    = useRef(new Animated.Value(0)).current;
  const tagSlide      = useRef(new Animated.Value(14)).current;
  const flagOpacity   = useRef(new Animated.Value(0)).current;
  const flagSlide     = useRef(new Animated.Value(44)).current;
  const flagScale     = useRef(new Animated.Value(0.82)).current;
  const ribbonOpacity = useRef(new Animated.Value(0)).current;
  const ribbonScale   = useRef(new Animated.Value(0.75)).current;
  const ctaOpacity    = useRef(new Animated.Value(0)).current;
  const ctaSlide      = useRef(new Animated.Value(28)).current;
  const ctaScale      = useRef(new Animated.Value(0.9)).current;
  const progressAnim  = useRef(new Animated.Value(0)).current;
  const bgExpand      = useRef(new Animated.Value(1.4)).current;

  useEffect(() => {
    // BG zoom in
    Animated.timing(bgExpand, { toValue: 1, duration: 1400, easing: Easing.out(Easing.cubic), useNativeDriver: true }).start();

    // Curtain
    Animated.parallel([
      Animated.timing(curtainTop, { toValue: -height * 0.5, duration: 950, delay: 50, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
      Animated.timing(curtainBot, { toValue:  height * 0.5, duration: 950, delay: 50, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
    ]).start();

    // Logo
    Animated.parallel([
      Animated.spring(logoScale,   { toValue: 1, tension: 75, friction: 7, delay: 650, useNativeDriver: true }),
      Animated.timing(logoOpacity, { toValue: 1, duration: 300, delay: 650, useNativeDriver: true }),
      Animated.spring(logoRotate,  { toValue: 0, tension: 70, friction: 8, delay: 650, useNativeDriver: true }),
    ]).start();

    // Halo breathe
    Animated.loop(Animated.sequence([
      Animated.timing(haloPulse, { toValue: 1.22, duration: 1900, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
      Animated.timing(haloPulse, { toValue: 1.0,  duration: 1900, easing: Easing.inOut(Easing.sin), useNativeDriver: true }),
    ])).start();

    // Brand
    Animated.parallel([
      Animated.timing(brandOpacity, { toValue: 1, duration: 500, delay: 900, useNativeDriver: true }),
      Animated.spring(brandSlide,   { toValue: 0, tension: 85, friction: 9, delay: 900, useNativeDriver: true }),
      Animated.spring(brandScale,   { toValue: 1, tension: 85, friction: 9, delay: 900, useNativeDriver: true }),
    ]).start();

    // Date
    Animated.parallel([
      Animated.timing(dateOpacity, { toValue: 1, duration: 450, delay: 1100, useNativeDriver: true }),
      Animated.spring(dateSlide,   { toValue: 0, tension: 85, friction: 9, delay: 1100, useNativeDriver: true }),
    ]).start();

    // Slogan
    Animated.parallel([
      Animated.timing(tagOpacity, { toValue: 1, duration: 450, delay: 1300, useNativeDriver: true }),
      Animated.spring(tagSlide,   { toValue: 0, tension: 85, friction: 9, delay: 1300, useNativeDriver: true }),
    ]).start();

    // Flag
    Animated.parallel([
      Animated.timing(flagOpacity, { toValue: 1, duration: 500, delay: 1500, useNativeDriver: true }),
      Animated.spring(flagSlide,   { toValue: 0, tension: 60, friction: 9, delay: 1500, useNativeDriver: true }),
      Animated.spring(flagScale,   { toValue: 1, tension: 55, friction: 8, delay: 1500, useNativeDriver: true }),
    ]).start();

    // Ribbon
    Animated.parallel([
      Animated.timing(ribbonOpacity, { toValue: 1, duration: 400, delay: 1900, useNativeDriver: true }),
      Animated.spring(ribbonScale,   { toValue: 1, tension: 75, friction: 8, delay: 1900, useNativeDriver: true }),
    ]).start();

    // CTA
    Animated.parallel([
      Animated.timing(ctaOpacity, { toValue: 1, duration: 400, delay: 2050, useNativeDriver: true }),
      Animated.spring(ctaSlide,   { toValue: 0, tension: 72, friction: 8, delay: 2050, useNativeDriver: true }),
      Animated.spring(ctaScale,   { toValue: 1, tension: 72, friction: 8, delay: 2050, useNativeDriver: true }),
    ]).start();

    // Progress
    Animated.timing(progressAnim, { toValue: 1, duration: 60000, delay: 500, useNativeDriver: false }).start();

    const navTimer = setTimeout(() => navigation.replace("MainTabs"), 60500);
    return () => clearTimeout(navTimer);
  }, []);

  const progressWidth = progressAnim.interpolate({ inputRange: [0, 1], outputRange: ["0%", "100%"] });
  const logoRot = logoRotate.interpolate({ inputRange: [-20, 0], outputRange: ["-20deg", "0deg"] });

  return (
    <View style={styles.root}>
      <StatusBar barStyle="light-content" backgroundColor="#880012" />

      {/* ── Layered Background ── */}
      <View style={styles.bgBase} />
      {/* Radial zoom in */}
      <Animated.View style={[styles.bgRadial, { transform: [{ scale: bgExpand }] }]} />
      {/* Vignette top/bottom */}
      <View style={styles.bgTopDark} />
      <View style={styles.bgBottomDark} />

      {/* ── Diagonal light rays ── */}
      {[0.05, 0.22, 0.40, 0.58, 0.76, 0.92].map((pos, i) => (
        <View key={i} style={[styles.lightRay, {
          left: width * pos,
          opacity: 0.02 + i * 0.007,
          width: i % 2 === 0 ? 2 : 1.2,
        }]} />
      ))}

      {/* ── Particles ── */}
      {PARTICLES.map(p => <FloatingParticle key={p.id} {...p} />)}

      {/* ── Fireworks ── */}
      {BURSTS.map(b => <FireworkBurst key={b.id} {...b} />)}

      {/* ── LOGO ── */}
      <Animated.View style={[styles.logoZone, {
        opacity: logoOpacity,
        transform: [{ scale: logoScale }, { rotate: logoRot }],
      }]}>
        {/* Breathe ring */}
        <Animated.View style={[styles.haloOuter, { transform: [{ scale: haloPulse }] }]} />
        {/* Rotating dots */}
        <RotatingHalo size={158} />
        {/* Inner glow */}
        <View style={styles.haloInner} />
        {/* Circle */}
        <View style={styles.logoCircle}>
          <UTEBookStoreLogo size={84} />
        </View>
        {/* Star badge */}
        <View style={styles.starBadge}>
          <StarSVG size={14} color="#7A0010" />
        </View>
      </Animated.View>

      {/* ── Center ── */}
      <View style={styles.centerContent}>

        {/* Brand */}
        <Animated.View style={[styles.brandWrap, {
          opacity: brandOpacity,
          transform: [{ translateY: brandSlide }, { scale: brandScale }],
        }]}>
          <View style={styles.brandSuperRow}>
            <View style={styles.brandLine} />
            <Text style={styles.brandSuper}>✦  ĐẠI HỌC CÔNG NGHỆ KỸ THUẬT TP HỒ CHÍ MINH ✦</Text>
            <View style={styles.brandLine} />
          </View>
          <View style={styles.brandRow}>
            <Text style={styles.brandUTE}>UTE</Text>
            <View style={styles.brandDivider} />
            <View>
              <Text style={styles.brandBook}>BOOK</Text>
              <Text style={styles.brandStore}>STORE</Text>
            </View>
          </View>
        </Animated.View>

        {/* Date badge */}
        <Animated.View style={[{ opacity: dateOpacity, transform: [{ translateY: dateSlide }] }]}>
          <View style={styles.dateBadge}>
            <Text style={styles.dateEmoji}>🎖</Text>
            <Text style={styles.dateBadgeText}>30/4</Text>
            <View style={styles.dateDot} />
            <Text style={styles.dateBadgeText}>1/5</Text>
            <Text style={styles.dateEmoji}>🛠</Text>
            <View style={styles.dateSep} />
            <Text style={styles.dateYear}>2026</Text>
          </View>
        </Animated.View>

        {/* Slogan */}
        <Animated.Text style={[styles.slogan, {
          opacity: tagOpacity,
          transform: [{ translateY: tagSlide }],
        }]}>
          Chào mừng Ngày Giải Phóng Miền Nam{"\n"}& Ngày Quốc tế Lao động 🇻🇳
        </Animated.Text>

        {/* Flag */}
        <Animated.View style={{
          opacity: flagOpacity,
          transform: [{ translateY: flagSlide }, { scale: flagScale }],
          alignItems: "center",
        }}>
          <VietnamFlag />
          {/* Ribbon */}
          <Animated.View style={[styles.ribbon, {
            opacity: ribbonOpacity,
            transform: [{ scale: ribbonScale }],
          }]}>
            <View style={styles.ribbonLine} />
            <View style={styles.ribbonBadge}>
              <Text style={styles.ribbonText}>✦  51 NĂM THỐNG NHẤT  ✦</Text>
            </View>
            <View style={styles.ribbonLine} />
          </Animated.View>
        </Animated.View>
      </View>

      {/* ── CTA ── */}
      <Animated.View style={[styles.bottomSection, {
        opacity: ctaOpacity,
        transform: [{ translateY: ctaSlide }, { scale: ctaScale }],
      }]}>
        <TouchableOpacity
          style={styles.ctaBtn}
          onPress={() => navigation.replace("MainTabs")}
          activeOpacity={0.82}
        >
          <CTAShimmer />
          <Text style={styles.ctaText}>🎉  Vào mua sách thôi!</Text>
        </TouchableOpacity>

        {/* Progress bar */}
        <View style={styles.progressRow}>
          <View style={styles.progressTrack}>
            <Animated.View style={[styles.progressFill, { width: progressWidth }]} />
            <Animated.View style={[styles.progressGlowTip, { left: progressWidth }]} />
          </View>
          <Text style={styles.progressHint}>Tự động chuyển sau 60 giây</Text>
        </View>
      </Animated.View>

      {/* Curtain */}
      <Animated.View style={[styles.curtain, styles.curtainTop, { transform: [{ translateY: curtainTop }] }]} />
      <Animated.View style={[styles.curtain, styles.curtainBot, { transform: [{ translateY: curtainBot }] }]} />
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    alignItems: "center",
    justifyContent: "space-between",
    paddingTop: 50,
    paddingBottom: 42,
    overflow: "hidden",
  },

  // Background
  bgBase: {
    position: "absolute", top: 0, left: 0, right: 0, bottom: 0,
    backgroundColor: "#880012",
  },
  bgRadial: {
    position: "absolute",
    width: width * 1.7,
    height: width * 1.7,
    borderRadius: width * 0.85,
    top: height * 0.12,
    left: -width * 0.35,
    backgroundColor: "#C40020",
  },
  bgTopDark: {
    position: "absolute", top: 0, left: 0, right: 0,
    height: height * 0.40,
    backgroundColor: "rgba(0,0,0,0.42)",
  },
  bgBottomDark: {
    position: "absolute", bottom: 0, left: 0, right: 0,
    height: height * 0.20,
    backgroundColor: "rgba(0,0,0,0.30)",
  },
  lightRay: {
    position: "absolute",
    top: -height * 0.08,
    height: height * 1.25,
    backgroundColor: "#FFD700",
    transform: [{ rotate: "13deg" }],
  },

  // Logo
  logoZone: {
    alignItems: "center",
    justifyContent: "center",
  },
  haloOuter: {
    position: "absolute",
    width: 166, height: 166, borderRadius: 83,
    borderWidth: 1.2,
    borderColor: "rgba(255,215,0,0.22)",
    backgroundColor: "rgba(255,215,0,0.05)",
  },
  haloInner: {
    position: "absolute",
    width: 130, height: 130, borderRadius: 65,
    borderWidth: 2,
    borderColor: "rgba(255,215,0,0.55)",
    shadowColor: "#FFD700",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 18,
    elevation: 14,
  },
  logoCircle: {
    width: 112, height: 112, borderRadius: 56,
    backgroundColor: "#AA0018",
    alignItems: "center", justifyContent: "center",
    borderWidth: 2.5, borderColor: "#FFD700",
    shadowColor: "#FFD700",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.7,
    shadowRadius: 20,
    elevation: 16,
    overflow: "hidden",
  },
  starBadge: {
    position: "absolute", top: 1, right: 1,
    width: 28, height: 28, borderRadius: 14,
    backgroundColor: "#FFD700",
    alignItems: "center", justifyContent: "center",
    borderWidth: 2.5, borderColor: "#880012",
    shadowColor: "#FFD700",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1, shadowRadius: 10,
    elevation: 10,
  },

  // Center
  centerContent: {
    alignItems: "center",
    gap: 10,
    paddingHorizontal: 22,
    width: "100%",
  },

  // Brand
  brandWrap: { alignItems: "center", gap: 2 },
  brandSuperRow: {
    flexDirection: "row", alignItems: "center", gap: 8,
    marginBottom: 3,
  },
  brandLine: {
    flex: 1, height: 1,
    backgroundColor: "rgba(255,215,0,0.38)",
  },
  brandSuper: {
    fontSize: 8.5,
    color: "rgba(255,215,0,0.72)",
    fontWeight: "800",
    letterSpacing: 2.2,
  },
  brandRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  brandUTE: {
    fontSize: 52,
    fontWeight: "900",
    color: "#FFD700",
    letterSpacing: 5,
    textShadowColor: "rgba(255,200,0,0.8)",
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 24,
  },
  brandDivider: {
    width: 2, height: 42,
    backgroundColor: "rgba(255,215,0,0.4)",
    borderRadius: 1,
  },
  brandBook: {
    fontSize: 22,
    fontWeight: "900",
    color: "#FFFFFF",
    letterSpacing: 3,
    lineHeight: 24,
    textShadowColor: "rgba(0,0,0,0.5)",
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
  },
  brandStore: {
    fontSize: 16,
    fontWeight: "300",
    color: "rgba(255,228,180,0.85)",
    letterSpacing: 3.5,
    lineHeight: 20,
  },

  // Date badge
  dateBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: "rgba(0,0,0,0.32)",
    borderWidth: 1,
    borderColor: "rgba(255,215,0,0.52)",
    borderRadius: 99,
    paddingHorizontal: 18,
    paddingVertical: 7,
    shadowColor: "#FFD700",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.28,
    shadowRadius: 12,
    elevation: 5,
  },
  dateEmoji: { fontSize: 12 },
  dateBadgeText: {
    fontSize: 12.5,
    color: "#FFD700",
    fontWeight: "800",
    letterSpacing: 0.8,
  },
  dateDot: {
    width: 3, height: 3, borderRadius: 1.5,
    backgroundColor: "rgba(255,215,0,0.5)",
  },
  dateSep: {
    width: 1, height: 16,
    backgroundColor: "rgba(255,215,0,0.3)",
  },
  dateYear: {
    fontSize: 12.5,
    color: "rgba(255,215,0,0.75)",
    fontWeight: "700",
    letterSpacing: 1.2,
  },

  // Slogan
  slogan: {
    fontSize: 12,
    color: "rgba(255,225,180,0.78)",
    textAlign: "center",
    lineHeight: 18.5,
    letterSpacing: 0.35,
    fontStyle: "italic",
  },

  // Ribbon
  ribbon: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 10,
    gap: 8,
    paddingHorizontal: 4,
    alignSelf: "stretch",
  },
  ribbonLine: {
    flex: 1, height: 1,
    backgroundColor: "rgba(255,215,0,0.32)",
  },
  ribbonBadge: {
    backgroundColor: "rgba(0,0,0,0.38)",
    borderWidth: 1,
    borderColor: "rgba(255,215,0,0.42)",
    borderRadius: 4,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  ribbonText: {
    fontSize: 9,
    color: "#FFD700",
    fontWeight: "800",
    letterSpacing: 1.8,
  },

  // CTA
  bottomSection: {
    width: "100%",
    alignItems: "center",
    paddingHorizontal: 22,
    gap: 12,
  },
  ctaBtn: {
    width: "100%",
    backgroundColor: "#FFD700",
    paddingVertical: 17,
    borderRadius: 20,
    alignItems: "center",
    overflow: "hidden",
    shadowColor: "#FFD700",
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.72,
    shadowRadius: 24,
    elevation: 18,
  },
  ctaText: {
    fontSize: 16,
    fontWeight: "900",
    color: "#6E000E",
    letterSpacing: 0.6,
  },

  // Progress
  progressRow: {
    width: "100%",
    alignItems: "center",
    gap: 5,
  },
  progressTrack: {
    width: "65%",
    height: 3,
    backgroundColor: "rgba(255,255,255,0.12)",
    borderRadius: 99,
    overflow: "visible",
  },
  progressFill: {
    height: "100%",
    backgroundColor: "#FFD700",
    borderRadius: 99,
  },
  progressGlowTip: {
    position: "absolute",
    top: -4, marginLeft: -4.5,
    width: 11, height: 11, borderRadius: 5.5,
    backgroundColor: "#FFD700",
    shadowColor: "#FFD700",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1, shadowRadius: 8,
    elevation: 8,
  },
  progressHint: {
    fontSize: 10,
    color: "rgba(255,210,150,0.48)",
    letterSpacing: 0.4,
    marginTop: 4,
  },

  // Curtain
  curtain: {
    position: "absolute",
    width: "100%", height: "50%",
    backgroundColor: "#650010",
    zIndex: 99,
  },
  curtainTop: { top: 0 },
  curtainBot: { bottom: 0 },
});