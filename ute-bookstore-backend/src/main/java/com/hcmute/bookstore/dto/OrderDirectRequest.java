package com.hcmute.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderDirectRequest {
    private String user_id;
    private String shipping_address_id;

    // Danh sách sản phẩm mua ngay (thường chỉ có 1 nhưng để List cho linh hoạt)
    private List<DirectItemDTO> items;

    private BigDecimal total_price;      // Giá gốc của các món hàng

    // --- BỔ SUNG ĐỂ KHỚP VỚI ENTITY VÀ ORDER_REQUEST ---
    private BigDecimal shipping_fee;           // Phí vận chuyển
    private BigDecimal voucher_discount;       // Số tiền giảm từ Voucher
    private BigDecimal points_discount_amount; // Số tiền quy đổi từ điểm thưởng
    // --------------------------------------------------

    private Integer discount_points;     // Số điểm thưởng khách chọn dùng
    private String discount_coupon;      // Mã code voucher
    private BigDecimal final_total;      // Tổng cuối: Total + Ship - Voucher - Points
    private String payment_method;
    private String address;
}