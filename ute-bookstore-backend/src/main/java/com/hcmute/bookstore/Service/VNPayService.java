package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Untils.VNPayUtils;
import com.hcmute.bookstore.dto.PaymentDTO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
@RequiredArgsConstructor
public class VNPayService {

    @Value("${vnpay.tmnCode:}")
    private String tmnCode;

    @Value("${vnpay.hashSecret:}")
    private String hashSecret; // CHỈ DÙNG DUY NHẤT BIẾN NÀY

    @Value("${vnpay.payUrl:}")
    private String payUrl;

    @Value("${vnpay.returnUrl:}")
    private String returnUrl;

    public String createPaymentUrl(PaymentDTO dto, HttpServletRequest request) throws UnsupportedEncodingException {
        ensureConfigured();
        String vnp_Version = "2.1.0";
        String vnp_Command = "pay";
        String vnp_TxnRef = dto.getOrderId();
        long amount = dto.getAmount() * 100;

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", vnp_Version);
        params.put("vnp_Command", vnp_Command);
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(amount));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", vnp_TxnRef);

        // Sửa lại dòng này cho con
        String orderInfo = "ThanhToanDonHang" + vnp_TxnRef; // Viết liền, không dấu, không cách, không hai chấm
        params.put("vnp_OrderInfo", orderInfo);
        params.put("vnp_OrderType", "order");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", returnUrl);
        params.put("vnp_IpAddr", "127.0.0.1");

        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        String vnp_CreateDate = formatter.format(new Date());
        params.put("vnp_CreateDate", vnp_CreateDate);

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, 15);
        params.put("vnp_ExpireDate", formatter.format(cal.getTime()));

        // --- BẮT ĐẦU NỐI CHUỖI CHUẨN VNPAY 2.1.0 ---
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();

        // TreeMap đã sắp xếp sẵn theo Alphabet rồi
        Iterator<Map.Entry<String, String>> itr = params.entrySet().iterator();
        while (itr.hasNext()) {
            Map.Entry<String, String> entry = itr.next();
            String key = entry.getKey();
            String value = entry.getValue();

            if ((value != null) && (value.length() > 0)) {
                // ENCODE trước khi nối vào bất cứ đâu
                String encodedKey = URLEncoder.encode(key, StandardCharsets.US_ASCII.toString());
                String encodedValue = URLEncoder.encode(value, StandardCharsets.US_ASCII.toString());

                // 1. Build HashData (Dùng giá trị ĐÃ ENCODE)
                hashData.append(encodedKey).append('=').append(encodedValue);

                // 2. Build Query (Cũng dùng giá trị ĐÃ ENCODE)
                query.append(encodedKey).append('=').append(encodedValue);

                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }

        // Dùng hashSecret chuẩn
        String vnp_SecureHash = VNPayUtils.hmacSHA512(this.hashSecret, hashData.toString());
        String paymentUrl = payUrl + "?" + query.toString() + "&vnp_SecureHash=" + vnp_SecureHash;
        System.out.println("DEBUG - Secret used: " + this.hashSecret);
        System.out.println("DEBUG - HashData: " + hashData.toString());
        return paymentUrl;
    }

    public boolean validateReturn(Map<String, String> vnpParams) {
        String vnp_SecureHash = vnpParams.get("vnp_SecureHash");
        // 1. Phải dùng TreeMap để các tham số trả về được sắp xếp đúng A-Z
        Map<String, String> fields = new TreeMap<>();
        for (Map.Entry<String, String> entry : vnpParams.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();
            // Bỏ qua các field không dùng để băm
            if (!key.equals("vnp_SecureHash") && !key.equals("vnp_SecureHashType") && value != null && !value.isEmpty()) {
                fields.put(key, value);
            }
        }

        // 2. Nối chuỗi lại y hệt lúc tạo link (Raw data)
        StringBuilder hashData = new StringBuilder();
        Iterator<Map.Entry<String, String>> itr = fields.entrySet().iterator();
        while (itr.hasNext()) {
            Map.Entry<String, String> entry = itr.next();
            hashData.append(entry.getKey()).append('=').append(entry.getValue()); // KHÔNG ENCODE chỗ này nhen má
            if (itr.hasNext()) {
                hashData.append('&');
            }
        }

        // 3. Ký lại để so sánh
        String signValue = VNPayUtils.hmacSHA512(this.hashSecret, hashData.toString());

        System.out.println("DEBUG RETURN - Chuỗi băm trả về: " + hashData.toString());
        System.out.println("DEBUG RETURN - Chữ ký tính lại: " + signValue);
        System.out.println("DEBUG RETURN - Chữ ký VNPAY gửi: " + vnp_SecureHash);

        return signValue.equalsIgnoreCase(vnp_SecureHash);
    }

    private void ensureConfigured() {
        if (tmnCode == null || tmnCode.isBlank()
                || hashSecret == null || hashSecret.isBlank()
                || payUrl == null || payUrl.isBlank()
                || returnUrl == null || returnUrl.isBlank()) {
            throw new IllegalStateException("VNPay config missing. Set vnpay.tmnCode, vnpay.hashSecret, vnpay.payUrl, vnpay.returnUrl");
        }
    }
}