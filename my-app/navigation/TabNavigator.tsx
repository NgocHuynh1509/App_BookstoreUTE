import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import HomeScreen from "../screens/home";
import ProfileScreen from "../screens/profile/ProfileScreen";
import CartScreen from "../screens/profile/CartScreen";   // thêm
import NotificationScreen from "../screens/NotificationScreen"; // tự tạo
import { Ionicons } from "@expo/vector-icons";

const Tab = createBottomTabNavigator();

export default function TabNavigator() {
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
                options={{
                    tabBarLabel: "Thông báo",
                    tabBarIcon: ({ color }) => (
                        <Ionicons name="notifications-outline" size={24} color={color} />
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