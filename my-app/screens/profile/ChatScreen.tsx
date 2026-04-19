import { useRoute, useNavigation } from "@react-navigation/native"; // FIX: Thêm useNavigation
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
import { Animated } from "react-native";


interface Message {
    id: string;
    content: string;
    mediaUrl?: string;
    messageType: 'TEXT' | 'IMAGE' | 'VIDEO' | 'PRODUCT' | 'ORDER';
    senderRole: 'USER' | 'ADMIN';
    createdAt: string;
    reaction?: string;
    
    // REPLY FIELDS
    replyToId?: string;
    replyToContent?: string;
    replyToMediaUrl?: string;
    replyToMessageType?: 'TEXT' | 'IMAGE' | 'VIDEO' | 'PRODUCT' | 'ORDER';
    replyToSender?: string;
// Thêm các trường này
    bookId?: string;
    bookName?: string;
    bookImage?: string;
    bookPrice?: number; // Hoặc dùng totalPrice nếu bạn map vào đó
// ... các trường cũ
    orderId?: string;
    orderStatus?: string;
    totalPrice?: number;
    orderItemCount?: number; // <--- Thêm dòng này để chứa số lượng mặt hàng
    image?: string;
}

const BASE_URL = Constants.expoConfig?.extra?.API_URL || "http://192.168.1.22:8080";

const ChatScreen: React.FC = () => {
    const route = useRoute<any>();
        const navigation = useNavigation<any>(); // Thêm navigation để dùng goBack
    const [activeTab, setActiveTab] = useState<'seller' | 'ai'>('seller');
    const [messages, setMessages] = useState<Message[]>([]);
    const [inputText, setInputText] = useState("");
    const [loading, setLoading] = useState(true);
    const [userData, setUserData] = useState<{username: string, token: string} | null>(null);
    const stompClient = useRef<Client | null>(null);
    const headerHeight = useHeaderHeight();
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
    const reactionAnim = useRef<{[key: string]: Animated.Value}>({});
    const [replyMessage, setReplyMessage] = useState<Message | null>(null);
// Nhận cả productPreview (từ màn chi tiết sách) và orderPreview (từ màn đơn hàng)
    const { productPreview, orderPreview } = route.params || {};

    // Sử dụng state này để điều khiển việc hiển thị/ẩn banner
    const [previewItem, setPreviewItem] = useState(productPreview);
    const [orderInfo, setOrderInfo] = useState(orderPreview); // State cho đơn hàng


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
        setLoading(true);
        setMessages([]);
        setPage(0);
        setHasMore(true);

        await loadHistory(0);
        await connectWebSocket();

        setLoading(false);
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

            await axios.post(
                `${BASE_URL}/chat/mark-seen/${userData.username}`,
                {},
                { headers: { Authorization: `Bearer ${userData.token}` } }
            ).catch(err => console.log("Mark seen error:", err));

            const newMessages = res.data;

            if (newMessages.length === 0) {
                setHasMore(false);
            } else {
                setMessages(prev => {
                    const merged = [...prev, ...newMessages];
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

    const sendMessage = async () => {
        if (!inputText.trim() || !userData || !stompClient.current?.connected) return;

        const currentBookId = previewItem?.id || null;
        const currentOrderId = orderInfo?.orderId || null; // Lấy Order ID từ banner


        const chatRequest = {
            userName: userData.username,
            receiverName: "admin",
            senderRole: "USER",
            content: inputText.trim(),
            messageType: "TEXT",
            replyToId: replyMessage?.id || null,
            bookId: currentBookId, // <--- TRUYỀN ID THẬT Ở ĐÂY
            orderId: currentOrderId, // Gửi Order ID lên Backend
        };

        stompClient.current.publish({
            destination: "/app/chat.sendMessage",
            body: JSON.stringify(chatRequest),
        });

        const localMsg: Message = {
            id: `temp-${Date.now()}`,
            content: inputText.trim(),
            senderRole: 'USER',
            messageType: 'TEXT',
            createdAt: new Date().toISOString(),
            replyToId: replyMessage?.id,
            replyToContent: replyMessage?.content,
            replyToMediaUrl: replyMessage?.mediaUrl,
            replyToMessageType: replyMessage?.messageType,
            replyToSender: replyMessage?.senderRole === 'ADMIN' ? 'Admin' : replyMessage?.userName,
            bookId: currentBookId,
            orderId: currentOrderId,
        };

        setMessages(prev => [localMsg, ...prev]);
        setInputText("");
        setReplyMessage(null);
        // Tùy chọn: Ẩn banner sau khi đã gửi tin nhắn trao đổi về món đó
            if (previewItem) setPreviewItem(null);
// ... phần còn lại giữ nguyên
        if (orderInfo) setOrderInfo(null); // Gửi xong thì ẩn banner đơn hàng
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

        stompClient.current.publish({
            destination: "/app/chat.react",
            body: JSON.stringify(payload),
        });

        setMessages(prev =>
            prev.map(msg =>
                msg.id === selectedMessage.id
                    ? { ...msg, reaction: type }
                    : msg
            )
        );

        if (!reactionAnim.current[selectedMessage.id]) {
            reactionAnim.current[selectedMessage.id] = new Animated.Value(0);
        }

        reactionAnim.current[selectedMessage.id].setValue(0);
        Animated.spring(reactionAnim.current[selectedMessage.id], {
            toValue: 1,
            friction: 3,
            tension: 200,
            useNativeDriver: true,
        }).start();

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
                client.subscribe(`/user/queue/messages`, (message) => {
                    const newMessage = JSON.parse(message.body);
                    setMessages((prev) => {
                        const tempIndex = prev.findIndex(
                            m =>
                                m.id.startsWith("temp-") &&
                                Math.abs(new Date(m.createdAt).getTime() - new Date(newMessage.createdAt).getTime()) < 5000
                        );
                        if (tempIndex !== -1) {
                            const updated = [...prev];
                            updated[tempIndex] = newMessage;
                            return updated;
                        }
                        const isExist = prev.some(m => m.id === newMessage.id);
                        if (isExist) return prev;
                        return [newMessage, ...prev];
                    });
                });
                client.subscribe(`/user/queue/reactions`, (data) => {
                    const updatedMessage = JSON.parse(data.body);
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
                headers: { 'Authorization': `Bearer ${userData.token}` },
                body: formData,
            });

            if (!uploadRes.ok) throw new Error("Upload failed");

            const mediaUrl = await uploadRes.text();

            const chatRequest = {
                userName: userData.username,
                receiverName: "admin",
                senderRole: "USER",
                content: "",
                mediaUrl: mediaUrl,
                messageType: "IMAGE",
                replyToId: replyMessage?.id || null,
            };

            stompClient.current.publish({
                destination: "/app/chat.sendMessage",
                body: JSON.stringify(chatRequest),
            });
            
            setReplyMessage(null);

        } catch (error) {
            console.error("Upload Image Error:", error);
            Alert.alert("Lỗi", "Không thể tải ảnh lên. Vui lòng thử lại.");
        }
    };

    const renderReplyContent = (msg: Message) => {
        if (!msg.replyToId) return null;
        const isImage = msg.replyToMessageType === 'IMAGE';
        return (
            <View style={styles.replyBubble}>
                <Text style={styles.replySender}>
                    {msg.replyToSender || (msg.senderRole === 'USER' ? 'Admin' : 'Bạn')}
                </Text>
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                    {isImage && msg.replyToMediaUrl && (
                        <Image 
                            source={{ uri: `${BASE_URL}${msg.replyToMediaUrl}` }} 
                            style={styles.replyThumb} 
                        />
                    )}
                    <Text numberOfLines={1} style={styles.replyText}>
                        {isImage ? "[Hình ảnh]" : msg.replyToContent}
                    </Text>
                </View>
            </View>
        );
    };

    return (
        <SafeAreaView style={styles.container} edges={['top']}>
            <View style={styles.header}><Text style={styles.title}>Tin nhắn</Text></View>
            <View style={styles.tabContainer}>
                <TouchableOpacity style={[styles.tab, activeTab === 'seller' && styles.activeTab]} onPress={() => setActiveTab('seller')}>
                    <Text style={[styles.tabText, activeTab === 'seller' && styles.activeTabText]}>Người bán</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.tab, activeTab === 'ai' && styles.activeTab]} onPress={() => setActiveTab('ai')}>
                    <Text style={[styles.tabText, activeTab === 'ai' && styles.activeTabText]}>Trợ lý AI</Text>
                </TouchableOpacity>
            </View>

            <KeyboardAvoidingView
                behavior={Platform.OS === "ios" ? "padding" : "height"}
                style={{ flex: 1 }}
                keyboardVerticalOffset={headerHeight + (Platform.OS === "ios" ? 0 : 20)}
            >
                <View style={styles.content}>
                    {activeTab === 'seller' ? (
                        loading ? <ActivityIndicator size="large" color="#007AFF" style={{ flex: 1 }} /> : (
                            <>
                                {/* Banner sản phẩm đang trao đổi */}
                                {previewItem && (
                                    <View style={styles.productBanner}>
                                        <View style={styles.bannerHeader}>
                                            <Text style={styles.bannerHeaderText}>Bạn đang trao đổi với Người bán về mặt hàng này</Text>
                                            {/* SỬA TẠI ĐÂY: Khi đóng banner thì set previewItem về null */}
                                                <TouchableOpacity onPress={() => setPreviewItem(null)}>
                                                    <Ionicons name="close" size={18} color="#999" />
                                                </TouchableOpacity>
                                        </View>

                                        <View style={styles.bannerBody}>
                                            <Image source={{ uri: previewItem.cover_image }} style={styles.bannerImg} />
                                            <View style={styles.bannerInfo}>
                                                <Text numberOfLines={1} style={styles.bannerTitle}>{previewItem.title}</Text>
                                                <Text style={styles.bannerPrice}>{previewItem.price?.toLocaleString('vi-VN')}đ</Text>
                                            </View>
                                            <TouchableOpacity
                                                style={styles.changeBtn}
                                                onPress={() => navigation.goBack()}
                                            >
                                                <Text style={styles.changeBtnText}>Thay đổi</Text>
                                            </TouchableOpacity>
                                        </View>
                                    </View>
                                )}

                                {/* Banner đơn hàng đang trao đổi */}
                                {!!orderInfo && (
                                    <View style={[styles.productBanner, { borderLeftColor: '#F57C00', borderLeftWidth: 4 }]}>
                                        <View style={styles.bannerHeader}>
                                            <Text style={[styles.bannerHeaderText, { color: '#F57C00' }]}>
                                                Bạn đang hỏi về đơn hàng #{orderInfo.orderId}
                                            </Text>
                                            <TouchableOpacity onPress={() => setOrderInfo(null)}>
                                                <Ionicons name="close" size={18} color="#999" />
                                            </TouchableOpacity>
                                        </View>

                                        <View style={styles.bannerBody}> {/* Đã sửa s thành styles */}
                                            <Image source={{ uri: orderInfo.image }} style={styles.bannerImg} />
                                            <View style={styles.bannerInfo}>
                                                <Text style={styles.bannerTitle}>Đơn hàng gồm {orderInfo.productCount} sản phẩm</Text>
                                                <Text style={styles.bannerPrice}>Tổng: {orderInfo.totalPrice?.toLocaleString('vi-VN')}đ</Text>
                                                <Text style={{ fontSize: 12, color: '#666' }}>Trạng thái: {orderInfo.status}</Text>
                                            </View>
                                            <TouchableOpacity
                                                style={[styles.changeBtn, { backgroundColor: '#FFF3E0' }]}
                                                onPress={() => navigation.goBack()}
                                            >
                                                <Text style={[styles.changeBtnText, { color: '#F57C00' }]}>Xem đơn</Text>
                                            </TouchableOpacity>
                                        </View>
                                    </View>
                                )}
                                <FlatList
                                    data={messages}
                                    keyExtractor={(item, index) => item.id + "-" + index}
                                    renderItem={({ item, index }) => {
                                        const isMe = item.senderRole === "USER";
                                        const prev = messages[index + 1];
                                        const showDate = !prev || formatDateLabel(prev.createdAt) !== formatDateLabel(item.createdAt);

                                        return (
                                            <View key={item.id} style={{ marginBottom: 10 }}> {/* Thêm margin ở đây để các tin nhắn không dính nhau */}
                                                {showDate && (
                                                    <View style={{ alignItems: 'center', marginVertical: 15 }}>
                                                        <Text style={styles.dateLabel}>{formatDateLabel(item.createdAt)}</Text>
                                                    </View>
                                                )}

                                                <TouchableOpacity
                                                    onPress={() => setShowTimeId(prev => prev === item.id ? null : item.id)}
                                                    onLongPress={() => {
                                                        // 1. Chặn tin nhắn của chính mình
                                                            if (item.senderRole !== "ADMIN") return;
                                                        setSelectedMessage(item);
                                                        setReactionModalVisible(true);
                                                    }}
                                                    activeOpacity={0.8}
                                                >
                                                    <View style={[styles.messageWrapper, isMe ? styles.myMsg : styles.otherMsg]}>
                                                        {renderReplyContent(item)}

                                                        {/* 1. CARD SẢN PHẨM */}
                                                        {item.bookId && (
                                                            <TouchableOpacity
                                                                activeOpacity={0.9}
                                                                onPress={() => navigation.navigate("BookDetail", { id: item.bookId })}
                                                                style={{ alignSelf: isMe ? 'flex-end' : 'flex-start', marginBottom: 6 }}
                                                            >
                                                                <View style={styles.productMessageCard}>
                                                                    <Image source={{ uri: item.bookImage }} style={styles.productMsgImg} />
                                                                    <View style={styles.productMsgInfo}>
                                                                        <Text style={styles.productMsgTitle}>{item.bookName}</Text>
                                                                        <Text style={styles.productMsgPrice}>
                                                                            {item.bookPrice || item.totalPrice
                                                                                ? `${Number(item.bookPrice || item.totalPrice).toLocaleString('vi-VN')}đ`
                                                                                : "Liên hệ"}
                                                                        </Text>
                                                                    </View>
                                                                </View>
                                                            </TouchableOpacity>
                                                        )}

                                                        {item.orderId && (
                                                            <TouchableOpacity
                                                                activeOpacity={0.9}
                                                                onPress={() => navigation.navigate("OrderDetail", { orderId: item.orderId })}
                                                                style={{ alignSelf: isMe ? 'flex-end' : 'flex-start', marginBottom: 6 }}
                                                            >
                                                                <View style={[styles.productMessageCard, { borderLeftColor: '#F57C00', borderLeftWidth: 4 }]}>
                                                                    <Image
                                                                        source={{ uri: item.image || item.bookImage }}
                                                                        style={styles.productMsgImg}
                                                                    />
                                                                    <View style={styles.productMsgInfo}>
                                                                        <Text style={[styles.productMsgTitle, { color: '#F57C00' }]}>
                                                                            Đơn hàng #{item.orderId}
                                                                        </Text>

                                                                        {/* Dòng hiển thị số lượng mặt hàng nè */}
                                                                        <Text style={{ fontSize: 12, color: '#666', fontWeight: '500' }}>
                                                                            Số lượng: {item.orderItemCount || 0} mặt hàng
                                                                        </Text>

                                                                        <Text style={styles.productMsgPrice}>
                                                                            Tổng: {Number(item.totalPrice).toLocaleString('vi-VN')}đ
                                                                        </Text>

                                                                        <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 2 }}>
                                                                            <Ionicons name="ellipse" size={8} color={item.orderStatus === 'completed' ? '#4CAF50' : '#F57C00'} />
                                                                            <Text style={{ fontSize: 11, color: '#888', marginLeft: 4 }}>
                                                                                {item.orderStatus}
                                                                            </Text>
                                                                        </View>
                                                                    </View>
                                                                </View>
                                                            </TouchableOpacity>
                                                        )}

                                                        {/* 2. HÌNH ẢNH */}
                                                        {item.messageType === 'IMAGE' && item.mediaUrl && (
                                                            <Image
                                                                source={{ uri: `${BASE_URL}${item.mediaUrl}` }}
                                                                style={[styles.messageImage, { alignSelf: isMe ? 'flex-end' : 'flex-start', marginBottom: 4 }]}
                                                                resizeMode="cover"
                                                            />
                                                        )}

                                                        {/* 3. BUBBLE VĂN BẢN (CHỈ RENDER 1 LẦN) */}
                                                        {item.content ? (
                                                            <View style={[
                                                                styles.messageBubble,
                                                                isMe ? styles.myBubble : styles.otherBubble,
                                                                {
                                                                    alignSelf: isMe ? 'flex-end' : 'flex-start',
                                                                    marginTop: (item.bookId || item.mediaUrl) ? 2 : 0
                                                                }
                                                            ]}>
                                                                <Text style={isMe ? styles.myText : styles.otherText}>
                                                                    {item.content}
                                                                </Text>

                                                                {/* REACTION CHO TIN NHẮN CÓ CHỮ */}
                                                                {item.reaction && (
                                                                    <View style={[
                                                                        styles.reactionOutside,
                                                                        { [isMe ? 'left' : 'right']: -10, bottom: -5 }
                                                                    ]}>
                                                                        <Text style={{ fontSize: 12 }}>
                                                                            {REACTIONS.find(r => r.type === item.reaction)?.emoji}
                                                                        </Text>
                                                                    </View>
                                                                )}
                                                            </View>
                                                        ) : (
                                                            /* REACTION CHO TIN NHẮN CHỈ CÓ ẢNH/CARD */
                                                            item.reaction && (
                                                                <View style={[
                                                                    styles.reactionOutside,
                                                                    { alignSelf: isMe ? 'flex-end' : 'flex-start', [isMe ? 'marginRight' : 'marginLeft']: 5 }
                                                                ]}>
                                                                    <Text style={{ fontSize: 12 }}>
                                                                        {REACTIONS.find(r => r.type === item.reaction)?.emoji}
                                                                    </Text>
                                                                </View>
                                                            )
                                                        )}
                                                    {/* --- THÊM PHẦN NÀY VÀO ĐỂ HIỆN GIỜ KHI NHẤN --- */}
                                                    {showTimeId === item.id && (
                                                        <View style={{
                                                            alignSelf: isMe ? 'flex-end' : 'flex-start',
                                                            marginTop: 4,
                                                            marginHorizontal: 12
                                                        }}>
                                                            <Text style={{ fontSize: 10, color: '#999' }}>
                                                                {formatTime(item.createdAt)}
                                                            </Text>
                                                        </View>
                                                    )}
                                                    </View>
                                                </TouchableOpacity>
                                            </View>
                                        );
                                    }}

                                    inverted
                                    onEndReached={() => {
                                        if (!loadingMore && hasMore && messages.length >= 20) loadHistory(page + 1);
                                    }}
                                    onEndReachedThreshold={0.1}
                                    contentContainerStyle={{ padding: 16 }}
                                />
                                <View>
                                    {replyMessage && (
                                        <View style={styles.replyPreviewBar}>
                                            <View style={{ flex: 1 }}>
                                                <Text style={styles.replyPreviewHeader}>Đang trả lời {replyMessage.senderRole === 'ADMIN' ? 'Admin' : 'Bạn'}</Text>
                                                <Text numberOfLines={1} style={styles.replyPreviewText}>
                                                    {replyMessage.messageType === 'IMAGE' ? "[Hình ảnh]" : replyMessage.content}
                                                </Text>
                                            </View>
                                            {replyMessage.messageType === 'IMAGE' && (
                                                <Image source={{ uri: `${BASE_URL}${replyMessage.mediaUrl}` }} style={styles.replyPreviewThumb} />
                                            )}
                                            <TouchableOpacity onPress={() => setReplyMessage(null)}>
                                                <Ionicons name="close-circle" size={20} color="red" />
                                            </TouchableOpacity>
                                        </View>
                                    )}
                                    <View style={styles.inputArea}>
                                        <TouchableOpacity onPress={pickImage} style={{ marginRight: 10 }}>
                                            <Ionicons name="image-outline" size={28} color="#007AFF" />
                                        </TouchableOpacity>
                                        <TextInput style={styles.input} placeholder="Nhập tin nhắn..." value={inputText} onChangeText={setInputText} />
                                        <TouchableOpacity onPress={sendMessage}>
                                            <Ionicons name="send" size={24} color="#007AFF" />
                                        </TouchableOpacity>
                                    </View>
                                </View>
                            </>
                        )
                    ) : (
                        <View style={styles.emptyBox}><Text>Giao diện AI đang cập nhật...</Text></View>
                    )}
                </View>
            </KeyboardAvoidingView>
            <Modal visible={reactionModalVisible} transparent animationType="fade">
                <View style={styles.modalOverlay}>
                    <View style={styles.modalBox}>
                        <Text style={{ fontWeight: "bold", marginBottom: 10 }}>Chọn cảm xúc</Text>
                        <View style={{ flexDirection: "row" }}>
                            {REACTIONS.map((item) => (
                                <TouchableOpacity key={item.type} onPress={() => sendReaction(item.type)} style={styles.reactionItem}>
                                    <Text style={{ fontSize: 22 }}>{item.emoji}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                        <View style={{ marginTop: 15, width: "100%" }}>
                            <TouchableOpacity onPress={() => { setReplyMessage(selectedMessage); setReactionModalVisible(false); setSelectedMessage(null); }} style={styles.modalButton}>
                                <Text style={{ color: "#007AFF", fontWeight: "600" }}>↩ Trả lời</Text>
                            </TouchableOpacity>
                            <TouchableOpacity onPress={() => { setReactionModalVisible(false); setSelectedMessage(null); }} style={styles.modalButton}>
                                <Text style={{ color: "red" }}>Đóng</Text>
                            </TouchableOpacity>
                        </View>
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
    messageWrapper: { marginBottom: 12, maxWidth: '80%', position: "relative" },
    myMsg: { alignSelf: 'flex-end' },
    otherMsg: { alignSelf: 'flex-start' },
    messageBubble: { padding: 12, borderRadius: 18 },
    myBubble: { backgroundColor: '#007AFF' },
    otherBubble: { backgroundColor: '#FFF' },
    myText: { color: '#FFF' },
    otherText: { color: '#333' },
    inputArea: { flexDirection: 'row', padding: 12, backgroundColor: '#FFF', alignItems: 'center', borderTopWidth: 1, borderTopColor: '#EEE' },
    input: { flex: 1, backgroundColor: '#F0F2F5', borderRadius: 24, paddingHorizontal: 16, height: 40, marginRight: 10 },
    emptyBox: { flex: 1, justifyContent: "center", alignItems: "center" },
    modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', justifyContent: 'center', alignItems: 'center' },
    modalBox: { backgroundColor: '#FFF', padding: 20, borderRadius: 12, alignItems: 'center', width: 350 },
    reactionOutside: { position: 'absolute', bottom: -12, backgroundColor: '#FFF', borderRadius: 12, paddingHorizontal: 6, paddingVertical: 2, borderWidth: 1, borderColor: '#EEE', elevation: 3 },
    dateLabel: { fontSize: 12, color: '#666', backgroundColor: '#EAEAEA', paddingHorizontal: 10, paddingVertical: 4, borderRadius: 10 },
    messageImage: { width: 200, height: 200, borderRadius: 12 },
    replyBubble: { backgroundColor: 'rgba(0,0,0,0.05)', borderRadius: 10, padding: 8, marginBottom: 4, borderLeftWidth: 3, borderLeftColor: '#007AFF' },
    replySender: { fontSize: 11, fontWeight: 'bold', color: '#007AFF', marginBottom: 2 },
    replyText: { fontSize: 12, color: '#666', flexShrink: 1 },
    replyThumb: { width: 30, height: 30, borderRadius: 4, marginRight: 6 },
    replyPreviewBar: { backgroundColor: '#F0F2F5', padding: 10, flexDirection: 'row', alignItems: 'center', borderTopWidth: 1, borderTopColor: '#EEE' },
    replyPreviewHeader: { fontSize: 11, fontWeight: 'bold', color: '#007AFF' },
    replyPreviewText: { fontSize: 12, color: '#666' },
    replyPreviewThumb: { width: 40, height: 40, borderRadius: 4, marginRight: 10 },
    reactionItem: { marginHorizontal: 6, padding: 8 },
    modalButton: { paddingVertical: 10, alignItems: "center", width: '100%'},

    productBanner: {
        backgroundColor: '#fff',
        padding: 12,
        margin: 10,
        borderRadius: 15,
        // shadow cho nổi bật
        elevation: 3,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
      },
      bannerHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 8,
      },
      bannerHeaderText: {
        fontSize: 12,
        color: '#888',
      },
      bannerBody: {
        flexDirection: 'row',
        alignItems: 'center',
      },
      bannerImg: {
        width: 50,
        height: 50,
        borderRadius: 8,
      },
      bannerInfo: {
        flex: 1,
        marginLeft: 10,
      },
      bannerTitle: {
        fontSize: 14,
        fontWeight: '500',
        color: '#333',
      },
      bannerPrice: {
        fontSize: 14,
        color: '#ee4d2d',
        fontWeight: 'bold',
      },
      changeBtn: {
        borderWidth: 1,
        borderColor: '#ddd',
        paddingHorizontal: 10,
        paddingVertical: 5,
        borderRadius: 5,
      },
      changeBtnText: {
        fontSize: 13,
        color: '#333',
      },
    productMessageCard: {
        flexDirection: 'row',
        backgroundColor: '#fff',
        borderRadius: 12,
        padding: 12, // Tăng padding cho thoáng
        width: 280,  // Tăng chiều rộng banner (trước có thể là 220-240)
        minHeight: 100, // Tăng chiều cao tối thiểu
        borderWidth: 1,
        borderColor: '#E8E8E8',
        alignItems: 'flex-start',
        // Đổ bóng cho giống hình mẫu bạn gửi
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
    },
    productMsgImg: {
        width: 80,  // Chỉnh ảnh bự ra (từ 50 lên 80)
        height: 100, // Tăng chiều cao ảnh cho cân đối với sách
        borderRadius: 4,
        backgroundColor: '#f9f9f9',
    },
    productMsgInfo: {
        flex: 1,
        marginLeft: 12,
        justifyContent: 'center',
    },
    productMsgTitle: {
        fontSize: 15,
        fontWeight: '600',
        color: '#333',
        lineHeight: 20, // Khoảng cách dòng để đọc tên sách dễ hơn
        marginBottom: 8,
        // Không để numberOfLines ở đây để nó hiện hết tên
    },
    productMsgPrice: {
        fontSize: 16,
        color: '#ee4d2d', // Màu cam đỏ đặc trưng giá tiền
        fontWeight: '700',
    },

    // Thêm vào trong StyleSheet.create của ChatScreen.tsx
    productBanner: {
        backgroundColor: "#FFF",
        padding: 12,
        borderBottomWidth: 1,
        borderBottomColor: "#EEE",
        flexDirection: "column",
    },
    bannerHeader: {
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
        marginBottom: 8,
    },
    bannerHeaderText: {
        fontSize: 12,
        fontWeight: "600",
        color: "#007AFF",
    },
    bannerBody: {
        flexDirection: "row",
        alignItems: "center",
    },
    bannerImg: {
        width: 50,
        height: 50,
        borderRadius: 8,
        backgroundColor: "#F0F0F0",
    },
    bannerInfo: {
        flex: 1,
        marginLeft: 12,
        justifyContent: "center",
    },
    bannerTitle: {
        fontSize: 14,
        fontWeight: "700",
        color: "#333",
        marginBottom: 2,
    },
    bannerPrice: {
        fontSize: 13,
        fontWeight: "600",
        color: "#E53935", // Màu đỏ cho giá tiền
    },
    changeBtn: {
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 15,
        backgroundColor: "#F0F7FF",
        borderWidth: 1,
        borderColor: "#007AFF",
    },
    changeBtnText: {
        fontSize: 12,
        color: "#007AFF",
        fontWeight: "600",
    },
});

export default ChatScreen;