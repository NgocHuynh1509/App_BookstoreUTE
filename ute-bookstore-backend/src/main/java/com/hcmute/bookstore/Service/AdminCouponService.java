package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Coupon;
import com.hcmute.bookstore.Entity.Customers;
import com.hcmute.bookstore.Repository.CouponRepository;
import com.hcmute.bookstore.Repository.CustomerRepository;
import com.hcmute.bookstore.dto.admin.AdminCouponRequest;
import com.hcmute.bookstore.dto.admin.AdminCouponResponse;
import com.hcmute.bookstore.dto.admin.AdminCouponStatsResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminCouponService {

    private final CouponRepository couponRepository;
    private final CustomerRepository customerRepository;

    public List<AdminCouponResponse> getCoupons(String search, String status, String scope) {
        List<Coupon> coupons;
        if (search != null && !search.isBlank()) {
            coupons = couponRepository.findByCodeContainingIgnoreCase(search.trim());
        } else if ("public".equalsIgnoreCase(scope)) {
            coupons = couponRepository.findByCustomerIsNull();
        } else if ("private".equalsIgnoreCase(scope)) {
            coupons = couponRepository.findByCustomerIsNotNull();
        } else {
            coupons = couponRepository.findAll();
        }

        LocalDateTime now = LocalDateTime.now();
        return coupons.stream()
                .filter(coupon -> matchesStatus(coupon, status, now))
                .sorted(Comparator.comparing(Coupon::getExpiryDate, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
                .map(coupon -> toResponse(coupon, now))
                .collect(Collectors.toList());
    }

    public AdminCouponResponse getCoupon(String id) {
        Coupon coupon = couponRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã giảm giá"));
        return toResponse(coupon, LocalDateTime.now());
    }

    public AdminCouponResponse create(AdminCouponRequest request) {
        validateRequest(request, null);

        Coupon coupon = new Coupon();
        coupon.setId(UUID.randomUUID().toString());
        applyRequest(coupon, request, true);
        return toResponse(couponRepository.save(coupon), LocalDateTime.now());
    }

    public AdminCouponResponse update(String id, AdminCouponRequest request) {
        Coupon coupon = couponRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã giảm giá"));
        validateRequest(request, coupon);
        applyRequest(coupon, request, false);
        return toResponse(couponRepository.save(coupon), LocalDateTime.now());
    }

    public void delete(String id) {
        if (!couponRepository.existsById(id)) {
            throw new RuntimeException("Không tìm thấy mã giảm giá");
        }
        couponRepository.deleteById(id);
    }

    public AdminCouponStatsResponse getStats() {
        List<Coupon> coupons = couponRepository.findAll();
        LocalDateTime now = LocalDateTime.now();
        AdminCouponStatsResponse response = new AdminCouponStatsResponse();

        long activeCount = coupons.stream()
                .filter(coupon -> isActive(coupon, now))
                .count();
        long expiringSoonCount = coupons.stream()
                .filter(coupon -> coupon.getExpiryDate() != null)
                .filter(coupon -> coupon.getExpiryDate().isAfter(now))
                .filter(coupon -> coupon.getExpiryDate().isBefore(now.plusDays(7)))
                .count();
        long totalUsed = coupons.stream()
                .mapToLong(coupon -> coupon.getUsedCount() == null ? 0 : coupon.getUsedCount())
                .sum();

        Coupon topUsed = coupons.stream()
                .max(Comparator.comparingInt(coupon -> coupon.getUsedCount() == null ? 0 : coupon.getUsedCount()))
                .orElse(null);

        response.setActiveCount(activeCount);
        response.setExpiringSoonCount(expiringSoonCount);
        response.setTotalUsedCount(totalUsed);
        response.setTopUsedCode(topUsed != null ? topUsed.getCode() : null);
        response.setTopUsedCount(topUsed != null && topUsed.getUsedCount() != null ? topUsed.getUsedCount() : 0);
        return response;
    }

    private void validateRequest(AdminCouponRequest request, Coupon existing) {
        if (request == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }
        if (request.getCode() == null || request.getCode().isBlank()) {
            throw new RuntimeException("Mã giảm giá không được để trống");
        }
        String code = request.getCode().trim();
        if (existing == null) {
            if (couponRepository.existsByCodeIgnoreCase(code)) {
                throw new RuntimeException("Mã giảm giá đã tồn tại");
            }
        } else if (!code.equalsIgnoreCase(existing.getCode())) {
            if (couponRepository.existsByCodeIgnoreCase(code)) {
                throw new RuntimeException("Mã giảm giá đã tồn tại");
            }
        }

        Integer percent = request.getDiscountPercent();
        Integer amount = request.getDiscountAmount();
        boolean hasPercent = percent != null && percent > 0;
        boolean hasAmount = amount != null && amount > 0;
        if (hasPercent == hasAmount) {
            throw new RuntimeException("Chỉ chọn 1 loại giảm giá (% hoặc tiền)");
        }
        if (request.getExpiryDate() == null || !request.getExpiryDate().isAfter(LocalDateTime.now())) {
            throw new RuntimeException("Ngày hết hạn phải lớn hơn ngày hiện tại");
        }
        if (request.getUsageLimit() != null && request.getUsageLimit() < 0) {
            throw new RuntimeException("Số lượt dùng không hợp lệ");
        }
        if (existing != null && request.getUsageLimit() != null) {
            int usedCount = existing.getUsedCount() == null ? 0 : existing.getUsedCount();
            if (request.getUsageLimit() < usedCount) {
                throw new RuntimeException("Số lượt dùng không được nhỏ hơn đã dùng");
            }
        }
    }

    private void applyRequest(Coupon coupon, AdminCouponRequest request, boolean isCreate) {
        coupon.setCode(request.getCode().trim());
        coupon.setDiscountPercent(request.getDiscountPercent());
        coupon.setDiscountAmount(request.getDiscountAmount());
        coupon.setMinOrderValue(request.getMinOrderValue());
        coupon.setMaxDiscount(request.getMaxDiscount());
        coupon.setExpiryDate(request.getExpiryDate());
        coupon.setUsageLimit(request.getUsageLimit());
        if (isCreate) {
            coupon.setUsedCount(0);
        }

        String customerId = request.getCustomerId();
        if (customerId != null && !customerId.isBlank()) {
            Customers customer = customerRepository.findById(customerId.trim())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy khách hàng"));
            coupon.setCustomer(customer);
        } else {
            coupon.setCustomer(null);
        }
    }

    private AdminCouponResponse toResponse(Coupon coupon, LocalDateTime now) {
        AdminCouponResponse response = new AdminCouponResponse();
        response.setId(coupon.getId());
        response.setCode(coupon.getCode());
        response.setDiscountPercent(coupon.getDiscountPercent());
        response.setDiscountAmount(coupon.getDiscountAmount());
        response.setMinOrderValue(coupon.getMinOrderValue());
        response.setMaxDiscount(coupon.getMaxDiscount());
        response.setExpiryDate(coupon.getExpiryDate());
        response.setUsageLimit(coupon.getUsageLimit());
        response.setUsedCount(coupon.getUsedCount() == null ? 0 : coupon.getUsedCount());
        if (coupon.getCustomer() != null) {
            response.setCustomerId(coupon.getCustomer().getCustomerId());
            response.setCustomerName(coupon.getCustomer().getFullName());
        }
        response.setStatus(resolveStatus(coupon, now));
        return response;
    }

    private boolean matchesStatus(Coupon coupon, String status, LocalDateTime now) {
        if (status == null || status.isBlank() || "all".equalsIgnoreCase(status)) {
            return true;
        }
        String normalized = status.trim().toUpperCase();
        return normalized.equals(resolveStatus(coupon, now));
    }

    private String resolveStatus(Coupon coupon, LocalDateTime now) {
        if (coupon == null) {
            return "UNKNOWN";
        }
        if (coupon.getExpiryDate() == null || coupon.getExpiryDate().isBefore(now)) {
            return "EXPIRED";
        }
        int used = coupon.getUsedCount() == null ? 0 : coupon.getUsedCount();
        Integer limit = coupon.getUsageLimit();
        if (limit != null && used >= limit) {
            return "USED_UP";
        }
        return "ACTIVE";
    }

    private boolean isActive(Coupon coupon, LocalDateTime now) {
        return "ACTIVE".equals(resolveStatus(coupon, now));
    }
}

