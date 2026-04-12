import { Redirect } from 'expo-router';

export default function Index() {
  // File này chỉ làm nhiệm vụ: Hễ ai vào trang chủ "/" thì đá sang "/LoginScreen"
  return <Redirect href="/LoginScreen" />;
}