import { Stack } from 'expo-router';
// PHẢI CÓ TỪ KHÓA export Ở ĐÂY
export const AuthContext = createContext<any>(null);

export default function RootLayout() {
  return (
    // Stack giúp quản lý việc chuyển trang theo dạng chồng lớp (LIFO)
    <Stack screenOptions={{ headerShown: false }}>
      {/* 1. Nhóm Tabs: Chứa 4 trang chính (Trang chủ, Giỏ hàng, Thông báo, Tôi) */}
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />

      {/* 2. Màn hình Đăng nhập: Hiển thị như một trang riêng biệt */}
      <Stack.Screen
        name="LoginScreen"
        options={{
          headerShown: true,
          title: 'Đăng nhập',
          presentation: 'modal' // Tùy chọn: làm nó trượt từ dưới lên (kiểu iPhone)
        }}
      />
    </Stack>
  );
}