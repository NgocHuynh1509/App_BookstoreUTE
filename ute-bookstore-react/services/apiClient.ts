import axios from 'axios';
import * as SecureStore from 'expo-secure-store';
import { BASE_URL, TOKEN_KEY } from '../constants/Config';

const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
});

// Tự động đính kèm Token vào Header cho các request sau
apiClient.interceptors.request.use(async (config) => {
  const token = await SecureStore.getItemAsync(TOKEN_KEY);
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default apiClient;