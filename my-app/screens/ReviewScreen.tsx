import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, Alert, StatusBar, Platform,
  SafeAreaView, ScrollView, Image,
} from "react-native";
import api from "../services/api";
import { useRoute, useNavigation } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import React, { useEffect, useState } from "react";

// ─── Palette ──────────────────────────────────────────────────────────────────
const C = {
  // Màu đỏ chuẩn thương hiệu UTE - Mạnh mẽ, nhiệt huyết
  primary:     "#B8001A",

  // Đỏ trung bình cho các trạng thái Active/Hover
  primaryMid:  "#D0001F",

  // Nền đỏ cực nhạt cho các block nội dung (thay cho màu xanh nhạt cũ)
  primarySoft: "#FFF5F5",

  // Màu hồng nhạt để highlight hoặc làm viền nhẹ
  primaryTint: "#FFDADA",

  // Nền ứng dụng: Trắng sứ ấm áp (Tránh mỏi mắt hơn trắng xanh cũ)
  bg:          "#FFFBFB",

  // Bề mặt các thẻ (Card), khung trắng tinh
  surface:     "#FFFFFF",

  // Viền: Màu hồng xám nhạt (Thay cho viền xanh dương cũ)
  border:      "#FEE2E2",

  // Văn bản chính: Nâu đen đậm (Hợp với đỏ hơn là xanh đen cũ)
  text1:       "#2D0A0A",

  // Văn bản phụ: Xám đỏ trung tính
  text2:       "#6D5B5B",

  // Văn bản mờ, ghi chú
  text3:       "#AFA0A0",

  // Ngôi sao đánh giá: Vàng Gold (Đồng bộ với ngôi sao trên lá cờ)
  star:        "#FFB300",

  // Ngôi sao khi không được chọn: Xám hồng nhạt
  starOff:     "#F5EEEE",
};

// ─── Star label helper ────────────────────────────────────────────────────────
const STAR_LABELS = ["", "Tệ", "Không hay", "Bình thường", "Khá hay", "Tuyệt vời!"];
const STAR_COLORS = ["", "#E53935", "#FF7043", "#FFC107", "#66BB6A", "#1E88E5"];

export default function ReviewScreen() {
  const { params }  = useRoute<any>();
  const navigation  = useNavigation<any>();
  const { book_id, order_id } = params;
  const [bookInfo, setBookInfo] = useState<any>(null);
  const [rating, setRating]   = useState(5);
  const [comment, setComment] = useState("");
  const [loading, setLoading] = useState(false);
  const [focused, setFocused] = useState(false);
  const [isReviewed, setIsReviewed] = useState(false);


  const loadMyReview = async () => {
    try {
      if (!book_id || !order_id) return;

      const token = await AsyncStorage.getItem("token");
      if (!token) return;

      const res = await api.get(
          `/reviews/my-review?book_id=${book_id}&order_id=${order_id}`,
          {
            headers: { Authorization: `Bearer ${token}` },
          }
      );

      if (res.data?.reviewed) {
        setRating(res.data.rating);
        setComment(res.data.comment || "");
        setIsReviewed(true);
      }
    } catch (err) {
      console.log("LOAD MY REVIEW ERROR:", err);
    }
  };

  const loadBookInfo = async () => {
    try {
      if (!book_id) return;

      const res = await api.get(`/books/${book_id}`);
      setBookInfo(res.data);
    } catch (err) {
      console.log("LOAD BOOK INFO ERROR:", err);
    }
  };

  console.log("BOOK INFO:", bookInfo);

  useEffect(() => {
    loadBookInfo();
    loadMyReview();
  }, []);


  // ==========================
  // API LOGIC (unchanged)
  // ==========================
  const sendReview = async () => {
    setLoading(true);
    try {
      const token = await AsyncStorage.getItem("token");
      console.log("REVIEW TOKEN:", token);
      console.log("REVIEW URL:", `${api.defaults.baseURL}/reviews`);

      if (!token) {
        setLoading(false);
        Alert.alert("Lỗi", "Bạn chưa đăng nhập");
        return;
      }

      const res = await api.post(
          "/reviews",
          { book_id, order_id, rating, comment },
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
      );

      console.log("REVIEW RESPONSE:", res.data);

      let rewardMsg = "";

      if (res.data.reward.type === "points") {
        rewardMsg = "🎉 Bạn được +10 điểm tích lũy";
      } else {
        rewardMsg = "🎉 Bạn được tặng mã: " + res.data.reward.code;
      }

      Alert.alert("Thành công", `${res.data.message}\n\n${rewardMsg}`);

      navigation.goBack();
    } catch (err: any) {
      const status = err?.response?.status;
      const data = err?.response?.data;

      if (status === 409 && data?.review) {
        setRating(data.review.rating);
        setComment(data.review.comment || "");
        setIsReviewed(true);

        Alert.alert("Thông báo", "Bạn đã đánh giá sản phẩm này rồi");
        return;
      }

      Alert.alert("Lỗi", data?.message || "Có lỗi xảy ra");
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={s.safe}>
      <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

      {/* ── TOP BAR ───────────────────────────────────────────── */}
      <View style={s.topBar}>
        <View style={s.topBarBlob} />
        <TouchableOpacity style={s.backBtn} onPress={() => navigation.goBack()}>
          <Ionicons name="chevron-back" size={22} color="#FFF" />
        </TouchableOpacity>
        <Text style={s.topBarTitle}>Đánh giá sản phẩm</Text>
        <View style={{ width: 38 }} />
      </View>

      <ScrollView
        contentContainerStyle={s.scroll}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        {/* ── REWARD HINT ─────────────────────────────────────── */}
        {!isReviewed ? (
            <View style={s.rewardBanner}>
              <View style={s.rewardIconWrap}>
                <Text style={{ fontSize: 22 }}>🎁</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={s.rewardTitle}>Nhận thưởng khi đánh giá</Text>
                <Text style={s.rewardSub}>+10 điểm tích lũy hoặc mã giảm giá hấp dẫn</Text>
              </View>
            </View>
        ) : (
            <View style={s.reviewedBanner}>
              <View style={s.reviewedIconWrap}>
                <Ionicons name="checkmark-circle" size={22} color="#00AB56" />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={s.reviewedTitle}>Bạn đã đánh giá sản phẩm này</Text>
                <Text style={s.reviewedSub}>Cảm ơn bạn đã chia sẻ trải nghiệm của mình.</Text>
              </View>
            </View>
        )}

        {bookInfo && (
            <View style={s.bookCard}>
              <Image
                  source={{ uri: bookInfo.cover_image || bookInfo.picture }}
                  style={s.bookImage}
              />

              <View style={{ flex: 1 }}>
                <Text style={s.bookTitle} numberOfLines={2}>
                  {bookInfo.title}
                </Text>

                <Text style={s.bookAuthor}>
                  {bookInfo.author_name || bookInfo.author || "Chưa cập nhật tác giả"}
                </Text>

                <View style={s.priceBlock}>
                  {!!bookInfo.original_price &&
                      Number(bookInfo.original_price) > Number(bookInfo.price) && (
                          <View style={s.oldPriceRow}>
                            <Text style={s.oldPrice}>
                              {Number(bookInfo.original_price).toLocaleString("vi-VN")}đ
                            </Text>

                            <View style={s.discountBadge}>
                              <Text style={s.discountBadgeTxt}>
                                -
                                {Math.round(
                                    ((Number(bookInfo.original_price) - Number(bookInfo.price)) /
                                        Number(bookInfo.original_price)) *
                                    100
                                )}
                                %
                              </Text>
                            </View>
                          </View>
                      )}

                  <Text style={s.bookPriceVip}>
                    {typeof bookInfo.price !== "undefined"
                        ? Number(bookInfo.price).toLocaleString("vi-VN") + "đ"
                        : "Đang cập nhật"}
                  </Text>
                </View>
              </View>
            </View>
        )}

        {/* ── STAR RATING CARD ────────────────────────────────── */}
        <View style={s.card}>
          <Text style={s.cardLabel}>Chất lượng sản phẩm</Text>

          {/* Stars */}
          <View style={s.starRow}>
            {[1, 2, 3, 4, 5].map(star => (
              <TouchableOpacity
                key={star}
                onPress={() => !isReviewed && setRating(star)}
                activeOpacity={0.7}
                style={s.starBtn}
              >
                <Text style={[s.starChar, { color: rating >= star ? C.star : C.starOff }]}>
                  ★
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Star label */}
          <View style={[s.starLabelWrap, { backgroundColor: STAR_COLORS[rating] + "18" }]}>
            <Text style={[s.starLabelTxt, { color: STAR_COLORS[rating] }]}>
              {STAR_LABELS[rating]}
            </Text>
          </View>

          {/* 5 dot indicators */}
          <View style={s.dotRow}>
            {[1,2,3,4,5].map(i => (
              <View
                key={i}
                style={[
                  s.dot,
                  i <= rating && { backgroundColor: STAR_COLORS[rating], transform: [{ scale: 1.2 }] }
                ]}
              />
            ))}
          </View>
        </View>

        {/* ── COMMENT CARD ────────────────────────────────────── */}
        <View style={s.card}>
          <Text style={s.cardLabel}>Nhận xét của bạn</Text>
          <TextInput
              editable={!isReviewed}
            style={[s.textarea, focused && s.textareaFocused]}
            placeholder="Chia sẻ trải nghiệm của bạn về cuốn sách này..."
            placeholderTextColor={C.text3}
            multiline
            value={comment}
            onChangeText={setComment}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            textAlignVertical="top"
          />
          <Text style={s.charCount}>{comment.length} ký tự</Text>
        </View>

        {/* ── TIPS ─────────────────────────────────────────────── */}
        <View style={s.tipsCard}>
          <Text style={s.tipsTitle}>💡 Gợi ý viết đánh giá hay</Text>
          {[
            "Nội dung, chủ đề và cốt truyện có thú vị không?",
            "Cách trình bày, dịch thuật có dễ hiểu không?",
            "Bạn có giới thiệu cuốn sách này cho bạn bè không?",
          ].map((tip, i) => (
            <View key={i} style={s.tipRow}>
              <View style={s.tipDot} />
              <Text style={s.tipTxt}>{tip}</Text>
            </View>
          ))}
        </View>

        {/* ── SUBMIT ──────────────────────────────────────────── */}
        <TouchableOpacity
            style={[s.submitBtn, (loading || isReviewed) && s.submitBtnLoading]}
            onPress={sendReview}
            disabled={loading || isReviewed}
            activeOpacity={0.85}
        >
          {loading ? (
              <Text style={s.submitBtnTxt}>Đang gửi...</Text>
          ) : (
              <>
                <Ionicons name="send-outline" size={18} color="#FFF" />
                <Text style={s.submitBtnTxt}>
                  {isReviewed ? "Đã đánh giá" : "Gửi đánh giá"}
                </Text>
              </>
          )}
        </TouchableOpacity>

        <View style={{ height: 20 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: C.bg },

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

  scroll: { padding: 16, gap: 14 },

  // ── Reward banner
  rewardBanner: {
    backgroundColor: C.primarySoft,
    borderRadius: 18, padding: 16,
    flexDirection: "row", alignItems: "center", gap: 14,
    borderWidth: 1, borderColor: C.primaryTint,
  },
  rewardIconWrap: {
    width: 44, height: 44, borderRadius: 22,
    backgroundColor: C.surface,
    justifyContent: "center", alignItems: "center",
  },
  rewardTitle: { fontSize: 14, fontWeight: "800", color: C.text1, marginBottom: 3 },
  rewardSub:   { fontSize: 12, color: C.text2, lineHeight: 18 },

  // ── Card
  card: {
    backgroundColor: C.surface, borderRadius: 20, padding: 18,
    elevation: 2,
    shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08, shadowRadius: 8,
    gap: 14,
  },
  cardLabel: { fontSize: 15, fontWeight: "800", color: C.text1 },

  // Stars
  starRow: { flexDirection: "row", justifyContent: "center", gap: 6 },
  starBtn: { padding: 4 },
  starChar: { fontSize: 44 },

  starLabelWrap: {
    alignSelf: "center", borderRadius: 20,
    paddingHorizontal: 20, paddingVertical: 6,
  },
  starLabelTxt: { fontSize: 15, fontWeight: "800" },

  dotRow: { flexDirection: "row", justifyContent: "center", gap: 8 },
  dot: {
    width: 8, height: 8, borderRadius: 4,
    backgroundColor: C.border,
  },

  // Textarea
  textarea: {
    height: 120,
    backgroundColor: C.bg,
    borderWidth: 1.5, borderColor: C.border,
    borderRadius: 14, padding: 14,
    fontSize: 14, color: C.text1,
    lineHeight: 22,
  },
  textareaFocused: {
    borderColor: C.primaryMid,
    backgroundColor: C.primarySoft,
  },
  charCount: {
    textAlign: "right", fontSize: 12, color: C.text3,
    marginTop: -6,
  },

  // Tips
  tipsCard: {
    backgroundColor: C.surface, borderRadius: 20, padding: 16,
    gap: 10,
    borderWidth: 1, borderColor: C.border,
  },
  tipsTitle: { fontSize: 13, fontWeight: "700", color: C.text2 },
  tipRow:    { flexDirection: "row", alignItems: "flex-start", gap: 10 },
  tipDot:    {
    width: 6, height: 6, borderRadius: 3,
    backgroundColor: C.primaryMid, marginTop: 6, flexShrink: 0,
  },
  tipTxt:    { flex: 1, fontSize: 13, color: C.text3, lineHeight: 20 },

  // Submit
  submitBtn: {
    flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8,
    backgroundColor: C.primaryMid, borderRadius: 16, paddingVertical: 17,
    elevation: 5,
    shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.30, shadowRadius: 12,
  },
  submitBtnLoading: { backgroundColor: C.text3, elevation: 0, shadowOpacity: 0 },
  submitBtnTxt:     { color: "#FFF", fontSize: 16, fontWeight: "800" },
  bookCard: {
    backgroundColor: C.surface,
    borderRadius: 20,
    padding: 14,
    flexDirection: "row",
    gap: 12,
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#E8EEF9",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
  bookImage: {
    width: 78,
    height: 112,
    borderRadius: 12,
    backgroundColor: C.bg,
  },
  bookTitle: {
    fontSize: 15,
    fontWeight: "800",
    color: C.text1,
    marginBottom: 4,
  },
  bookAuthor: {
    fontSize: 13,
    color: C.text2,
    marginBottom: 6,
  },
  bookPrice: {
    fontSize: 15,
    fontWeight: "800",
    color: C.primaryMid,
  },
  priceBlock: {
    marginTop: 4,
    gap: 4,
  },

  oldPriceRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    flexWrap: "wrap",
  },

  oldPrice: {
    fontSize: 13,
    color: C.text3,
    textDecorationLine: "line-through",
  },

  discountBadge: {
    backgroundColor: "#FFE8E6",
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 999,
    alignSelf: "flex-start",
  },

  discountBadgeTxt: {
    color: "#E53935",
    fontSize: 12,
    fontWeight: "800",
  },

  bookPriceVip: {
    fontSize: 20,
    fontWeight: "900",
    color: "#E53935",
    letterSpacing: 0.2,
  },
  reviewedBanner: {
    backgroundColor: "#E9F8F0",
    borderRadius: 18,
    padding: 16,
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    borderWidth: 1,
    borderColor: "#BFE8CF",
  },

  reviewedIconWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: "#FFFFFF",
    justifyContent: "center",
    alignItems: "center",
  },

  reviewedTitle: {
    fontSize: 14,
    fontWeight: "800",
    color: "#0D1B3E",
    marginBottom: 3,
  },

  reviewedSub: {
    fontSize: 12,
    color: "#4A5980",
    lineHeight: 18,
  },
});