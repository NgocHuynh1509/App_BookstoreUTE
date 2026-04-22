import React from "react";
import { View, Text, StyleSheet } from "react-native";

type Props = {
  text: string;
  isMe: boolean;
};

const C = {
  me: "#1E88E5",
  other: "#FFFFFF",
  border: "#DDEEFF",
  text: "#0D1B3E",
};

const ChatBubble: React.FC<Props> = ({ text, isMe }) => {
  return (
    <View style={[s.bubble, isMe ? s.bubbleMe : s.bubbleOther]}>
      <Text style={isMe ? s.textMe : s.textOther}>{text}</Text>
    </View>
  );
};

const s = StyleSheet.create({
  bubble: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 18,
    marginTop: 2,
    maxWidth: "78%",
  },
  bubbleMe: {
    backgroundColor: C.me,
    alignSelf: "flex-end",
    borderBottomRightRadius: 4,
  },
  bubbleOther: {
    backgroundColor: C.other,
    alignSelf: "flex-start",
    borderBottomLeftRadius: 4,
    borderWidth: 0.5,
    borderColor: C.border,
  },
  textMe: {
    color: "#FFF",
    fontSize: 14.5,
    lineHeight: 20,
  },
  textOther: {
    color: C.text,
    fontSize: 14.5,
    lineHeight: 20,
  },
});

export default ChatBubble;

