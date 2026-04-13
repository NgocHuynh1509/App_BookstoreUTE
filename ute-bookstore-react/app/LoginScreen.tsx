import React, { useState, useContext } from 'react';
import {
  View, TextInput, StyleSheet, TouchableOpacity,
  Text, ActivityIndicator, Alert
} from 'react-native';
import { useRouter } from 'expo-router';
import { loginService } from '../services/authService';
import { AuthContext } from './_layout'; // Import context từ Root Layout

export default function LoginScreen() {
  const router = useRouter();
  const { setUser } = useContext(AuthContext); // Lấy hàm setUser để lưu trạng thái đăng nhập

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    // 1. Kiểm tra đầu vào
    if (!email || !password) {
      Alert.alert('Thông báo', 'Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setLoading(true);
    try {
      // 2. Gọi API đăng nhập
      const userData = await loginService(email, password);

      // 3. Lưu thông tin user vào Global State (Context)
      // Điều này sẽ giúp trang Home tự động đổi sang tên User
      setUser(userData);

      Alert.alert('Thành công', `Chào mừng ${userData.userName}`);

      // 4. Điều hướng về trang chính
      // Dùng replace để người dùng không bấm "back" quay lại màn hình login được nữa
      router.replace('/(tabs)');

    } catch (err: any) {
        // Kiểm tra nếu có tin nhắn lỗi cụ thể, không thì hiện thông báo chung
        const errorMessage = err?.response?.data?.message || err?.message || "Đã có lỗi xảy ra";
        Alert.alert('Lỗi', errorMessage);
      } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>ĐĂNG NHẬP</Text>

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Email hoặc Tên đăng nhập"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <TextInput
          style={styles.input}
          placeholder="Mật khẩu"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />
      </View>

      <TouchableOpacity
        style={[styles.button, loading && styles.buttonDisabled]}
        onPress={handleLogin}
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Đăng nhập</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.backLink}
        onPress={() => router.back()}
      >
        <Text style={styles.backLinkText}>Quay lại trang chủ</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 25,
    backgroundColor: '#fff'
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 40,
    color: '#333'
  },
  inputContainer: {
    marginBottom: 25
  },
  input: {
    borderWidth: 1,
    borderColor: '#eee',
    padding: 15,
    borderRadius: 12,
    marginBottom: 15,
    backgroundColor: '#f9f9f9',
    fontSize: 16
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#007AFF',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 5,
    elevation: 3
  },
  buttonDisabled: {
    backgroundColor: '#ccc'
  },
  buttonText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16
  },
  backLink: {
    marginTop: 20,
    alignItems: 'center'
  },
  backLinkText: {
    color: '#666',
    fontSize: 14
  }
});