import {
  View, Text, TextInput, TouchableOpacity,
  FlatList, Image, ScrollView, StyleSheet,
  StatusBar, Platform, ActivityIndicator,
} from "react-native";
import { useEffect, useState } from "react";
import { Ionicons } from "@expo/vector-icons";
import api from "../services/api";

// ─── Palette ──────────────────────────────────────────────────────────────────
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

  // Văn bản chính: Nâu đen đậm (Hợp với đỏ hơn là xanh đen cũ)
  text1:       "#2D0A0A",

  // Văn bản phụ: Xám đỏ trung tính
  text2:       "#6D5B5B",

  // Văn bản mờ, ghi chú hoặc icon nền
  text3:       "#AFA0A0",

  // Màu Sale: Giữ đỏ tươi rực rỡ để kích thích mua hàng
  sale:        "#E53935",
};

// ─── Sort options ─────────────────────────────────────────────────────────────
const SORT_OPTIONS = [
  { key: "relevant",   label: "Phù hợp nhất",   icon: "sparkles-outline" },
  { key: "low-high",   label: "Giá thấp → cao", icon: "trending-up-outline" },
  { key: "high-low",   label: "Giá cao → thấp", icon: "trending-down-outline" },
  { key: "newest",     label: "Mới nhất",       icon: "calendar-outline" },
  { key: "bestseller", label: "Bán chạy nhất",  icon: "flame-outline" },
];

// ─── Helpers ──────────────────────────────────────────────────────────────────
const getBookImage = (item: any) =>
    item.cover_image || item.imageUrl || item.image || "https://via.placeholder.com/300x450?text=No+Image";

const getBookAuthor = (item: any) =>
    item.author_name || item.author || "Không rõ tác giả";

const getBookPrice = (item: any) => Number(item.price || 0);

const getBookId = (item: any) =>
    item.id || item.bookId;

function normalizeRecommendItem(item: any) {
  return {
    id: item.id ?? item.bookId,
    bookId: item.bookId ?? item.id,
    title: item.title ?? "",
    author_name: item.author_name ?? item.author ?? "Không rõ tác giả",
    cover_image: item.cover_image ?? item.imageUrl ?? item.image ?? "",
    price: Number(item.price ?? 0),
    score: Number(item.score ?? 0),
    isRecommended: true,
  };
}

// ─── Book card ────────────────────────────────────────────────────────────────
function BookCard({ item, onPress }: any) {
  const image = item.cover_image || item.imageUrl || item.image || "https://via.placeholder.com/300x450?text=No+Image";
  const author = item.author_name || item.author || "Không rõ";
  const price = Number(item.price || 0);
  const originalPrice = Number(item.original_price || 0);
  const hasDiscount = originalPrice > price;

  return (
      <TouchableOpacity style={s.cardG} onPress={onPress} activeOpacity={0.85}>
        <View style={{ position: "relative" }}>
          <Image source={{ uri: image }} style={s.cardGImg} resizeMode="cover" />

          {hasDiscount && (
              <View style={s.discountBadge}>
                <Text style={s.discountBadgeTxt}>
                  -{Math.round(((originalPrice - price) / originalPrice) * 100)}%
                </Text>
              </View>
          )}
        </View>

        <View style={s.cardGBody}>
          <Text style={s.cardGTitle} numberOfLines={2}>
            {item.title}
          </Text>

          <Text style={s.cardGAuthor} numberOfLines={1}>
            {author}
          </Text>

          <Text style={s.cardGPrice}>
            {price.toLocaleString("vi-VN")}đ
          </Text>

          {hasDiscount && (
              <Text style={s.cardGOldPrice}>
                {originalPrice.toLocaleString("vi-VN")}đ
              </Text>
          )}

          {item.score !== undefined && item.score > 0 && (
              <Text style={s.bookScore}>
                Tương đồng: {(Number(item.score) * 100).toFixed(1)}%
              </Text>
          )}
        </View>
      </TouchableOpacity>
  );
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────
export default function SearchResultScreen({ route, navigation }: any) {
  const {
    keyword: routeKeyword = "",
    bookId: routeBookId = "",
    mode: routeMode = "search",
  } = route.params || {};

  const [searchText, setSearchText]             = useState(routeKeyword);
  const [books, setBooks]                       = useState<any[]>([]);
  const [loading, setLoading]                   = useState(false);
  const [sort, setSort]                         = useState("relevant");
  const [showSortDropdown, setShowSortDropdown] = useState(false);
  const [mode, setMode]                         = useState(routeMode);
  const [selectedBookId, setSelectedBookId]     = useState(routeBookId);

  // const loadData = async () => {
  //   setLoading(true);
  //   try {
  //     let data: any[] = [];
  //
  //     if (mode === "recommend" && selectedBookId) {
  //       const res = await api.get(`/api/recommend/${selectedBookId}`);
  //
  //       const raw = typeof res.data === "string"
  //           ? JSON.parse(res.data)
  //           : res.data;
  //
  //       if (!Array.isArray(raw)) {
  //         setBooks([]);
  //         return;
  //       }
  //
  //       const detailList = await Promise.all(
  //           raw.map(async (item: any) => {
  //             try {
  //               const detail = await api.get(`/books/${item.bookId}`);
  //               return {
  //                 ...detail.data,
  //                 score: item.score,
  //               };
  //             } catch (err) {
  //               console.log("Lỗi load book:", item.bookId, err);
  //               return null;
  //             }
  //           })
  //       );
  //
  //       data = detailList.filter(Boolean);
  //     } else {
  //       const res = await api.get("/books/search", {
  //         params: { keyword: searchText.trim() },
  //       });
  //
  //       data = Array.isArray(res.data) ? [...res.data] : [];
  //     }
  //
  //     if (sort === "low-high") {
  //       data.sort((a, b) => getBookPrice(a) - getBookPrice(b));
  //     }
  //     if (sort === "high-low") {
  //       data.sort((a, b) => getBookPrice(b) - getBookPrice(a));
  //     }
  //     if (sort === "newest") {
  //       data.sort((a, b) => String(getBookId(b)).localeCompare(String(getBookId(a))));
  //     }
  //
  //     setBooks(data);
  //   } catch (err) {
  //     console.log("Lỗi load search result:", err);
  //     setBooks([]);
  //   } finally {
  //     setLoading(false);
  //   }
  // };

  const loadData = async () => {
    setLoading(true);
    try {
      let data: any[] = [];

      if (mode === "recommend" && selectedBookId) {
        const res = await api.get(`/api/recommend/${selectedBookId}`);

        const raw = typeof res.data === "string"
            ? JSON.parse(res.data)
            : res.data;

        if (!Array.isArray(raw)) {
          setBooks([]);
          return;
        }

        const detailList = await Promise.all(
            raw.map(async (item: any) => {
              try {
                const detail = await api.get(`/books/${item.bookId}`);
                return {
                  ...detail.data,
                  score: item.score,
                };
              } catch (err) {
                console.log("Lỗi load book:", item.bookId, err);
                return null;
              }
            })
        );

        data = detailList.filter(Boolean);
      } else {
        const keyword = searchText.trim();

        if (!keyword) {
          setBooks([]);
          return;
        }

        const res = await api.get("/books/search", {
          params: { keyword },
        });

        data = Array.isArray(res.data) ? [...res.data] : [];
      }

      if (sort === "low-high") {
        data.sort((a, b) => getBookPrice(a) - getBookPrice(b));
      }
      if (sort === "high-low") {
        data.sort((a, b) => getBookPrice(b) - getBookPrice(a));
      }
      if (sort === "newest") {
        data.sort((a, b) => String(getBookId(b)).localeCompare(String(getBookId(a))));
      }

      setBooks(data);
    } catch (err) {
      console.log("Lỗi load search result:", err);
      setBooks([]);
    } finally {
      setLoading(false);
    }
  };

  const handleManualSearch = () => {
    const keyword = searchText.trim();
    if (!keyword) return;

    setMode("search");
    setSelectedBookId("");
  };

  // cập nhật khi params đổi
  useEffect(() => {
    setSearchText(routeKeyword || "");
    setSelectedBookId(routeBookId || "");
    setMode(routeMode || "search");
  }, [routeKeyword, routeBookId, routeMode]);

  useEffect(() => {
    loadData();
  }, [searchText, sort, selectedBookId, mode]);

  // const handleManualSearch = () => {
  //   if (!searchText.trim()) return;
  //   setMode("search");
  //   setSelectedBookId("");
  //   loadData();
  // };

  const activeSort = SORT_OPTIONS.find(x => x.key === sort);

  return (
      <View style={s.container}>
        <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

        <View style={s.header}>
          <View style={s.headerBlob} />

          <View style={s.headerTop}>
            <TouchableOpacity
                style={s.backBtn}
                onPress={() => navigation.canGoBack() && navigation.goBack()}
            >
              <Ionicons name="chevron-back" size={22} color="#FFF" />
            </TouchableOpacity>

            <TouchableOpacity
                style={s.searchBar}
                activeOpacity={0.85}
                onPress={() =>
                    navigation.navigate("SearchScreen", {
                      keyword: searchText,
                    })
                }
            >
              <Ionicons name="search-outline" size={17} color={C.primaryMid} />

              <Text
                  style={[s.searchInput, { color: searchText ? C.text1 : C.text3 }]}
                  numberOfLines={1}
                  ellipsizeMode="tail"
              >
                {searchText || "Tìm tên sách, tác giả..."}
              </Text>

              {searchText.length > 0 && (
                  <Ionicons name="chevron-forward" size={16} color={C.text3} />
              )}
            </TouchableOpacity>

            <TouchableOpacity style={s.goBtn} onPress={handleManualSearch}>
              <Ionicons name="arrow-forward" size={18} color="#FFF" />
            </TouchableOpacity>
          </View>
        </View>

        <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={s.scroll}>
          <View style={s.filterBar}>
            <View>
              <View style={{ flexDirection: "row", alignItems: "baseline", gap: 4 }}>
                <Text style={s.resultNum}>{books.length}</Text>
                <Text style={s.resultLabel}>kết quả</Text>
              </View>

              <Text style={s.modeText}>
                {mode === "recommend"
                    ? "Gợi ý sách tương tự"
                    : `Kết quả tìm kiếm cho "${searchText}"`}
              </Text>
            </View>

            <View>
              <TouchableOpacity
                  style={[s.sortBtn, showSortDropdown && s.sortBtnActive]}
                  onPress={() => setShowSortDropdown(v => !v)}
                  activeOpacity={0.85}
              >
                <Ionicons
                    name={activeSort?.icon as any}
                    size={13}
                    color={showSortDropdown ? "#FFF" : C.primaryMid}
                />
                <Text style={[s.sortBtnTxt, showSortDropdown && { color: "#FFF" }]}>
                  {activeSort?.label}
                </Text>
                <Ionicons
                    name={showSortDropdown ? "chevron-up" : "chevron-down"}
                    size={13}
                    color={showSortDropdown ? "#FFF" : C.primaryMid}
                />
              </TouchableOpacity>

              {showSortDropdown && (
                  <View style={s.dropdown}>
                    {SORT_OPTIONS.map((op, idx) => {
                      const active = op.key === sort;
                      return (
                          <TouchableOpacity
                              key={op.key}
                              style={[
                                s.dropdownItem,
                                active && s.dropdownItemActive,
                                idx === SORT_OPTIONS.length - 1 && { borderBottomWidth: 0 },
                              ]}
                              onPress={() => {
                                setSort(op.key);
                                setShowSortDropdown(false);
                              }}
                          >
                            <Ionicons name={op.icon as any} size={14} color={active ? C.primaryMid : C.text3} />
                            <Text style={[s.dropdownTxt, active && s.dropdownTxtActive]}>{op.label}</Text>
                            {active && (
                                <Ionicons
                                    name="checkmark"
                                    size={14}
                                    color={C.primaryMid}
                                    style={{ marginLeft: "auto" as any }}
                                />
                            )}
                          </TouchableOpacity>
                      );
                    })}
                  </View>
              )}
            </View>
          </View>

          {loading ? (
              <View style={s.centerBox}>
                <ActivityIndicator size="large" color={C.primaryMid} />
                <Text style={{ color: C.text3, marginTop: 10, fontSize: 14 }}>
                  {mode === "recommend" ? "Đang tải gợi ý..." : "Đang tìm kiếm..."}
                </Text>
              </View>
          ) : books.length === 0 ? (
              <View style={s.centerBox}>
                <View style={s.emptyIconWrap}>
                  <Ionicons name="search-outline" size={44} color={C.primaryTint} />
                </View>
                <Text style={s.emptyTitle}>
                  {mode === "recommend" ? "Không có gợi ý phù hợp" : "Không tìm thấy kết quả"}
                </Text>
                <Text style={s.emptySub}>
                  {mode === "recommend"
                      ? "Hiện chưa có sách tương tự cho lựa chọn này"
                      : "Thử từ khóa khác hoặc kiểm tra lại chính tả"}
                </Text>
              </View>
          ) : (
              <FlatList
                  data={books}
                  keyExtractor={(item, index) => String(getBookId(item) ?? index)}
                  numColumns={2}
                  scrollEnabled={false}
                  columnWrapperStyle={s.gridRow}
                  renderItem={({ item }) => (
                      <BookCard
                          item={item}
                          onPress={() =>
                              navigation.navigate("BookDetail", {
                                id: item.id ?? item.bookId,
                                bookId: item.bookId ?? item.id,
                              })
                          }
                      />
                  )}
              />
          )}
        </ScrollView>
      </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },

  header: {
    backgroundColor: C.primaryMid,
    paddingTop: Platform.OS === "android" ? (StatusBar.currentHeight || 0) + 10 : 52,
    paddingBottom: 18,
    paddingHorizontal: 14,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
    overflow: "hidden",
  },
  headerBlob: {
    position: "absolute",
    width: 160,
    height: 160,
    borderRadius: 80,
    backgroundColor: "rgba(255,255,255,0.08)",
    top: -50,
    right: -30,
  },
  headerTop: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  backBtn: {
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: "rgba(255,255,255,0.18)",
    justifyContent: "center",
    alignItems: "center",
    flexShrink: 0,
  },

  searchBar: {
    flexShrink: 1,
    flexGrow: 0,
    width: "100%",
    maxWidth: 220,
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: C.surface,
    borderRadius: 14,
    paddingHorizontal: 12,
    paddingVertical: 9,
    elevation: 2,
    shadowColor: C.primary,
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.10,
    shadowRadius: 4,
  },

  searchInput: {
    flex: 1,
    minWidth: 0,
    fontSize: 14,
    color: C.text1,
    paddingVertical: 0,
  },
  goBtn: {
    width: 38,
    height: 38,
    borderRadius: 14,
    backgroundColor: "rgba(255,255,255,0.22)",
    justifyContent: "center",
    alignItems: "center",
    flexShrink: 0,
  },

  scroll: { padding: 16, paddingBottom: 30 },

  filterBar: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: 14,
  },
  resultNum:   { fontSize: 22, fontWeight: "900", color: C.text1 },
  resultLabel: { fontSize: 13, color: C.text3 },
  modeText:    { fontSize: 12, color: C.text2, marginTop: 2, maxWidth: 180 },

  sortBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 5,
    backgroundColor: C.surface,
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderWidth: 1.5,
    borderColor: C.primaryTint,
    elevation: 2,
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
  },
  sortBtnActive: { backgroundColor: C.primaryMid, borderColor: C.primaryMid },
  sortBtnTxt:    { fontSize: 13, color: C.primaryMid, fontWeight: "600" },

  dropdown: {
    position: "absolute",
    right: 0,
    top: 46,
    zIndex: 99,
    backgroundColor: C.surface,
    borderRadius: 16,
    width: 195,
    elevation: 12,
    shadowColor: C.primary,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.15,
    shadowRadius: 14,
    overflow: "hidden",
  },
  dropdownItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    paddingHorizontal: 14,
    paddingVertical: 13,
    borderBottomWidth: 1,
    borderColor: C.border,
  },
  dropdownItemActive: { backgroundColor: C.primarySoft },
  dropdownTxt:        { fontSize: 14, color: C.text2 },
  dropdownTxtActive:  { color: C.primaryMid, fontWeight: "700" },

  centerBox: { alignItems: "center", paddingTop: 60, gap: 10 },
  emptyIconWrap: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: C.primarySoft,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 4,
  },
  emptyTitle: {
    fontSize: 17,
    fontWeight: "800",
    color: C.text1,
  },
  emptySub: {
    fontSize: 14,
    color: C.text3,
    textAlign: "center",
    lineHeight: 21,
    paddingHorizontal: 24,
  },

  gridRow: {
    justifyContent: "space-between",
    gap: 12,
  },

  cardG: {
    width: "48%",
    backgroundColor: C.surface,
    borderRadius: 18,
    marginBottom: 14,
    overflow: "hidden",
    elevation: 3,
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.10,
    shadowRadius: 8,
  },

  cardGImg: {
    width: "100%",
    height: 168,
  },

  discountBadge: {
    position: "absolute",
    top: 8,
    left: 8,
    backgroundColor: C.sale,
    borderRadius: 8,
    paddingHorizontal: 8,
    paddingVertical: 3,
  },

  discountBadgeTxt: {
    color: "#FFF",
    fontSize: 11,
    fontWeight: "800",
  },

  cardGBody: {
    padding: 10,
  },

  cardGTitle: {
    fontSize: 13,
    fontWeight: "700",
    color: C.text1,
    marginBottom: 3,
    lineHeight: 18,
  },

  cardGAuthor: {
    fontSize: 11,
    color: C.text3,
    marginBottom: 5,
  },

  cardGPrice: {
    fontSize: 15,
    fontWeight: "800",
    color: C.sale,
  },

  cardGOldPrice: {
    fontSize: 11,
    color: C.text3,
    textDecorationLine: "line-through",
    marginTop: 1,
  },

  bookScore: {
    fontSize: 11,
    color: "#2E7D32",
    fontWeight: "700",
    marginTop: 4,
  },
});