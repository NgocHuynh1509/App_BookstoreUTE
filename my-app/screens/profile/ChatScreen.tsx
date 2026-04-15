import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";

const ChatScreen: React.FC = () => {
    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Tin nhắn</Text>
            </View>

            <View style={styles.emptyBox}>
                <Ionicons name="chatbubble-ellipses-outline" size={80} color="#ccc" />
                <Text style={styles.emptyTitle}>Chưa có cuộc trò chuyện nào</Text>
                <Text style={styles.emptySub}>
                    Khi có tin nhắn mới, bạn sẽ thấy ở đây
                </Text>
            </View>
        </SafeAreaView>
    );
};

export default ChatScreen;

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