import { NavigationContainer } from "@react-navigation/native";
import { Provider as PaperProvider } from "react-native-paper";
import { SafeAreaProvider } from "react-native-safe-area-context";
import AppNavigator from "./navigation/AppNavigator";
import { useEffect } from "react";
import { initSearchHistoryTable } from "./services/searchHistory";
import { initRecentlyViewedTable } from "./services/recentlyViewed";
import { NotificationProvider } from "./contexts/NotificationContext";

import * as Notifications from "expo-notifications";
import { registerForPushNotificationsAsync } from "./services/pushNotification";
import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";

const API_URL =
    Constants.expoConfig?.extra?.API_URL || "http://192.168.1.28:8080";

export default function App() {

  useEffect(() => {
    initSearchHistoryTable();
  }, []);

  useEffect(() => {
    initRecentlyViewedTable();
  }, []);

  // 🔥 đăng ký push notification
  useEffect(() => {
    const setupPush = async () => {
      try {
        console.log("SETUP PUSH START");

        const token = await registerForPushNotificationsAsync();
        console.log("PUSH TOKEN =", token);

        const jwt = await AsyncStorage.getItem("token");
        console.log("JWT =", jwt);

        if (!token) {
          console.log("NO PUSH TOKEN");
          return;
        }

        if (!jwt) {
          console.log("NO JWT");
          return;
        }

        const res = await axios.post(
            `${API_URL}/api/users/save-fcm-token`,
            { token },
            {
              headers: {
                Authorization: `Bearer ${jwt}`,
              },
            }
        );

        console.log("SAVE TOKEN OK =", res.status, res.data);
      } catch (err) {
        console.log(
            "SAVE TOKEN ERROR =",
            err?.response?.status,
            err?.response?.data || err.message
        );
      }
    };

    setupPush();
  }, []);

  // 🔥 khi nhận notification (app đang mở)
  useEffect(() => {
    const sub = Notifications.addNotificationReceivedListener((notification) => {
      console.log("📩 NOTI RECEIVED:", notification);
    });

    return () => sub.remove();
  }, []);

  return (
      <SafeAreaProvider>
        <PaperProvider>
          <NotificationProvider>
            <NavigationContainer>
              <AppNavigator />
            </NavigationContainer>
          </NotificationProvider>
        </PaperProvider>
      </SafeAreaProvider>
  );
}