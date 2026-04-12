import { useEffect, useState } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import * as SecureStore from 'expo-secure-store';
import { TOKEN_KEY } from '@/constants/Config';

export default function RootLayout() {
  const segments = useSegments();
  const router = useRouter();
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const checkToken = async () => {
      const token = await SecureStore.getItemAsync(TOKEN_KEY);

      // Phải khớp với tên file LoginScreen.tsx
      const inAuthGroup = segments[0] === 'LoginScreen';

      if (!token && !inAuthGroup) {
        // Nếu không có token -> Chuyển đến LoginScreen
        router.replace('/LoginScreen');
      } else if (token && inAuthGroup) {
        // Nếu có token rồi mà định vào Login -> Đẩy vào App chính
        router.replace('/(tabs)');
      }
      setIsReady(true);
    };

    checkToken();
  }, [segments]);

  // Nếu chưa check xong token thì có thể trả về null hoặc màn hình loading
  if (!isReady) return null;

  return (
      <Stack>
        {/* 1. Khai báo file index mồi nhưng ẩn nó đi */}
        <Stack.Screen name="index" options={{ headerShown: false }} />

        {/* 2. Giữ nguyên LoginScreen của bạn */}
        <Stack.Screen name="LoginScreen" options={{ headerShown: false }} />

        {/* 3. Các nhóm khác */}
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      </Stack>
    );
}