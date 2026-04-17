import React, { useState, useEffect, useRef } from "react";
import { View, Text, StyleSheet, TouchableOpacity, FlatList, TextInput, KeyboardAvoidingView, Platform, ActivityIndicator, Alert, Image } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import * as ImagePicker from 'expo-image-picker';
import { Client } from "@stomp/stompjs";
import axios from "axios";
import Constants from "expo-constants";
import AsyncStorage from "@react-native-async-storage/async-storage";
import SockJS from 'sockjs-client';
import { useHeaderHeight } from '@react-navigation/elements';

interface Message {
    id: string;
    content: string;
    mediaUrl?: string;
    messageType: 'TEXT' | 'IMAGE' | 'VIDEO' | 'PRODUCT' | 'ORDER';
    senderRole: 'USER' | 'ADMIN';
    createdAt: string;
}

const BASE_URL = Constants.expoConfig?.extra?.API_URL || "http://192.168.1.22:8080";

const ChatScreen: React.FC = () => {
    const [activeTab, setActiveTab] = useState<'seller' | 'ai'>('seller');
    const [messages, setMessages] = useState<Message[]>([]);
    const [inputText, setInputText] = useState("");
    const [loading, setLoading] = useState(true);
    const [userData, setUserData] = useState<{username: string, token: string} | null>(null);
    const stompClient = useRef<Client | null>(null);
    const headerHeight = useHeaderHeight(); // Lấy chiều cao header tự động

    useEffect(() => {
        const getUserData = async () => {
            try {
                const savedUser = await AsyncStorage.getItem("user");
                const token = await AsyncStorage.getItem("token");
                if (savedUser) {
                    const parsedUser = JSON.parse(savedUser);
                    setUserData({
                        username: parsedUser.username,
                        token: token || parsedUser.token
                    });
                }
            } catch (e) {
                console.error("Lỗi lấy thông tin user:", e);
            }
        };
        getUserData();
    }, []);

    useEffect(() => {
        if (activeTab === 'seller' && userData) {
            initChat();
        } else {
            disconnectWebSocket();
        }
        return () => disconnectWebSocket();
    }, [activeTab, userData]);

    const initChat = async () => {
        setLoading(true);
        await loadHistory();
        await connectWebSocket();
        setLoading(false);
    };

    // Trong loadHistory: Đảm bảo dữ liệu nhận về được hiển thị đúng
    const loadHistory = async () => {
        if (!userData) return;
        try {
            // API này hiện tại đã trả về List<ChatMessageResponse> bao gồm cả tin nhắn Admin gửi
            const res = await axios.get(`${BASE_URL}/chat/history/${userData.username}`, {
                headers: { Authorization: `Bearer ${userData.token}` }
            });

            // Vì FlatList dùng 'inverted', tin nhắn mới nhất phải ở đầu mảng
            // Nếu Backend trả về DESC (mới nhất trước) thì chỉ cần set thẳng
            setMessages(res.data);
        } catch (e) {
            console.error("History Error", e);
        }
    };



    // Trong sendMessage: Đảm bảo cấu trúc giống hệt Flutter Admin
    const sendMessage = async () => {
        if (!inputText.trim() || !userData || !stompClient.current?.connected) return;

        const chatRequest = {
            userName: userData.username, // Người gửi
            receiverName: "admin",       // Người nhận luôn là admin
            senderRole: "USER",
            content: inputText.trim(),
            messageType: "TEXT",
        };

        stompClient.current.publish({
            destination: "/app/chat.sendMessage",
            body: JSON.stringify(chatRequest),
        });

        // Optimistic UI: Hiển thị ngay lập tức
        const localMsg: Message = {
            id: `temp-${Date.now()}`, // ID tạm
            content: inputText.trim(),
            senderRole: 'USER',
            messageType: 'TEXT',
            createdAt: new Date().toISOString()
        };

        setMessages(prev => [localMsg, ...prev]);
        setInputText("");
    };

    const connectWebSocket = async () => {
        if (!userData) return;
        const socketUrl = `${BASE_URL}/ws-bookstore`;
        const client = new Client({
            webSocketFactory: () => new SockJS(socketUrl),
            connectHeaders: { Authorization: `Bearer ${userData.token}` },
            debug: (str) => console.log("--- STOMP DEBUG ---", str),
            onConnect: () => {
                console.log("✅ KẾT NỐI THÀNH CÔNG!");

                // Trong connectWebSocket: Sửa callback nhận tin nhắn
                    client.subscribe(`/user/queue/messages`, (message) => {
                        const newMessage = JSON.parse(message.body);

                        // Kiểm tra tránh trùng tin nhắn do Optimistic UI khi chính mình gửi
                        setMessages((prev) => {
                            const isExist = prev.some(m => m.id === newMessage.id);
                            if (isExist) return prev;
                            return [newMessage, ...prev];
                        });
                    });
            },
            onStompError: (frame) => console.log("❌ LỖI BROKER:", frame.headers['message']),
            reconnectDelay: 5000,
            heartbeatIncoming: 4000,
            heartbeatOutgoing: 4000,
        });
        client.activate();
        stompClient.current = client;
    };

    const disconnectWebSocket = () => {
        if (stompClient.current) stompClient.current.deactivate();
    };
    const pickImage = async () => {
            const result = await ImagePicker.launchImageLibraryAsync({
                mediaTypes: ['images'],
                allowsEditing: true,
                quality: 0.8,
            });

            if (!result.canceled && result.assets && result.assets.length > 0) {
                uploadAndSendImage(result.assets[0]);
            }
        };

        const uploadAndSendImage = async (asset: any) => {
            if (!userData || !stompClient.current?.connected) return;

            const formData = new FormData();
            const uri = Platform.OS === 'ios' ? asset.uri.replace('file://', '') : asset.uri;

            formData.append('file', {
                uri: uri,
                name: asset.fileName || uri.split('/').pop() || 'image.jpg',
                type: asset.mimeType || 'image/jpeg',
            } as any);

            try {
                const uploadRes = await fetch(`${BASE_URL}/chat/upload`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${userData.token}`
                    },
                    body: formData,
                });

                if (!uploadRes.ok) {
                    throw new Error(`Upload failed with status ${uploadRes.status}`);
                }

                const mediaUrl = await uploadRes.text();

                const chatRequest = {
                    userName: userData.username,
                    receiverName: "admin",
                    senderRole: "USER",
                    content: "", // Optionally add a note like "Đã gửi một ảnh"
                    mediaUrl: mediaUrl,
                    messageType: "IMAGE",
                };

                stompClient.current.publish({
                    destination: "/app/chat.sendMessage",
                    body: JSON.stringify(chatRequest),
                });

            } catch (error) {
                console.error("Upload Image Error:", error);
                Alert.alert("Lỗi", "Không thể tải ảnh lên. Vui lòng thử lại.");
            }
        };

//     const sendMessage = async () => {
//         if (!inputText.trim() || !userData || !stompClient.current?.connected) return;
//         const chatRequest = {
//             userName: userData.username,
//             receiverName: "admin",
//             senderRole: "USER",
//             content: inputText.trim(),
//             messageType: "TEXT",
//         };
//         stompClient.current.publish({
//             destination: "/app/chat.sendMessage",
//             body: JSON.stringify(chatRequest),
//         });
//         const localMsg: Message = {
//             id: Date.now().toString(),
//             content: inputText.trim(),
//             senderRole: 'USER',
//             messageType: 'TEXT',
//             createdAt: new Date().toISOString()
//         };
//         setMessages(prev => [localMsg, ...prev]);
//         setInputText("");
//     };

    return (
            <SafeAreaView style={styles.container} edges={['top']}>
                {/* Header và Tabs giữ nguyên bên trong SafeAreaView */}
                <View style={styles.header}><Text style={styles.title}>Tin nhắn</Text></View>
                <View style={styles.tabContainer}>
                    <TouchableOpacity style={[styles.tab, activeTab === 'seller' && styles.activeTab]} onPress={() => setActiveTab('seller')}>
                        <Text style={[styles.tabText, activeTab === 'seller' && styles.activeTabText]}>Người bán</Text>
                    </TouchableOpacity>
                    <TouchableOpacity style={[styles.tab, activeTab === 'ai' && styles.activeTab]} onPress={() => setActiveTab('ai')}>
                        <Text style={[styles.tabText, activeTab === 'ai' && styles.activeTabText]}>Trợ lý AI</Text>
                    </TouchableOpacity>
                </View>

                {/* Chỉ sử dụng MỘT KeyboardAvoidingView bọc phần nội dung chat */}
                <KeyboardAvoidingView
                    behavior={Platform.OS === "ios" ? "padding" : "height"}
                    style={{ flex: 1 }}
                    // Offset giúp đẩy phần nhập liệu lên trên bàn phím
                    keyboardVerticalOffset={headerHeight + (Platform.OS === "ios" ? 0 : 20)}
                >
                    <View style={styles.content}>
                        {activeTab === 'seller' ? (
                            loading ? <ActivityIndicator size="large" color="#007AFF" style={{ flex: 1 }} /> : (
                                <>
                                    <FlatList
                                        data={messages}
                                        keyExtractor={(item) => item.id}
                                        renderItem={({item}) => {
                                            const isMe = item.senderRole === "USER";
                                            return (
                                                <View style={[styles.messageWrapper, isMe ? styles.myMsg : styles.otherMsg]}>
                                                    <View style={[styles.messageBubble, isMe ? styles.myBubble : styles.otherBubble]}>
                                                        {item.messageType === 'IMAGE' && item.mediaUrl ? (
                                                            <Image
                                                                source={{ uri: `${BASE_URL}${item.mediaUrl}` }}
                                                                style={{ width: 200, height: 200, borderRadius: 10, marginBottom: item.content ? 8 : 0 }}
                                                                resizeMode="cover"
                                                            />
                                                        ) : null}
                                                        {item.content ? <Text style={isMe ? styles.myText : styles.otherText}>{item.content}</Text> : null}
                                                    </View>
    </View>
                                            );
                                        }}
                                        inverted
                                        contentContainerStyle={{ padding: 16 }}
                                    />
                                    <View style={styles.inputArea}>
                                        <TouchableOpacity onPress={pickImage} style={{ marginRight: 10 }}>
                                            <Ionicons name="image-outline" size={28} color="#007AFF" />
                                        </TouchableOpacity>
                                        <TextInput
                                            style={styles.input}
                                            placeholder="Nhập tin nhắn..."
                                            value={inputText}
                                            onChangeText={setInputText}
                                        />
                                        <TouchableOpacity onPress={sendMessage}>
                                            <Ionicons name="send" size={24} color="#007AFF" />
                                        </TouchableOpacity>
                                    </View>
                                </>
                            )
                        ) : (
                            <View style={styles.emptyBox}><Text>Giao diện AI đang cập nhật...</Text></View>
                        )}
                    </View>
                </KeyboardAvoidingView>
            </SafeAreaView>
        );
    };

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: "#FFF" },
    header: { padding: 16 },
    title: { fontSize: 22, fontWeight: "800" },
    tabContainer: { flexDirection: "row", paddingHorizontal: 16, borderBottomWidth: 1, borderColor: "#EEE" },
    tab: { marginRight: 24, paddingVertical: 12 },
    activeTab: { borderBottomColor: "#007AFF", borderBottomWidth: 2 },
    tabText: { fontSize: 16, color: "#888" },
    activeTabText: { color: "#007AFF", fontWeight: "600" },
    content: { flex: 1, backgroundColor: "#F5F7FB" },
    messageWrapper: { marginBottom: 12, maxWidth: '80%' },
    myMsg: { alignSelf: 'flex-end' },
    otherMsg: { alignSelf: 'flex-start' },
    messageBubble: { padding: 12, borderRadius: 18 },
    myBubble: { backgroundColor: '#007AFF' },
    otherBubble: { backgroundColor: '#FFF' },
    myText: { color: '#FFF' },
    otherText: { color: '#333' },
    inputArea: { flexDirection: 'row', padding: 12, backgroundColor: '#FFF', alignItems: 'center', borderTopWidth: 1, borderTopColor: '#EEE' },
    input: { flex: 1, backgroundColor: '#F0F2F5', borderRadius: 24, paddingHorizontal: 16, height: 40, marginRight: 10 },
    emptyBox: { flex: 1, justifyContent: "center", alignItems: "center" }
});

export default ChatScreen;