
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useEffect, useState } from "react";

export const useAuth = () => {
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    loadUser();
  }, []);

  const loadUser = async () => {
    try {
      const savedUser = await AsyncStorage.getItem("user");
      if (savedUser) {
        setUser(JSON.parse(savedUser));
      }
    } catch (error) {
      console.log("Load user failed:", error);
    }
  };

  const saveUser = async (data: any) => {
    try {
      if (data.token) {
        await AsyncStorage.setItem("token", data.token);
      }
      await AsyncStorage.setItem("user", JSON.stringify(data));
      setUser(data);
    } catch (error) {
      console.log("Save user failed:", error);
    }
  };

  const logout = async () => {
    await AsyncStorage.removeItem("user");
    await AsyncStorage.removeItem("token");
    setUser(null);
  };

  return { user, saveUser, logout, loadUser };
};