import React, { createContext, useContext, useEffect, useState } from "react";
import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Constants from "expo-constants";
import {
    connectNotificationSocket,
    disconnectNotificationSocket,
} from "../sockets/notificationSocket";

const API_URL = Constants.expoConfig?.extra?.API_URL || "http://192.168.1.28:8080";

const NotificationContext = createContext();

export const useNotification = () => {
    return useContext(NotificationContext);
};

export const NotificationProvider = ({ children }) => {
    const [notifications, setNotifications] = useState([]);
    const [unreadCount, setUnreadCount] = useState(0);

    const getAuthHeaders = async () => {
        const token = await AsyncStorage.getItem("token");
        return {
            Authorization: `Bearer ${token}`,
        };
    };

    const fetchNotifications = async () => {
        try {
            const headers = await getAuthHeaders();
            const res = await axios.get(`${API_URL}/api/notifications`, { headers });
            setNotifications(res.data.content || []);
        } catch (err) {
            console.log("FETCH NOTI ERROR:", err?.response?.data || err.message);
        }
    };

    const fetchUnread = async () => {
        try {
            const headers = await getAuthHeaders();
            const res = await axios.get(`${API_URL}/api/notifications/unread-count`, { headers });
            setUnreadCount(res.data || 0);
        } catch (err) {
            console.log("UNREAD ERROR:", err?.response?.data || err.message);
        }
    };

    const markAsRead = async (id) => {
        try {
            const headers = await getAuthHeaders();
            await axios.put(`${API_URL}/api/notifications/${id}/read`, {}, { headers });

            setNotifications((prev) =>
                prev.map((n) => (n.id === id ? { ...n, isRead: true } : n))
            );

            setUnreadCount((prev) => Math.max(prev - 1, 0));
        } catch (err) {
            console.log("MARK READ ERROR:", err?.response?.data || err.message);
        }
    };

    const markAllAsRead = async () => {
        try {
            const headers = await getAuthHeaders();
            await axios.put(`${API_URL}/api/notifications/read-all`, {}, { headers });

            // cập nhật UI luôn
            setNotifications((prev) =>
                prev.map((n) => ({ ...n, isRead: true }))
            );

            setUnreadCount(0);
        } catch (err) {
            console.log("MARK ALL ERROR:", err?.response?.data || err.message);
        }
    };

    useEffect(() => {
        fetchNotifications();
        fetchUnread();

        const initSocket = async () => {
            const token = await AsyncStorage.getItem("token");
            if (!token) return;

            connectNotificationSocket(token, (newNoti) => {
                setNotifications((prev) => [newNoti, ...prev]);
                setUnreadCount((prev) => prev + 1);
            });
        };

        initSocket();

        return () => {
            disconnectNotificationSocket();
        };
    }, []);

    return (
        <NotificationContext.Provider
            value={{
                notifications,
                unreadCount,
                markAsRead,
                markAllAsRead,
                refresh: fetchNotifications,
            }}
        >
            {children}
        </NotificationContext.Provider>
    );
};