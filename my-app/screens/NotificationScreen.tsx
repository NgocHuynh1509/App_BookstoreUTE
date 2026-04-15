import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { SafeAreaView } from "react-native-safe-area-context";

const NotificationScreen: React.FC = () => {
    return (
        <SafeAreaView style={styles.container}>

            {/* HEADER */}
            <View style={styles.header}>
                <Text style={styles.title}>Thông báo</Text>
            </View>

            {/* EMPTY STATE */}
            <View style={styles.emptyBox}>
                <Ionicons name="notifications-off-outline" size={80} color="#ccc" />

                <Text style={styles.emptyTitle}>
                    Chưa có thông báo
                </Text>

                <Text style={styles.emptySub}>
                    Khi có hoạt động mới, bạn sẽ thấy ở đây
                </Text>
            </View>

        </SafeAreaView>
    );
};

export default NotificationScreen;

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#F5F7FB",
    },

    header: {
        padding: 16,
        backgroundColor: "#FFF",
        borderBottomWidth: 1,
        borderColor: "#eee",
    },

    title: {
        fontSize: 20,
        fontWeight: "800",
        color: "#111",
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
        color: "#333",
    },

    emptySub: {
        fontSize: 14,
        color: "#888",
        marginTop: 6,
        textAlign: "center",
    },
});