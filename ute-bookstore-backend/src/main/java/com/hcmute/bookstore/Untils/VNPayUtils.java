package com.hcmute.bookstore.Untils;

import jakarta.servlet.http.HttpServletRequest;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class VNPayUtils {

    // Trong VNPayUtils.java
    public static String hmacSHA512(String key, String data) {
        try {
            if (key == null || data == null) return "";
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(128);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff)); // Dùng cái này để ra mã hex chuẩn 128 ký tự
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }
    //Lấy toàn bộ params VNPay trả về từ request
    public static Map<String, String> getVnPayReturnData(HttpServletRequest request) {

        Map<String, String> fields = new HashMap<>();

        Map<String, String[]> requestParams = request.getParameterMap();
        for (Map.Entry<String, String[]> entry : requestParams.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue()[0]; // lấy phần tử đầu tiên
            fields.put(key, value);
        }

        return fields;
    }
}

