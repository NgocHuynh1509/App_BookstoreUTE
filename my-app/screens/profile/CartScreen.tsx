import React, { useState, useCallback, useEffect } from "react"; // Thêm useEffect vào đây
import {
  View, Text, Image, TouchableOpacity, StyleSheet,
  ScrollView, RefreshControl, ActivityIndicator, Alert,
  StatusBar, Platform,
} from "react-native";
import { Swipeable, GestureHandlerRootView } from "react-native-gesture-handler";
import { Ionicons } from "@expo/vector-icons";
import Constants from "expo-constants";
import { useFocusEffect, useNavigation } from "@react-navigation/native";
import axios from "axios";
import { useAuth } from "../../hooks/useAuth";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { CommonActions } from "@react-navigation/native";

const API_URL = Constants.expoConfig?.extra?.API_URL;

const C = {
  primary:     "#1565C0",
  primaryMid:  "#1E88E5",
  primarySoft: "#E3F2FD",
  primaryTint: "#BBDEFB",
  bg:          "#F0F6FF",
  surface:     "#FFFFFF",
  border:      "#DDEEFF",
  sale:        "#E53935",
  text1:       "#0D1B3E",
  text2:       "#4A5980",
  text3:       "#9AA8C8",
};

export default function CartScreen() {
  const { user, loadUser } = useAuth(); // loadUser lấy từ hook của bạn
  const navigation = useNavigation<any>();

  const [cartItems, setCartItems] = useState<any[]>([]);
  const [selectedItems, setSelectedItems] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // ─── FETCH DATA ──────────────────────────────────────────
  const fetchCart = async () => {
      // Quan trọng: Kiểm tra chính xác key userName (viết hoa N) như bạn đã lưu ở Login
      const currentUsername = user?.userName || user?.username;

      if (!currentUsername) {
          setLoading(false);
          setRefreshing(false);
          return;
      }

      try {
        const token = await AsyncStorage.getItem("token");
        if (!token) return;

        console.log("🚀 Fetching cart for:", currentUsername);
        const response = await axios.get(`${API_URL}/cart/${currentUsername}`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        setCartItems(response.data);
      } catch (error: any) {
        console.log("❌ Lỗi load giỏ hàng:", error.response?.status);
      } finally {
        setLoading(false);
        setRefreshing(false);
      }
  };

  // Mỗi khi màn hình được Focus, bắt buộc loadUser lại để cập nhật State
  useFocusEffect(
    useCallback(() => {
      loadUser();
    }, [])
  );

  // Khi state 'user' đã có dữ liệu từ loadUser, mới bắt đầu gọi fetchCart
  useEffect(() => {
      if (user) {
          fetchCart();
      }
  }, [user]);

  // Logic pull to refresh
  const onRefresh = () => {
    setRefreshing(true);
    fetchCart();
  };

  // ─── LOGIC HANDLERS (Giữ nguyên các hàm bổ trợ của bạn) ───
  const toggleSelect = (id: string) =>
    setSelectedItems(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );

  const toggleSelectAll = () =>
    setSelectedItems(
      selectedItems.length === cartItems.length ? [] : cartItems.map(i => i.id)
    );

  const updateQuantity = async (cartItemId: string, currentQty: number, delta: number) => {
    const newQty = currentQty + delta;
    if (newQty < 1) return;

    const item = cartItems.find(i => i.id === cartItemId);
    if (delta > 0 && item && newQty > item.stock) {
        Alert.alert("Thông báo", "Số lượng vượt quá tồn kho");
        return;
    }

    try {
        const token = await AsyncStorage.getItem("token");
        const currentUsername = user?.userName || user?.username; // Lấy diemngoc

        await axios.put(
          `${API_URL}/cart/update-quantity`,
          {
            cartItemId: cartItemId,
            quantity: newQty,
            username: currentUsername // Gửi kèm username lên để Backend khỏi tìm đâu xa
          },
          { headers: { Authorization: `Bearer ${token}` } }
        );

        setCartItems(prev =>
          prev.map(item => item.id === cartItemId ? { ...item, quantity: newQty } : item)
        );
      } catch (err) {
        console.log("❌ Lỗi cập nhật:", err.response?.data);
        Alert.alert("Lỗi", "Không thể cập nhật số lượng");
      }
  };

  const removeItem = async (cartItemId: string) => {
    Alert.alert("Xác nhận", "Xóa sản phẩm này khỏi giỏ hàng?", [
      { text: "Hủy" },
      {
        text: "Xóa",
        style: "destructive",
        onPress: async () => {
          try {
            const token = await AsyncStorage.getItem("token");
            const currentUsername = user?.userName || user?.username;

            // Gửi kèm username dưới dạng query parameter (?username=diemngoc)
            await axios.delete(`${API_URL}/cart/remove/${cartItemId}?username=${currentUsername}`, {
              headers: { Authorization: `Bearer ${token}` },
            });

            // Cập nhật UI local sau khi xóa thành công
            setCartItems(prev => prev.filter(i => i.id !== cartItemId));
            setSelectedItems(prev => prev.filter(id => id !== cartItemId));

          } catch (err) {
            console.log("❌ Lỗi xóa:", err.response?.data);
            Alert.alert("Lỗi", "Không thể xóa sản phẩm");
          }
        },
      },
    ]);
  };

  const calculateTotal = () =>
    cartItems
      .filter(item => selectedItems.includes(item.id))
      .reduce((sum, item) => sum + (item.price * item.quantity), 0);

  const handleGoToCheckout = () => {
    if (selectedItems.length === 0) {
      Alert.alert("Thông báo", "Vui lòng chọn sản phẩm để thanh toán");
      return;
    }
    const selectedFullItems = cartItems.filter(item => selectedItems.includes(item.id));
    navigation.navigate("Checkout", {
      selectedItems: selectedFullItems,
      totalPrice: calculateTotal(),
    });
  };

  const renderRightActions = (id: string) => (
    <TouchableOpacity style={s.deleteAction} onPress={() => removeItem(id)}>
      <Ionicons name="trash-outline" size={24} color="#fff" />
      <Text style={s.deleteActionTxt}>Xóa</Text>
    </TouchableOpacity>
  );

  if (loading && !refreshing) {
    return (
      <View style={[s.container, { justifyContent: "center" }]}>
        <ActivityIndicator size="large" color={C.primaryMid} />
      </View>
    );
  }

  const allSelected = cartItems.length > 0 && selectedItems.length === cartItems.length;

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <View style={s.container}>
        <StatusBar barStyle="light-content" />

        <View style={s.header}>
          <View style={s.headerTop}>
            <View>
              <Text style={s.headerTitle}>Giỏ hàng</Text>
              <Text style={s.headerSub}>{cartItems.length} sản phẩm</Text>
            </View>
            <TouchableOpacity style={s.selectAllBtn} onPress={toggleSelectAll}>
              <Ionicons
                name={allSelected ? "checkbox" : "square-outline"}
                size={18}
                color="#FFF"
              />
              <Text style={s.selectAllTxt}>Tất cả</Text>
            </TouchableOpacity>
          </View>
        </View>

        <ScrollView
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          contentContainerStyle={{ paddingBottom: 150 }}
        >
          {cartItems.length === 0 ? (
            <View style={s.emptyBox}>
              <Ionicons name="cart-outline" size={80} color={C.primaryTint} />
              <Text style={s.emptyTitle}>Giỏ hàng trống</Text>
              <TouchableOpacity
                  style={s.emptyBtn}
                  onPress={() =>
                      navigation.dispatch(
                          CommonActions.reset({
                            index: 0,
                            routes: [
                              {
                                name: "MainTabs",
                                params: { screen: "HomeTab" },
                              },
                            ],
                          })
                      )
                  }
              >
                <Text style={s.emptyBtnTxt}>Tiếp tục mua sắm</Text>
              </TouchableOpacity>
            </View>
          ) : (
            cartItems.map(item => (
              <Swipeable key={item.id} renderRightActions={() => renderRightActions(item.id)}>
                <View style={s.card}>
                  <TouchableOpacity onPress={() => toggleSelect(item.id)} style={s.checkboxWrap}>
                    <View style={[s.checkbox, selectedItems.includes(item.id) && s.checkboxActive]}>
                      {selectedItems.includes(item.id) && <Ionicons name="checkmark" size={14} color="#FFF" />}
                    </View>
                  </TouchableOpacity>

                  <Image
                    source={{ uri: item.cover_image?.startsWith('http') ? item.cover_image : `${API_URL}/uploads/${item.cover_image}` }}
                    style={s.cover}
                  />

                  <View style={s.info}>
                    <Text style={s.bookTitle} numberOfLines={2}>{item.title}</Text>
                    <Text style={s.bookPrice}>{Number(item.price).toLocaleString("vi-VN")}đ</Text>

                    <View style={s.qtyRow}>
                      <TouchableOpacity style={s.qtyBtn} onPress={() => updateQuantity(item.id, item.quantity, -1)}>
                        <Text style={s.qtyBtnTxt}>−</Text>
                      </TouchableOpacity>
                      <Text style={s.qtyVal}>{item.quantity}</Text>
                      <TouchableOpacity style={s.qtyBtn} onPress={() => updateQuantity(item.id, item.quantity, 1)}>
                        <Text style={s.qtyBtnTxt}>+</Text>
                      </TouchableOpacity>
                    </View>
                  </View>
                </View>
              </Swipeable>
            ))
          )}
        </ScrollView>

        {cartItems.length > 0 && (
          <View style={s.footer}>
            <View style={s.footerSummary}>
              <Text style={s.footerLabel}>Tổng cộng:</Text>
              <Text style={s.footerPrice}>{calculateTotal().toLocaleString("vi-VN")}đ</Text>
            </View>
            <TouchableOpacity
                style={[s.checkoutBtn, selectedItems.length === 0 && s.checkoutBtnDisabled]}
                onPress={handleGoToCheckout}
                disabled={selectedItems.length === 0}
            >
              <Text style={s.checkoutTxt}>Thanh toán ({selectedItems.length})</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    </GestureHandlerRootView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },
  header: { backgroundColor: C.primaryMid, padding: 20, paddingTop: 50, borderBottomLeftRadius: 25, borderBottomRightRadius: 25 },
  headerTop: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  headerTitle: { fontSize: 24, fontWeight: "bold", color: "#FFF" },
  headerSub: { color: "rgba(255,255,255,0.8)" },
  selectAllBtn: { flexDirection: "row", alignItems: "center", gap: 5 },
  selectAllTxt: { color: "#FFF", fontWeight: "600" },
  card: { flexDirection: "row", backgroundColor: "#FFF", marginHorizontal: 16, marginTop: 12, padding: 12, borderRadius: 15, alignItems: "center" },
  checkboxWrap: { marginRight: 10 },
  checkbox: { width: 22, height: 22, borderRadius: 5, borderWidth: 2, borderColor: C.primaryTint, justifyContent: "center", alignItems: "center" },
  checkboxActive: { backgroundColor: C.primaryMid, borderColor: C.primaryMid },
  cover: { width: 70, height: 100, borderRadius: 8 },
  info: { flex: 1, marginLeft: 12 },
  bookTitle: { fontSize: 15, fontWeight: "bold", color: C.text1 },
  bookPrice: { color: C.primaryMid, fontWeight: "800", marginVertical: 5 },
  qtyRow: { flexDirection: "row", alignItems: "center", backgroundColor: C.bg, alignSelf: "flex-start", borderRadius: 8 },
  qtyBtn: { padding: 8, width: 35, alignItems: "center" },
  qtyBtnTxt: { fontSize: 18, fontWeight: "bold", color: C.primaryMid },
  qtyVal: { paddingHorizontal: 10, fontWeight: "bold" },
  deleteAction: { backgroundColor: C.sale, justifyContent: "center", alignItems: "center", width: 80, marginTop: 12, borderRadius: 15, marginRight: 16 },
  deleteActionTxt: { color: "#FFF", fontSize: 12, fontWeight: "bold" },
  footer: { position: "absolute", bottom: 0, width: "100%", backgroundColor: "#FFF", padding: 20, borderTopWidth: 1, borderColor: C.border },
  footerSummary: { flexDirection: "row", justifyContent: "space-between", marginBottom: 15 },
  footerLabel: { fontSize: 16, color: C.text2 },
  footerPrice: { fontSize: 20, fontWeight: "bold", color: C.sale },
  checkoutBtn: { backgroundColor: C.primaryMid, padding: 15, borderRadius: 12, alignItems: "center" },
  checkoutBtnDisabled: { backgroundColor: C.text3 },
  checkoutTxt: { color: "#FFF", fontWeight: "bold", fontSize: 16 },
  emptyBox: { alignItems: "center", marginTop: 100 },
  emptyTitle: { fontSize: 18, color: C.text3, marginVertical: 20 },
  emptyBtn: { backgroundColor: C.primaryMid, padding: 12, borderRadius: 10 },
  emptyBtnTxt: { color: "#FFF", fontWeight: "bold" }
});