import React, { useEffect, useState } from "react";
import {
  View, Text, TextInput, TouchableOpacity, StyleSheet, Alert,
  ScrollView, Switch, SafeAreaView, StatusBar, Platform, Modal, FlatList
} from "react-native";
import { useNavigation, useRoute } from "@react-navigation/native";
import { useAuth } from "../../hooks/useAuth";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";
import { Ionicons } from "@expo/vector-icons";

const BASE_URL = Constants.expoConfig?.extra?.API_URL;

// ─── Palette ──────────────────────────────────────────────────────────────────
const C = {
  // Màu chính: Đỏ đậm (Deep Red) - mạnh mẽ và sang trọng
  primary:    "#8B0000",

  // Màu trung bình: Đỏ tươi hơn một chút (Vibrant Red) cho các nút bấm, icon
  primaryMid: "#B8001A",

  // Màu đỏ cực nhạt: Dùng cho background của các thẻ (Card) hoặc thông báo nhạt
  primarySoft:"#FFF5F5",

  // Màu đỏ nhạt: Dùng cho các khung, highlight nhẹ
  primaryTint:"#FFDADA",

  // Nền ứng dụng: Trắng pha chút đỏ rất nhẹ để tạo cảm giác ấm áp, không bị lạnh
  bg:         "#FFF9F9",

  // Các bề mặt trắng tinh khôi
  surface:    "#FFFFFF",

  // Viền: Màu hồng xám nhạt để đồng nhất tone
  border:     "#FEE2E2",

  // Viền khi focus: Đỏ rõ ràng
  borderFocus:"#B8001A",

  // Văn bản chính: Xanh đen cực đậm (gần như đen) để dễ đọc nhất
  text1:      "#1A0505",

  // Văn bản phụ: Xám đỏ
  text2:      "#5F4B4B",

  // Văn bản mờ/ghi chú: Xám hồng nhạt
  text3:      "#A38E8E",

  // Chỗ nhập liệu trống
  placeholder:"#D1C4C4",

  // Màu lỗi: Giữ nguyên đỏ tươi
  error:      "#E53935",
};

// ─── Labeled input ────────────────────────────────────────────────────────────
function Field({ label, icon, children }) {
  return (
    <View style={s.fieldWrap}>
      <View style={s.fieldLabel}>
        <Ionicons name={icon} size={15} color={C.primaryMid} />
        <Text style={s.fieldLabelTxt}>{label}</Text>
      </View>
      {children}
    </View>
  );
}

// ─── Styled TextInput ─────────────────────────────────────────────────────────
function SInput({ value, onChangeText, placeholder, keyboardType = "default", multiline = false, style = {} }) {
  const [focused, setFocused] = useState(false);
  return (
    <TextInput
      value={value}
      onChangeText={onChangeText}
      placeholder={placeholder}
      placeholderTextColor={C.placeholder}
      keyboardType={keyboardType}
      multiline={multiline}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
      style={[
        s.input,
        focused && s.inputFocused,
        multiline && s.inputMulti,
        style,
      ]}
    />
  );
}

export default function AddressForm() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const { id } = route.params || {};
  const { user } = useAuth();

  // CHỖ 1: State sử dụng CamelCase hoàn toàn để khớp DTO
  const [formData, setFormData] = useState({
    recipientName: "",
    phoneNumber:   "",
    province:       "",
    district:       "",
    ward:           "",
    specificAddress: "",
    isDefault: false,
  });
    // Trạng thái điều khiển Modal chọn tỉnh
      const [showProvinceModal, setShowProvinceModal] = useState(false);

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

  const set = (key: string, val: any) =>
    setFormData(prev => ({ ...prev, [key]: val }));

  // CHỖ 2: Load dữ liệu cũ gán vào đúng key CamelCase
  useEffect(() => {
    if (id) {
      const fetchOldData = async () => {
        try {
          const token = await AsyncStorage.getItem("token");
          const res = await fetch(`${BASE_URL}/addresses/${id}`, {
            headers: { Authorization: `Bearer ${token}` },
          });
          if (res.ok) {
            const current = await res.json();
            setFormData({
              recipientName:   current.recipientName || "",
              phoneNumber:     current.phoneNumber   || "",
              province:         current.province      || "",
              district:         current.district      || "",
              ward:             current.ward          || "",
              specificAddress: current.specificAddress || "",
              isDefault:       !!current.isDefault,
            });
          }
        } catch (error) {
          console.error("Lỗi fetch dữ liệu cũ:", error);
        }
      };
      fetchOldData();
    }
  }, [id]);

  // CHỖ 3: Submit dữ liệu lên Backend
  const handleSubmit = async () => {
    if (!formData.recipientName.trim() || !formData.phoneNumber.trim()) {
      return Alert.alert("Lỗi", "Vui lòng nhập họ tên và số điện thoại!");
    }

    const phoneRegex = /^[0-9]{10}$/;
        if (!phoneRegex.test(formData.phoneNumber.trim())) {
          return Alert.alert(
            "Số điện thoại không hợp lệ",
            "Số điện thoại phải bao gồm đúng 10 chữ số."
          );
        }

    try {
      const token  = await AsyncStorage.getItem("token");
      const url    = id ? `${BASE_URL}/addresses/${id}` : `${BASE_URL}/addresses/add`;
      const method = id ? "PUT" : "POST";

      const bodyPayload = {
        ...formData,
        id: id || null,
        customer: { customerId: user?.id }
      };

      const response = await fetch(url, {
        method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(bodyPayload),
      });

      if (response.ok) {
        Alert.alert("Thành công", id ? "Cập nhật thành công!" : "Đã thêm địa chỉ!");
        navigation.goBack();
      }
    } catch (error) {
      Alert.alert("Lỗi", "Kết nối server thất bại");
    }
  };

  const isEdit = !!id;

  return (
    <SafeAreaView style={s.safe}>
      <StatusBar barStyle="light-content" backgroundColor={C.primaryMid} />

      {/* Top Bar giữ nguyên */}
      <View style={s.topBar}>
        <TouchableOpacity style={s.backBtn} onPress={() => navigation.goBack()}>
          <Ionicons name="chevron-back" size={22} color="#FFF" />
        </TouchableOpacity>
        <Text style={s.topBarTitle}>{isEdit ? "Cập nhật địa chỉ" : "Thêm địa chỉ mới"}</Text>
        <View style={{ width: 38 }} />
      </View>

      <ScrollView contentContainerStyle={s.scroll} keyboardShouldPersistTaps="handled">

        {/* Info Card - ĐÃ SỬA TÊN BIẾN */}
        <View style={s.card}>
          <View style={s.cardHeader}>
            <Ionicons name="person-circle-outline" size={20} color={C.primaryMid} />
            <Text style={s.cardHeaderTxt}>Thông tin người nhận</Text>
          </View>

          <Field label="Họ và tên" icon="person-outline">
            <SInput
              value={formData.recipientName} // <-- Đã sửa
              onChangeText={t => set("recipientName", t)} // <-- Đã sửa
              placeholder="Nguyễn Văn A"
            />
          </Field>

          <Field label="Số điện thoại" icon="call-outline">
            <SInput
              value={formData.phoneNumber} // <-- Đã sửa
              onChangeText={t => set("phoneNumber", t)} // <-- Đã sửa
              placeholder="0901234567"
              keyboardType="phone-pad"
            />
          </Field>
        </View>

        {/* Address Card - ĐÃ SỬA TÊN BIẾN */}
        <View style={s.card}>
          <View style={s.cardHeader}>
            <Ionicons name="location-outline" size={20} color={C.primaryMid} />
            <Text style={s.cardHeaderTxt}>Địa chỉ giao hàng</Text>
          </View>

          <View style={s.row3}>
{/* CỘT TỈNH/TP - CHUYỂN THÀNH NÚT CHỌN */}
            <View style={{ flex: 1.2 }}>
              <Text style={s.miniLabel}>Tỉnh / TP</Text>
              <TouchableOpacity
                style={[s.input, { justifyContent: 'center', minHeight: 48 }]}
                onPress={() => setShowProvinceModal(true)}
              >
                <Text style={{ color: formData.province ? C.text1 : C.placeholder, fontSize: 14 }}>
                  {formData.province || "Chọn tỉnh"}
                </Text>
                <Ionicons name="chevron-down" size={14} color={C.text3} style={{ position: 'absolute', right: 8 }} />
              </TouchableOpacity>
            </View>


          </View>

          <View style={s.row3}>

                      <View style={{ flex: 1.2 }}>
                        <Text style={s.miniLabel}>Phường / Xã</Text>
                        <SInput value={formData.district} onChangeText={t => set("district", t)} placeholder="Quận 10" />
                      </View>

                    </View>

          <Field label="Địa chỉ cụ thể" icon="home-outline">
            <SInput
              value={formData.specificAddress} // <-- Đã sửa
              onChangeText={t => set("specificAddress", t)} // <-- Đã sửa
              placeholder="Số nhà, tên đường, tòa nhà..."
              multiline
            />
          </Field>
        </View>

        {/* Toggle Card - ĐÃ SỬA TÊN BIẾN */}
        <View style={s.toggleCard}>
          <View style={s.toggleLeft}>
            <View style={s.toggleIconWrap}><Ionicons name="star-outline" size={18} color={C.primaryMid} /></View>
            <View>
              <Text style={s.toggleTitle}>Địa chỉ mặc định</Text>
              <Text style={s.toggleSub}>Tự động chọn khi thanh toán</Text>
            </View>
          </View>
          <Switch
            value={formData.isDefault} // <-- Đã sửa
            onValueChange={v => set("isDefault", v)} // <-- Đã sửa
            trackColor={{ false: "#D0DCF0", true: C.primaryMid }}
            thumbColor="#FFF"
          />
        </View>

        {/* Action Buttons giữ nguyên */}
        <View style={s.btnRow}>
          <TouchableOpacity style={s.btnCancel} onPress={() => navigation.goBack()}>
            <Text style={s.btnCancelTxt}>Hủy</Text>
          </TouchableOpacity>
          <TouchableOpacity style={s.btnSave} onPress={handleSubmit}>
            <Text style={s.btnSaveTxt}>{isEdit ? "Cập nhật" : "Lưu địa chỉ"}</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* MODAL CHỌN TỈNH */}
            <Modal visible={showProvinceModal} animationType="slide" transparent={true}>
              <View style={s.modalOverlay}>
                <View style={s.modalContent}>
                  <View style={s.modalHeader}>
                    <Text style={s.modalTitle}>Chọn Tỉnh / Thành phố</Text>
                    <TouchableOpacity onPress={() => setShowProvinceModal(false)}>
                      <Ionicons name="close" size={24} color={C.text1} />
                    </TouchableOpacity>
                  </View>
                  <FlatList
                    data={provinceData}
                    keyExtractor={(item) => item.value}
                    renderItem={({ item }) => (
                      <TouchableOpacity
                        style={s.provinceItem}
                        onPress={() => {
                          set("province", item.value);
                          setShowProvinceModal(false);
                        }}
                      >
                        <Text style={s.provinceItemTxt}>{item.label}</Text>
                        {formData.province === item.value && <Ionicons name="checkmark" size={20} color={C.primaryMid} />}
                      </TouchableOpacity>
                    )}
                  />
                </View>
              </View>
            </Modal>
    </SafeAreaView>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: C.bg },

  // ── Top bar
  topBar: {
    backgroundColor: C.primaryMid,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 14,
    paddingVertical: 14,
    paddingTop: Platform.OS === "android" ? (StatusBar.currentHeight || 0) + 14 : 14,
  },
  backBtn: {
    width: 38, height: 38, borderRadius: 19,
    backgroundColor: "rgba(255,255,255,0.18)",
    justifyContent: "center", alignItems: "center",
  },
  topBarTitle: {
    fontSize: 17, fontWeight: "800", color: "#FFF", letterSpacing: 0.2,
  },

  scroll: {
    padding: 16, gap: 12, paddingBottom: 40,
  },

  // ── Card
  card: {
    backgroundColor: C.surface,
    borderRadius: 20,
    padding: 18,
    elevation: 2,
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08, shadowRadius: 8,
    gap: 14,
  },
  cardHeader: {
    flexDirection: "row", alignItems: "center", gap: 8,
    paddingBottom: 12,
    borderBottomWidth: 1, borderColor: C.border,
  },
  cardHeaderTxt: {
    fontSize: 15, fontWeight: "800", color: C.text1,
  },

  // ── Field
  fieldWrap: { gap: 6 },
  fieldLabel: {
    flexDirection: "row", alignItems: "center", gap: 5,
  },
  fieldLabelTxt: {
    fontSize: 12, fontWeight: "700", color: C.text2,
    textTransform: "uppercase", letterSpacing: 0.6,
  },
  miniLabel: {
    fontSize: 11, fontWeight: "700", color: C.text2,
    textTransform: "uppercase", letterSpacing: 0.6,
    marginBottom: 5,
  },

  // ── Input
  input: {
    backgroundColor: C.bg,
    borderWidth: 1.5, borderColor: C.border,
    borderRadius: 12,
    paddingHorizontal: 14, paddingVertical: 12,
    fontSize: 15, color: C.text1,
  },
  inputFocused: {
    borderColor: C.borderFocus,
    backgroundColor: C.primarySoft,
  },
  inputMulti: {
    height: 100, textAlignVertical: "top",
  },

  row3: { flexDirection: "row" },

  // ── Toggle card
  toggleCard: {
    backgroundColor: C.surface,
    borderRadius: 20, padding: 16,
    flexDirection: "row", alignItems: "center",
    justifyContent: "space-between",
    elevation: 2,
    shadowColor: C.primaryMid,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08, shadowRadius: 8,
  },
  toggleLeft: { flexDirection: "row", alignItems: "center", gap: 12 },
  toggleIconWrap: {
    width: 38, height: 38, borderRadius: 12,
    backgroundColor: C.primarySoft,
    justifyContent: "center", alignItems: "center",
  },
  toggleTitle: { fontSize: 15, fontWeight: "700", color: C.text1 },
  toggleSub: { fontSize: 12, color: C.text3, marginTop: 2 },

  // ── Buttons
  btnRow: {
    flexDirection: "row", gap: 12, marginTop: 8,
  },
  btnCancel: {
    flex: 1, flexDirection: "row", alignItems: "center", justifyContent: "center",
    gap: 6, paddingVertical: 16,
    backgroundColor: C.surface, borderRadius: 16,
    borderWidth: 1.5, borderColor: C.border,
  },
  btnCancelTxt: { fontSize: 15, fontWeight: "700", color: C.text2 },
  btnSave: {
    flex: 2, flexDirection: "row", alignItems: "center", justifyContent: "center",
    gap: 6, paddingVertical: 16,
    backgroundColor: C.primaryMid, borderRadius: 16,
    elevation: 4,
    shadowColor: C.primaryMid, shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.30, shadowRadius: 10,
  },
  btnSaveTxt: { fontSize: 15, fontWeight: "800", color: "#FFF" },

  // Style cho Modal chọn tỉnh
    modalOverlay: {
      flex: 1,
      backgroundColor: 'rgba(0,0,0,0.5)',
      justifyContent: 'flex-end',
    },
    modalContent: {
      backgroundColor: '#FFF',
      borderTopLeftRadius: 24,
      borderTopRightRadius: 24,
      height: '70%',
      padding: 20,
    },
    modalHeader: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: 20,
      paddingBottom: 10,
      borderBottomWidth: 1,
      borderBottomColor: '#EEE',
    },
    modalTitle: {
      fontSize: 18,
      fontWeight: '800',
      color: C.text1,
    },
    provinceItem: {
      paddingVertical: 15,
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      borderBottomWidth: 1,
      borderBottomColor: '#F5F5F5',
    },
    provinceItemTxt: {
      fontSize: 16,
      color: C.text1,
    },
});