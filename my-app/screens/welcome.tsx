import React, { useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  StatusBar,
  Animated,
  Dimensions,
} from "react-native";

const { width } = Dimensions.get("window");

export default function WelcomeScreen({ navigation }: any) {
  // Animation refs
  const logoAnim = useRef(new Animated.Value(0)).current;
  const logoFloat = useRef(new Animated.Value(0)).current;
  const fadeInBrand = useRef(new Animated.Value(0)).current;
  const slideFeatures = useRef(new Animated.Value(40)).current;
  const fadeFeatures = useRef(new Animated.Value(0)).current;
  const slideCta = useRef(new Animated.Value(40)).current;
  const fadeCta = useRef(new Animated.Value(0)).current;
  const progressAnim = useRef(new Animated.Value(0)).current;
  const ring1Scale = useRef(new Animated.Value(0.8)).current;
  const ring1Opacity = useRef(new Animated.Value(0.6)).current;
  const ring2Scale = useRef(new Animated.Value(0.8)).current;
  const ring2Opacity = useRef(new Animated.Value(0.4)).current;

  useEffect(() => {
    // 1. Logo drop-in + bounce
    Animated.spring(logoAnim, {
      toValue: 1,
      tension: 60,
      friction: 7,
      useNativeDriver: true,
    }).start();

    // 2. Logo floating loop
    const floatLoop = Animated.loop(
        Animated.sequence([
          Animated.timing(logoFloat, {
            toValue: -8,
            duration: 1800,
            useNativeDriver: true,
          }),
          Animated.timing(logoFloat, {
            toValue: 0,
            duration: 1800,
            useNativeDriver: true,
          }),
        ])
    );

    // 3. Ring pulse loops
    const ringLoop1 = Animated.loop(
        Animated.sequence([
          Animated.parallel([
            Animated.timing(ring1Scale, { toValue: 1.4, duration: 1800, useNativeDriver: true }),
            Animated.timing(ring1Opacity, { toValue: 0, duration: 1800, useNativeDriver: true }),
          ]),
          Animated.parallel([
            Animated.timing(ring1Scale, { toValue: 0.8, duration: 0, useNativeDriver: true }),
            Animated.timing(ring1Opacity, { toValue: 0.6, duration: 0, useNativeDriver: true }),
          ]),
        ])
    );

    const ringLoop2 = Animated.loop(
        Animated.sequence([
          Animated.delay(600),
          Animated.parallel([
            Animated.timing(ring2Scale, { toValue: 1.6, duration: 2200, useNativeDriver: true }),
            Animated.timing(ring2Opacity, { toValue: 0, duration: 2200, useNativeDriver: true }),
          ]),
          Animated.parallel([
            Animated.timing(ring2Scale, { toValue: 0.8, duration: 0, useNativeDriver: true }),
            Animated.timing(ring2Opacity, { toValue: 0.4, duration: 0, useNativeDriver: true }),
          ]),
        ])
    );

    // 4. Brand fade in
    Animated.timing(fadeInBrand, {
      toValue: 1,
      duration: 600,
      delay: 400,
      useNativeDriver: true,
    }).start();

    // 5. Features slide up
    Animated.parallel([
      Animated.timing(slideFeatures, {
        toValue: 0,
        duration: 600,
        delay: 700,
        useNativeDriver: true,
      }),
      Animated.timing(fadeFeatures, {
        toValue: 1,
        duration: 600,
        delay: 700,
        useNativeDriver: true,
      }),
    ]).start();

    // 6. CTA slide up
    Animated.parallel([
      Animated.timing(slideCta, {
        toValue: 0,
        duration: 600,
        delay: 950,
        useNativeDriver: true,
      }),
      Animated.timing(fadeCta, {
        toValue: 1,
        duration: 600,
        delay: 950,
        useNativeDriver: true,
      }),
    ]).start();

    // 7. Progress bar (5s)
    Animated.timing(progressAnim, {
      toValue: 1,
      duration: 5000,
      delay: 500,
      useNativeDriver: false,
    }).start();

    // Start loops
    floatLoop.start();
    ringLoop1.start();
    ringLoop2.start();

    // Auto navigate after 2.5s
    const timer = setTimeout(() => {
      navigation.replace("MainTabs");
    }, 2500);

    return () => {
      clearTimeout(timer);
      floatLoop.stop();
      ringLoop1.stop();
      ringLoop2.stop();
    };
  }, []);

  const logoTranslateY = logoAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [-60, 0],
  });

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ["0%", "100%"],
  });

  return (
      <View style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor="#0D47A1" />

        {/* Background circles for depth */}
        <View style={styles.bgCircle1} />
        <View style={styles.bgCircle2} />

        {/* Logo Section */}
        <Animated.View
            style={[
              styles.logoSection,
              {
                opacity: logoAnim,
                transform: [
                  { translateY: logoTranslateY },
                  { translateY: logoFloat },
                ],
              },
            ]}
        >
          {/* Pulse rings */}
          <Animated.View
              style={[
                styles.pulseRing,
                {
                  transform: [{ scale: ring1Scale }],
                  opacity: ring1Opacity,
                },
              ]}
          />
          <Animated.View
              style={[
                styles.pulseRing,
                styles.pulseRing2,
                {
                  transform: [{ scale: ring2Scale }],
                  opacity: ring2Opacity,
                },
              ]}
          />

          <View style={styles.logoWrapper}>
            <Image
                source={require("../assets/images/logo.png")}
                style={styles.logo}
                resizeMode="contain"
            />
          </View>
        </Animated.View>

        {/* Brand Name */}
        <Animated.View style={[styles.brandContainer, { opacity: fadeInBrand }]}>
          <Text style={styles.title}>
            <Text style={styles.titleUTE}>UTE</Text>
            <Text style={styles.titleRest}>BookStore</Text>
          </Text>
          <Text style={styles.subtitle}>Mua sách nhanh chóng &amp; tiện lợi</Text>
        </Animated.View>

        {/* Features */}
        <Animated.View
            style={[
              styles.featureContainer,
              {
                opacity: fadeFeatures,
                transform: [{ translateY: slideFeatures }],
              },
            ]}
        >
          {[
            { icon: "📚", text: "Sản phẩm chất lượng cao", color: "rgba(100,160,255,0.2)" },
            { icon: "🚀", text: "Giao hàng siêu tốc", color: "rgba(255,122,0,0.2)" },
            { icon: "🔒", text: "Thanh toán an toàn", color: "rgba(100,220,150,0.2)" },
          ].map((item, i) => (
              <View key={i} style={styles.featureItem}>
                <View style={[styles.featureIcon, { backgroundColor: item.color }]}>
                  <Text style={styles.featureEmoji}>{item.icon}</Text>
                </View>
                <Text style={styles.featureText}>{item.text}</Text>
              </View>
          ))}
        </Animated.View>

        {/* CTA + Progress */}
        <Animated.View
            style={[
              styles.ctaSection,
              {
                opacity: fadeCta,
                transform: [{ translateY: slideCta }],
              },
            ]}
        >
          <TouchableOpacity
              style={styles.button}
              onPress={() => navigation.replace("MainTabs")}
              activeOpacity={0.85}
          >
            <Text style={styles.buttonText}>Bắt đầu ngay →</Text>
          </TouchableOpacity>

          {/* Auto-advance progress */}
          <View style={styles.progressSection}>
            <View style={styles.progressBg}>
              <Animated.View style={[styles.progressFill, { width: progressWidth }]} />
            </View>
            <Text style={styles.progressLabel}>Tự động chuyển sau 5 giây</Text>
          </View>
        </Animated.View>
      </View>
  );
}

const LOGO_SIZE = 120;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#0D47A1",
    alignItems: "center",
    justifyContent: "space-between",
    paddingVertical: 70,
    paddingHorizontal: 28,
    overflow: "hidden",
  },

  // Background depth circles
  bgCircle1: {
    position: "absolute",
    width: 280,
    height: 280,
    borderRadius: 140,
    backgroundColor: "rgba(100,180,255,0.07)",
    top: -80,
    right: -80,
  },
  bgCircle2: {
    position: "absolute",
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: "rgba(255,122,0,0.06)",
    bottom: 60,
    left: -60,
  },

  // Logo area
  logoSection: {
    alignItems: "center",
    justifyContent: "center",
  },
  pulseRing: {
    position: "absolute",
    width: LOGO_SIZE + 30,
    height: LOGO_SIZE + 30,
    borderRadius: (LOGO_SIZE + 30) / 2,
    borderWidth: 1.5,
    borderColor: "rgba(100,180,255,0.4)",
  },
  pulseRing2: {
    width: LOGO_SIZE + 50,
    height: LOGO_SIZE + 50,
    borderRadius: (LOGO_SIZE + 50) / 2,
    borderColor: "rgba(100,180,255,0.25)",
  },
  logoWrapper: {
    width: LOGO_SIZE,
    height: LOGO_SIZE,
    borderRadius: LOGO_SIZE / 2,
    backgroundColor: "rgba(255,255,255,0.1)",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.15)",
  },
  logo: {
    width: 82,
    height: 82,
  },

  // Brand
  brandContainer: {
    alignItems: "center",
  },
  title: {
    fontSize: 30,
    letterSpacing: 0.5,
  },
  titleUTE: {
    color: "#FF7A00",
    fontWeight: "900",
  },
  titleRest: {
    color: "#FFFFFF",
    fontWeight: "800",
  },
  subtitle: {
    marginTop: 8,
    fontSize: 13.5,
    color: "rgba(200,225,255,0.8)",
    letterSpacing: 0.3,
  },

  // Features
  featureContainer: {
    width: "100%",
    gap: 10,
  },
  featureItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    backgroundColor: "rgba(255,255,255,0.08)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.12)",
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  featureIcon: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  featureEmoji: {
    fontSize: 18,
  },
  featureText: {
    fontSize: 13.5,
    color: "rgba(230,245,255,0.92)",
    fontWeight: "600",
  },

  // CTA
  ctaSection: {
    width: "100%",
    alignItems: "center",
  },
  button: {
    width: "100%",
    backgroundColor: "#FF7A00",
    paddingVertical: 15,
    borderRadius: 18,
    alignItems: "center",
    shadowColor: "#FF7A00",
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.45,
    shadowRadius: 16,
    elevation: 10,
  },
  buttonText: {
    color: "#fff",
    fontSize: 15,
    fontWeight: "800",
    letterSpacing: 0.3,
  },

  // Progress
  progressSection: {
    marginTop: 16,
    alignItems: "center",
    gap: 6,
  },
  progressBg: {
    width: 120,
    height: 3,
    backgroundColor: "rgba(255,255,255,0.15)",
    borderRadius: 99,
    overflow: "hidden",
  },
  progressFill: {
    height: "100%",
    backgroundColor: "#FF7A00",
    borderRadius: 99,
  },
  progressLabel: {
    fontSize: 11,
    color: "rgba(180,210,255,0.6)",
    fontWeight: "600",
  },
});