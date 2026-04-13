import { Redirect } from 'expo-router';

export default function Index() {
  // Vào app là vào thẳng hệ thống Tabs (Trang chủ)
  return <Redirect href="/(tabs)" />;
}