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
  Modal,
  Dimensions,
} from "react-native";
import { useRoute, useNavigation } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";

const { width } = Dimensions.get("window");
const BASE_URL = Constants.expoConfig?.extra?.API_URL;

const C = {
  primary: "#1565C0",
  bg: "#F0F6FF",
  surface: "#FFFFFF",
  text1: "#0D1B3E",
  text2: "#4A5980",
  orange: "#F57C00",
  green: "#2E7D32",
  red: "#C62828",
  border: "#DDEEFF",
};

export default function ReturnDetailScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation();
  const { orderId } = route.params;

  const [loading, setLoading] = useState(true);
  const [returnData, setReturnData] = useState<any>(null);
  const [selectedImage, setSelectedImage] = useState<string | null>(null);

  // Hàm helper để map trạng thái từ Backend sang UI
  const getStatusInfo = (status: string) => {
    switch (status?.toLowerCase()) {
      case "pending":
        return {
          label: "Yêu cầu đang chờ xử lý",
          sub: "Chúng tôi đã tiếp nhận yêu cầu và đang kiểm tra.",
          color: C.orange,
          icon: "time"
        };
      case "finished":
      case "completed":
      case "approved":
        return {
          label: "Đã xử lý xong",
          sub: "Yêu cầu hoàn trả đã được chấp nhận và thực hiện.",
          color: C.green,
          icon: "checkmark-circle"
        };
      case "rejected":
        return {
          label: "Yêu cầu bị từ chối",
          sub: "Rất tiếc, yêu cầu không đáp ứng chính sách hoàn trả.",
          color: C.red,
          icon: "close-circle"
        };
      default:
        return {
          label: "Đang cập nhật",
          sub: "Vui lòng kiểm tra lại sau.",
          color: C.text2,
          icon: "help-circle"
        };
    }
  };

  const fetchReturnDetail = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      const res = await fetch(`${BASE_URL}/api/orders/returns/detail/${orderId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) { setReturnData(null); return; }
      const data = await res.json();
      setReturnData(data);
    } catch (error) {
      console.error("Lỗi fetch:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReturnDetail(); }, [orderId]);

  if (loading) return (
    <View style={s.center}><ActivityIndicator size="large" color={C.primary} /></View>
  );

  if (!returnData) return (
    <View style={s.center}>
      <Text>Không tìm thấy yêu cầu.</Text>
      <TouchableOpacity onPress={() => navigation.goBack()} style={s.btnBackErr}><Text style={{color:'#FFF'}}>Quay lại</Text></TouchableOpacity>
    </View>
  );

  const statusInfo = getStatusInfo(returnData.status);

  return (
    <SafeAreaView style={s.container}>
      <StatusBar barStyle="dark-content" />

      <Modal visible={!!selectedImage} transparent={true} animationType="fade">
        <View style={s.modalContainer}>
          <TouchableOpacity style={s.closeModalBtn} onPress={() => setSelectedImage(null)}>
            <Ionicons name="close-circle" size={45} color="#FFF" />
          </TouchableOpacity>
          <Image source={{ uri: selectedImage || '' }} style={s.fullImage} resizeMode="contain" />
        </View>
      </Modal>

      <View style={s.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}><Ionicons name="chevron-back" size={28} color={C.text1} /></TouchableOpacity>
        <Text style={s.headerTitle}>Chi tiết hoàn trả</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={s.scroll}>
        {/* PHẦN TRẠNG THÁI ĐỘNG TỪ DATABASE */}
        <View style={[s.statusCard, { borderColor: statusInfo.color + '40' }]}>
          <View style={[s.statusIcon, { backgroundColor: statusInfo.color + '15' }]}>
            <Ionicons name={statusInfo.icon as any} size={35} color={statusInfo.color} />
          </View>
          <Text style={[s.statusTxt, { color: statusInfo.color }]}>{statusInfo.label}</Text>

          <View style={[s.orderBadge, { borderColor: C.primary }]}>
            <Text style={s.orderBadgeLabel}>MÃ ĐƠN HÀNG</Text>
            <Text style={s.orderBadgeValue}>#{orderId}</Text>
          </View>

          <Text style={s.subTxt}>{statusInfo.sub}</Text>
        </View>

        <View style={s.card}>
          <View style={s.cardHeader}>
            <Ionicons name="card-outline" size={20} color={C.primary} />
            <Text style={s.sectionTitle}>Thông tin nhận tiền hoàn</Text>
          </View>
          <View style={s.infoRow}><Text style={s.label}>Ngân hàng</Text><Text style={s.value}>{returnData.bankName}</Text></View>
          <View style={s.divider} />
          <View style={s.infoRow}><Text style={s.label}>Chủ tài khoản</Text><Text style={s.value}>{returnData.accountHolder}</Text></View>
          <View style={s.divider} />
          <View style={s.infoRow}><Text style={s.label}>Số tài khoản</Text><Text style={s.value}>{returnData.accountNumber}</Text></View>
        </View>

        <View style={s.card}>
          <View style={s.cardHeader}>
            <Ionicons name="chatbox-ellipses-outline" size={20} color={C.primary} />
            <Text style={s.sectionTitle}>Lý do hoàn trả</Text>
          </View>
          <Text style={s.reasonTxt}>"{returnData.reason}"</Text>

          {returnData.imageEvidences?.length > 0 && (
            <View style={s.imageSection}>
              <Text style={[s.label, { marginBottom: 12 }]}>Minh chứng hình ảnh</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                {returnData.imageEvidences.map((img: string, i: number) => {
                  const imageUrl = img.startsWith('data:image') || img.startsWith('http')
                    ? img
                    : `${BASE_URL}/uploads/${img}`;

                  return (
                    <TouchableOpacity key={i} onPress={() => setSelectedImage(imageUrl)}>
                      <Image source={{ uri: imageUrl }} style={s.evidenceImageMini} />
                    </TouchableOpacity>
                  );
                })}
              </ScrollView>
            </View>
          )}
        </View>

        {/* ─── BỔ SUNG: PHẢN HỒI TỪ NGƯỜI BÁN ─── */}
                <View style={[s.card, { borderLeftWidth: 5, borderLeftColor: returnData.reply ? C.green : C.orange }]}>
                  <View style={s.cardHeader}>
                    <Ionicons
                      name="storefront-outline"
                      size={20}
                      color={returnData.reply ? C.green : C.orange}
                    />
                    <Text style={[s.sectionTitle, { color: returnData.reply ? C.green : C.orange }]}>
                      Phản hồi từ người bán
                    </Text>
                  </View>

                  {returnData.reply ? (
                    <View style={s.replyBox}>
                      <Text style={s.replyTxt}>{returnData.reply}</Text>
                    </View>
                  ) : (
                    <View style={s.waitingBox}>
                      <ActivityIndicator size="small" color={C.orange} style={{ marginRight: 8 }} />
                      <Text style={s.waitingTxt}>Đang đợi phản hồi từ Shop...</Text>
                    </View>
                  )}
                </View>

        <View style={s.footer}>
          <Text style={s.footerTxt}>Ngày gửi: {new Date(returnData.createdAt).toLocaleString('vi-VN')}</Text>
          <Text style={s.footerTxt}>ID yêu cầu: {returnData.returnId}</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },
  center: { flex: 1, justifyContent: "center", alignItems: "center" },
  header: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", padding: 16, backgroundColor: C.surface, elevation: 2 },
  headerTitle: { fontSize: 18, fontWeight: "800", color: C.text1 },
  scroll: { padding: 16, gap: 16 },
  statusCard: { backgroundColor: C.surface, padding: 24, borderRadius: 24, alignItems: "center", borderWidth: 1.5, elevation: 4 },
  statusIcon: { width: 70, height: 70, borderRadius: 35, justifyContent: "center", alignItems: "center", marginBottom: 15 },
  statusTxt: { fontSize: 20, fontWeight: "800" },
  orderBadge: { backgroundColor: "#E3F2FD", paddingHorizontal: 25, paddingVertical: 10, borderRadius: 15, marginVertical: 15, alignItems: "center", borderWidth: 1.5 },
  orderBadgeLabel: { fontSize: 10, color: C.primary, fontWeight: "700" },
  orderBadgeValue: { fontSize: 22, fontWeight: "900", color: C.primary },
  subTxt: { fontSize: 13, color: C.text2, textAlign: "center" },
  card: { backgroundColor: C.surface, padding: 16, borderRadius: 20, borderWidth: 1, borderColor: C.border },
  cardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 15, gap: 8 },
  sectionTitle: { fontSize: 16, fontWeight: "800", color: C.primary },
  infoRow: { flexDirection: "row", justifyContent: "space-between" },
  label: { fontSize: 14, color: C.text2 },
  value: { fontSize: 14, fontWeight: "700", color: C.text1 },
  divider: { height: 1, backgroundColor: "#F0F0F0", marginVertical: 10 },
  reasonTxt: { fontSize: 15, color: C.text1, fontStyle: "italic", backgroundColor: "#F9F9F9", padding: 12, borderRadius: 10 },
  imageSection: { marginTop: 20 },
  evidenceImageMini: { width: 100, height: 100, borderRadius: 12, marginRight: 10 },
  modalContainer: { flex: 1, backgroundColor: "rgba(0,0,0,0.9)", justifyContent: "center" },
  closeModalBtn: { position: "absolute", top: 40, right: 20, zIndex: 1 },
  fullImage: { width: '100%', height: '80%' },
  footer: { alignItems: "center", marginVertical: 20 },
  footerTxt: { color: "#9EABB8", fontSize: 12 },
  btnBackErr: { backgroundColor: C.primary, padding: 12, borderRadius: 8, marginTop: 10 },
  // STYLE MỚI BỔ SUNG
    replyBox: {
      backgroundColor: "#F1F8E9", // Màu xanh lá rất nhạt
      padding: 15,
      borderRadius: 12,
      marginTop: 5,
    },
    replyTxt: {
      fontSize: 15,
      color: "#2E7D32",
      lineHeight: 22,
      fontWeight: "500",
    },
    waitingBox: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: "#FFF3E0", // Màu cam nhạt
      padding: 15,
      borderRadius: 12,
      marginTop: 5,
    },
    waitingTxt: {
      fontSize: 14,
      color: "#E65100",
      fontStyle: "italic",
    },
});