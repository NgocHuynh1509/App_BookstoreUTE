import apiClient from './apiClient';
import * as SecureStore from 'expo-secure-store';
import { TOKEN_KEY } from '../constants/Config';

// services/authService.ts

export const loginService = async (email: string, password: string) => {
  try {
    const response = await apiClient.post('/auth/login', {
      userName: email, // Giá trị lấy từ input email, nhưng key gửi lên phải là userName
      password: password
    });

    if (response.data.accessToken) {
      await SecureStore.setItemAsync(TOKEN_KEY, response.data.accessToken);
    }
    return response.data;
  } catch (error: any) {
    // Log lỗi chi tiết để debug nếu vẫn trượt
    console.log("Chi tiết lỗi validation:", error.response?.data);
    throw error.response?.data?.message || 'Lỗi đăng nhập';
  }
};

// 2. Đăng ký
export const registerService = async (registerData: any) => {
  try {
    const response = await apiClient.post('/auth/register', registerData);
    return response.data; // Trả về { message: "..." }
  } catch (error: any) {
    throw error.response?.data?.message || 'Lỗi đăng ký';
  }
};

// 3. Xác thực OTP
export const verifyOtpService = async (otpData: { email: string, otp: string }) => {
  try {
    const response = await apiClient.post('/auth/verify-register-otp', otpData);
    return response.data;
  } catch (error: any) {
    throw error.response?.data?.message || 'OTP không hợp lệ';
  }
};

// 4. Gửi lại OTP (Dùng @RequestParam nên truyền qua params)
export const resendOtpService = async (email: string, otpType: string) => {
  try {
    const response = await apiClient.post('/auth/resend-otp', null, {
      params: { email, otpType }
    });
    return response.data;
  } catch (error: any) {
    throw error.response?.data?.message || 'Không thể gửi lại OTP';
  }
};

// 5. Quên mật khẩu
export const forgotPasswordService = async (email: string) => {
  try {
    const response = await apiClient.post('/auth/forgot-password', { email });
    return response.data;
  } catch (error: any) {
    throw error.response?.data?.message || 'Lỗi gửi yêu cầu';
  }
};