import React from "react";
import { View, Text, StyleSheet, Image, TouchableOpacity } from "react-native";
import { Ionicons } from "@expo/vector-icons";

export type RecommendBook = {
  id: string | number;
  title: string;
  author?: string;
  price?: number;
  image?: string;
};

type Props = {
  book: RecommendBook;
  onPress: () => void;
};

const C = {
  surface: "#FFFFFF",
  border: "#DDEEFF",
  text1: "#0D1B3E",
  text2: "#4A5980",
  text3: "#9AA8C8",
  red: "#E53935",
  soft: "#E3F2FD",
};

const BookRecommendCard: React.FC<Props> = ({ book, onPress }) => {
  return (
    <TouchableOpacity style={s.card} activeOpacity={0.9} onPress={onPress}>
      <Image source={{ uri: book.image || "" }} style={s.image} />
      <View style={s.info}>
        <Text style={s.title} numberOfLines={2}>{book.title}</Text>
        {!!book.author && (
          <Text style={s.author} numberOfLines={1}>{book.author}</Text>
        )}
        <Text style={s.price}>
          {typeof book.price === "number" ? `${book.price.toLocaleString("vi-VN")}đ` : "Liên hệ"}
        </Text>
        <View style={s.footer}>
          <Ionicons name="book-outline" size={12} color={C.text3} />
          <Text style={s.footerText}> Xem chi tiết</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const s = StyleSheet.create({
  card: {
    backgroundColor: C.surface,
    borderRadius: 14,
    overflow: "hidden",
    width: 220,
    marginTop: 8,
    marginRight: 12,
    borderWidth: 1,
    borderColor: C.border,
    flexDirection: "row",
    shadowColor: "#1565C0",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  image: { width: 70, height: 94, backgroundColor: C.soft },
  info: { flex: 1, padding: 10, justifyContent: "space-between" },
  title: { fontSize: 13, fontWeight: "700", color: C.text1, lineHeight: 18 },
  author: { fontSize: 12, color: C.text2, fontWeight: "600" },
  price: { fontSize: 14, fontWeight: "800", color: C.red },
  footer: { flexDirection: "row", alignItems: "center" },
  footerText: { fontSize: 11, color: C.text3 },
});

export default BookRecommendCard;
