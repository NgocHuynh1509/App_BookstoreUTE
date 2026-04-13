import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';

export default function HomeScreen() {
  const router = useRouter();
  // Giả sử logic kiểm tra user (thực tế bạn nên dùng Context hoặc Redux)
  const [user, setUser] = useState<{ userName: string } | null>(null);

  return (
    <View style={styles.container}>
      {/* Header tùy biến phía trên */}
      <View style={styles.header}>
        {user ? (
          <View style={styles.userInfo}>
            <Text style={styles.welcomeText}>Chào, {user.userName}</Text>
            <TouchableOpacity onPress={() => setUser(null)}>
              <Text style={styles.logoutText}>Thoát</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <TouchableOpacity
            style={styles.loginBtn}
            onPress={() => router.push('/LoginScreen')}
          >
            <Text style={styles.loginBtnText}>Đăng nhập</Text>
          </TouchableOpacity>
        )}
      </View>

      <View style={styles.content}>
        <Text>Nội dung trang chủ ở đây</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f5f5f5' },
  header: {
    paddingTop: 50,
    paddingHorizontal: 20,
    paddingBottom: 20,
    backgroundColor: '#fff',
    flexDirection: 'row',
    justifyContent: 'flex-end', // Đẩy nút về bên phải
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  loginBtn: { backgroundColor: '#007AFF', paddingVertical: 8, paddingHorizontal: 20, borderRadius: 20 },
  loginBtnText: { color: '#fff', fontWeight: 'bold' },
  userInfo: { flexDirection: 'row', alignItems: 'center' },
  welcomeText: { marginRight: 15, fontWeight: '600' },
  logoutText: { color: 'red', fontSize: 12 },
  content: { flex: 1, justifyContent: 'center', alignItems: 'center' }
});