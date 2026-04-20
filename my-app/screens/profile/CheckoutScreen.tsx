import React, { useState, useEffect } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  Alert, Image, Modal, SafeAreaView, ActivityIndicator,
  StatusBar, Platform, TextInput,
} from 'react-native';
import { useRoute, useNavigation, CommonActions } from '@react-navigation/native';
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";
import { useAuth } from "../../hooks/useAuth";
import { WebView } from 'react-native-webview'; // <--- Thêm dòng này
import { Dropdown } from 'react-native-element-dropdown';

const API_URL = Constants.expoConfig?.extra?.API_URL;

// ─── Palette ──────────────────────────────────────────────────────────────────
const C = {
  primary:     "#1565C0",
  primaryMid:  "#1E88E5",
  primarySoft: "#E3F2FD",
  primaryTint: "#BBDEFB",
  bg:          "#F0F6FF",
  surface:     "#FFFFFF",
  border:      "#DDEEFF",
  text1:       "#0D1B3E",
  text2:       "#4A5980",
  text3:       "#9AA8C8",
  sale:        "#E53935",
  green:       "#00897B",
  greenBg:     "#E0F2F1",
  orange:      "#F57C00",
  orangeBg:    "#FFF3E0",
};


export default function CheckoutScreen() {
  const route      = useRoute<any>();
  const navigation = useNavigation<any>();
  const { user }   = useAuth();

  const { selectedItems = [], totalPrice = 0 } = route.params || {};

  const [currentAddress, setCurrentAddress]   = useState<any>(null);
  const [allAddresses, setAllAddresses]         = useState<any[]>([]);
  const [showAddressModal, setShowAddressModal] = useState(false);
  const [loading, setLoading]                   = useState(false);
  const [paymentMethod, setPaymentMethod]       = useState('COD');
  const [currentOrderId, setCurrentOrderId] = useState(null); // <--- THÊM DÒNG NÀY NÈ MÁ

  // ── Coupon state
  const [coupon, setCoupon]           = useState("");
  const [couponData, setCouponData]   = useState<any>(null);  // data từ API khi chọn coupon
  const [couponModal, setCouponModal] = useState(false);
  const [couponList, setCouponList]   = useState<any[]>([]);

  // ── Points state
  const [userPoints, setUserPoints]   = useState(0);
  const [usedPoints, setUsedPoints]   = useState(0);
  const [pointsInput, setPointsInput] = useState("");
  const [isFocus, setIsFocus] = useState(false);
  const provinceData = [
    { label: 'Thành phố Hà Nội', value: 'Hà Nội' },
    { label: 'Thành phố Hồ Chí Minh', value: 'Hồ Chí Minh' },
    { label: 'Thành phố Hải Phòng', value: 'Hải Phòng' },
    { label: 'Thành phố Đà Nẵng', value: 'Đà Nẵng' },
    { label: 'Thành phố Cần Thơ', value: 'Cần Thơ' },
    { label: 'Thành phố Huế', value: 'Huế' },
    { label: 'Tỉnh Tuyên Quang', value: 'Tuyên Quang' },
    { label: 'Tỉnh Lào Cai', value: 'Lào Cai' },
    { label: 'Tỉnh Thái Nguyên', value: 'Thái Nguyên' },
    { label: 'Tỉnh Phú Thọ', value: 'Phú Thọ' },
    { label: 'Tỉnh Bắc Ninh', value: 'Bắc Ninh' },
    { label: 'Tỉnh Hưng Yên', value: 'Hưng Yên' },
    { label: 'Tỉnh Ninh Bình', value: 'Ninh Bình' },
    { label: 'Tỉnh Quảng Trị', value: 'Quảng Trị' },
    { label: 'Tỉnh Quảng Ngãi', value: 'Quảng Ngãi' },
    { label: 'Tỉnh Gia Lai', value: 'Gia Lai' },
    { label: 'Tỉnh Khánh Hòa', value: 'Khánh Hòa' },
    { label: 'Tỉnh Lâm Đồng', value: 'Lâm Đồng' },
    { label: 'Tỉnh Đắk Lắk', value: 'Đắk Lắk' },
    { label: 'Tỉnh Đồng Nai', value: 'Đồng Nai' },
    { label: 'Tỉnh Tây Ninh', value: 'Tây Ninh' },
    { label: 'Tỉnh Vĩnh Long', value: 'Vĩnh Long' },
    { label: 'Tỉnh Đồng Tháp', value: 'Đồng Tháp' },
    { label: 'Tỉnh Cà Mau', value: 'Cà Mau' },
    { label: 'Tỉnh An Giang', value: 'An Giang' },
    { label: 'Tỉnh Lai Châu', value: 'Lai Châu' },
    { label: 'Tỉnh Điện Biên', value: 'Điện Biên' },
    { label: 'Tỉnh Sơn La', value: 'Sơn La' },
    { label: 'Tỉnh Lạng Sơn', value: 'Lạng Sơn' },
    { label: 'Tỉnh Quảng Ninh', value: 'Quảng Ninh' },
    { label: 'Tỉnh Thanh Hóa', value: 'Thanh Hóa' },
    { label: 'Tỉnh Nghệ An', value: 'Nghệ An' },
    { label: 'Tỉnh Hà Tĩnh', value: 'Hà Tĩnh' },
    { label: 'Tỉnh Cao Bằng', value: 'Cao Bằng' },
  ];
  // State cho form địa chỉ mới
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

    useEffect(() => { fetchInitialAddress(); fetchUserPoints(); }, [user?.id]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newAddr, setNewAddr] = useState({
    recipientName: '',
    phoneNumber: '',
    province: '',
    district: '',
    ward: '',
    specificAddress: '',
    isDefault: false
  });

  const goHomeAndClearStack = () => {
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
    );
  };

  // ─── 1. HÀM LƯU ĐỊA CHỈ (GỘP & TỐI ƯU) ──────────────────────────
    const handleAddNewAddress = async () => {
      // 1. Kiểm tra đầu vào
      if (!newAddr.recipientName || !newAddr.phoneNumber || !newAddr.specificAddress || !newAddr.province) {
        Alert.alert("Thông báo", "Vui lòng điền đầy đủ các thông tin bắt buộc");
        return;
      }

      // 2. Kiểm tra User ID (Tránh lỗi 400 như trong ảnh bạn gửi)
      if (!user?.id) {
        Alert.alert("Lỗi", "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại");
        return;
      }

      setLoading(true);
      try {
        const token = await AsyncStorage.getItem('token');

        // Payload gửi đi bao gồm cả isDefault (true/false)
        const payload = {
          ...newAddr,
          customer: { customerId: user.id }
        };

        const response = await fetch(`${API_URL}/addresses/add`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(payload),
        });

        const result = await response.json();

        if (response.ok) {
          // Backend trả về savedAddressDTO trong result.data
          setCurrentAddress(result.data);

          setShowAddModal(false);

          // RESET STATE: Trở về trắng để lần sau thêm địa chỉ khác không bị dính dữ liệu cũ
          setNewAddr({
            recipientName: '',
            phoneNumber: '',
            province: '',
            district: '',
            ward: '',
            specificAddress: '',
            isDefault: false // Reset về false cho lần thêm sau
          });

          Alert.alert("Thành công", "Đã lưu địa chỉ giao hàng mới");
        } else {
          // Hiển thị lỗi từ Backend (Ví dụ: "Thiếu thông tin khách hàng")
          Alert.alert("Lỗi", result.message || "Không thể lưu địa chỉ.");
        }
      } catch (error) {
        console.error("Lỗi khi thêm địa chỉ:", error);
        Alert.alert("Lỗi", "Kết nối server thất bại");
      } finally {
        setLoading(false);
      }
    };

    const fetchInitialAddress = async () => {
      if (!user?.id) return;
      try {
        const token = await AsyncStorage.getItem('token');
        const res = await fetch(`${API_URL}/addresses/default/${user.id}`, {
          headers: { 'Authorization': `Bearer ${token}` },
        });

        const data = await res.json(); // Bây giờ parse thoải mái, không bao giờ lỗi nữa!

        if (res.ok && data) {
          setCurrentAddress(data);
        } else {
          setCurrentAddress(null);
        }
      } catch (err) {
        console.log("Lỗi tải địa chỉ:", err);
        setCurrentAddress(null);
      }
    };

    // ─── Tính Phí Vận Chuyển ────────────────────────────
    const shippingFee = (() => {
      if (!currentAddress) return 0;

      const province = (currentAddress.province || "").toLowerCase();

      // 1. Tính tổng số lượng quyển sách
      // Thêm dấu ? và giá trị mặc định để không bị crash nếu selectedItems rỗng
      const totalQuantity = (selectedItems || []).reduce((sum, item) => {
        return sum + (Number(item.quantity) || 0);
      }, 0);

      // 2. Xác định phí ship cơ bản theo khu vực
      let baseFee = 0;
      const group20k = ["đồng nai", "tây ninh", "lâm đồng", "đồng tháp", "bình dương"];

      if (province.includes("hồ chí minh") || province.includes("tphcm")) {
        baseFee = 10000;
      } else if (group20k.some(p => province.includes(p))) {
        baseFee = 20000;
      } else {
        baseFee = 30000;
      }

      // 3. Cộng thêm phí dựa trên số lượng quyển sách
      let extraFee = 0;
      if (totalQuantity > 10) {
        extraFee = 15000; // Trên 10 quyển thêm 15k
      } else if (totalQuantity > 5) {
        extraFee = 10000; // Trên 5 quyển thêm 10k
      }

      return baseFee + extraFee;
    })();


  // Load điểm hiện có của user
  const fetchUserPoints = async () => {
    if (!user?.id) return;
    try {
      const token = await AsyncStorage.getItem('token');
      const res   = await fetch(`${API_URL}/profile`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      if (res.ok && data.reward_points != null) {
        setUserPoints(data.reward_points);
      }
    } catch (err) { console.log("Lỗi fetch điểm:", err); }
  };

  const openAddressSelector = async () => {
    if (!user?.id) return;
    setLoading(true);
    try {
      const token = await AsyncStorage.getItem('token');
      const res = await fetch(`${API_URL}/addresses/user/${user.id}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        },
      });

      const data = await res.json(); // Data này là List<ShippingAddressDTO>

      if (res.ok) {
        // Data lúc này là mảng các object gọn nhẹ (id, recipientName, phoneNumber...)
        setAllAddresses(Array.isArray(data) ? data : []);
        setShowAddressModal(true);
      } else {
        Alert.alert("Thông báo", "Không tìm thấy danh sách địa chỉ");
      }
    } catch (error) {
      console.error(error);
      Alert.alert("Lỗi", "Không thể tải danh sách địa chỉ");
    } finally {
      setLoading(false);
    }
  };

  const selectAddress = (addr: any) => { setCurrentAddress(addr); setShowAddressModal(false); };

  const openCouponSelector = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      const res   = await fetch(`${API_URL}/api/coupons/available/${user.id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setCouponList(Array.isArray(data) ? data : []);
      setCouponModal(true);
    } catch { Alert.alert("Lỗi", "Không tải được danh sách coupon"); }
  };

  // Chọn coupon — lưu toàn bộ data của coupon để tính locally
  const handleSelectCoupon = (c: any) => {
    setCoupon(c.code);
    setCouponData(c);
    setCouponModal(false);
  };

  const handleRemoveCoupon = () => { setCoupon(""); setCouponData(null); };

  // Thay đổi số điểm muốn dùng
  const handlePointsChange = (val: string) => {
    const raw = Number(val.replace(/[^0-9]/g, "")) || 0;
    const capped = Math.min(raw, userPoints);       // không dùng quá số điểm có
    setPointsInput(capped > 0 ? capped.toString() : "");
    setUsedPoints(capped);
  };

  // ─── Tính giảm giá LOCALLY — không cần gọi API ────────────────────────────
  //  1 điểm = 100đ (điều chỉnh theo backend nếu khác)
  const POINT_RATE = 100;

  const discountFromCoupon = (() => {
    if (!couponData) return 0;
    if (couponData.discount_percent) {
      return Math.round(totalPrice * couponData.discount_percent / 100);
    }
    if (couponData.discount_amount) {
      return Math.min(Number(couponData.discount_amount), totalPrice);
    }
    return 0;
  })();

  const discountFromPoints  = usedPoints * POINT_RATE;
  const totalDiscount       = discountFromCoupon + discountFromPoints;
  const displayedTotal = Math.max(0, totalPrice - totalDiscount) + shippingFee;
  // Thêm state này vào đầu CheckoutScreen
  const [paymentUrl, setPaymentUrl] = useState(null);
  const [showWebView, setShowWebView] = useState(false);

  // ==========================
  // ĐẶT HÀNG — gửi thông tin coupon + điểm lên server
  // ==========================
  const handleOrder = async () => {
    if (!currentAddress) {
      Alert.alert("Thông báo", "Vui lòng chọn địa chỉ giao hàng");
      return;
    }

    setLoading(true);
    try {
      const token = await AsyncStorage.getItem('token');
      const isBuyNow = route.params?.isBuyNow || false;

      // 1. Rẽ nhánh Endpoint
      const endpoint = isBuyNow
        ? `${API_URL}/api/orders/buy-now`
        : `${API_URL}/api/orders/create`;

      // 2. Tạo Payload riêng biệt
      let payload = {};
      if (isBuyNow) {
        payload = {
          user_id: user?.id,
          shipping_address_id: currentAddress.id,
          items: selectedItems.map(it => ({
            book_id: it.book_id,
            quantity: Number(it.quantity) || 1,
            price: Number(it.price) || 0
          })),
            // --- BỔ SUNG CÁC CỘT TIỀN MỚI ---
                    shipping_fee: shippingFee, // Hiện tại má đang để Free ship
                    voucher_discount: Number(discountFromCoupon) || 0,
                    points_discount_amount: Number(discountFromPoints) || 0,
          total_price: Number(totalPrice) || 0,
          discount_points: Number(usedPoints) || 0,
          discount_coupon: coupon || "",
          final_total: Number(displayedTotal) || 0,
          payment_method: paymentMethod,
          address: currentAddress.addressString || ""
        };
      } else {
        payload = {
            // --- BỔ SUNG CÁC CỘT TIỀN MỚI ---
                    shipping_fee: shippingFee, // Hiện tại má đang để Free ship
                    voucher_discount: Number(discountFromCoupon) || 0,
                    points_discount_amount: Number(discountFromPoints) || 0,
          user_id: user?.id,
          shipping_address_id: currentAddress.id,
          items: selectedItems,
          total_price: totalPrice,
          discount_points: usedPoints,
          discount_coupon: coupon,
          final_total: displayedTotal,
          payment_method: paymentMethod,
          isFromCart: route.params?.isFromCart ?? true,
        };
      }

      console.log("🚀 GỌI API:", endpoint);

      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload),
      });

      const data = await res.json();

      if (res.ok && data.success) {
          // LƯU LẠI ORDER ID ĐỂ TÍ NỮA DÙNG TRONG WEBVIEW
                  setCurrentOrderId(data.orderId); // <--- THÊM DÒNG NÀY
        // 3. Xử lý sau khi gọi API thành công
        if (paymentMethod === 'VNPAY' && data.vnpayUrl) {
          // Lưu URL và mở WebView (Nhớ khai báo 2 state này ở đầu Component nhen)
          setPaymentUrl(data.vnpayUrl);
          setShowWebView(true);
        } else {
          // Thanh toán COD thành công
          Alert.alert("✅ Thành công", "Đơn hàng của bạn đã được đặt thành công!", [
            { text: "OK", onPress: goHomeAndClearStack }
          ]);
        }
      } else {
        Alert.alert("Thất bại", data.error || data.message || "Lỗi xử lý đơn hàng");
      }
    } catch (err) {
      console.log("❌ Lỗi Fetch:", err);
      Alert.alert("Lỗi", "Kết nối server thất bại");
    } finally {
      setLoading(false);
    }
  }; // <-- Má thiếu cái dấu đóng này nè!

  const coverUri = (img: string) => img?.startsWith('http') ? img : `${API_URL}/uploads/${img}`;

  const PAYMENT_OPTIONS = [
    { key: 'COD',   label: 'Thanh toán khi nhận hàng', sub: 'Trả tiền mặt khi giao hàng', icon: 'cash-outline' },
    { key: 'VNPAY', label: 'Thanh toán qua VNPAY',     sub: 'Thẻ ATM, Internet Banking',   icon: 'card-outline' },
  ];
    const handleUpdateFailedStatus = async (orderId) => {
      if (!orderId) return;

      try {
        // 1. Phải lấy Token ra nè má
        const token = await AsyncStorage.getItem('token');

        console.log("🚀 Đang gọi API update có Token cho:", orderId);

        const response = await fetch(`${API_URL}/api/orders/update-status`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}` // <--- NHÉT TOKEN VÀO ĐÂY
          },
          body: JSON.stringify({ orderId: orderId, status: 'FAILED' })
        });

        console.log("Mã phản hồi từ Server:", response.status);
      } catch (err) {
        console.log("❌ Lỗi Fetch:", err.message);
      }
    };

  return (
    <SafeAreaView style={s.container}>
      <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

      {/* ── TOP BAR ────────────────────────────────────────────── */}
      <View style={s.topBar}>
        <View style={s.topBarBlob} />
        <TouchableOpacity style={s.backBtn} onPress={() => navigation.canGoBack() && navigation.goBack()}>
          <Ionicons name="chevron-back" size={22} color="#FFF" />
        </TouchableOpacity>
        <Text style={s.topBarTitle}>Xác nhận đơn hàng</Text>
        <View style={{ width: 38 }} />
      </View>

      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={s.scroll}>

        {/* ── 1. ADDRESS ───────────────────────────────────────── */}
        {/* ── 1. ADDRESS ───────────────────────────────────────── */}
        <View style={s.card}>
          {/* Header có nút + để thêm địa chỉ mới mọi lúc */}
          <View style={{
            flexDirection: 'row',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 10
          }}>
            <SectionHeader icon="location-outline" title="Địa chỉ nhận hàng" />

            <TouchableOpacity
              onPress={() => setShowAddModal(true)}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                backgroundColor: C.primarySoft,
                paddingHorizontal: 10,
                paddingVertical: 4,
                borderRadius: 12,
                marginRight: 5
              }}
            >
              <Ionicons name="add" size={16} color={C.primaryMid} />
              <Text style={{ color: C.primaryMid, fontSize: 12, fontWeight: '700', marginLeft: 2 }}>Thêm mới</Text>
            </TouchableOpacity>
          </View>

          {currentAddress ? (
            // HIỂN THỊ KHI ĐÃ CÓ ĐỊA CHỈ
            <TouchableOpacity
              style={s.addressBox}
              onPress={openAddressSelector}
              activeOpacity={0.85}
            >
              <View style={s.addressContent}>
                <View style={s.addressIconWrap}>
                  <Ionicons name="location" size={18} color={C.primaryMid} />
                </View>
                <View style={{ flex: 1 }}>
                  <View style={{ flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
                    <Text style={s.addressName}>
                      {currentAddress.recipientName || currentAddress.recipient_name}
                      <Text style={{ color: C.text3, fontWeight: 'normal' }}>  |  </Text>
                      {currentAddress.phoneNumber || currentAddress.phone_number}
                    </Text>

                    {/* HIỂN THỊ BADGE MẶC ĐỊNH NẾU LÀ TRUE */}
                    {(currentAddress.isDefault || currentAddress.is_default === 1) && (
                      <View style={{
                        backgroundColor: C.primarySoft,
                        paddingHorizontal: 6,
                        paddingVertical: 2,
                        borderRadius: 4,
                        borderWidth: 0.5,
                        borderColor: C.primaryMid
                      }}>
                        <Text style={{ color: C.primaryMid, fontSize: 10, fontWeight: '700' }}>Mặc định</Text>
                      </View>
                    )}
                  </View>

                  <Text style={s.addressDetail} numberOfLines={2}>
                    {[
                      currentAddress.specificAddress || currentAddress.specific_address,
                      currentAddress.ward,
                      currentAddress.district,
                      currentAddress.province
                    ].filter(Boolean).join(", ")}
                  </Text>
                </View>

                <TouchableOpacity style={s.changeBtn} onPress={openAddressSelector}>
                  <Text style={s.changeBtnTxt}>Đổi</Text>
                  <Ionicons name="chevron-forward" size={14} color={C.primaryMid} />
                </TouchableOpacity>
              </View>
            </TouchableOpacity>
          ) : (
            // HIỂN THỊ KHI CHƯA CÓ ĐỊA CHỈ (TRỐNG)
            <TouchableOpacity
              style={[s.addressBox, s.addressBoxEmpty, {
                paddingVertical: 30,
                alignItems: 'center',
                borderStyle: 'dashed',
                borderWidth: 1.5,
                borderColor: C.primaryTint
              }]}
              onPress={() => setShowAddModal(true)}
            >
              <View style={{
                backgroundColor: C.primarySoft,
                width: 50,
                height: 50,
                borderRadius: 25,
                justifyContent: 'center',
                alignItems: 'center',
                marginBottom: 10
              }}>
                <Ionicons name="add" size={30} color={C.primaryMid} />
              </View>
              <Text style={{ color: C.primaryMid, fontWeight: '700', fontSize: 15 }}>
                Chưa có địa chỉ giao hàng
              </Text>
              <Text style={{ color: C.text3, fontSize: 13, marginTop: 4 }}>
                Nhấn để thêm địa chỉ nhận hàng của bạn
              </Text>
            </TouchableOpacity>
          )}
        </View>

        {/* ── 2. PRODUCTS ──────────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="bag-outline" title={`Sản phẩm (${selectedItems.length})`} />
          {selectedItems.map((item: any, idx: number) => (
            <View key={item.cart_item_id || item.id} style={[s.itemRow, idx === selectedItems.length - 1 && { borderBottomWidth: 0 }]}>
              <Image source={{ uri: coverUri(item.cover_image) }} style={s.itemImg} resizeMode="cover" />
              <View style={s.itemInfo}>
                <Text style={s.itemTitle} numberOfLines={2}>{item.title}</Text>
                <View style={s.itemQtyRow}>
                  <Text style={s.itemQty}>x{item.quantity}</Text>
                  <Text style={s.itemUnitPrice}>{Number(item.price).toLocaleString("vi-VN")}đ/cuốn</Text>
                </View>
              </View>
              <Text style={s.itemTotal}>{(item.price * item.quantity).toLocaleString("vi-VN")}đ</Text>
            </View>
          ))}
        </View>

        {/* ── 3. PAYMENT ───────────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="wallet-outline" title="Phương thức thanh toán" />
          <View style={{ gap: 10 }}>
            {PAYMENT_OPTIONS.map(opt => {
              const active = paymentMethod === opt.key;
              return (
                <TouchableOpacity key={opt.key} style={[s.payOption, active && s.payOptionActive]} onPress={() => setPaymentMethod(opt.key)} activeOpacity={0.85}>
                  <View style={[s.payIconWrap, active && s.payIconWrapActive]}>
                    <Ionicons name={opt.icon as any} size={18} color={active ? "#FFF" : C.primaryMid} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={[s.payLabel, active && s.payLabelActive]}>{opt.label}</Text>
                    <Text style={s.paySub}>{opt.sub}</Text>
                  </View>
                  <Ionicons name={active ? "radio-button-on" : "radio-button-off"} size={20} color={active ? C.primaryMid : C.text3} />
                </TouchableOpacity>
              );
            })}
          </View>
        </View>

        {/* ── 4. COUPON ────────────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="pricetag-outline" title="Mã giảm giá" />
          {coupon ? (
            <View style={s.couponSelectedRow}>
              <View style={s.couponSelectedPill}>
                <Ionicons name="pricetag" size={14} color={C.primaryMid} />
                <Text style={s.couponSelectedCode}>{coupon}</Text>
              </View>
              {discountFromCoupon > 0 && (
                <Text style={s.couponSaveTxt}>-{discountFromCoupon.toLocaleString("vi-VN")}đ</Text>
              )}
              <TouchableOpacity onPress={handleRemoveCoupon} style={{ padding: 2 }}>
                <Ionicons name="close-circle" size={20} color={C.text3} />
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity style={s.selectCouponBtn} onPress={openCouponSelector} activeOpacity={0.85}>
              <Ionicons name="pricetag-outline" size={16} color={C.primaryMid} />
              <Text style={s.selectCouponTxt}>Chọn mã giảm giá</Text>
              <Ionicons name="chevron-forward" size={16} color={C.text3} />
            </TouchableOpacity>
          )}
        </View>

        {/* ── 5. POINTS ────────────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="star-outline" title="Điểm thưởng" />

          {/* Points balance */}
          <View style={s.pointsInfoRow}>
            <Ionicons name="star" size={15} color={C.orange} />
            <Text style={s.pointsInfoTxt}>
              Số điểm có:{" "}
              <Text style={{ color: C.orange, fontWeight: "800" }}>{userPoints.toLocaleString("vi-VN")} điểm</Text>
              <Text style={{ color: C.text3 }}>  ≈ {(userPoints * POINT_RATE).toLocaleString("vi-VN")}đ</Text>
            </Text>
          </View>

          {/* Input */}
          <View style={s.pointsInputRow}>
            <TextInput
              placeholder={`Tối đa ${userPoints} điểm`}
              placeholderTextColor={C.text3}
              keyboardType="numeric"
              style={s.inputField}
              value={pointsInput}
              onChangeText={handlePointsChange}
            />
            {usedPoints > 0 && (
              <TouchableOpacity onPress={() => { setUsedPoints(0); setPointsInput(""); }} style={s.clearPointsBtn}>
                <Ionicons name="close-circle" size={18} color={C.text3} />
              </TouchableOpacity>
            )}
          </View>

          {/* Live discount preview */}
          {usedPoints > 0 && (
            <View style={s.discountBadge}>
              <Ionicons name="checkmark-circle-outline" size={15} color={C.green} />
              <Text style={s.discountBadgeTxt}>
                Dùng {usedPoints} điểm → giảm {discountFromPoints.toLocaleString("vi-VN")}đ
              </Text>
            </View>
          )}
        </View>

        {/* ── 6. SUMMARY ───────────────────────────────────────── */}
        <View style={s.card}>
          <SectionHeader icon="receipt-outline" title="Tóm tắt thanh toán" />
          <View style={s.summaryBody}>
            <View style={s.summaryRow}>
              <Text style={s.summaryLabel}>Tạm tính ({selectedItems.length} sản phẩm)</Text>
              <Text style={s.summaryVal}>{totalPrice.toLocaleString("vi-VN")}đ</Text>
            </View>
            <View style={s.summaryRow}>
              <Text style={s.summaryLabel}>Phí vận chuyển</Text>
              <Text style={[s.summaryVal, { color: C.text1 }]}>
                {shippingFee === 0 ? "Chưa chọn địa chỉ" : `${shippingFee.toLocaleString("vi-VN")}đ`}
              </Text>
            </View>
            {discountFromCoupon > 0 && (
              <View style={s.summaryRow}>
                <Text style={s.summaryLabel}>Mã giảm ({coupon})</Text>
                <Text style={[s.summaryVal, { color: C.green }]}>-{discountFromCoupon.toLocaleString("vi-VN")}đ</Text>
              </View>
            )}
            {discountFromPoints > 0 && (
              <View style={s.summaryRow}>
                <Text style={s.summaryLabel}>Điểm thưởng ({usedPoints} điểm)</Text>
                <Text style={[s.summaryVal, { color: C.green }]}>-{discountFromPoints.toLocaleString("vi-VN")}đ</Text>
              </View>
            )}
            <View style={s.summaryRow}>
              <Text style={s.summaryLabel}>Phương thức</Text>
              <Text style={[s.summaryVal, { color: C.primaryMid }]}>{paymentMethod}</Text>
            </View>
            <View style={s.summaryDivider} />
            <View style={s.summaryRow}>
              <Text style={s.summaryTotalLabel}>Tổng thanh toán</Text>
              <View style={{ alignItems: "flex-end" }}>
                {totalDiscount > 0 && (
                  <Text style={s.summaryOriginal}>{totalPrice.toLocaleString("vi-VN")}đ</Text>
                )}
                <Text style={s.summaryTotalVal}>{displayedTotal.toLocaleString("vi-VN")}đ</Text>
              </View>
            </View>
          </View>
        </View>

        <View style={{ height: 110 }} />
      </ScrollView>

      {/* ── FOOTER — real-time ───────────────────────────────────── */}
      <View style={s.footer}>
        <View>
          <Text style={s.footerLabel}>Tổng thanh toán</Text>
          <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
            {totalDiscount > 0 && <Text style={s.footerOriginal}>{totalPrice.toLocaleString("vi-VN")}đ</Text>}
            <Text style={s.footerTotal}>{displayedTotal.toLocaleString("vi-VN")}đ</Text>
          </View>
          {totalDiscount > 0 && <Text style={s.footerSaved}>Tiết kiệm {totalDiscount.toLocaleString("vi-VN")}đ 🎉</Text>}
        </View>
        <TouchableOpacity style={[s.orderBtn, loading && s.orderBtnDisabled]} onPress={handleOrder} disabled={loading} activeOpacity={0.85}>
          {loading ? <ActivityIndicator color="#FFF" /> : (
            <><Ionicons name="checkmark-circle-outline" size={18} color="#FFF" /><Text style={s.orderBtnTxt}>Đặt hàng</Text></>
          )}
        </TouchableOpacity>
      </View>

      {/* ── ADDRESS MODAL ────────────────────────────────────────── */}
      <Modal visible={showAddressModal} animationType="slide" transparent>
        <View style={s.modalOverlay}>
          <View style={s.modalSheet}>
            <View style={s.sheetHandle} />
            <View style={s.sheetHeader}>
              <Text style={s.sheetTitle}>Chọn địa chỉ giao hàng</Text>
              <TouchableOpacity style={s.sheetCloseBtn} onPress={() => setShowAddressModal(false)}>
                <Ionicons name="close" size={20} color={C.text2} />
              </TouchableOpacity>
            </View>
            <ScrollView showsVerticalScrollIndicator={false}>
              {allAddresses.map((addr, idx) => {
                // Kiểm tra xem địa chỉ này có đang được chọn hay không
                const sel = currentAddress?.id === addr.id;

                // Kiểm tra trạng thái mặc định (hỗ trợ cả Boolean true và Integer 1)
                const isDefault = addr.isDefault || addr.is_default === 1;

                return (
                  <TouchableOpacity
                    key={addr.id}
                    style={[s.addrItem, sel && s.addrItemActive, idx === allAddresses.length - 1 && { borderBottomWidth: 0 }]}
                    onPress={() => selectAddress(addr)}
                    activeOpacity={0.85}
                  >
                    <View style={[s.addrAccent, sel && { backgroundColor: C.primaryMid }]} />

                    <View style={s.addrBody}>
                      <View style={s.addrNameRow}>
                        {/* Hiển thị tên người nhận: hỗ trợ cả 2 kiểu đặt tên biến */}
                        <Text style={s.addrName}>
                          {addr.recipientName || addr.recipient_name}
                        </Text>

                        {/* Nhãn Mặc định */}
                        {isDefault && (
                          <View style={s.defaultBadge}>
                            <Text style={s.defaultBadgeTxt}>Mặc định</Text>
                          </View>
                        )}
                      </View>

                      {/* Số điện thoại */}
                      <Text style={s.addrPhone}>
                        {addr.phoneNumber || addr.phone_number}
                      </Text>

                      {/* Địa chỉ chi tiết */}
                      <Text style={s.addrDetail} numberOfLines={2}>
                        {[
                          addr.specificAddress || addr.specific_address,
                          addr.ward,
                          addr.district,
                          addr.province
                        ].filter(Boolean).join(", ")}
                      </Text>
                    </View>

                    <Ionicons
                      name={sel ? "radio-button-on" : "radio-button-off"}
                      size={22}
                      color={sel ? C.primaryMid : C.text3}
                    />
                  </TouchableOpacity>
                );
              })}
              <View style={{ height: 20 }} />
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* ── COUPON MODAL ─────────────────────────────────────────── */}
      <Modal visible={couponModal} animationType="slide" transparent>
        <View style={s.modalOverlay}>
          <View style={s.modalSheet}>
            <View style={s.sheetHandle} />
            <View style={s.sheetHeader}>
              <Text style={s.sheetTitle}>Chọn mã giảm giá</Text>
              <TouchableOpacity style={s.sheetCloseBtn} onPress={() => setCouponModal(false)}>
                <Ionicons name="close" size={20} color={C.text2} />
              </TouchableOpacity>
            </View>
            <ScrollView showsVerticalScrollIndicator={false}>
              {couponList.length === 0 && (
                <View style={{ alignItems: "center", paddingVertical: 40 }}>
                  <Ionicons name="pricetag-outline" size={44} color={C.primaryTint} />
                  <Text style={{ color: C.text3, marginTop: 10, fontSize: 14 }}>Không có mã giảm giá khả dụng</Text>
                </View>
              )}
              {couponList.map((c: any, idx: number) => {
                const sel = coupon === c.code;
                return (
                  <TouchableOpacity key={c.id}
                    style={[s.couponItem, sel && s.couponItemActive, idx === couponList.length - 1 && { borderBottomWidth: 0 }]}
                    onPress={() => handleSelectCoupon(c)} activeOpacity={0.85}>
                    <View style={[s.couponIconWrap, sel && s.couponIconWrapActive]}>
                      <Ionicons name="pricetag-outline" size={18} color={sel ? "#FFF" : C.primaryMid} />
                    </View>
                    <View style={{ flex: 1 }}>
                      <Text style={[s.couponCode, sel && { color: C.primaryMid }]}>{c.code}</Text>
                      <Text style={s.couponDesc}>
                        {c.discount_percent ? `Giảm ${c.discount_percent}%` : `Giảm ${Number(c.discount_amount).toLocaleString("vi-VN")}đ`}
                      </Text>
                      <Text style={s.couponExpire}>Hạn: {new Date(c.expiry_date).toLocaleDateString("vi-VN")}</Text>
                    </View>
                    {/* Live preview discount amount */}
                    <View style={{ alignItems: "flex-end", gap: 4 }}>
                      <Text style={s.couponPreviewAmt}>
                        -{c.discount_percent
                          ? Math.round(totalPrice * c.discount_percent / 100).toLocaleString("vi-VN")
                          : Math.min(Number(c.discount_amount), totalPrice).toLocaleString("vi-VN")}đ
                      </Text>
                      <Ionicons name={sel ? "radio-button-on" : "radio-button-off"} size={22} color={sel ? C.primaryMid : C.text3} />
                    </View>
                  </TouchableOpacity>
                );
              })}
              <View style={{ height: 30 }} />
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* ── ADD NEW ADDRESS MODAL ────────────────────────────────────── */}
      <Modal visible={showAddModal} animationType="slide" transparent>
        <View style={s.modalOverlay}>
          <View style={[s.modalSheet, { height: '85%' }]}>
            <View style={s.sheetHandle} />
            <View style={s.sheetHeader}>
              <Text style={s.sheetTitle}>Thêm địa chỉ mới</Text>
              <TouchableOpacity style={s.sheetCloseBtn} onPress={() => setShowAddModal(false)}>
                <Ionicons name="close" size={20} color={C.text2} />
              </TouchableOpacity>
            </View>

            <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={{ padding: 20 }}>
              <View style={{ gap: 15 }}>

                {/* Tên người nhận */}
                <View>
                  <Text style={{ fontSize: 13, fontWeight: '700', color: C.text2, marginBottom: 8 }}>Người nhận *</Text>
                  <TextInput
                    style={s.inputField}
                    placeholder="Nhập tên người nhận"
                    placeholderTextColor={C.text3}
                    value={newAddr.recipientName}
                    onChangeText={(txt) => setNewAddr({...newAddr, recipientName: txt})}
                  />
                </View>

                {/* Số điện thoại */}
                <View>
                  <Text style={{ fontSize: 13, fontWeight: '700', color: C.text2, marginBottom: 8 }}>Số điện thoại *</Text>
                  <TextInput
                    style={s.inputField}
                    placeholder="Nhập số điện thoại liên lạc"
                    placeholderTextColor={C.text3}
                    keyboardType="phone-pad"
                    value={newAddr.phoneNumber}
                    onChangeText={(txt) => setNewAddr({...newAddr, phoneNumber: txt})}
                  />
                </View>

                <View>
                    <Text style={{ fontSize: 13, fontWeight: '700', color: C.text2, marginBottom: 8 }}>
                      Tỉnh / Thành phố *
                    </Text>

                    <Dropdown
                      style={[
                        s.inputField, // Giữ style cũ của bạn để đồng bộ giao diện
                        { height: 50, paddingHorizontal: 12 },
                        isFocus && { borderColor: 'blue' }
                      ]}
                      placeholderStyle={{ fontSize: 14, color: C.text3 }}
                      selectedTextStyle={{ fontSize: 14, color: C.text2 }}
                      inputSearchStyle={{ height: 40, fontSize: 14 }}
                      data={provinceData}
                      search // Hiện ô tìm kiếm cho người dùng gõ tên tỉnh nhanh hơn
                      maxHeight={300}
                      labelField="label"
                      valueField="value"
                      placeholder="-- Chọn Tỉnh / Thành phố --"
                      searchPlaceholder="Tìm tên tỉnh..."
                      value={newAddr.province}
                      onFocus={() => setIsFocus(true)}
                      onBlur={() => setIsFocus(false)}
                      onChange={item => {
                        setNewAddr({...newAddr, province: item.value}); // Cập nhật vào state cũ của bạn
                        setIsFocus(false);
                      }}
                    />
                  </View>

                {/* Quận / Huyện */}
                <View>
                  <Text style={{ fontSize: 13, fontWeight: '700', color: C.text2, marginBottom: 8 }}>Phường / Xã *</Text>
                  <TextInput
                    style={s.inputField}
                    placeholder="Ví dụ: Phường Tam Bình"
                    placeholderTextColor={C.text3}
                    value={newAddr.district}
                    onChangeText={(txt) => setNewAddr({...newAddr, district: txt})}
                  />
                </View>



                {/* Địa chỉ cụ thể */}
                <View>
                  <Text style={{ fontSize: 13, fontWeight: '700', color: C.text2, marginBottom: 8 }}>Địa chỉ cụ thể *</Text>
                  <TextInput
                    style={[s.inputField, { height: 80, textAlignVertical: 'top' }]}
                    placeholder="Số nhà, tên đường..."
                    placeholderTextColor={C.text3}
                    multiline
                    value={newAddr.specificAddress}
                    onChangeText={(txt) => setNewAddr({...newAddr, specificAddress: txt})}
                  />
                </View>
                {/* Đặt làm mặc định */}
                <TouchableOpacity
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    paddingVertical: 10,
                    marginTop: 5
                  }}
                  activeOpacity={0.8}
                  onPress={() => setNewAddr({...newAddr, isDefault: !newAddr.isDefault})}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                    <View style={{
                      width: 24,
                      height: 24,
                      borderRadius: 6,
                      borderWidth: 2,
                      borderColor: newAddr.isDefault ? C.primaryMid : C.border,
                      backgroundColor: newAddr.isDefault ? C.primaryMid : 'transparent',
                      justifyContent: 'center',
                      alignItems: 'center'
                    }}>
                      {newAddr.isDefault && <Ionicons name="checkmark" size={16} color="#FFF" />}
                    </View>
                    <Text style={{ fontSize: 14, color: C.text1, fontWeight: '600' }}>Đặt làm địa chỉ mặc định</Text>
                  </View>


                </TouchableOpacity>

                {/* Nút lưu */}
                <TouchableOpacity
                  style={[s.orderBtn, { width: '100%', marginTop: 10 }, loading && s.orderBtnDisabled]}
                  onPress={handleAddNewAddress}
                  disabled={loading}
                >
                  {loading ? <ActivityIndicator color="#FFF" /> : (
                    <>
                      <Ionicons name="save-outline" size={20} color="#FFF" />
                      <Text style={s.orderBtnTxt}>LƯU ĐỊA CHỈ</Text>
                    </>
                  )}
                </TouchableOpacity>

                <TouchableOpacity
                  onPress={() => setShowAddModal(false)}
                  style={{ padding: 10, alignItems: 'center' }}
                >
                  <Text style={{ color: C.text3, fontWeight: '600' }}>Hủy bỏ</Text>
                </TouchableOpacity>

              </View>
              <View style={{ height: 40 }} />
            </ScrollView>
          </View>
        </View>
      </Modal>
      {/* --- MODAL WEBVIEW THANH TOÁN VNPAY --- */}
        <Modal visible={showWebView} animationType="slide">
          <SafeAreaView style={{ flex: 1 }}>
            <View style={{
              height: 50,
              flexDirection: 'row',
              alignItems: 'center',
              paddingHorizontal: 15,
              borderBottomWidth: 1,
              borderColor: '#EEE',
              backgroundColor: '#FFF'
            }}>
              <TouchableOpacity onPress={() => setShowWebView(false)}>
                <Ionicons name="close" size={25} color="#333" />
              </TouchableOpacity>
              <Text style={{ fontSize: 16, fontWeight: 'bold', marginLeft: 20 }}>Thanh toán VNPAY</Text>
            </View>

            <WebView
              source={{ uri: paymentUrl }}
              onNavigationStateChange={(navState) => {
                // Chỉ xử lý khi thấy link return
                if (navState.url.includes('vnpay-return')) {

                  // --- CHIÊU NÀY LÀ QUAN TRỌNG NHẤT ---
                  // Dùng Regex để móc OrderId trực tiếp từ URL của VNPAY trả về
                  const orderIdMatch = navState.url.match(/[?&]vnp_TxnRef=([^&]+)/);
                  const resCodeMatch = navState.url.match(/[?&]vnp_ResponseCode=([^&]+)/);

                  // Nếu Regex tìm thấy thì dùng, không thì mới dùng currentOrderId làm dự phòng
                  const orderIdFromUrl = orderIdMatch ? orderIdMatch[1] : currentOrderId;
                  const responseCode = resCodeMatch ? resCodeMatch[1] : "99";

                  setShowWebView(false);

                  setTimeout(() => {
                    if (responseCode === '00') {
                      Alert.alert("✅ Thành công", "Đơn hàng đã thanh toán!", [
                        { text: "OK", onPress: goHomeAndClearStack }
                      ]);
                    } else {
                      handleUpdateFailedStatus(orderIdFromUrl);
                      Alert.alert("⚠️ Thông báo", "Giao dịch đã bị hủy.", [
                        { text: "OK", onPress: goHomeAndClearStack }
                      ]);
                    }
                  }, 500);
                }
              }}
            />
          </SafeAreaView>
        </Modal>
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },
  topBar: { backgroundColor: C.primaryMid, flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingTop: Platform.OS === "android" ? (StatusBar.currentHeight || 0) + 10 : 10, paddingBottom: 16, paddingHorizontal: 14, borderBottomLeftRadius: 28, borderBottomRightRadius: 28, overflow: "hidden" },
  topBarBlob: { position: "absolute", width: 160, height: 160, borderRadius: 80, backgroundColor: "rgba(255,255,255,0.08)", top: -50, right: -30 },
  backBtn: { width: 38, height: 38, borderRadius: 19, backgroundColor: "rgba(255,255,255,0.18)", justifyContent: "center", alignItems: "center" },
  topBarTitle: { fontSize: 17, fontWeight: "800", color: "#FFF" },
  scroll: { padding: 16, gap: 14 },
  card: { backgroundColor: C.surface, borderRadius: 20, padding: 18, elevation: 2, shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, gap: 12 },
  sectionHeader: { flexDirection: "row", alignItems: "center", gap: 8 },
  sectionIconWrap: { width: 30, height: 30, borderRadius: 10, backgroundColor: C.primarySoft, justifyContent: "center", alignItems: "center" },
  sectionTitle: { fontSize: 15, fontWeight: "800", color: C.text1 },
  addressBox: { borderWidth: 1.5, borderColor: C.primaryTint, borderRadius: 16, overflow: "hidden" },
  addressBoxEmpty: { borderStyle: "dashed" },
  addressContent: { flexDirection: "row", alignItems: "center", gap: 12, padding: 14 },
  addressEmpty: { flexDirection: "row", alignItems: "center", gap: 10, padding: 14, justifyContent: "center" },
  addressEmptyTxt: { flex: 1, fontSize: 14, color: C.primaryMid, fontWeight: "600" },
  addressIconWrap: { width: 36, height: 36, borderRadius: 18, backgroundColor: C.primarySoft, justifyContent: "center", alignItems: "center", flexShrink: 0 },
  addressName: { fontSize: 14, fontWeight: "700", color: C.text1, marginBottom: 4 },
  addressDetail: { fontSize: 13, color: C.text3, lineHeight: 18 },
  changeBtn: { backgroundColor: C.primarySoft, borderRadius: 10, paddingHorizontal: 10, paddingVertical: 5, borderWidth: 1, borderColor: C.primaryTint },
  changeBtnTxt: { fontSize: 12, color: C.primaryMid, fontWeight: "700" },
  itemRow: { flexDirection: "row", alignItems: "center", gap: 12, paddingVertical: 12, borderBottomWidth: 1, borderColor: C.border },
  itemImg: { width: 58, height: 80, borderRadius: 10, backgroundColor: C.primarySoft },
  itemInfo: { flex: 1, gap: 5 },
  itemTitle: { fontSize: 13, fontWeight: "700", color: C.text1, lineHeight: 18 },
  itemQtyRow: { flexDirection: "row", alignItems: "center", gap: 8 },
  itemQty: { backgroundColor: C.primarySoft, borderRadius: 8, paddingHorizontal: 8, paddingVertical: 2, fontSize: 12, fontWeight: "700", color: C.primaryMid },
  itemUnitPrice: { fontSize: 12, color: C.text3 },
  itemTotal: { fontSize: 14, fontWeight: "800", color: C.text1 },
  payOption: { flexDirection: "row", alignItems: "center", gap: 12, borderWidth: 1.5, borderColor: C.border, borderRadius: 16, padding: 14, backgroundColor: C.bg },
  payOptionActive: { borderColor: C.primaryMid, backgroundColor: C.primarySoft },
  payIconWrap: { width: 38, height: 38, borderRadius: 12, backgroundColor: C.primarySoft, justifyContent: "center", alignItems: "center" },
  payIconWrapActive: { backgroundColor: C.primaryMid },
  payLabel: { fontSize: 14, fontWeight: "700", color: C.text1 },
  payLabelActive: { color: C.primaryMid },
  paySub: { fontSize: 12, color: C.text3, marginTop: 2 },
  couponSelectedRow: { flexDirection: "row", alignItems: "center", gap: 10, backgroundColor: C.primarySoft, borderRadius: 14, padding: 12, borderWidth: 1, borderColor: C.primaryTint },
  couponSelectedPill: { flexDirection: "row", alignItems: "center", gap: 6, backgroundColor: C.surface, borderRadius: 10, paddingHorizontal: 10, paddingVertical: 5, borderWidth: 1, borderColor: C.primaryTint },
  couponSelectedCode: { fontSize: 14, fontWeight: "800", color: C.primaryMid },
  couponSaveTxt: { flex: 1, fontSize: 14, fontWeight: "700", color: C.green },
  selectCouponBtn: { flexDirection: "row", alignItems: "center", gap: 10, borderWidth: 1.5, borderColor: C.border, borderRadius: 14, padding: 14, backgroundColor: C.bg },
  selectCouponTxt: { flex: 1, fontSize: 14, fontWeight: "600", color: C.text2 },
  pointsInfoRow: { flexDirection: "row", alignItems: "center", gap: 7, backgroundColor: C.orangeBg, borderRadius: 10, paddingHorizontal: 12, paddingVertical: 8 },
  pointsInfoTxt: { fontSize: 13, color: C.orange },
  pointsInputRow: { flexDirection: "row", alignItems: "center", gap: 8 },
  inputField: { flex: 1, backgroundColor: C.bg, borderWidth: 1.5, borderColor: C.border, borderRadius: 12, paddingHorizontal: 14, paddingVertical: 11, fontSize: 14, color: C.text1 },
  clearPointsBtn: { padding: 4 },
  discountBadge: { flexDirection: "row", alignItems: "center", gap: 6, backgroundColor: C.greenBg, borderRadius: 10, paddingHorizontal: 12, paddingVertical: 7 },
  discountBadgeTxt: { fontSize: 13, color: C.green, fontWeight: "700" },
  summaryBody: { gap: 10 },
  summaryRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "flex-start" },
  summaryLabel: { fontSize: 14, color: C.text2 },
  summaryVal: { fontSize: 14, color: C.text1, fontWeight: "600" },
  summaryDivider: { height: 1, backgroundColor: C.border, marginVertical: 4 },
  summaryTotalLabel: { fontSize: 16, fontWeight: "800", color: C.text1 },
  summaryTotalVal: { fontSize: 20, fontWeight: "900", color: C.sale },
  summaryOriginal: { fontSize: 12, color: C.text3, textDecorationLine: "line-through" },
  footer: { position: "absolute", bottom: 0, left: 0, right: 0, backgroundColor: C.surface, flexDirection: "row", justifyContent: "space-between", alignItems: "center", paddingHorizontal: 20, paddingTop: 14, paddingBottom: Platform.OS === "ios" ? 30 : 16, borderTopWidth: 1, borderColor: C.border, elevation: 20, shadowColor: C.primaryMid, shadowOffset: { width: 0, height: -4 }, shadowOpacity: 0.10, shadowRadius: 12 },
  footerLabel: { fontSize: 13, color: C.text3, marginBottom: 2 },
  footerTotal: { fontSize: 22, fontWeight: "900", color: C.sale },
  footerOriginal: { fontSize: 13, color: C.text3, textDecorationLine: "line-through" },
  footerSaved: { fontSize: 12, color: C.green, fontWeight: "600", marginTop: 2 },
  orderBtn: { flexDirection: "row", alignItems: "center", gap: 8, backgroundColor: C.primaryMid, borderRadius: 16, paddingVertical: 14, paddingHorizontal: 28, elevation: 5, shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.30, shadowRadius: 10 },
  orderBtnDisabled: { backgroundColor: C.text3, elevation: 0, shadowOpacity: 0 },
  orderBtnTxt: { color: "#FFF", fontSize: 16, fontWeight: "800" },
  modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.45)", justifyContent: "flex-end" },
  modalSheet: { backgroundColor: C.surface, borderTopLeftRadius: 28, borderTopRightRadius: 28, maxHeight: "72%", paddingTop: 12, paddingBottom: 0 },
  sheetHandle: { width: 40, height: 4, borderRadius: 2, backgroundColor: C.border, alignSelf: "center", marginBottom: 12 },
  sheetHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", paddingHorizontal: 20, paddingBottom: 14, borderBottomWidth: 1, borderColor: C.border },
  sheetTitle: { fontSize: 17, fontWeight: "800", color: C.text1 },
  sheetCloseBtn: { width: 32, height: 32, borderRadius: 16, backgroundColor: C.bg, justifyContent: "center", alignItems: "center" },
  addrItem: { flexDirection: "row", alignItems: "center", paddingVertical: 14, paddingHorizontal: 20, borderBottomWidth: 1, borderColor: C.border, gap: 12 },
  addrItemActive: { backgroundColor: C.primarySoft },
  addrAccent: { width: 4, position: "absolute", left: 0, top: 14, bottom: 14, backgroundColor: C.border, borderRadius: 4 },
  addrBody: { flex: 1, paddingLeft: 4 },
  addrNameRow: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 3 },
  addrName: { fontSize: 14, fontWeight: "700", color: C.text1 },
  defaultBadge: { backgroundColor: C.primarySoft, borderRadius: 10, paddingHorizontal: 8, paddingVertical: 2, borderWidth: 1, borderColor: C.primaryTint },
  defaultBadgeTxt: { fontSize: 10, color: C.primaryMid, fontWeight: "700" },
  addrPhone: { fontSize: 13, color: C.text2, marginBottom: 3 },
  addrDetail: { fontSize: 12, color: C.text3, lineHeight: 17 },
  couponItem: { flexDirection: "row", alignItems: "center", paddingVertical: 14, paddingHorizontal: 20, borderBottomWidth: 1, borderColor: C.border, gap: 12 },
  couponItemActive: { backgroundColor: C.primarySoft },
  couponIconWrap: { width: 38, height: 38, borderRadius: 12, backgroundColor: C.primarySoft, justifyContent: "center", alignItems: "center" },
  couponIconWrapActive: { backgroundColor: C.primaryMid },
  couponCode: { fontSize: 15, fontWeight: "800", color: C.text1, marginBottom: 2 },
  couponDesc: { fontSize: 13, color: C.text2, marginBottom: 2 },
  couponExpire: { fontSize: 11, color: C.text3 },
  couponPreviewAmt: { fontSize: 13, fontWeight: "800", color: C.green },
});