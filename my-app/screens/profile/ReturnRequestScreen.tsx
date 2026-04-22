import React, { useState } from "react";
import {
  View, Text, TextInput, TouchableOpacity, ScrollView,
  StyleSheet, SafeAreaView, Alert, Image, ActivityIndicator
} from "react-native";
import { useRoute, useNavigation } from "@react-navigation/native";
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from "@expo/vector-icons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";
import * as FileSystem from 'expo-file-system/legacy';

const BASE_URL = Constants.expoConfig?.extra?.API_URL;

export default function ReturnRequestScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation();
  const { orderId } = route.params;

  const [loading, setLoading] = useState(false);
  const [reason, setReason] = useState("");
  const [bankName, setBankName] = useState("");
  const [accHolder, setAccHolder] = useState("");
  const [accNumber, setAccNumber] = useState("");

  // 1. CHUYỂN THÀNH MẢNG ẢNH
  const [images, setImages] = useState<string[]>([]);

  // 2. LOGIC CHỌN NHIỀU ẢNH
  const pickImages = async () => {
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsMultipleSelection: true, // Cho phép chọn nhiều
      selectionLimit: 0, // Giới hạn tối đa 5 ảnh
      quality: 0.3, // Giảm chất lượng xuống để giảm dung lượng
    });

    if (!result.canceled) {
      // Lấy danh sách URI từ các ảnh đã chọn
      const selectedUris = result.assets.map(asset => asset.uri);
      setImages(prev => [...prev, ...selectedUris]);
    }
  };

  // Hàm xóa một ảnh nếu người dùng chọn nhầm
  const removeImage = (index: number) => {
    const newImages = [...images];
    newImages.splice(index, 1);
    setImages(newImages);
  };

  const handleSubmit = async () => {
    // Kiểm tra tất cả các trường: lý do, ngân hàng, chủ tài khoản, số tài khoản và mảng ảnh
        if (!reason.trim()) {
          Alert.alert("Thiếu thông tin", "Vui lòng nhập lý do hoàn trả.");
          return;
        }
        if (images.length === 0) {
          Alert.alert("Thiếu hình ảnh", "Vui lòng chọn ít nhất 1 hình ảnh minh chứng lỗi sản phẩm.");
          return;
        }
        if (!bankName.trim()) {
          Alert.alert("Thiếu thông tin", "Vui lòng nhập tên ngân hàng.");
          return;
        }
        if (!accHolder.trim()) {
          Alert.alert("Thiếu thông tin", "Vui lòng nhập tên chủ tài khoản.");
          return;
        }
        if (!accNumber.trim()) {
          Alert.alert("Thiếu thông tin", "Vui lòng nhập số tài khoản ngân hàng.");
          return;
        }

    setLoading(true);
    try {
      const token = await AsyncStorage.getItem("token");

      const base64Images = await Promise.all(
        images.map(async (uri) => {
          const base64 = await FileSystem.readAsStringAsync(uri, {
            encoding: 'base64',
          });
          const extension = uri.split('.').pop()?.toLowerCase() || 'jpeg';
          const mimeType = extension === 'png' ? 'image/png' : 'image/jpeg';
          return `data:${mimeType};base64,${base64}`;
        })
      );

      const response = await fetch(`${BASE_URL}/api/orders/returns/submit`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          orderId,
          reason,
          bankName,
          accountHolder: accHolder,
          accountNumber: accNumber,
          imageEvidences: base64Images, // 3. TÊN BIẾN PHẢI KHỚP VỚI DTO BACKEND (có 's')
        }),
      });

      if (response.ok) {
        Alert.alert("Thành công", "Yêu cầu của bạn đã được gửi đi.", [
          { text: "OK", onPress: () => navigation.goBack() }
        ]);
      } else {
        const errorData = await response.json();
        Alert.alert("Lỗi", errorData.message || "Không thể gửi yêu cầu");
      }
    } catch (error: any) {
      console.log("SUBMIT ERROR:", error);
      Alert.alert("Lỗi", `Kết nối server thất bại: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={s.container}>
      {/* Header giữ nguyên */}
      <View style={s.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Ionicons name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={s.headerTitle}>Yêu cầu hoàn trả</Text>
        <View style={{ width: 24 }} />
      </View>

      <ScrollView contentContainerStyle={s.scroll}>
        <Text style={s.label}>Lý do hoàn trả *</Text>
        <TextInput
          style={[s.input, s.textArea]}
          placeholder="Mô tả chi tiết lỗi sản phẩm..."
          multiline
          value={reason}
          onChangeText={setReason}
        />

        <Text style={s.label}>Minh chứng hình ảnh ({images.length})</Text>

        {/* 4. GIAO DIỆN CHỌN NHIỀU ẢNH */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginBottom: 20 }}>
          <TouchableOpacity style={s.addMoreBtn} onPress={pickImages}>
            <Ionicons name="camera-outline" size={28} color="#999" />
            <Text style={{ color: "#999", fontSize: 10 }}>Thêm ảnh</Text>
          </TouchableOpacity>

          {images.map((uri, index) => (
            <View key={index} style={s.imageWrapper}>
              <Image source={{ uri }} style={s.previewImageMini} />
              <TouchableOpacity style={s.removeBadge} onPress={() => removeImage(index)}>
                <Ionicons name="close-circle" size={20} color="#E53935" />
              </TouchableOpacity>
            </View>
          ))}
        </ScrollView>

        {/* Phần thông tin ngân hàng và nút Submit giữ nguyên */}
        <View style={s.bankCard}>
          <Text style={s.bankTitle}>Thông tin nhận tiền hoàn</Text>
          <Text style={s.label}>Tên ngân hàng</Text>
          <TextInput style={s.input} placeholder="Ví dụ: MB Bank..." value={bankName} onChangeText={setBankName} />
          <Text style={s.label}>Chủ tài khoản</Text>
          <TextInput style={s.input} placeholder="NGUYEN VAN A" value={accHolder} onChangeText={setAccHolder} />
          <Text style={s.label}>Số tài khoản</Text>
          <TextInput style={s.input} keyboardType="numeric" placeholder="0123456789..." value={accNumber} onChangeText={setAccNumber} />
        </View>

        <TouchableOpacity style={s.submitBtn} onPress={handleSubmit} disabled={loading}>
          {loading ? <ActivityIndicator color="#FFF" /> : <Text style={s.submitTxt}>Gửi yêu cầu</Text>}
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  // Nền container chuyển sang màu trắng kem ấm áp
  container: { flex: 1, backgroundColor: "#FFFBFB" },

  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    padding: 16,
    backgroundColor: "#FFFFFF",
    borderBottomWidth: 1,
    borderBottomColor: "#FEE2E2", // Viền hồng nhạt
  },

  headerTitle: { fontSize: 18, fontWeight: "bold", color: "#2D0A0A" }, // Chữ nâu đen

  scroll: { padding: 16 },

  label: { fontSize: 14, fontWeight: "600", marginBottom: 8, color: "#5F4B4B" }, // Chữ phụ xám đỏ

  input: {
    backgroundColor: "#FFF",
    borderWidth: 1,
    borderColor: "#FEE2E2", // Viền hồng nhạt
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    color: "#2D0A0A"
  },

  textArea: { height: 100, textAlignVertical: "top" },

  // Style cho danh sách ảnh
  addMoreBtn: {
    width: 80,
    height: 80,
    backgroundColor: "#FFF5F5", // Đỏ cực nhạt
    borderRadius: 8,
    justifyContent: "center",
    alignItems: "center",
    marginRight: 10,
    borderWidth: 1,
    borderStyle: 'dashed',
    borderColor: "#FFDADA", // Viền hồng
  },

  imageWrapper: { position: 'relative', marginRight: 10 },
  previewImageMini: { width: 80, height: 80, borderRadius: 8 },

  removeBadge: {
    position: 'absolute',
    top: -5,
    right: -5,
    backgroundColor: '#B8001A', // Nút xóa màu đỏ đậm
    borderRadius: 10,
    elevation: 2,
  },

  // Bank Card chuyển sang tone Đỏ/Vàng sang trọng
  bankCard: {
    backgroundColor: "#FFF",
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#FFDADA", // Thay Xanh dương bằng Hồng nhạt
    marginBottom: 20,
    shadowColor: "#B8001A",
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },

  bankTitle: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#B8001A", // Màu đỏ thương hiệu
    marginBottom: 15
  },

  // Nút gửi đơn hàng rực rỡ
  submitBtn: {
    backgroundColor: "#B8001A", // Đỏ chuẩn UTE
    padding: 16,
    borderRadius: 12,
    alignItems: "center",
    shadowColor: "#B8001A",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },

  submitTxt: { color: "#FFF", fontWeight: "bold", fontSize: 16, letterSpacing: 0.5 },
});