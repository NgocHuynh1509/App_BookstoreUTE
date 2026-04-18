
import React, { useState, useEffect, useRef } from "react";
import { View, Text, StyleSheet, TouchableOpacity, FlatList, TextInput, KeyboardAvoidingView, Platform, ActivityIndicator, Alert, Image } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Modal } from "react-native";
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
    // ✅ THÊM
        reaction?: string;
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
    const [reactionModalVisible, setReactionModalVisible] = useState(false);
    const [selectedMessage, setSelectedMessage] = useState<Message | null>(null);
    const REACTIONS = [
        { type: 'LIKE', emoji: '👍' },
        { type: 'LOVE', emoji: '❤️' },
        { type: 'HAHA', emoji: '😆' },
        { type: 'WOW', emoji: '😮' },
        { type: 'SAD', emoji: '😢' },
        { type: 'ANGRY', emoji: '😡' },
    ];
    const [page, setPage] = useState(0);
    const [hasMore, setHasMore] = useState(true);
    const [loadingMore, setLoadingMore] = useState(false);
    const [showTimeId, setShowTimeId] = useState<string | null>(null);

    const formatTime = (dateStr: string) => {
        const date = new Date(dateStr);
        return date.toLocaleTimeString('vi-VN', {
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const formatDateLabel = (dateStr: string) => {
        const date = new Date(dateStr);
        const now = new Date();

        const isToday =
            date.getDate() === now.getDate() &&
            date.getMonth() === now.getMonth() &&
            date.getFullYear() === now.getFullYear();

        const yesterday = new Date();
        yesterday.setDate(now.getDate() - 1);

        const isYesterday =
            date.getDate() === yesterday.getDate() &&
            date.getMonth() === yesterday.getMonth() &&
            date.getFullYear() === yesterday.getFullYear();

        if (isToday) return "Hôm nay";
        if (isYesterday) return "Hôm qua";

        return date.toLocaleDateString("vi-VN");
    };

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
        setLoading(true); // thêm
        setMessages([]);
        setPage(0);
        setHasMore(true);

        await loadHistory(0);
        await connectWebSocket();

        setLoading(false); // 🔥 QUAN TRỌNG
    };
    const loadHistory = async (nextPage = 0) => {
        if (!userData || !hasMore) return;

        if (nextPage !== 0) {
            setLoadingMore(true);
        }

        try {
            const res = await axios.get(
                `${BASE_URL}/chat/history/${userData.username}?page=${nextPage}&size=20`,
                {
                    headers: { Authorization: `Bearer ${userData.token}` }
                }
            );

            const newMessages = res.data;

            if (newMessages.length === 0) {
                setHasMore(false);
            } else {
                setMessages(prev => {
                    const merged = [...prev, ...newMessages];

                    // 🔥 remove duplicate theo id
                    const unique = merged.filter(
                        (msg, index, self) =>
                            index === self.findIndex(m => m.id === msg.id)
                    );

                    return unique;
                });
                setPage(nextPage);
            }

        } catch (e) {
            console.error("History Error", e);
        } finally {
            setLoadingMore(false);
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
    const sendReaction = (type: string) => {
        if (!selectedMessage || !stompClient.current?.connected || !userData) return;

        if (selectedMessage.id.startsWith("temp-")) {
            Alert.alert("Thông báo", "Tin nhắn chưa gửi xong");
            return;
        }

        const payload = {
            messageId: selectedMessage.id,
            partnerName: "admin",
            reaction: type
        };

        console.log("🔥 SEND REACTION:", payload);

        stompClient.current.publish({
            destination: "/app/chat.react",
            body: JSON.stringify(payload),
        });

        // ✅ THÊM ĐOẠN NÀY (QUAN TRỌNG)
            setMessages(prev =>
                prev.map(msg =>
                    msg.id === selectedMessage.id
                        ? { ...msg, reaction: type }
                        : msg
                )
            );

        setReactionModalVisible(false);
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

                        setMessages((prev) => {
                            // 🔥 tìm tin nhắn temp trùng nội dung
                            const tempIndex = prev.findIndex(
                                m =>
                                    m.id.startsWith("temp-") &&
                                    Math.abs(new Date(m.createdAt).getTime() - new Date(newMessage.createdAt).getTime()) < 5000
                            );

                            // ✅ nếu có → replace
                            if (tempIndex !== -1) {
                                const updated = [...prev];
                                updated[tempIndex] = newMessage;
                                return updated;
                            }

                            // ❌ tránh duplicate
                            const isExist = prev.some(m => m.id === newMessage.id);
                            if (isExist) {
                                console.log("⚠️ DUPLICATE MESSAGE:", newMessage.id);
                                return prev;
                            }

                            return [newMessage, ...prev];
                        });
                    });
                // 2. Subscribe nhận Reaction REALTIME
                    client.subscribe(`/user/queue/reactions`, (data) => {
                        const updatedMessage = JSON.parse(data.body);

                        // Cập nhật lại tin nhắn trong danh sách có ID tương ứng
                        setMessages((prev) =>
                            prev.map(msg =>
                                msg.id === updatedMessage.id
                                ? { ...msg, reaction: updatedMessage.reaction }
                                : msg
                            )
                        );
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
                                        keyExtractor={(item, index) => item.id + "-" + index}
                                        renderItem={({ item, index }) => {
                                            const isMe = item.senderRole === "USER";

                                            // 🔥 lấy message trước (do inverted nên là index + 1)
                                            const prev = messages[index + 1];

                                            const showDate =
                                                !prev ||
                                                formatDateLabel(prev.createdAt) !== formatDateLabel(item.createdAt);
                                            return (
                                                <>
                                                {/* ✅ Divider ngày */}
                                                            {showDate && (
                                                                <View style={{ alignItems: 'center', marginVertical: 10 }}>
                                                                    <Text style={{
                                                                        fontSize: 12,
                                                                        color: '#666',
                                                                        backgroundColor: '#EAEAEA',
                                                                        paddingHorizontal: 10,
                                                                        paddingVertical: 4,
                                                                        borderRadius: 10
                                                                    }}>
                                                                        {formatDateLabel(item.createdAt)}
                                                                    </Text>
                                                                </View>
                                                            )}

                                                <TouchableOpacity
                                                    onPress={() => {
                                                        setShowTimeId(prev => prev === item.id ? null : item.id);
                                                    }}

                                                    onLongPress={() => {
                                                        setSelectedMessage(item);
                                                        setReactionModalVisible(true);
                                                    }}
                                                    activeOpacity={0.8}
                                                >
                                                <View style={[styles.messageWrapper, isMe ? styles.myMsg : styles.otherMsg]}>
                                                    <View style={[
                                                        styles.messageBubble,
                                                        isMe ? styles.myBubble : styles.otherBubble,
                                                        item.messageType === 'IMAGE' && {
                                                            backgroundColor: 'transparent',
                                                            padding: 0
                                                        }
                                                    ]}>
                                                        {item.messageType === 'IMAGE' && item.mediaUrl ? (
                                                            <Image
                                                                source={{ uri: `${BASE_URL}${item.mediaUrl}` }}
                                                                style={{
                                                                    width: 200,
                                                                    height: 200,
                                                                    borderRadius: 12,   // bo góc đẹp hơn
                                                                }}
                                                                resizeMode="cover"
                                                            />
                                                        ) : null}
                                                        {item.content ? (
                                                           <Text style={isMe ? styles.myText : styles.otherText}>
                                                             {item.content}
                                                                </Text>
                                                        ) : null}
                                                        {showTimeId === item.id && (
                                                            <Text style={{
                                                                fontSize: 10,
                                                                color: isMe ? 'rgba(255,255,255,0.6)' : '#888',
                                                                marginTop: 4,
                                                                alignSelf: isMe ? 'flex-end' : 'flex-start',
                                                            }}>
                                                                {formatTime(item.createdAt)}
                                                            </Text>
                                                        )}




                                                    </View>
                                                            {item.reaction && (
                                                            <View style={{
                                                                position: 'absolute',
                                                                bottom: -10,
                                                                right: isMe ? undefined : -5,
                                                                left: isMe ? -5 : undefined,
                                                                backgroundColor: '#FFF',
                                                                borderRadius: 12,
                                                                paddingHorizontal: 6,
                                                                paddingVertical: 2,
                                                                borderWidth: 1,
                                                                borderColor: '#EEE'
                                                            }}>
                                                                <Text style={{ fontSize: 12, lineHeight: 14 }}>
                                                                    {REACTIONS.find(r => r.type === item.reaction)?.emoji}
                                                                </Text>
                                                            </View>
                                                        )}

                                                </View>
                                                </TouchableOpacity>
                                                </>
                                            );
                                        }}
                                        inverted
                                            onEndReached={() => {
                                                if (!loadingMore && hasMore && messages.length >= 20) {
                                                    loadHistory(page + 1);
                                                }
                                            }}
                                            onEndReachedThreshold={0.1}
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
                <Modal
                    visible={reactionModalVisible}
                    transparent
                    animationType="fade"
                >
                    <View style={styles.modalOverlay}>
                        <View style={styles.modalBox}>
                            <Text style={{ fontWeight: "bold", marginBottom: 10 }}>
                                Chọn cảm xúc
                            </Text>

                            <View style={{ flexDirection: "row" }}>
                                {REACTIONS.map((item) => {
                                    const isSelected = selectedMessage?.reaction === item.type;

                                    return (
                                        <TouchableOpacity
                                            key={item.type}
                                            onPress={() => sendReaction(item.type)}
                                            style={{
                                                marginHorizontal: 6,
                                                padding: 8,
                                                borderRadius: 20,

                                                // 🔥 highlight nếu đang chọn
                                                backgroundColor: isSelected ? "#007AFF22" : "transparent",
                                                borderWidth: isSelected ? 2 : 0,
                                                borderColor: "#007AFF"
                                            }}
                                        >
                                            <Text style={{
                                                fontSize: 22,

                                                // 🔥 làm nổi emoji
                                                transform: [{ scale: isSelected ? 1.2 : 1 }]
                                            }}>
                                                {item.emoji}
                                            </Text>
                                        </TouchableOpacity>
                                    );
                                })}
                            </View>

                            <TouchableOpacity
                                onPress={() => setReactionModalVisible(false)}
                                style={{ marginTop: 15 }}
                            >
                                <Text style={{ color: "red" }}>Đóng</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                </Modal>
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
    messageWrapper: { marginBottom: 12, maxWidth: '80%',overflow: 'visible' },
    myMsg: { alignSelf: 'flex-end' },
    otherMsg: { alignSelf: 'flex-start' },
    messageBubble: { padding: 12, borderRadius: 18,overflow: 'visible' },
    myBubble: { backgroundColor: '#007AFF' },
    otherBubble: { backgroundColor: '#FFF' },
    myText: { color: '#FFF' },
    otherText: { color: '#333' },
    inputArea: { flexDirection: 'row', padding: 12, backgroundColor: '#FFF', alignItems: 'center', borderTopWidth: 1, borderTopColor: '#EEE' },
    input: { flex: 1, backgroundColor: '#F0F2F5', borderRadius: 24, paddingHorizontal: 16, height: 40, marginRight: 10 },
    emptyBox: { flex: 1, justifyContent: "center", alignItems: "center" },
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.4)',
        justifyContent: 'center',
        alignItems: 'center',
    },

    modalBox: {
        backgroundColor: '#FFF',
        padding: 20,
        borderRadius: 12,
        alignItems: 'center',
        width: 350,
    },
    reactionBadge: {
        position: 'absolute',
        bottom: -8,

        backgroundColor: '#FFF',
        borderRadius: 10,

        paddingHorizontal: 4,
        paddingVertical: 1,

        minWidth: 20,
        height: 18,

        justifyContent: 'center',
        alignItems: 'center',

        borderWidth: 1,
        borderColor: '#EEE',

        elevation: 3,
    },
    reactionOutside: {
        position: 'absolute',
        bottom: -12,

        backgroundColor: '#FFF',
        borderRadius: 12,

        paddingHorizontal: 6,
        paddingVertical: 2,

        borderWidth: 1,
        borderColor: '#EEE',

        elevation: 3,
    },
});

export default ChatScreen;