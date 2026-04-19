import { Client } from "@stomp/stompjs";
import SockJS from "sockjs-client";
import Constants from "expo-constants";

const API_URL = Constants.expoConfig?.extra?.API_URL || "http://192.168.1.28:8080";

let stompClient = null;

export const connectNotificationSocket = (token, onMessage) => {
    if (stompClient && stompClient.active) return stompClient;

    stompClient = new Client({
        webSocketFactory: () => new SockJS(`${API_URL}/ws-bookstore`),
        connectHeaders: {
            Authorization: `Bearer ${token}`,
        },
        reconnectDelay: 5000,
        debug: (str) => {
            console.log("STOMP:", str);
        },
        onConnect: () => {
            console.log("Notification socket connected");

            stompClient.subscribe("/user/queue/notifications", (message) => {
                if (message.body) {
                    const body = JSON.parse(message.body);
                    onMessage(body);
                }
            });
        },
        onStompError: (frame) => {
            console.log("STOMP ERROR:", frame.headers["message"]);
            console.log("DETAIL:", frame.body);
        },
        onWebSocketError: (event) => {
            console.log("WS ERROR:", event);
        },
    });

    stompClient.activate();
    return stompClient;
};

export const disconnectNotificationSocket = () => {
    if (stompClient) {
        stompClient.deactivate();
        stompClient = null;
    }
};