import AsyncStorage from "@react-native-async-storage/async-storage";
import { useEffect, useState } from "react";
import api from "../services/api";

export const useAuth = () => {
  const [user, setUser] = useState<any>(null);
  const [loadingUser, setLoadingUser] = useState(true);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      setLoadingUser(true);

      const token = await AsyncStorage.getItem("token");
      console.log("LOAD USER TOKEN:", token);

      if (!token) {
        setUser(null);
        return;
      }

      const res = await api.get("/profile", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      console.log("PROFILE RESPONSE:", res.data);

      const profile = {
        id: res.data.id,
        username: res.data.username ?? res.data.userName,
        fullName: res.data.fullName,
        email: res.data.email,
        phone: res.data.phone,
        address: res.data.address,
        avatar: res.data.avatar,
        reward_points: res.data.reward_points ?? res.data.rewardPoints ?? 0,
        role: res.data.role,
        token,
      };

      await AsyncStorage.setItem("user", JSON.stringify(profile));
      setUser(profile);
    } catch (error: any) {
      console.log("LOAD USER STATUS:", error?.response?.status);
      console.log("LOAD USER DATA:", error?.response?.data);
      console.log("Load user failed:", error);
      setUser(null);
    } finally {
      setLoadingUser(false);
    }
  };

  const saveUser = async (data: any) => {
    try {
      if (data.token) {
        await AsyncStorage.setItem("token", data.token);
      }

      const basicUser = {
        id: data.id ?? data.userId,
        username: data.username ?? data.userName,
        role: data.role,
        token: data.token,
      };

      await AsyncStorage.setItem("user", JSON.stringify(basicUser));
      setUser(basicUser);

      await loadUser();
    } catch (error) {
      console.log("Save user failed:", error);
    }
  };

  const logout = async () => {
    await AsyncStorage.removeItem("user");
    await AsyncStorage.removeItem("token");
    setUser(null);
  };

  return { user, saveUser, logout, loadUser, loadingUser };
};