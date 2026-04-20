import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Image,
  StatusBar,
} from "react-native";
import { useRoute, useNavigation } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";

const BASE_URL = Constants.expoConfig?.extra?.API_URL;

const C = {
  primary: "#1565C0",
  bg: "#F0F6FF",
  surface: "#FFFFFF",
  text1: "#0D1B3E",
  text2: "#4A5980",
  orange: "#F57C00",
  green: "#00897B",
  border: "#DDEEFF",
};

export default function ReturnDetailScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation();
  const { orderId } = route.params;

  const [loading, setLoading] = useState(true);
  const [returnData, setReturnData] = useState<any>(null);

  const fetchReturnDetail = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      const res = await fetch(`${BASE_URL}/api/orders/returns/detail/${orderId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      // Kiểm tra nếu response không thành công (404, 500...)
      if (!res.ok) {
          const errorText = await res.text(); // Đọc dạng text để xem lỗi gì
          console.log("Server error text:", errorText);
          setReturnData(null);
          return;
      }

      const data = await res.json();
      setReturnData(data);
    } catch (error) {
      console.error("Lỗi fetch return detail:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReturnDetail();
  }, [orderId]);

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={C.primary} />
      </View>
    );
  }

  if (!returnData) {
    return (
      <View style={s.center}>
        <Text>Không tìm thấy thông tin yêu cầu.</Text>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={{ color: C.primary, marginTop: 10 }}>Quay lại</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <SafeAreaView style={s.container}>
      <StatusBar barStyle="dark-content" />

      {/* Header */}
      <View style={s.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={s.backBtn}>
          <Ionicons name="chevron-back" size={24} color={C.text1} />
        </TouchableOpacity>
        <Text style={s.headerTitle}>Chi tiết hoàn trả</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={s.scroll}>
        {/* Status Card */}
        <View style={s.statusCard}>
          <View style={s.statusIcon}>
            <Ionicons name="time-outline" size={30} color={C.orange} />
          </View>
          <Text style={s.statusTxt}>Yêu cầu đang chờ xử lý</Text>
          <Text style={s.subTxt}>Chúng tôi sẽ xem xét và phản hồi trong vòng 24-48h</Text>
        </View>

        {/* Thông tin hoàn tiền */}
        <View style={s.card}>
          <Text style={s.sectionTitle}>Thông tin nhận tiền hoàn</Text>
          <View style={s.infoRow}>
            <Text style={s.label}>Ngân hàng:</Text>
            <Text style={s.value}>{returnData.bankName}</Text>
          </View>
          <View style={s.infoRow}>
            <Text style={s.label}>Chủ tài khoản:</Text>
            <Text style={s.value}>{returnData.accountHolder}</Text>
          </View>
          <View style={s.infoRow}>
            <Text style={s.label}>Số tài khoản:</Text>
            <Text style={s.value}>{returnData.accountNumber}</Text>
          </View>
        </View>

        {/* Lý do */}
        <View style={s.card}>
          <Text style={s.sectionTitle}>Lý do hoàn trả</Text>
          <Text style={s.reasonTxt}>{returnData.reason}</Text>

          {returnData.imageEvidence && (
            <View style={s.imageContainer}>
              <Text style={[s.label, { marginBottom: 8 }]}>Minh chứng:</Text>
              <Image
                source={{ uri: returnData.imageEvidence }}
                style={s.evidenceImage}
                resizeMode="cover"
              />
            </View>
          )}
        </View>

        {/* Mã đơn hàng */}
        <View style={[s.card, { alignItems: 'center', backgroundColor: 'transparent', elevation: 0, shadowOpacity: 0 }]}>
           <Text style={{ color: C.text2, fontSize: 12 }}>Mã đơn hàng: #{orderId}</Text>
           <Text style={{ color: C.text2, fontSize: 12 }}>Ngày gửi: {new Date(returnData.createdAt).toLocaleDateString('vi-VN')}</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: C.surface,
  },
  headerTitle: { fontSize: 18, fontWeight: '800', color: C.text1 },
  backBtn: { width: 40, height: 40, justifyContent: 'center' },
  scroll: { padding: 16, gap: 16 },
  statusCard: {
    backgroundColor: C.surface,
    padding: 24,
    borderRadius: 20,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: C.border,
  },
  statusIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#FFF3E0',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  statusTxt: { fontSize: 18, fontWeight: '800', color: C.orange },
  subTxt: { fontSize: 13, color: C.text2, textAlign: 'center', marginTop: 4 },
  card: {
    backgroundColor: C.surface,
    padding: 16,
    borderRadius: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
  },
  sectionTitle: { fontSize: 15, fontWeight: '800', color: C.primary, marginBottom: 12 },
  infoRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 },
  label: { fontSize: 14, color: C.text2 },
  value: { fontSize: 14, fontWeight: '600', color: C.text1 },
  reasonTxt: { fontSize: 14, color: C.text1, lineHeight: 20, fontStyle: 'italic' },
  imageContainer: { marginTop: 16 },
  evidenceImage: { width: '100%', height: 200, borderRadius: 12, backgroundColor: '#EEE' },
});