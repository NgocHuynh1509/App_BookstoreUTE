import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import HomeScreen from "../screens/home";
import ProfileScreen from "../screens/profile/ProfileScreen";
import CartScreen from "../screens/profile/CartScreen";   // thêm
import NotificationScreen from "../screens/NotificationScreen"; // tự tạo
import { Ionicons } from "@expo/vector-icons";
import { useNotification } from "../contexts/NotificationContext";
import {View, Text, Alert} from "react-native";
import { useAuth } from "../hooks/useAuth";


const Tab = createBottomTabNavigator();

export default function TabNavigator() {
    const { unreadCount } = useNotification();
    const { user } = useAuth();

    const requireLogin = (navigation: any, message: string) => {
        if (user) return false;

        Alert.alert(
            "Yêu cầu đăng nhập",
            message,
            [
                { text: "Để sau", style: "cancel" },
                {
                    text: "Đăng nhập",
                    onPress: () => navigation.navigate("Login"),
                },
            ]
        );

        return true;
    };

    return (
        <Tab.Navigator
            screenOptions={{
                headerShown: false,
                tabBarActiveTintColor: "#6C63FF",
                tabBarInactiveTintColor: "#999",
                tabBarStyle: {
                    height: 60,
                    paddingBottom: 8,
                },
            }}
        >
            {/* HOME */}
            <Tab.Screen
                name="HomeTab"
                component={HomeScreen}
                options={{
                    tabBarLabel: "Trang chủ",
                    tabBarIcon: ({ color }) => (
                        <Ionicons name="home-outline" size={24} color={color} />
                    ),
                }}
            />

            {/* CART */}
            <Tab.Screen
                name="CartTab"
                component={CartScreen}
                listeners={({ navigation }) => ({
                    tabPress: (e) => {
                        const blocked = requireLogin(
                            navigation,
                            "Bạn cần đăng nhập để xem giỏ hàng"
                        );
                        if (blocked) e.preventDefault();
                    },
                })}
                options={{
                    tabBarLabel: "Giỏ hàng",
                    tabBarIcon: ({ color }) => (
                        <Ionicons name="cart-outline" size={24} color={color} />
                    ),
                }}
            />

            {/* NOTIFICATION */}
            <Tab.Screen
                name="NotifyTab"
                component={NotificationScreen}
                listeners={({ navigation }) => ({
                    tabPress: (e) => {
                        const blocked = requireLogin(
                            navigation,
                            "Bạn cần đăng nhập để xem thông báo"
                        );
                        if (blocked) e.preventDefault();
                    },
                })}
                options={{
                    tabBarLabel: "Thông báo",
                    tabBarIcon: ({ color }) => (
                        <View style={{ width: 24, height: 24 }}>
                            <Ionicons name="notifications-outline" size={24} color={color} />

                            {user && unreadCount > 0 && (
                                <View
                                    style={{
                                        position: "absolute",
                                        top: -5,
                                        right: -10,
                                        backgroundColor: "red",
                                        borderRadius: 10,
                                        paddingHorizontal: 5,
                                        minWidth: 18,
                                        alignItems: "center",
                                    }}
                                >
                                    <Text
                                        style={{
                                            color: "#fff",
                                            fontSize: 10,
                                            fontWeight: "bold",
                                        }}
                                    >
                                        {unreadCount > 99 ? "99+" : unreadCount}
                                    </Text>
                                </View>
                            )}
                        </View>
                    ),
                }}
            />

            {/* PROFILE */}
            <Tab.Screen
                name="ProfileTab"
                component={ProfileScreen}
                options={{
                    tabBarLabel: "Tôi",
                    tabBarIcon: ({ color }) => (
                        <Ionicons name="person-outline" size={24} color={color} />
                    ),
                }}
            />
        </Tab.Navigator>
    );
}