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
import Svg, { Path, Circle, Polygon } from "react-native-svg";

const { width, height } = Dimensions.get("window");

// ─────────────────────────────────────────────────────────────
// Decorative spark configs
// ─────────────────────────────────────────────────────────────
const SPARKS = [
  { id: 0, cx: width * 0.18, cy: height * 0.12, color: "#FFD700", angle: -60, dist: 55, delay: 300 },
  { id: 1, cx: width * 0.18, cy: height * 0.12, color: "#FFB800", angle: -30, dist: 48, delay: 300 },
  { id: 2, cx: width * 0.18, cy: height * 0.12, color: "#FFFFFF", angle: 0, dist: 52, delay: 300 },
  { id: 3, cx: width * 0.18, cy: height * 0.12, color: "#FFD700", angle: -90, dist: 44, delay: 300 },
  { id: 4, cx: width * 0.18, cy: height * 0.12, color: "#FFB800", angle: 30, dist: 50, delay: 300 },
  { id: 5, cx: width * 0.82, cy: height * 0.09, color: "#FFD700", angle: -120, dist: 58, delay: 600 },
  { id: 6, cx: width * 0.82, cy: height * 0.09, color: "#FFFFFF", angle: -150, dist: 46, delay: 600 },
  { id: 7, cx: width * 0.82, cy: height * 0.09, color: "#FFD700", angle: -90, dist: 54, delay: 600 },
  { id: 8, cx: width * 0.82, cy: height * 0.09, color: "#FFB800", angle: -60, dist: 50, delay: 600 },
  { id: 9, cx: width * 0.82, cy: height * 0.09, color: "#FFD700", angle: -180, dist: 42, delay: 600 },
  { id: 10, cx: width * 0.62, cy: height * 0.21, color: "#FFD700", angle: 45, dist: 40, delay: 950 },
  { id: 11, cx: width * 0.62, cy: height * 0.21, color: "#FFFFFF", angle: 90, dist: 36, delay: 950 },
  { id: 12, cx: width * 0.62, cy: height * 0.21, color: "#FFB800", angle: 135, dist: 44, delay: 950 },
  { id: 13, cx: width * 0.62, cy: height * 0.21, color: "#FFD700", angle: 0, dist: 38, delay: 950 },
];

function Spark({ cx, cy, color, angle, dist, delay }: (typeof SPARKS)[0]) {
  const anim = useRef(new Animated.Value(0)).current;
  const opacityAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const loop = Animated.loop(
        Animated.sequence([
          Animated.delay(delay),
          Animated.parallel([
            Animated.timing(anim, {
              toValue: 1,
              duration: 700,
              easing: Easing.out(Easing.quad),
              useNativeDriver: true,
            }),
            Animated.sequence([
              Animated.timing(opacityAnim, {
                toValue: 1,
                duration: 150,
                useNativeDriver: true,
              }),
              Animated.timing(opacityAnim, {
                toValue: 0,
                duration: 550,
                useNativeDriver: true,
              }),
            ]),
          ]),
          Animated.parallel([
            Animated.timing(anim, {
              toValue: 0,
              duration: 0,
              useNativeDriver: true,
            }),
            Animated.timing(opacityAnim, {
              toValue: 0,
              duration: 0,
              useNativeDriver: true,
            }),
          ]),
          Animated.delay(1800),
        ])
    );

    loop.start();
    return () => loop.stop();
  }, [anim, opacityAnim, delay]);

  const rad = (angle * Math.PI) / 180;
  const tx = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [0, Math.cos(rad) * dist],
  });
  const ty = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [0, Math.sin(rad) * dist],
  });

  return (
      <Animated.View
          style={{
            position: "absolute",
            left: cx,
            top: cy,
            width: 4,
            height: 4,
            borderRadius: 2,
            backgroundColor: color,
            opacity: opacityAnim,
            transform: [{ translateX: tx }, { translateY: ty }],
            shadowColor: color,
            shadowOffset: { width: 0, height: 0 },
            shadowOpacity: 1,
            shadowRadius: 4,
            elevation: 4,
          }}
      />
  );
}

function StarDecor({
                     x,
                     y,
                     size,
                     delay,
                   }: {
  x: number;
  y: number;
  size: number;
  delay: number;
}) {
  const twinkle = useRef(new Animated.Value(0.35)).current;

  useEffect(() => {
    const loop = Animated.loop(
        Animated.sequence([
          Animated.delay(delay),
          Animated.timing(twinkle, {
            toValue: 1,
            duration: 600,
            useNativeDriver: true,
          }),
          Animated.timing(twinkle, {
            toValue: 0.35,
            duration: 600,
            useNativeDriver: true,
          }),
        ])
    );
    loop.start();
    return () => loop.stop();
  }, [twinkle, delay]);

  return (
      <Animated.Text
          style={{
            position: "absolute",
            left: x,
            top: y,
            fontSize: size,
            opacity: twinkle,
            color: "#FFD700",
          }}
      >
        ★
      </Animated.Text>
  );
}

// ─────────────────────────────────────────────────────────────
// Star chuẩn 5 cánh
// ─────────────────────────────────────────────────────────────
function StarShape({
                     size = 100,
                     color = "#FFD700",
                   }: {
  size?: number;
  color?: string;
}) {
  return (
      <Svg width={size} height={size} viewBox="0 0 100 100">
        <Polygon
            points="50,5 61,38 95,38 67,58 78,91 50,71 22,91 33,58 5,38 39,38"
            fill={color}
        />
      </Svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Logo UTEBookStore vẽ bằng SVG
// ─────────────────────────────────────────────────────────────
function LogoUTEBookStore({ size = 120 }: { size?: number }) {
  return (
      <Svg width={size} height={size} viewBox="0 0 200 200">
        {/* arc */}
        <Path
            d="M30 78 C30 35, 170 35, 170 78"
            fill="none"
            stroke="#60A5FA"
            strokeWidth="5"
            strokeLinecap="round"
        />

        {/* top star */}
        <Polygon
            points="100,18 106,34 123,34 109,44 114,60 100,50 86,60 91,44 77,34 94,34"
            fill="#FBBF24"
        />

        {/* side stars */}
        <Polygon
            points="55,58 59,68 70,68 61,74 64,85 55,78 46,85 49,74 40,68 51,68"
            fill="#FBBF24"
        />
        <Polygon
            points="145,58 149,68 160,68 151,74 154,85 145,78 136,85 139,74 130,68 141,68"
            fill="#FBBF24"
        />

        {/* book */}
        <Path
            d="M38 118 C58 108, 77 108, 96 122 L96 146 C77 132, 58 130, 38 138 Z"
            fill="#0D1B5E"
        />
        <Path
            d="M162 118 C142 108, 123 108, 104 122 L104 146 C123 132, 142 130, 162 138 Z"
            fill="#2563EB"
        />
        <Path
            d="M46 104 C64 97, 80 98, 96 111"
            fill="none"
            stroke="#0D1B5E"
            strokeWidth="5"
            strokeLinecap="round"
        />
        <Path
            d="M154 104 C136 97, 120 98, 104 111"
            fill="none"
            stroke="#2563EB"
            strokeWidth="5"
            strokeLinecap="round"
        />
        <Path
            d="M54 95 C69 90, 82 91, 96 102"
            fill="none"
            stroke="#0D1B5E"
            strokeWidth="4"
            strokeLinecap="round"
        />
        <Path
            d="M146 95 C131 90, 118 91, 104 102"
            fill="none"
            stroke="#2563EB"
            strokeWidth="4"
            strokeLinecap="round"
        />

        {/* tower */}
        <Path
            d="M90 76 L100 60 L110 76 L110 125 L90 125 Z"
            fill="#0D1B5E"
        />
        <Path
            d="M94 45 C94 38, 106 38, 106 45 L106 60 L94 60 Z"
            fill="#0D1B5E"
        />
        <Circle cx="100" cy="78" r="8" fill="#FFFFFF" />
        <Path
            d="M100 72 L100 78 L104 80"
            fill="none"
            stroke="#0D1B5E"
            strokeWidth="2"
            strokeLinecap="round"
        />
        <Path
            d="M96 125 L96 146"
            stroke="#0D1B5E"
            strokeWidth="4"
            strokeLinecap="round"
        />
        <Path
            d="M104 125 L104 146"
            stroke="#0D1B5E"
            strokeWidth="4"
            strokeLinecap="round"
        />
      </Svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Vietnam flag
// ─────────────────────────────────────────────────────────────
function VietnamFlag({ waveAnim }: { waveAnim: Animated.Value }) {
  const FLAG_W = width * 0.72;
  const FLAG_H = FLAG_W * 0.6;

  const skewRight = waveAnim.interpolate({
    inputRange: [-6, 6],
    outputRange: ["-4deg", "4deg"],
  });
  const skewMid = waveAnim.interpolate({
    inputRange: [-6, 6],
    outputRange: ["-2deg", "2deg"],
  });

  const STRIPE_W = FLAG_W / 3;

  return (
      <View
          style={{
            width: FLAG_W,
            height: FLAG_H,
            flexDirection: "row",
            overflow: "hidden",
            borderRadius: 4,
            shadowColor: "#000",
            shadowOffset: { width: 0, height: 8 },
            shadowOpacity: 0.45,
            shadowRadius: 16,
            elevation: 14,
          }}
      >
        <View
            style={{
              width: STRIPE_W,
              height: FLAG_H,
              backgroundColor: "#C8001E",
            }}
        />
        <Animated.View
            style={{
              width: STRIPE_W,
              height: FLAG_H * 1.1,
              backgroundColor: "#C8001E",
              transform: [{ skewY: skewMid }],
              marginTop: -FLAG_H * 0.05,
            }}
        />
        <Animated.View
            style={{
              width: STRIPE_W,
              height: FLAG_H * 1.15,
              backgroundColor: "#C8001E",
              transform: [{ skewY: skewRight }],
              marginTop: -FLAG_H * 0.08,
            }}
        />

        <View
            style={{
              position: "absolute",
              width: FLAG_W,
              height: FLAG_H,
              alignItems: "center",
              justifyContent: "center",
            }}
        >
          <StarShape size={FLAG_H * 0.5} color="#FFD700" />
        </View>

        <View
            style={{
              position: "absolute",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              borderWidth: 1.5,
              borderColor: "rgba(255,215,0,0.35)",
              borderRadius: 4,
            }}
        />
      </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────
export default function WelcomeScreen({ navigation }: any) {
  const curtainTop = useRef(new Animated.Value(0)).current;
  const curtainBot = useRef(new Animated.Value(0)).current;
  const logoScale = useRef(new Animated.Value(0.6)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const stripeLeft = useRef(new Animated.Value(-width)).current;
  const stripeRight = useRef(new Animated.Value(width)).current;
  const brandOpacity = useRef(new Animated.Value(0)).current;
  const brandSlide = useRef(new Animated.Value(20)).current;
  const dateOpacity = useRef(new Animated.Value(0)).current;
  const dateSlide = useRef(new Animated.Value(16)).current;
  const tagOpacity = useRef(new Animated.Value(0)).current;
  const ctaOpacity = useRef(new Animated.Value(0)).current;
  const ctaSlide = useRef(new Animated.Value(20)).current;
  const progressAnim = useRef(new Animated.Value(0)).current;
  const flagWave = useRef(new Animated.Value(0)).current;
  const flagOpacity = useRef(new Animated.Value(0)).current;
  const flagSlide = useRef(new Animated.Value(30)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(curtainTop, {
        toValue: -height * 0.5,
        duration: 800,
        delay: 80,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(curtainBot, {
        toValue: height * 0.5,
        duration: 800,
        delay: 80,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start();

    Animated.parallel([
      Animated.spring(stripeLeft, {
        toValue: 0,
        tension: 50,
        friction: 9,
        delay: 600,
        useNativeDriver: true,
      }),
      Animated.spring(stripeRight, {
        toValue: 0,
        tension: 50,
        friction: 9,
        delay: 700,
        useNativeDriver: true,
      }),
    ]).start();

    Animated.parallel([
      Animated.spring(logoScale, {
        toValue: 1,
        tension: 60,
        friction: 7,
        delay: 800,
        useNativeDriver: true,
      }),
      Animated.timing(logoOpacity, {
        toValue: 1,
        duration: 400,
        delay: 800,
        useNativeDriver: true,
      }),
    ]).start();

    Animated.parallel([
      Animated.timing(brandOpacity, {
        toValue: 1,
        duration: 500,
        delay: 1050,
        useNativeDriver: true,
      }),
      Animated.timing(brandSlide, {
        toValue: 0,
        duration: 500,
        delay: 1050,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();

    Animated.parallel([
      Animated.timing(dateOpacity, {
        toValue: 1,
        duration: 500,
        delay: 1280,
        useNativeDriver: true,
      }),
      Animated.timing(dateSlide, {
        toValue: 0,
        duration: 500,
        delay: 1280,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();

    Animated.timing(tagOpacity, {
      toValue: 1,
      duration: 500,
      delay: 1500,
      useNativeDriver: true,
    }).start();

    Animated.parallel([
      Animated.timing(flagOpacity, {
        toValue: 1,
        duration: 600,
        delay: 1700,
        useNativeDriver: true,
      }),
      Animated.timing(flagSlide, {
        toValue: 0,
        duration: 600,
        delay: 1700,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();

    Animated.parallel([
      Animated.timing(ctaOpacity, {
        toValue: 1,
        duration: 500,
        delay: 1750,
        useNativeDriver: true,
      }),
      Animated.timing(ctaSlide, {
        toValue: 0,
        duration: 500,
        delay: 1750,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();

    // 30 giây
    Animated.timing(progressAnim, {
      toValue: 1,
      duration: 30000,
      delay: 500,
      useNativeDriver: false,
    }).start();

    const waveLoop = Animated.loop(
        Animated.sequence([
          Animated.timing(flagWave, {
            toValue: 4,
            duration: 1200,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
          Animated.timing(flagWave, {
            toValue: -4,
            duration: 1200,
            easing: Easing.inOut(Easing.sin),
            useNativeDriver: true,
          }),
        ])
    );

    const waveTimeout = setTimeout(() => waveLoop.start(), 900);

    // auto nav sau 30.5 giây
    const timer = setTimeout(() => navigation.replace("MainTabs"), 30500);

    return () => {
      clearTimeout(timer);
      clearTimeout(waveTimeout);
      waveLoop.stop();
    };
  }, [
    curtainTop,
    curtainBot,
    logoScale,
    logoOpacity,
    stripeLeft,
    stripeRight,
    brandOpacity,
    brandSlide,
    dateOpacity,
    dateSlide,
    tagOpacity,
    ctaOpacity,
    ctaSlide,
    progressAnim,
    flagWave,
    flagOpacity,
    flagSlide,
    navigation,
  ]);

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ["0%", "100%"],
  });

  return (
      <View style={styles.root}>
        <StatusBar barStyle="light-content" backgroundColor="#0D1B5E" />

        <View style={styles.bgBase} />
        <View style={styles.bgTopShade} />

        <StarDecor x={width * 0.08} y={height * 0.38} size={10} delay={0} />
        <StarDecor x={width * 0.9} y={height * 0.32} size={8} delay={300} />
        <StarDecor x={width * 0.75} y={height * 0.55} size={6} delay={150} />
        <StarDecor x={width * 0.05} y={height * 0.6} size={7} delay={500} />
        <StarDecor x={width * 0.88} y={height * 0.7} size={9} delay={200} />
        <StarDecor x={width * 0.48} y={height * 0.79} size={6} delay={400} />

        {SPARKS.map((s) => (
            <Spark key={s.id} {...s} />
        ))}

        <Animated.View
            style={[
              styles.stripe,
              styles.stripeA,
              { transform: [{ translateX: stripeLeft }, { rotate: "-12deg" }] },
            ]}
        />
        <Animated.View
            style={[
              styles.stripe,
              styles.stripeB,
              { transform: [{ translateX: stripeRight }, { rotate: "-12deg" }] },
            ]}
        />

        <Animated.View
            style={[
              styles.logoZone,
              { opacity: logoOpacity, transform: [{ scale: logoScale }] },
            ]}
        >
          <View style={styles.logoGlowRing} />
          <View style={styles.logoCircle}>
            <LogoUTEBookStore size={102} />
          </View>
          <View style={styles.starBadge}>
            <StarShape size={16} color="#FBBF24" />
          </View>
        </Animated.View>

        <View style={styles.centerContent}>
          <Animated.View
              style={[
                styles.dateBadge,
                { opacity: dateOpacity, transform: [{ translateY: dateSlide }] },
              ]}
          >
            <Text style={styles.dateBadgeText}>UTE</Text>
            <View style={styles.dateBadgeDot} />
            <Text style={styles.dateBadgeText}>BOOK</Text>
            <View style={styles.dateBadgeDot} />
            <Text style={styles.dateBadgeText}>STORE</Text>
          </Animated.View>

          <Animated.View
              style={[
                styles.brandWrap,
                { opacity: brandOpacity, transform: [{ translateY: brandSlide }] },
              ]}
          >
            <View style={styles.brandRow}>
              <Text style={styles.brandUTE}>UTE</Text>
              <Text style={styles.brandBook}>BookStore</Text>
            </View>
          </Animated.View>

          <Animated.Text style={[styles.slogan, { opacity: tagOpacity }]}>
            Sách hay mỗi ngày{"\n"}Tri thức mở lối tương lai
          </Animated.Text>

          <Animated.View
              style={{
                opacity: flagOpacity,
                transform: [{ translateY: flagSlide }],
              }}
          >
            <VietnamFlag waveAnim={flagWave} />
          </Animated.View>
        </View>

        <Animated.View
            style={[
              styles.bottomSection,
              { opacity: ctaOpacity, transform: [{ translateY: ctaSlide }] },
            ]}
        >
          <TouchableOpacity
              style={styles.ctaBtn}
              onPress={() => navigation.replace("MainTabs")}
              activeOpacity={0.85}
          >
            <Text style={styles.ctaText}>📚 Vào UTEBookStore</Text>
          </TouchableOpacity>

          <View style={styles.progressWrap}>
            <View style={styles.progressTrack}>
              <Animated.View
                  style={[styles.progressFill, { width: progressWidth }]}
              />
            </View>
            <Text style={styles.progressHint}>Tự động chuyển sau 30 giây</Text>
          </View>
        </Animated.View>

        <Animated.View
            style={[
              styles.curtain,
              styles.curtainTop,
              { transform: [{ translateY: curtainTop }] },
            ]}
        />
        <Animated.View
            style={[
              styles.curtain,
              styles.curtainBot,
              { transform: [{ translateY: curtainBot }] },
            ]}
        />
      </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    alignItems: "center",
    justifyContent: "space-between",
    paddingVertical: 60,
    overflow: "hidden",
  },

  bgBase: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: "#0D1B5E",
  },

  bgTopShade: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    height: height * 0.5,
    backgroundColor: "rgba(0,0,0,0.18)",
  },

  stripe: {
    position: "absolute",
    width: width * 1.5,
    height: 2.5,
    borderRadius: 2,
    left: -width * 0.25,
  },

  stripeA: {
    top: height * 0.43,
    backgroundColor: "rgba(251,191,36,0.22)",
  },

  stripeB: {
    top: height * 0.54,
    backgroundColor: "rgba(251,191,36,0.12)",
  },

  logoZone: {
    alignItems: "center",
    justifyContent: "center",
    marginTop: 8,
  },

  logoGlowRing: {
    position: "absolute",
    width: 142,
    height: 142,
    borderRadius: 71,
    backgroundColor: "rgba(251,191,36,0.08)",
    borderWidth: 1.5,
    borderColor: "rgba(251,191,36,0.35)",
    shadowColor: "#FBBF24",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.45,
    shadowRadius: 18,
    elevation: 8,
  },

  logoCircle: {
    width: 114,
    height: 114,
    borderRadius: 57,
    backgroundColor: "#FFFFFF",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 2.5,
    borderColor: "#FBBF24",
    shadowColor: "#FBBF24",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.35,
    shadowRadius: 14,
    elevation: 10,
    overflow: "hidden",
  },

  starBadge: {
    position: "absolute",
    top: -4,
    right: -4,
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: "#FFFFFF",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 2,
    borderColor: "#0D1B5E",
    shadowColor: "#FBBF24",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 6,
    elevation: 6,
  },

  centerContent: {
    alignItems: "center",
    gap: 14,
    paddingHorizontal: 28,
  },

  dateBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: "rgba(251,191,36,0.12)",
    borderWidth: 1,
    borderColor: "rgba(251,191,36,0.32)",
    borderRadius: 99,
    paddingHorizontal: 18,
    paddingVertical: 6,
  },

  dateBadgeText: {
    fontSize: 12,
    color: "#FBBF24",
    fontWeight: "700",
    letterSpacing: 1.2,
  },

  dateBadgeDot: {
    width: 3,
    height: 3,
    borderRadius: 2,
    backgroundColor: "#FBBF24",
    opacity: 0.7,
  },

  brandWrap: {
    alignItems: "center",
  },

  brandRow: {
    flexDirection: "row",
    alignItems: "baseline",
  },

  brandUTE: {
    fontSize: 40,
    fontWeight: "900",
    color: "#FBBF24",
    letterSpacing: 2,
    textShadowColor: "rgba(251,191,36,0.35)",
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 12,
  },

  brandBook: {
    fontSize: 28,
    fontWeight: "700",
    color: "#FFFFFF",
    marginLeft: 4,
    textShadowColor: "rgba(0,0,0,0.28)",
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 4,
  },

  slogan: {
    fontSize: 13,
    color: "rgba(255,255,255,0.84)",
    textAlign: "center",
    lineHeight: 20,
    letterSpacing: 0.3,
  },

  bottomSection: {
    width: "100%",
    alignItems: "center",
    paddingHorizontal: 28,
    gap: 16,
  },

  ctaBtn: {
    width: "100%",
    backgroundColor: "#FBBF24",
    paddingVertical: 15,
    borderRadius: 16,
    alignItems: "center",
    shadowColor: "#FBBF24",
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.45,
    shadowRadius: 14,
    elevation: 10,
  },

  ctaText: {
    fontSize: 15,
    fontWeight: "800",
    color: "#0D1B5E",
    letterSpacing: 0.4,
  },

  progressWrap: {
    alignItems: "center",
    gap: 5,
  },

  progressTrack: {
    width: 120,
    height: 4,
    backgroundColor: "rgba(255,255,255,0.15)",
    borderRadius: 99,
    overflow: "hidden",
  },

  progressFill: {
    height: "100%",
    backgroundColor: "#FBBF24",
    borderRadius: 99,
  },

  progressHint: {
    fontSize: 11,
    color: "rgba(255,255,255,0.6)",
    letterSpacing: 0.2,
  },

  curtain: {
    position: "absolute",
    width: "100%",
    height: "50%",
    backgroundColor: "#081140",
    zIndex: 99,
  },

  curtainTop: { top: 0 },
  curtainBot: { bottom: 0 },
});