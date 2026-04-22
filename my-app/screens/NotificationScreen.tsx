import React from "react";
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    TouchableOpacity,
    RefreshControl,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { SafeAreaView } from "react-native-safe-area-context";
import { useNotification } from "../contexts/NotificationContext";
import { Alert } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { useCallback } from "react";




const NotificationScreen: React.FC<any> = ({ navigation }) => {
    const { notifications, markAsRead, markAllAsRead, refresh } = useNotification();

    useFocusEffect(
        useCallback(() => {
            refresh();
        }, [])
    );

    const handlePress = async (item: any) => {
        if (!item.isRead) {
            await markAsRead(item.id);
        }

        if (item.referenceId) {
            navigation.navigate("OrderDetail", {
                orderId: item.referenceId,
            });
        }
    };

    const getIconName = (type: string) => {
        switch (type) {
            case "ORDER_CREATED":
                return "receipt-outline";
            case "ORDER_CONFIRMED":
                return "checkmark-circle-outline";
            case "ORDER_SHIPPING":
                return "car-outline";
            case "ORDER_COMPLETED":
                return "cube-outline";
            case "ORDER_CANCELLED":
                return "close-circle-outline";
            case "ORDER_RETURNED":
                return "refresh-circle-outline";
            case "PAYMENT_SUCCESS":
                return "card-outline";
            case "PAYMENT_FAILED":
                return "alert-circle-outline";
            case "PAYMENT_REMINDER":
                return "time-outline";
            default:
                return "notifications-outline";
        }
    };

    const handleReadAll = () => {
        Alert.alert(
            "Đọc tất cả",
            "Bạn muốn đánh dấu tất cả thông báo là đã đọc?",
            [
                { text: "Hủy" },
                { text: "Xác nhận", onPress: markAllAsRead },
            ]
        );
    };

    const renderItem = ({ item }: any) => (
        <TouchableOpacity
            style={[styles.item, !item.isRead && styles.unreadItem]}
            onPress={() => handlePress(item)}
        >
            <View style={styles.iconWrap}>
                <Ionicons name={getIconName(item.type) as any} size={24} color="#2563eb" />
            </View>

            <View style={styles.content}>
                <Text style={styles.itemTitle}>{item.title}</Text>
                <Text style={styles.itemMessage}>{item.message}</Text>
                <Text style={styles.itemTime}>{item.createdAt}</Text>
            </View>
        </TouchableOpacity>
    );

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Thông báo</Text>

                {notifications.length > 0 && (
                    <TouchableOpacity
                        style={styles.readAllBtn}
                        onPress={handleReadAll}
                        activeOpacity={0.7}
                    >
                        <Ionicons name="checkmark-done-outline" size={16} color="#2563eb" />
                        <Text style={styles.readAllText}>Đọc tất cả</Text>
                    </TouchableOpacity>
                )}
            </View>

            {notifications.length === 0 ? (
                <View style={styles.emptyBox}>
                    <Ionicons name="notifications-off-outline" size={80} color="#ccc" />
                    <Text style={styles.emptyTitle}>Chưa có thông báo</Text>
                    <Text style={styles.emptySub}>
                        Khi có hoạt động mới, bạn sẽ thấy ở đây
                    </Text>
                </View>
            ) : (
                <FlatList
                    data={notifications}
                    keyExtractor={(item) => item.id.toString()}
                    renderItem={renderItem}
                    contentContainerStyle={styles.listContent}
                    refreshControl={
                        <RefreshControl refreshing={false} onRefresh={refresh} />
                    }
                />
            )}
        </SafeAreaView>
    );
};

export default NotificationScreen;

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#FFFBFB", // Nền trắng sứ ấm áp
    },

    header: {
        padding: 16,
        backgroundColor: "#FFF",
        borderBottomWidth: 1,
        borderColor: "#FEE2E2", // Viền hồng nhạt đồng bộ

        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
    },

    title: {
        fontSize: 20,
        fontWeight: "800",
        color: "#2D0A0A", // Nâu đen đậm (sang trọng hơn đen thuần)
    },

    listContent: {
        padding: 16,
    },

    item: {
        flexDirection: "row",
        backgroundColor: "#FFF",
        borderRadius: 16,
        padding: 14,
        marginBottom: 10,
        borderWidth: 1,
        borderColor: "#FEE2E2", // Viền nhẹ nhàng
    },

    unreadItem: {
        backgroundColor: "#FFF5F5", // Nền đỏ cực nhạt cho thông báo chưa đọc
    },

    iconWrap: {
        width: 44,
        height: 44,
        borderRadius: 22,
        backgroundColor: "#FFDADA", // Màu hồng nhạt cho vòng tròn icon
        justifyContent: "center",
        alignItems: "center",
        marginRight: 12,
    },

    content: {
        flex: 1,
    },

    itemTitle: {
        fontSize: 15,
        fontWeight: "700",
        color: "#2D0A0A",
    },

    itemMessage: {
        marginTop: 4,
        fontSize: 14,
        color: "#5F4B4B", // Xám đỏ
    },

    itemTime: {
        marginTop: 8,
        fontSize: 12,
        color: "#AFA0A0",
    },

    emptyBox: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        paddingHorizontal: 30,
    },

    emptyTitle: {
        fontSize: 18,
        fontWeight: "700",
        marginTop: 16,
        color: "#2D0A0A",
    },

    emptySub: {
        fontSize: 14,
        color: "#AFA0A0",
        marginTop: 6,
        textAlign: "center",
    },

    readAllBtn: {
        flexDirection: "row",
        alignItems: "center",
        gap: 4,
        backgroundColor: "#FFF5F5", // Nền hồng nhạt cho nút "Đã đọc tất cả"
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 999,
    },

    readAllText: {
        color: "#B8001A", // Màu đỏ thương hiệu UTE
        fontSize: 13,
        fontWeight: "600",
    },
});