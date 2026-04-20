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
  const [image, setImage] = useState<string | null>(null);

  const pickImage = async () => {
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 0.5,
    });

    if (!result.canceled) {
      setImage(result.assets[0].uri);
    }
  };

  const handleSubmit = async () => {
    if (!reason || !bankName || !accNumber) {
      Alert.alert("Lỗi", "Vui lòng nhập đầy đủ lý do và thông tin ngân hàng");
      return;
    }

    setLoading(true);
    try {
      const token = await AsyncStorage.getItem("token");

      // Note: Trong thực tế, bạn cần upload ảnh lên Cloudinary/Firebase trước để lấy URL
      // Ở đây tôi giả định gửi URL ảnh hoặc bạn xử lý upload tại đây.

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
          imageEvidence: image, // Nên là URL sau khi upload
        }),
      });

      if (response.ok) {
        Alert.alert("Thành công", "Yêu cầu của bạn đã được gửi đi.", [
          { text: "OK", onPress: () => navigation.goBack() }
        ]);
      } else {
        Alert.alert("Lỗi", "Không thể gửi yêu cầu lúc này");
      }
    } catch (error) {
      Alert.alert("Lỗi", "Kết nối server thất bại");
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={s.container}>
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

        <Text style={s.label}>Minh chứng hình ảnh</Text>
        <TouchableOpacity style={s.imageBtn} onPress={pickImage}>
          {image ? (
            <Image source={{ uri: image }} style={s.previewImage} />
          ) : (
            <View style={s.imagePlaceholder}>
              <Ionicons name="camera-outline" size={32} color="#999" />
              <Text style={{ color: "#999" }}>Bấm để chọn ảnh</Text>
            </View>
          )}
        </TouchableOpacity>

        <View style={s.bankCard}>
          <Text style={s.bankTitle}>Thông tin nhận tiền hoàn</Text>

          <Text style={s.label}>Tên ngân hàng</Text>
          <TextInput style={s.input} placeholder="Ví dụ: MB Bank, Vietcombank..." value={bankName} onChangeText={setBankName} />

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
  container: { flex: 1, backgroundColor: "#F8F9FA" },
  header: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", padding: 16, backgroundColor: "#FFF" },
  headerTitle: { fontSize: 18, fontWeight: "bold" },
  scroll: { padding: 16 },
  label: { fontSize: 14, fontWeight: "600", marginBottom: 8, color: "#444" },
  input: { backgroundColor: "#FFF", borderWidth: 1, borderColor: "#DDD", borderRadius: 8, padding: 12, marginBottom: 16 },
  textArea: { height: 100, textAlignVertical: "top" },
  imageBtn: { height: 150, backgroundColor: "#EEE", borderRadius: 8, justifyContent: "center", alignItems: "center", marginBottom: 20, overflow: "hidden" },
  previewImage: { width: "100%", height: "100%" },
  imagePlaceholder: { alignItems: "center" },
  bankCard: { backgroundColor: "#FFF", padding: 16, borderRadius: 12, borderWidth: 1, borderColor: "#E3F2FD", marginBottom: 20 },
  bankTitle: { fontSize: 16, fontWeight: "bold", color: "#1565C0", marginBottom: 15 },
  submitBtn: { backgroundColor: "#E53935", padding: 16, borderRadius: 12, alignItems: "center" },
  submitTxt: { color: "#FFF", fontWeight: "bold", fontSize: 16 },
});