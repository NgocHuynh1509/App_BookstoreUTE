package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.*;
import com.hcmute.bookstore.Repository.*;
import com.hcmute.bookstore.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrdersRepository ordersRepository;
    private final UsersRepository usersRepository;
    private final OrderDetailRepository orderDetailRepository;
    @Autowired
    private CouponRepository couponRepo;
    @Autowired private BooksRepository bookRepo;
    @Autowired private ShippingAddressRepository addressRepo;
    @Autowired private CartRepository cartRepo;
    @Autowired private CartDetailRepository cartDetailRepo;

    public List<OrderHistoryResponse> getOrdersByUserId(String userIdFromClient, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        if (!customerId.equals(userIdFromClient)) {
            throw new RuntimeException("Bạn không có quyền xem đơn hàng này");
        }

        List<Orders> orders = ordersRepository.findByCustomer_CustomerIdOrderByOrderDateDesc(customerId);

        return orders.stream()
                .map(order -> new OrderHistoryResponse(
                        order.getOrderId(),
                        normalizeHistoryStatus(order.getStatus()),
                        order.getOrderDate(),
                        order.getTotalAmount()
                ))
                .toList();
    }

//    private String normalizeStatus(String status) {
//        if (status == null) return "pending";
//
//        return switch (status.trim().toLowerCase()) {
//            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
//            case "processing", "dang_xu_ly", "đang xử lý" -> "processing";
//            case "shipping", "dang_giao", "đang giao" -> "shipping";
//            case "completed", "hoan_thanh", "hoàn thành" -> "completed";
//            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
//            default -> status.toLowerCase();
//        };
//    }

    private String normalizeHistoryStatus(String status) {
        if (status == null) return "pending";

        return switch (status.trim().toLowerCase()) {
            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
            case "confirmed", "da_xac_nhan", "đã xác nhận",
                 "processing", "dang_xu_ly", "đang xử lý",
                 "preparing", "dang_chuan_bi", "đang chuẩn bị" -> "confirmed";
            case "shipping", "dang_giao", "đang giao", "delivery" -> "shipping";
            case "completed", "hoan_thanh", "hoàn thành",
                 "success", "giao_thanh_cong" -> "completed";
            case "returned", "hoan_tra", "hoàn trả" -> "returned";
            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
            default -> "pending";
        };
    }

    private String normalizeDetailStatus(String status) {
        if (status == null) return "pending";

        return switch (status.trim().toLowerCase()) {
            case "pending", "cho_xac_nhan", "chờ xác nhận" -> "pending";
            case "confirmed", "da_xac_nhan", "đã xác nhận",
                 "processing", "dang_xu_ly", "đang xử lý",
                 "preparing", "dang_chuan_bi", "đang chuẩn bị" -> "confirmed";
            case "shipping", "delivery", "dang_giao", "đang giao" -> "shipping";
            case "completed", "success", "hoan_thanh", "hoàn thành", "giao_thanh_cong" -> "completed";
            case "returned", "hoan_tra", "hoàn trả" -> "returned";
            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
            default -> "pending";
        };
    }

    public OrderDetailResponse getOrderDetail(String orderId, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        Orders order = ordersRepository.findByOrderIdAndCustomer_CustomerId(orderId, customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        List<OrderDetail> orderDetails = orderDetailRepository.findByOrder_OrderId(orderId);

        List<OrderDetailItemResponse> items = orderDetails.stream()
                .map(od -> new OrderDetailItemResponse(
                        od.getBook().getBookId(),
                        od.getBook().getTitle(),
                        od.getQuantity(),
                        od.getUnitPrice()
                ))
                .toList();

//        String address;
//        if (order.getShippingAddress() != null) {
//            var sa = order.getShippingAddress();
//
//            address = sa.getSpecificAddress()
//                    + (sa.getWard() != null ? ", " + sa.getWard() : "")
//                    + ", " + sa.getDistrict()
//                    + ", " + sa.getProvince();
//        } else {
//            address = order.getAddress();
//        }
//
//        String customerName = user.getFullName() != null
//                ? user.getFullName()
//                : (user.getCustomer() != null ? user.getCustomer().getFullName() : "Khách hàng");
//
//        String phone = user.getCustomer() != null
//                ? user.getCustomer().getPhone()
//                : "";
        String address;
        String customerName;
        String phone;

        if (order.getShippingAddress() != null) {
            var sa = order.getShippingAddress();

            address = sa.getSpecificAddress()
                    + (sa.getWard() != null ? ", " + sa.getWard() : "")
                    + ", " + sa.getDistrict()
                    + ", " + sa.getProvince();

            customerName = sa.getRecipientName();
            phone = sa.getPhoneNumber();
        } else {
            address = order.getAddress();

            customerName = user.getFullName();
            phone = user.getCustomer() != null ? user.getCustomer().getPhone() : "";
        }

        return new OrderDetailResponse(
                order.getOrderId(),
                normalizeDetailStatus(order.getStatus()),
                order.getOrderDate(),
                order.getTotalAmount(),
                address,
                customerName,
                phone,
                order.getPaymentMethod(), // <--- Bổ sung lôi từ Entity ra đây
                order.getShippingFee(),
                order.getVoucherDiscount() != null ? order.getVoucherDiscount() : BigDecimal.ZERO,
                order.getPointsDiscount() != null ? order.getPointsDiscount() : BigDecimal.ZERO,
                items
        );
    }

    @Transactional
    public String cancelOrder(String orderId, String emailFromToken) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        Orders order = ordersRepository.findByOrderIdAndCustomer_CustomerId(orderId, customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        String normalizedStatus = normalizeHistoryStatus(order.getStatus());
        if (!"pending".equals(normalizedStatus)) {
            throw new RuntimeException("Chỉ có thể huỷ đơn đang chờ xác nhận");
        }

        Date now = new Date();
        long diffMillis = now.getTime() - order.getOrderDate().getTime();
        long diffMinutes = TimeUnit.MILLISECONDS.toMinutes(diffMillis);

        if (diffMinutes > 60) {
            throw new RuntimeException("Đã quá 60 phút, không thể huỷ đơn hàng");
        }

        // --- LOGIC QUAN TRỌNG: HOÀN KHO & TRỪ ĐÃ BÁN ---
        List<OrderDetail> details = order.getOrderDetail_Order();
        for (OrderDetail detail : details) {
            Books book = detail.getBook();
            int quantityToReturn = detail.getQuantity();

            // 1. Cộng lại vào kho (quantity)
            book.setQuantity(book.getQuantity() + quantityToReturn);

            // 2. Trừ bớt số lượng đã bán (soldQuantity)
            // Lưu ý: Phải check để không bị âm (đề phòng lỗi logic)
            int newSoldQuantity = Math.max(0, book.getSoldQuantity() - quantityToReturn);
            book.setSoldQuantity(newSoldQuantity);

            // Lưu cập nhật cho từng cuốn sách
            bookRepo.save(book);
        }

        // Cập nhật trạng thái đơn hàng
        order.setStatus("cancelled");
        ordersRepository.save(order);

        return "Đơn hàng đã được huỷ thành công.";
    }

    @Transactional(rollbackFor = Exception.class)
    public String createOrder(OrderRequest request) throws Exception {
        // 1. Kiểm tra User thông qua Customer ID gửi từ Frontend (request.getUser_id())
        Users user = usersRepository.findByCustomer_CustomerId(request.getUser_id())
                .orElseThrow(() -> new Exception("Không tìm thấy User với Customer ID: " + request.getUser_id()));

        Customers customer = user.getCustomer();
        if (customer == null) {
            throw new Exception("Người dùng chưa có thông tin khách hàng (Customer)");
        }

        // 2. Xử lý trừ điểm thưởng (Reward Points)
        if (request.getDiscount_points() != null && request.getDiscount_points() > 0) {
            if (user.getRewardPoints() < request.getDiscount_points()) {
                throw new Exception("Không đủ điểm thưởng");
            }
            user.setRewardPoints(user.getRewardPoints() - request.getDiscount_points());
            usersRepository.save(user);
        }

        // 3. Xử lý Coupon
        if (request.getDiscount_coupon() != null && !request.getDiscount_coupon().isEmpty()) {
            Coupon coupon = couponRepo.findByCode(request.getDiscount_coupon())
                    .orElseThrow(() -> new Exception("Mã giảm giá không hợp lệ"));

            if (coupon.getUsedCount() >= coupon.getUsageLimit()) {
                throw new Exception("Mã giảm giá đã hết lượt sử dụng");
            }

            coupon.setUsedCount(coupon.getUsedCount() + 1);
            couponRepo.save(coupon);
        }

        // 4. Tạo thực thể Order
        String orderId = "ORD" + System.currentTimeMillis();
        Orders order = new Orders();
        order.setOrderId(orderId);
        order.setCustomer(customer);
        order.setPaymentMethod(request.getPayment_method());
        order.setTotalAmount(request.getFinal_total());

        // Ưu tiên lấy address string từ request, nếu không có thì để mặc định
        String shippingAddr = request.getAddress() != null ? request.getAddress() : "Giao đến ID: " + request.getShipping_address_id();
        order.setAddress(shippingAddr);

        order.setStatus("PENDING");
        order.setOrderDate(new Date());
        // --- MÁ CHÈN THÊM MẤY DÒNG NÀY VÀO ĐÂY ---
        order.setShippingFee(request.getShipping_fee() != null ? request.getShipping_fee() : BigDecimal.ZERO);
        order.setVoucherDiscount(request.getVoucher_discount() != null ? request.getVoucher_discount() : BigDecimal.ZERO);
        order.setPointsDiscount(request.getPoints_discount_amount() != null ? request.getPoints_discount_amount() : BigDecimal.ZERO);

// Ghi chú tự động dựa trên mã giảm giá (tùy chọn)
        String autoNote = "Đơn hàng mới";
        if (request.getDiscount_coupon() != null) autoNote += " | Voucher: " + request.getDiscount_coupon();
        order.setNote(autoNote);
// -----------------------------------------

        // Gán shipping address entity (khóa ngoại)
        if (request.getShipping_address_id() != null) {
            ShippingAddress sa = addressRepo.findById(request.getShipping_address_id()).orElse(null);
            order.setShippingAddress(sa);
        }

        ordersRepository.save(order);

        // 5. Lưu OrderDetails, Cập nhật kho và Tăng số lượng đã bán
        List<String> purchasedBookIds = new ArrayList<>();

        for (CartItemDTO item : request.getItems()) {
            // Lưu ý: Đảm bảo item.getBook_id() không bị null
            Books book = bookRepo.findById(item.getBook_id())
                    .orElseThrow(() -> new Exception("Sách không tồn tại: " + item.getBook_id()));

            if (book.getQuantity() < item.getQuantity()) {
                throw new Exception("Sách '" + book.getTitle() + "' không đủ số lượng!");
            }

            // Cập nhật kho
            book.setQuantity(book.getQuantity() - item.getQuantity());
            book.setSoldQuantity(book.getSoldQuantity() + item.getQuantity());
            bookRepo.save(book);

            // QUAN TRỌNG: Lưu OrderDetail
            OrderDetail detail = new OrderDetail();
            // Tạo ID phức hợp cho OrderDetail
            OrderdetailId detailId = new OrderdetailId(order.getOrderId(), book.getBookId());
            detail.setOrderDetailId(detailId);

            detail.setOrder(order);
            detail.setBook(book);
            detail.setQuantity(item.getQuantity());
            detail.setUnitPrice(item.getPrice());

            // Thực hiện lưu vào database
            orderDetailRepository.save(detail);

            purchasedBookIds.add(book.getBookId());
        }

// 6. XỬ LÝ GIỎ HÀNG
        // Dùng getter đúng (ví dụ request.isFromCart())
        if (request.isFromCart()) {
            Cart cart = cartRepo.findByCustomer(customer);
            if (cart != null) {
                // Log ra để kiểm tra nếu vẫn chưa xóa được
                System.out.println("Đang xóa giỏ hàng cho CartId: " + cart.getCartId());
                System.out.println("Các BookId cần xóa: " + purchasedBookIds);

                cartDetailRepo.deleteByCartIdAndBookIds(cart.getCartId(), purchasedBookIds);
                updateCartTotals(cart);
            }
        }

        return orderId;
    }

    /**
     * Cập nhật lại tổng tiền và số lượng của Cart sau khi xóa các CartDetail
     */
    private void updateCartTotals(Cart cart) {
        // Lấy lại danh sách chi tiết giỏ hàng còn lại sau khi xóa
        List<CartDetail> remaining = cartDetailRepo.findByCart_CartId(cart.getCartId());

        int totalQty = 0;
        BigDecimal totalAmt = BigDecimal.ZERO;

        for (CartDetail cd : remaining) {
            totalQty += cd.getQuantity();
            totalAmt = totalAmt.add(cd.getUnitPrice().multiply(new BigDecimal(cd.getQuantity())));
        }

        cart.setQuantity(totalQty);
        cart.setTotalAmount(totalAmt);
        cartRepo.save(cart); // Cập nhật lại header của giỏ hàng
    }

    @Transactional(rollbackFor = Exception.class)
    public String createDirectOrder(OrderDirectRequest request) throws Exception {
        // 1. Kiểm tra User
        Users user = usersRepository.findByCustomer_CustomerId(request.getUser_id())
                .orElseThrow(() -> new Exception("Không tìm thấy User: " + request.getUser_id()));

        Customers customer = user.getCustomer();

        // 2. Điểm thưởng (Dùng Integer giúp check null an toàn)
        if (request.getDiscount_points() != null && request.getDiscount_points() > 0) {
            if (user.getRewardPoints() < request.getDiscount_points()) {
                throw new Exception("Không đủ điểm thưởng");
            }
            user.setRewardPoints(user.getRewardPoints() - request.getDiscount_points());
            usersRepository.save(user);
        }

        // 3. Xử lý Coupon
        if (request.getDiscount_coupon() != null && !request.getDiscount_coupon().isEmpty()) {
            Coupon coupon = couponRepo.findByCode(request.getDiscount_coupon())
                    .orElseThrow(() -> new Exception("Mã giảm giá không hợp lệ"));

            if (coupon.getUsedCount() >= coupon.getUsageLimit()) {
                throw new Exception("Mã giảm giá đã hết lượt sử dụng");
            }

            coupon.setUsedCount(coupon.getUsedCount() + 1);
            couponRepo.save(coupon);
        }

        // 4. Tạo thực thể Order
        String orderId = "ORD" + System.currentTimeMillis();
        Orders order = new Orders();
        order.setOrderId(orderId);
        order.setCustomer(customer);
        order.setPaymentMethod(request.getPayment_method());
        order.setTotalAmount(request.getFinal_total());

        String shippingAddr = request.getAddress() != null ? request.getAddress() : "Giao đến ID: " + request.getShipping_address_id();
        order.setAddress(shippingAddr);
        order.setStatus("PENDING");
        order.setOrderDate(new Date());
        // --- MÁ CHÈN THÊM MẤY DÒNG NÀY VÀO ĐÂY ---
        order.setShippingFee(request.getShipping_fee() != null ? request.getShipping_fee() : BigDecimal.ZERO);
        order.setVoucherDiscount(request.getVoucher_discount() != null ? request.getVoucher_discount() : BigDecimal.ZERO);
        order.setPointsDiscount(request.getPoints_discount_amount() != null ? request.getPoints_discount_amount() : BigDecimal.ZERO);

// Ghi chú tự động dựa trên mã giảm giá (tùy chọn)
        String autoNote = "Đơn hàng mới";
        if (request.getDiscount_coupon() != null) autoNote += " | Voucher: " + request.getDiscount_coupon();
        order.setNote(autoNote);
// -----------------------------------------

        if (request.getShipping_address_id() != null) {
            ShippingAddress sa = addressRepo.findById(request.getShipping_address_id()).orElse(null);
            order.setShippingAddress(sa);
        }

        ordersRepository.save(order);

        // 5. Lưu OrderDetails (Dùng DirectItemDTO)
        for (DirectItemDTO item : request.getItems()) {
            Books book = bookRepo.findById(item.getBook_id())
                    .orElseThrow(() -> new Exception("Sách không tồn tại: " + item.getBook_id()));

            // Trừ kho
            book.setQuantity(book.getQuantity() - item.getQuantity());
            book.setSoldQuantity(book.getSoldQuantity() + item.getQuantity());
            bookRepo.save(book);

            // Lưu Detail
            OrderDetail detail = new OrderDetail();
            OrderdetailId detailId = new OrderdetailId(order.getOrderId(), book.getBookId());
            detail.setOrderDetailId(detailId);
            detail.setOrder(order);
            detail.setBook(book);
            detail.setQuantity(item.getQuantity());
            detail.setUnitPrice(item.getPrice());
            orderDetailRepository.save(detail);
        }

        return orderId;
    }

    public void confirmDelivered(String orderId) {
        Orders order = ordersRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (!order.getStatus().equals("Shipping")) {
            throw new RuntimeException("Chỉ đơn đang giao mới được xác nhận");
        }

        order.setStatus("Completed");
        ordersRepository.save(order);
    }

}