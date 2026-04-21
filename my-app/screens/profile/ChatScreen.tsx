import { useRoute, useNavigation } from "@react-navigation/native";
import React, { useState, useEffect, useRef } from "react";
import {
    View, Text, StyleSheet, TouchableOpacity, FlatList,
    TextInput, KeyboardAvoidingView, Platform, ActivityIndicator,
    Alert, Image, Modal, Animated,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import * as ImagePicker from "expo-image-picker";
import { Client } from "@stomp/stompjs";
import axios from "axios";
import Constants from "expo-constants";
import AsyncStorage from "@react-native-async-storage/async-storage";
import SockJS from "sockjs-client";
import { useHeaderHeight } from "@react-navigation/elements";
import ChatBubble from "../../components/ChatBubble";
import BookRecommendCard, { type RecommendBook } from "../../components/BookRecommendCard";

// ─── Types ────────────────────────────────────────────────────────────────────
interface Message {
    id: string;
    content: string;
    mediaUrl?: string;
    messageType: "TEXT" | "IMAGE" | "VIDEO" | "PRODUCT" | "ORDER";
    senderRole: "USER" | "ADMIN";
    createdAt: string;
    reaction?: string;
    replyToId?: string;
    replyToContent?: string;
    replyToMediaUrl?: string;
    replyToMessageType?: "TEXT" | "IMAGE" | "VIDEO" | "PRODUCT" | "ORDER";
    replyToSender?: string;
    bookId?: string;
    bookName?: string;
    bookImage?: string;
    bookPrice?: number;
    orderId?: string;
    orderStatus?: string;
    totalPrice?: number;
    orderItemCount?: number;
    image?: string;
    userName?: string;
}

interface AiMessage {
    id: string;
    role: "USER" | "AI";
    text: string;
    createdAt: string;
    recommendations?: RecommendBook[];
}

// ─── Constants ────────────────────────────────────────────────────────────────
const BASE_URL = Constants.expoConfig?.extra?.API_URL || "http://192.168.1.22:8080";

const C = {
    primary:    "#1565C0",
    mid:        "#1E88E5",
    light:      "#42A5F5",
    soft:       "#E3F2FD",
    tint:       "#BBDEFB",
    bg:         "#F0F6FF",
    surface:    "#FFFFFF",
    border:     "#DDEEFF",
    text1:      "#0D1B3E",
    text2:      "#4A5980",
    text3:      "#9AA8C8",
    orange:     "#FF8A00",
    red:        "#E53935",
    msgMe:      "#1E88E5",
    msgOther:   "#FFFFFF",
};

const REACTIONS = [
    { type: "LIKE",  emoji: "👍" },
    { type: "LOVE",  emoji: "❤️" },
    { type: "HAHA",  emoji: "😆" },
    { type: "WOW",   emoji: "😮" },
    { type: "SAD",   emoji: "😢" },
    { type: "ANGRY", emoji: "😡" },
];

// ─── Component ────────────────────────────────────────────────────────────────
const ChatScreen: React.FC = () => {
    const route      = useRoute<any>();
    const navigation = useNavigation<any>();
    const headerHeight = useHeaderHeight();

    const [activeTab, setActiveTab]           = useState<"seller" | "ai">("seller");
    const [messages, setMessages]             = useState<Message[]>([]);
    const [inputText, setInputText]           = useState("");
    const [loading, setLoading]               = useState(true);
    const [userData, setUserData]             = useState<{ username: string; token: string } | null>(null);
    const [reactionModalVisible, setReactionModalVisible] = useState(false);
    const [selectedMessage, setSelectedMessage] = useState<Message | null>(null);
    const [page, setPage]                     = useState(0);
    const [hasMore, setHasMore]               = useState(true);
    const [loadingMore, setLoadingMore]       = useState(false);
    const [showTimeId, setShowTimeId]         = useState<string | null>(null);
    const [replyMessage, setReplyMessage]     = useState<Message | null>(null);

    const [aiMessages, setAiMessages]         = useState<AiMessage[]>([]);
    const [aiInputText, setAiInputText]       = useState("");
    const [aiLoading, setAiLoading]           = useState(false);

    const stompClient  = useRef<Client | null>(null);
    const reactionAnim = useRef<{ [key: string]: Animated.Value }>({});
    const aiListRef    = useRef<FlatList<AiMessage> | null>(null);

    const { productPreview, orderPreview } = route.params || {};
    const [previewItem, setPreviewItem] = useState(productPreview);
    const [orderInfo,   setOrderInfo]   = useState(orderPreview);

    // ── Formatters ──────────────────────────────────────────────────────────────
    const formatTime = (dateStr: string) =>
        new Date(dateStr).toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" });

    const formatDateLabel = (dateStr: string) => {
        const date = new Date(dateStr);
        const now  = new Date();
        const yesterday = new Date(); yesterday.setDate(now.getDate() - 1);
        const sameDay = (a: Date, b: Date) =>
            a.getDate() === b.getDate() && a.getMonth() === b.getMonth() && a.getFullYear() === b.getFullYear();
        if (sameDay(date, now))       return "Hôm nay";
        if (sameDay(date, yesterday)) return "Hôm qua";
        return date.toLocaleDateString("vi-VN");
    };

    // ── Data loading ─────────────────────────────────────────────────────────────
    useEffect(() => {
        const getUserData = async () => {
            try {
                const savedUser = await AsyncStorage.getItem("user");
                const token     = await AsyncStorage.getItem("token");
                if (savedUser) {
                    const p = JSON.parse(savedUser);
                    setUserData({ username: p.username, token: token || p.token });
                }
            } catch (e) { console.error("Lỗi lấy thông tin user:", e); }
        };
        getUserData();
    }, []);

    useEffect(() => {
        if (activeTab === "seller" && userData) initChat();
        else disconnectWebSocket();
        return () => disconnectWebSocket();
    }, [activeTab, userData]);

    const initChat = async () => {
        setLoading(true);
        setMessages([]); setPage(0); setHasMore(true);
        await loadHistory(0);
        await connectWebSocket();
        setLoading(false);
    };

    const loadHistory = async (nextPage = 0) => {
        if (!userData || !hasMore) return;
        if (nextPage !== 0) setLoadingMore(true);
        try {
            const res = await axios.get(
                `${BASE_URL}/chat/history/${userData.username}?page=${nextPage}&size=20`,
                { headers: { Authorization: `Bearer ${userData.token}` } }
            );
            await axios.post(
                `${BASE_URL}/chat/mark-seen/${userData.username}`, {},
                { headers: { Authorization: `Bearer ${userData.token}` } }
            ).catch(() => {});
            const newMessages = res.data;
            if (newMessages.length === 0) {
                setHasMore(false);
            } else {
                setMessages(prev => {
                    const merged = [...prev, ...newMessages];
                    return merged.filter((msg, i, self) => i === self.findIndex(m => m.id === msg.id));
                });
                setPage(nextPage);
            }
        } catch (e) { console.error("History Error", e); }
        finally { setLoadingMore(false); }
    };

    // ── WebSocket ────────────────────────────────────────────────────────────────
    const connectWebSocket = async () => {
        if (!userData) return;
        const client = new Client({
            webSocketFactory: () => new SockJS(`${BASE_URL}/ws-bookstore`),
            connectHeaders: { Authorization: `Bearer ${userData.token}` },
            onConnect: () => {
                client.subscribe("/user/queue/messages", (message) => {
                    const newMsg = JSON.parse(message.body);
                    setMessages(prev => {
                        const tempIdx = prev.findIndex(
                            m => m.id.startsWith("temp-") &&
                                Math.abs(new Date(m.createdAt).getTime() - new Date(newMsg.createdAt).getTime()) < 5000
                        );
                        if (tempIdx !== -1) { const u = [...prev]; u[tempIdx] = newMsg; return u; }
                        if (prev.some(m => m.id === newMsg.id)) return prev;
                        return [newMsg, ...prev];
                    });
                });
                client.subscribe("/user/queue/reactions", (data) => {
                    const updated = JSON.parse(data.body);
                    setMessages(prev => prev.map(m => m.id === updated.id ? { ...m, reaction: updated.reaction } : m));
                });
            },
            onStompError: (f) => console.log("STOMP ERROR:", f.headers["message"]),
            reconnectDelay: 5000,
        });
        client.activate();
        stompClient.current = client;
    };

    const disconnectWebSocket = () => {
        if (stompClient.current) stompClient.current.deactivate();
    };

    // ── Sending ───────────────────────────────────────────────────────────────────
    const sendMessage = async () => {
        if (!inputText.trim() || !userData || !stompClient.current?.connected) return;
        const currentBookId  = previewItem?.id  || null;
        const currentOrderId = orderInfo?.orderId || null;

        stompClient.current.publish({
            destination: "/app/chat.sendMessage",
            body: JSON.stringify({
                userName: userData.username, receiverName: "admin", senderRole: "USER",
                content: inputText.trim(), messageType: "TEXT",
                replyToId: replyMessage?.id || null,
                bookId: currentBookId, orderId: currentOrderId,
            }),
        });

        const localMsg: Message = {
            id: `temp-${Date.now()}`,
            content: inputText.trim(),
            senderRole: "USER", messageType: "TEXT",
            createdAt: new Date().toISOString(),
            replyToId: replyMessage?.id,
            replyToContent: replyMessage?.content,
            replyToMediaUrl: replyMessage?.mediaUrl,
            replyToMessageType: replyMessage?.messageType,
            replyToSender: replyMessage?.senderRole === "ADMIN" ? "Admin" : replyMessage?.userName,
            bookId: currentBookId ?? undefined,
            orderId: currentOrderId ?? undefined,
        };

        setMessages(prev => [localMsg, ...prev]);
        setInputText("");
        setReplyMessage(null);
        if (previewItem)  setPreviewItem(null);
        if (orderInfo)    setOrderInfo(null);
    };

    const sendReaction = (type: string) => {
        if (!selectedMessage || !stompClient.current?.connected || !userData) return;
        if (selectedMessage.id.startsWith("temp-")) {
            Alert.alert("Thông báo", "Tin nhắn chưa gửi xong"); return;
        }
        stompClient.current.publish({
            destination: "/app/chat.react",
            body: JSON.stringify({ messageId: selectedMessage.id, partnerName: "admin", reaction: type }),
        });
        setMessages(prev => prev.map(m => m.id === selectedMessage.id ? { ...m, reaction: type } : m));

        if (!reactionAnim.current[selectedMessage.id])
            reactionAnim.current[selectedMessage.id] = new Animated.Value(0);
        reactionAnim.current[selectedMessage.id].setValue(0);
        Animated.spring(reactionAnim.current[selectedMessage.id], {
            toValue: 1, friction: 3, tension: 200, useNativeDriver: true,
        }).start();
        setReactionModalVisible(false);
    };

    const pickImage = async () => {
        const result = await ImagePicker.launchImageLibraryAsync({
            mediaTypes: ["images"], allowsEditing: true, quality: 0.8,
        });
        if (!result.canceled && result.assets?.length > 0) uploadAndSendImage(result.assets[0]);
    };

    const uploadAndSendImage = async (asset: any) => {
        if (!userData || !stompClient.current?.connected) return;
        const formData = new FormData();
        const uri = Platform.OS === "ios" ? asset.uri.replace("file://", "") : asset.uri;
        formData.append("file", { uri, name: asset.fileName || "image.jpg", type: asset.mimeType || "image/jpeg" } as any);
        try {
            const res = await fetch(`${BASE_URL}/chat/upload`, {
                method: "POST", headers: { Authorization: `Bearer ${userData.token}` }, body: formData,
            });
            if (!res.ok) throw new Error("Upload failed");
            const mediaUrl = await res.text();
            stompClient.current.publish({
                destination: "/app/chat.sendMessage",
                body: JSON.stringify({
                    userName: userData.username, receiverName: "admin", senderRole: "USER",
                    content: "", mediaUrl, messageType: "IMAGE", replyToId: replyMessage?.id || null,
                }),
            });
            setReplyMessage(null);
        } catch (e) {
            console.error("Upload error:", e);
            Alert.alert("Lỗi", "Không thể tải ảnh lên. Vui lòng thử lại.");
        }
    };

    const renderReplyContent = (msg: Message) => {
        if (!msg.replyToId) return null;
        const isImage = msg.replyToMessageType === "IMAGE";
        const isMe    = msg.senderRole === "USER";
        return (
            <View style={[s.replyBubble, isMe ? s.replyBubbleMe : s.replyBubbleOther]}>
                <Text style={[s.replySender, isMe ? s.replySenderMe : s.replySenderOther]}>
                    {msg.replyToSender || (msg.senderRole === "USER" ? "Admin" : "Bạn")}
                </Text>
                <View style={{ flexDirection: "row", alignItems: "center" }}>
                    {isImage && msg.replyToMediaUrl && (
                        <Image source={{ uri: `${BASE_URL}${msg.replyToMediaUrl}` }} style={s.replyThumb} />
                    )}
                    <Text numberOfLines={1} style={[s.replyText, isMe ? s.replyTextMe : s.replyTextOther]}>
                        {isImage ? "[Hình ảnh]" : msg.replyToContent}
                    </Text>
                </View>
            </View>
        );
    };

    const renderMessage = ({ item, index }: { item: Message; index: number }) => {
        const isMe     = item.senderRole === "USER";
        const prev     = messages[index + 1];
        const showDate = !prev || formatDateLabel(prev.createdAt) !== formatDateLabel(item.createdAt);
        const reactionEmoji = REACTIONS.find(r => r.type === item.reaction)?.emoji;

        return (
            <View style={{ marginBottom: 6 }}>
                {showDate && (
                    <View style={s.dateLabelWrap}>
                        <Text style={s.dateLabel}>{formatDateLabel(item.createdAt)}</Text>
                    </View>
                )}

                <TouchableOpacity
                    onPress={() => setShowTimeId(prevState => prevState === item.id ? null : item.id)}
                    onLongPress={() => {
                        if (item.senderRole !== "ADMIN") return;
                        setSelectedMessage(item);
                        setReactionModalVisible(true);
                    }}
                    activeOpacity={0.85}
                >
                    <View style={[s.msgWrapper, isMe ? s.msgWrapperMe : s.msgWrapperOther]}>
                        {renderReplyContent(item)}

                        {item.bookId && (
                            <TouchableOpacity
                                onPress={() => navigation.navigate("BookDetail", { id: item.bookId })}
                                style={[s.productCard, { alignSelf: isMe ? "flex-end" : "flex-start" }]}
                                activeOpacity={0.88}
                            >
                                <Image source={{ uri: item.bookImage }} style={s.productCardImg} />
                                <View style={s.productCardInfo}>
                                    <Text style={s.productCardTitle} numberOfLines={2}>{item.bookName}</Text>
                                    <Text style={s.productCardPrice}>
                                        {(item.bookPrice || item.totalPrice)
                                            ? `${Number(item.bookPrice || item.totalPrice).toLocaleString("vi-VN")}đ`
                                            : "Liên hệ"}
                                    </Text>
                                    <View style={s.productCardFooter}>
                                        <Ionicons name="book-outline" size={11} color={C.text3} />
                                        <Text style={s.productCardFooterText}> Xem chi tiết</Text>
                                    </View>
                                </View>
                            </TouchableOpacity>
                        )}

                        {item.orderId && (
                            <TouchableOpacity
                                onPress={() => navigation.navigate("OrderDetail", { orderId: item.orderId })}
                                style={[s.orderCard, { alignSelf: isMe ? "flex-end" : "flex-start" }]}
                                activeOpacity={0.88}
                            >
                                <View style={s.orderCardHeader}>
                                    <Ionicons name="receipt-outline" size={13} color={C.orange} />
                                    <Text style={s.orderCardId}> Đơn #{item.orderId}</Text>
                                    <View style={[s.orderStatusDot, { backgroundColor: item.orderStatus === "completed" ? "#4CAF50" : C.orange }]} />
                                    <Text style={s.orderStatusText}>{item.orderStatus}</Text>
                                </View>
                                <View style={s.orderCardBody}>
                                    {(item.image || item.bookImage) && (
                                        <Image source={{ uri: item.image || item.bookImage }} style={s.orderCardImg} />
                                    )}
                                    <View style={{ flex: 1, marginLeft: 10 }}>
                                        <Text style={s.orderCardItems}>{item.orderItemCount || 0} mặt hàng</Text>
                                        <Text style={s.orderCardTotal}>
                                            {Number(item.totalPrice).toLocaleString("vi-VN")}đ
                                        </Text>
                                    </View>
                                </View>
                            </TouchableOpacity>
                        )}

                        {item.messageType === "IMAGE" && item.mediaUrl && (
                            <Image
                                source={{ uri: `${BASE_URL}${item.mediaUrl}` }}
                                style={[s.msgImage, { alignSelf: isMe ? "flex-end" : "flex-start" }]}
                                resizeMode="cover"
                            />
                        )}

                        {item.content ? (
                            <View style={[
                                s.bubble,
                                isMe ? s.bubbleMe : s.bubbleOther,
                                { alignSelf: isMe ? "flex-end" : "flex-start" },
                            ]}>
                                <Text style={isMe ? s.bubbleTextMe : s.bubbleTextOther}>{item.content}</Text>
                                {reactionEmoji && (
                                    <View style={[s.reactionBadge, { [isMe ? "left" : "right"]: -8 }]}>
                                        <Text style={{ fontSize: 11 }}>{reactionEmoji}</Text>
                                    </View>
                                )}
                            </View>
                        ) : (
                            reactionEmoji && (
                                <View style={[s.reactionBadgeImg, { alignSelf: isMe ? "flex-end" : "flex-start" }]}>
                                    <Text style={{ fontSize: 11 }}>{reactionEmoji}</Text>
                                </View>
                            )
                        )}

                        {showTimeId === item.id && (
                            <Text style={[s.timeLabel, { textAlign: isMe ? "right" : "left" }]}>
                                {formatTime(item.createdAt)}
                            </Text>
                        )}
                    </View>
                </TouchableOpacity>
            </View>
        );
    };

    // ── AI helpers ──────────────────────────────────────────────────────────────

    const parseAiResponse = (input: unknown) => {
        if (input === null || input === undefined) {
            return "Xin lỗi, tôi chưa thể trả lời lúc này.";
        }
        if (typeof input === "string") {
            const raw = input.trim();
            if (!raw) return "Xin lỗi, tôi chưa thể trả lời lúc này.";
            if (raw.startsWith("{") && raw.endsWith("}")) {
                try {
                    const parsed = JSON.parse(raw);
                    return parseAiResponse(parsed);
                } catch {
                    return raw;
                }
            }
            return raw;
        }
        if (typeof input === "object") {
            const obj = input as { reply?: string; message?: string; text?: string };
            const text = obj.reply || obj.message || obj.text;
            if (text && typeof text === "string") return text.trim();
        }
        return "Xin lỗi, tôi chưa thể trả lời lúc này.";
    };

    const buildBookImageUrl = (image?: string) => {
        if (!image) return "";
        if (image.startsWith("http")) return image;
        if (image.startsWith("/uploads/")) return `${BASE_URL}${image}`;
        if (image.startsWith("uploads/")) return `${BASE_URL}/${image}`;
        return `${BASE_URL}/uploads/${image}`;
    };

    const InitialWelcomeMessage = ({ onSuggestionPress }: { onSuggestionPress: (text: string) => void }) => (
        <View style={s.aiWelcomeBox}>
            <View style={[s.aiBubble, s.aiBubbleOther, { alignSelf: "flex-start" }]}>
                <Text style={s.aiBubbleTextOther}>
                    {"Xin chào 👋\nMình là trợ lý AI của nhà sách.\nBạn muốn tìm thể loại sách nào?"}
                </Text>
            </View>
            <SuggestionChips onPress={onSuggestionPress} />
        </View>
    );

    const SuggestionChips = ({ onPress }: { onPress: (text: string) => void }) => {
        const suggestions = ["Tình cảm", "Trinh thám", "Self-help", "Buồn cảm động", "Lập trình"];
        return (
            <View style={s.aiSuggestWrap}>
                {suggestions.map((item) => (
                    <TouchableOpacity
                        key={item}
                        style={s.aiSuggestChip}
                        activeOpacity={0.85}
                        onPress={() => onPress(item)}
                    >
                        <Text style={s.aiSuggestText}>{item}</Text>
                    </TouchableOpacity>
                ))}
            </View>
        );
    };

    const sendAiMessage = async (overrideText?: string) => {
        const text = (overrideText ?? aiInputText).trim();
        if (!text || aiLoading) return;

        const userMsg: AiMessage = {
            id: `ai-${Date.now()}`,
            role: "USER",
            text,
            createdAt: new Date().toISOString(),
        };

        setAiMessages((prev) => [...prev, userMsg]);
        setAiInputText("");
        setAiLoading(true);

        try {
            const res = await axios.post(
                `${BASE_URL}/chat/ai`,
                { message: text, userName: userData?.username ?? null },
                {
                    timeout: 8000,
                    ...(userData?.token
                        ? { headers: { Authorization: `Bearer ${userData.token}` } }
                        : {}),
                }
            );
            const data = res?.data;
            const replyText = parseAiResponse(
                typeof data === "string" ? data : data?.reply ?? data?.message ?? data?.text ?? data
            );
            const rawBooks = data && typeof data === "object" ? data.books : undefined;
            const books = Array.isArray(rawBooks)
                ? rawBooks.map((b: any) => ({
                    id: b.id,
                    title: b.title,
                    author: b.author,
                    price: b.price,
                    image: buildBookImageUrl(b.image),
                }))
                : [];

            const aiMsg: AiMessage = {
                id: `ai-${Date.now()}-r`,
                role: "AI",
                text: replyText,
                createdAt: new Date().toISOString(),
                recommendations: books,
            };
            setAiMessages((prev) => [...prev, aiMsg]);
        } catch (e: any) {
            const isTimeout = e?.code === "ECONNABORTED" || String(e?.message || "").toLowerCase().includes("timeout");
            const fallbackText = isTimeout
                ? "AI đang bận, mình gợi ý nhanh vài sách cho bạn nhé"
                : "Xin lỗi, tôi chưa thể trả lời lúc này.";
            const aiMsg: AiMessage = {
                id: `ai-${Date.now()}-e`,
                role: "AI",
                text: fallbackText,
                createdAt: new Date().toISOString(),
            };
            setAiMessages((prev) => [...prev, aiMsg]);
        } finally {
            setAiLoading(false);
            requestAnimationFrame(() => aiListRef.current?.scrollToEnd({ animated: true }));
        }
    };

    const AiMessageBubble = ({ message }: { message: AiMessage }) => {
        const isMe = message.role === "USER";
        return <ChatBubble text={message.text} isMe={isMe} />;
    };


    const AiTypingBubble = () => (
        <View style={[s.aiBubble, s.aiBubbleOther, { alignSelf: "flex-start" }]}>
            <View style={{ flexDirection: "row", alignItems: "center", gap: 8 }}>
                <ActivityIndicator size="small" color={C.mid} />
                <Text style={s.aiBubbleTextOther}>Đang suy nghĩ...</Text>
            </View>
        </View>
    );

    const renderAiMessage = ({ item }: { item: AiMessage }) => {
        const isMe = item.role === "USER";
        return (
            <View style={[s.aiMsgWrap, isMe ? s.aiMsgWrapMe : s.aiMsgWrapOther]}>
                <AiMessageBubble message={item} />
                {!!item.recommendations?.length && (
                    <View style={s.aiRecommendList}>
                        {item.recommendations.map((book) => (
                            <BookRecommendCard
                                key={String(book.id)}
                                book={book}
                                onPress={() => navigation.navigate("BookDetail", { id: book.id })}
                            />
                        ))}
                    </View>
                )}
            </View>
        );
    };

    // ── Main render ───────────────────────────────────────────────────────────────
    return (
        <SafeAreaView style={s.root} edges={["top"]}>

            {/* Header */}
            <View style={s.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={s.backBtn}>
                    <Ionicons name="chevron-back" size={22} color={C.primary} />
                </TouchableOpacity>
                <Text style={s.headerTitle}>Tin nhắn</Text>
                <View style={{ width: 36 }} />
            </View>

            {/* Tabs */}
            <View style={s.tabBar}>
                {(["seller", "ai"] as const).map(tab => (
                    <TouchableOpacity
                        key={tab}
                        style={[s.tabItem, activeTab === tab && s.tabItemActive]}
                        onPress={() => setActiveTab(tab)}
                    >
                        <Text style={[s.tabText, activeTab === tab && s.tabTextActive]}>
                            {tab === "seller" ? "Người bán" : "Trợ lý AI"}
                        </Text>
                    </TouchableOpacity>
                ))}
            </View>

            <KeyboardAvoidingView
                behavior={Platform.OS === "ios" ? "padding" : "height"}
                style={{ flex: 1 }}
                keyboardVerticalOffset={headerHeight + (Platform.OS === "ios" ? 0 : 20)}
            >
                <View style={s.chatArea}>
                    {activeTab === "seller" ? (
                        loading
                            ? <ActivityIndicator size="large" color={C.mid} style={{ flex: 1 }} />
                            : (
                                <>
                                    {/* Product banner */}
                                    {previewItem && (
                                        <View style={s.banner}>
                                            <View style={s.bannerRow}>
                                                <Ionicons name="information-circle-outline" size={14} color={C.mid} />
                                                <Text style={s.bannerLabel}> Đang trao đổi về sản phẩm này</Text>
                                                <TouchableOpacity onPress={() => setPreviewItem(null)} hitSlop={{ top: 6, bottom: 6, left: 6, right: 6 }}>
                                                    <Ionicons name="close" size={16} color={C.text3} />
                                                </TouchableOpacity>
                                            </View>
                                            <View style={s.bannerBody}>
                                                <Image source={{ uri: previewItem.cover_image }} style={s.bannerImg} />
                                                <View style={{ flex: 1, marginLeft: 10 }}>
                                                    <Text numberOfLines={1} style={s.bannerTitle}>{previewItem.title}</Text>
                                                    <Text style={s.bannerPrice}>{previewItem.price?.toLocaleString("vi-VN")}đ</Text>
                                                </View>
                                                <TouchableOpacity style={s.bannerBtn} onPress={() => navigation.goBack()}>
                                                    <Text style={s.bannerBtnText}>Đổi</Text>
                                                </TouchableOpacity>
                                            </View>
                                        </View>
                                    )}

                                    {/* Order banner */}
                                    {!!orderInfo && (
                                        <View style={[s.banner, s.bannerOrange]}>
                                            <View style={s.bannerRow}>
                                                <Ionicons name="receipt-outline" size={14} color={C.orange} />
                                                <Text style={[s.bannerLabel, { color: C.orange }]}> Hỏi về đơn #{orderInfo.orderId}</Text>
                                                <TouchableOpacity onPress={() => setOrderInfo(null)} hitSlop={{ top: 6, bottom: 6, left: 6, right: 6 }}>
                                                    <Ionicons name="close" size={16} color={C.text3} />
                                                </TouchableOpacity>
                                            </View>
                                            <View style={s.bannerBody}>
                                                {orderInfo.image && <Image source={{ uri: orderInfo.image }} style={s.bannerImg} />}
                                                <View style={{ flex: 1, marginLeft: 10 }}>
                                                    <Text style={s.bannerTitle}>{orderInfo.productCount} sản phẩm</Text>
                                                    <Text style={s.bannerPrice}>{orderInfo.totalPrice?.toLocaleString("vi-VN")}đ</Text>
                                                </View>
                                                <TouchableOpacity style={[s.bannerBtn, s.bannerBtnOrange]} onPress={() => navigation.goBack()}>
                                                    <Text style={[s.bannerBtnText, { color: C.orange }]}>Xem</Text>
                                                </TouchableOpacity>
                                            </View>
                                        </View>
                                    )}

                                    {/* Messages */}
                                    <FlatList
                                        data={messages}
                                        keyExtractor={(item, idx) => `${item.id}-${idx}`}
                                        renderItem={renderMessage}
                                        inverted
                                        onEndReached={() => {
                                            if (!loadingMore && hasMore && messages.length >= 20) loadHistory(page + 1);
                                        }}
                                        onEndReachedThreshold={0.1}
                                        contentContainerStyle={{ paddingHorizontal: 14, paddingVertical: 12 }}
                                        ListFooterComponent={loadingMore ? <ActivityIndicator size="small" color={C.mid} style={{ padding: 10 }} /> : null}
                                    />

                                    {/* Reply preview bar */}
                                    {replyMessage && (
                                        <View style={s.replyBar}>
                                            <View style={s.replyBarAccent} />
                                            <View style={{ flex: 1, marginLeft: 10 }}>
                                                <Text style={s.replyBarHeader}>
                                                    Trả lời {replyMessage.senderRole === "ADMIN" ? "Admin" : "Bạn"}
                                                </Text>
                                                <Text numberOfLines={1} style={s.replyBarText}>
                                                    {replyMessage.messageType === "IMAGE" ? "[Hình ảnh]" : replyMessage.content}
                                                </Text>
                                            </View>
                                            {replyMessage.messageType === "IMAGE" && (
                                                <Image source={{ uri: `${BASE_URL}${replyMessage.mediaUrl}` }} style={s.replyBarThumb} />
                                            )}
                                            <TouchableOpacity onPress={() => setReplyMessage(null)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                                                <Ionicons name="close-circle" size={20} color={C.text3} />
                                            </TouchableOpacity>
                                        </View>
                                    )}

                                    {/* Input area */}
                                    <View style={s.inputArea}>
                                        <TouchableOpacity onPress={pickImage} style={s.inputIconBtn}>
                                            <Ionicons name="image-outline" size={24} color={C.mid} />
                                        </TouchableOpacity>
                                        <TextInput
                                            style={s.input}
                                            placeholder="Nhập tin nhắn..."
                                            placeholderTextColor={C.text3}
                                            value={inputText}
                                            onChangeText={setInputText}
                                            multiline
                                        />
                                        <TouchableOpacity
                                            onPress={sendMessage}
                                            style={[s.sendBtn, !inputText.trim() && s.sendBtnDisabled]}
                                            disabled={!inputText.trim()}
                                        >
                                            <Ionicons name="send" size={18} color="#FFF" />
                                        </TouchableOpacity>
                                    </View>
                                </>
                            )
                    ) : (
                        <View style={{ flex: 1 }}>
                            <FlatList
                                ref={aiListRef}
                                data={aiMessages}
                                keyExtractor={(item) => item.id}
                                renderItem={renderAiMessage}
                                contentContainerStyle={{ paddingHorizontal: 14, paddingVertical: 12 }}
                                onContentSizeChange={() => aiListRef.current?.scrollToEnd({ animated: true })}
                                onLayout={() => aiListRef.current?.scrollToEnd({ animated: true })}
                                ListFooterComponent={aiLoading ? <AiTypingBubble /> : null}
                                ListEmptyComponent={
                                    <InitialWelcomeMessage onSuggestionPress={(text) => sendAiMessage(text)} />
                                }
                            />

                            <View style={s.inputArea}>
                                <TextInput
                                    style={s.input}
                                    placeholder="Hỏi BookAI về sách..."
                                    placeholderTextColor={C.text3}
                                    value={aiInputText}
                                    onChangeText={setAiInputText}
                                    multiline
                                />
                                <TouchableOpacity
                                    onPress={() => sendAiMessage()}
                                    style={[s.sendBtn, (!aiInputText.trim() || aiLoading) && s.sendBtnDisabled]}
                                    disabled={!aiInputText.trim() || aiLoading}
                                >
                                    <Ionicons name="send" size={18} color="#FFF" />
                                </TouchableOpacity>
                            </View>
                        </View>
                    )}
                </View>
            </KeyboardAvoidingView>

            {/* Reaction modal */}
            <Modal visible={reactionModalVisible} transparent animationType="fade">
                <TouchableOpacity
                    style={s.modalOverlay}
                    activeOpacity={1}
                    onPress={() => { setReactionModalVisible(false); setSelectedMessage(null); }}
                >
                    <View style={s.modalBox}>
                        <Text style={s.modalTitle}>Cảm xúc</Text>
                        <View style={s.reactionsRow}>
                            {REACTIONS.map(item => (
                                <TouchableOpacity key={item.type} onPress={() => sendReaction(item.type)} style={s.reactionItem}>
                                    <Text style={{ fontSize: 26 }}>{item.emoji}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                        <View style={s.modalDivider} />
                        <TouchableOpacity
                            onPress={() => {
                                setReplyMessage(selectedMessage);
                                setReactionModalVisible(false);
                                setSelectedMessage(null);
                            }}
                            style={s.modalAction}
                        >
                            <Ionicons name="return-down-back-outline" size={16} color={C.mid} />
                            <Text style={s.modalActionText}> Trả lời</Text>
                        </TouchableOpacity>
                    </View>
                </TouchableOpacity>
            </Modal>
        </SafeAreaView>
    );
};

// ─── Styles ───────────────────────────────────────────────────────────────────
const s = StyleSheet.create({
    root:         { flex: 1, backgroundColor: C.surface },

    // Header
    header:       { flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingHorizontal: 14, paddingVertical: 12, backgroundColor: C.surface, borderBottomWidth: 0.5, borderBottomColor: C.border },
    backBtn:      { width: 36, height: 36, borderRadius: 18, backgroundColor: C.soft, alignItems: "center", justifyContent: "center" },
    headerTitle:  { fontSize: 17, fontWeight: "800", color: C.text1 },

    // Tabs
    tabBar:       { flexDirection: "row", paddingHorizontal: 16, backgroundColor: C.surface, borderBottomWidth: 0.5, borderBottomColor: C.border },
    tabItem:      { marginRight: 24, paddingVertical: 12 },
    tabItemActive:{ borderBottomWidth: 2.5, borderBottomColor: C.mid },
    tabText:      { fontSize: 15, color: C.text3, fontWeight: "600" },
    tabTextActive:{ color: C.mid, fontWeight: "700" },

    // Chat area
    chatArea:     { flex: 1, backgroundColor: C.bg },

    // Banners
    banner: {
        backgroundColor: C.surface,
        marginHorizontal: 12, marginTop: 10,
        borderRadius: 14,
        padding: 12,
        borderWidth: 1, borderColor: C.tint,
        borderLeftWidth: 3, borderLeftColor: C.mid,
    },
    bannerOrange: { borderColor: "#FFE0B2", borderLeftColor: C.orange },
    bannerRow:    { flexDirection: "row", alignItems: "center", marginBottom: 8 },
    bannerLabel:  { flex: 1, fontSize: 12, fontWeight: "700", color: C.mid },
    bannerBody:   { flexDirection: "row", alignItems: "center" },
    bannerImg:    { width: 44, height: 56, borderRadius: 8, backgroundColor: C.soft },
    bannerTitle:  { fontSize: 13, fontWeight: "700", color: C.text1, lineHeight: 18, marginBottom: 2 },
    bannerPrice:  { fontSize: 13, fontWeight: "700", color: C.red },
    bannerBtn:    { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 10, backgroundColor: C.soft, borderWidth: 1, borderColor: C.tint },
    bannerBtnOrange: { backgroundColor: "#FFF3E0", borderColor: "#FFE0B2" },
    bannerBtnText:   { fontSize: 12, fontWeight: "700", color: C.mid },

    // Messages
    msgWrapper:      { maxWidth: "78%" },
    msgWrapperMe:    { alignSelf: "flex-end" },
    msgWrapperOther: { alignSelf: "flex-start" },

    bubble:        { paddingHorizontal: 14, paddingVertical: 10, borderRadius: 18, marginTop: 2, position: "relative" },
    bubbleMe:      { backgroundColor: C.msgMe, borderBottomRightRadius: 4 },
    bubbleOther:   { backgroundColor: C.msgOther, borderBottomLeftRadius: 4, borderWidth: 0.5, borderColor: C.border },
    bubbleTextMe:  { color: "#FFF", fontSize: 14.5, lineHeight: 20 },
    bubbleTextOther: { color: C.text1, fontSize: 14.5, lineHeight: 20 },

    msgImage: { width: 200, height: 200, borderRadius: 14, marginTop: 2 },

    // Reply bubbles
    replyBubble:      { borderRadius: 10, padding: 8, marginBottom: 4, borderLeftWidth: 3 },
    replyBubbleMe:    { backgroundColor: "rgba(255,255,255,0.15)", borderLeftColor: "rgba(255,255,255,0.6)" },
    replyBubbleOther: { backgroundColor: C.soft, borderLeftColor: C.mid },
    replySender:      { fontSize: 11, fontWeight: "700", marginBottom: 2 },
    replySenderMe:    { color: "rgba(255,255,255,0.9)" },
    replySenderOther: { color: C.mid },
    replyText:        { fontSize: 12, flexShrink: 1 },
    replyTextMe:      { color: "rgba(255,255,255,0.8)" },
    replyTextOther:   { color: C.text2 },
    replyThumb:       { width: 28, height: 28, borderRadius: 4, marginRight: 6 },

    // Reaction badges
    reactionBadge:    { position: "absolute", bottom: -10, backgroundColor: "#FFF", borderRadius: 10, paddingHorizontal: 5, paddingVertical: 2, borderWidth: 0.5, borderColor: C.border, elevation: 2 },
    reactionBadgeImg: { backgroundColor: "#FFF", borderRadius: 10, paddingHorizontal: 5, paddingVertical: 2, borderWidth: 0.5, borderColor: C.border, elevation: 2, marginTop: 4 },

    // Timestamp
    timeLabel: { fontSize: 10, color: C.text3, marginTop: 4, marginHorizontal: 4 },

    // Date label
    dateLabelWrap: { alignItems: "center", marginVertical: 12 },
    dateLabel:     { fontSize: 11.5, color: C.text3, backgroundColor: "#E8EFF9", paddingHorizontal: 12, paddingVertical: 4, borderRadius: 99, fontWeight: "600" },

    // Product card in message
    productCard: {
        backgroundColor: C.surface, borderRadius: 14, overflow: "hidden",
        width: 260, marginTop: 2, borderWidth: 1, borderColor: C.border,
        flexDirection: "row",
        shadowColor: C.primary, shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3,
    },
    productCardImg:        { width: 72, height: 96, backgroundColor: C.soft },
    productCardInfo:       { flex: 1, padding: 10, justifyContent: "space-between" },
    productCardTitle:      { fontSize: 13, fontWeight: "700", color: C.text1, lineHeight: 18 },
    productCardPrice:      { fontSize: 14, fontWeight: "800", color: C.red },
    productCardFooter:     { flexDirection: "row", alignItems: "center" },
    productCardFooterText: { fontSize: 11, color: C.text3 },

    // Order card in message
    orderCard: {
        backgroundColor: C.surface, borderRadius: 14, overflow: "hidden",
        width: 260, marginTop: 2, borderWidth: 1, borderColor: "#FFE0B2",
        borderLeftWidth: 3, borderLeftColor: C.orange,
        shadowColor: C.orange, shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 8, elevation: 3,
    },
    orderCardHeader:   { flexDirection: "row", alignItems: "center", paddingHorizontal: 12, paddingTop: 10, paddingBottom: 6 },
    orderCardId:       { fontSize: 12, fontWeight: "700", color: C.orange, flex: 1 },
    orderStatusDot:    { width: 7, height: 7, borderRadius: 3.5, marginRight: 4 },
    orderStatusText:   { fontSize: 11, color: C.text2 },
    orderCardBody:     { flexDirection: "row", alignItems: "center", paddingHorizontal: 12, paddingBottom: 10 },
    orderCardImg:      { width: 44, height: 56, borderRadius: 8, backgroundColor: C.soft },
    orderCardItems:    { fontSize: 12, color: C.text2, fontWeight: "600", marginBottom: 4 },
    orderCardTotal:    { fontSize: 14, fontWeight: "800", color: C.red },

    // Reply bar
    replyBar:       { flexDirection: "row", alignItems: "center", backgroundColor: C.surface, paddingHorizontal: 14, paddingVertical: 10, borderTopWidth: 0.5, borderTopColor: C.border },
    replyBarAccent: { width: 3, height: 36, backgroundColor: C.mid, borderRadius: 2 },
    replyBarHeader: { fontSize: 11, fontWeight: "700", color: C.mid, marginBottom: 2 },
    replyBarText:   { fontSize: 12, color: C.text2 },
    replyBarThumb:  { width: 36, height: 36, borderRadius: 6, marginHorizontal: 8 },

    // Input area
    inputArea:       { flexDirection: "row", alignItems: "flex-end", paddingHorizontal: 12, paddingVertical: 10, backgroundColor: C.surface, borderTopWidth: 0.5, borderTopColor: C.border, gap: 8 },
    inputIconBtn:    { width: 38, height: 38, borderRadius: 19, backgroundColor: C.soft, alignItems: "center", justifyContent: "center" },
    input:           { flex: 1, backgroundColor: C.soft, borderRadius: 20, paddingHorizontal: 16, paddingVertical: 9, fontSize: 14.5, color: C.text1, maxHeight: 100, borderWidth: 1, borderColor: C.tint },
    sendBtn:         { width: 38, height: 38, borderRadius: 19, backgroundColor: C.mid, alignItems: "center", justifyContent: "center" },
    sendBtnDisabled: { backgroundColor: C.tint },

    // Empty
    emptyBox:  { flex: 1, justifyContent: "center", alignItems: "center", gap: 12 },
    emptyText: { fontSize: 15, color: C.text3, fontWeight: "600" },

    // Modal
    modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.45)", justifyContent: "center", alignItems: "center" },
    modalBox:     { backgroundColor: C.surface, borderRadius: 20, padding: 20, alignItems: "center", width: 320 },
    modalTitle:   { fontSize: 15, fontWeight: "800", color: C.text1, marginBottom: 14 },
    reactionsRow: { flexDirection: "row", gap: 4 },
    reactionItem: { padding: 8, borderRadius: 12 },
    modalDivider: { height: 0.5, backgroundColor: C.border, width: "100%", marginVertical: 14 },
    modalAction:  { flexDirection: "row", alignItems: "center", paddingVertical: 6 },
    modalActionText: { fontSize: 14, fontWeight: "700", color: C.mid },

    // AI messages
    aiMsgWrap:      { marginBottom: 12, maxWidth: "75%" },
    aiMsgWrapMe:    { alignSelf: "flex-end" },
    aiMsgWrapOther: { alignSelf: "flex-start" },
    aiBubble:        { paddingHorizontal: 14, paddingVertical: 10, borderRadius: 18, marginTop: 2, position: "relative" },
    aiBubbleMe:      { backgroundColor: C.msgMe, borderBottomRightRadius: 4 },
    aiBubbleOther:   { backgroundColor: C.msgOther, borderBottomLeftRadius: 4, borderWidth: 0.5, borderColor: C.border },
    aiBubbleTextMe:  { color: "#FFF", fontSize: 14.5, lineHeight: 20 },
    aiBubbleTextOther: { color: C.text1, fontSize: 14.5, lineHeight: 20 },


    // AI typing bubble
    aiTypingBubble: {
        backgroundColor: C.msgOther,
        borderRadius: 18,
        padding: 10,
        marginTop: 2,
        alignSelf: "flex-start",
        flexDirection: "row",
        alignItems: "center",
        gap: 8,
    },
    aiRecommendList: { paddingLeft: 6 },
    aiWelcomeBox: { paddingHorizontal: 14, paddingVertical: 10 },
    aiSuggestWrap: { flexDirection: "row", flexWrap: "wrap", gap: 8, marginTop: 10 },
    aiSuggestChip: {
        backgroundColor: C.surface,
        borderWidth: 1,
        borderColor: C.tint,
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 16,
    },
    aiSuggestText: { fontSize: 12.5, color: C.text1, fontWeight: "600" },
});

export default ChatScreen;

