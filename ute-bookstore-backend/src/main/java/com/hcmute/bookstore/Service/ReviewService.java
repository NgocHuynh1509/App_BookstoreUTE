package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.*;
import com.hcmute.bookstore.Exception.AlreadyReviewedException;
import com.hcmute.bookstore.Repository.*;
import com.hcmute.bookstore.dto.CreateReviewRequest;
import com.hcmute.bookstore.dto.CreateReviewResponse;
import com.hcmute.bookstore.dto.MyReviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final UsersRepository usersRepository;
    private final OrdersRepository ordersRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final BooksRepository booksRepository;
    private final CouponRepository couponRepository;

    @Transactional
    public CreateReviewResponse createReview(String emailFromToken, CreateReviewRequest request) {
        if (request.getRating() == null || request.getRating() < 1 || request.getRating() > 5) {
            throw new RuntimeException("Số sao phải từ 1 đến 5");
        }

        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        Orders order = ordersRepository.findByOrderIdAndCustomer_CustomerId(
                        request.getOrder_id(),
                        customerId
                )
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        String normalizedStatus = normalizeReviewableStatus(order.getStatus());
        if (!"success".equals(normalizedStatus)) {
            throw new RuntimeException("Chỉ được đánh giá đơn hàng đã giao thành công");
        }

        boolean boughtThisBook = orderDetailRepository.existsByOrder_OrderIdAndBook_BookId(
                request.getOrder_id(),
                request.getBook_id()
        );

        if (!boughtThisBook) {
            throw new RuntimeException("Sản phẩm này không thuộc đơn hàng");
        }

        Optional<Review> existingReviewOpt = reviewRepository
                .findByCustomer_CustomerIdAndBook_BookId(customerId, request.getBook_id());

        if (existingReviewOpt.isPresent()) {
            Review existingReview = existingReviewOpt.get();

            MyReviewResponse myReview = new MyReviewResponse(
                    existingReview.getReviewId(),
                    existingReview.getBook().getBookId(),
                    request.getOrder_id(),
                    existingReview.getRating(),
                    existingReview.getComment(),
                    formatDate(existingReview.getCreationDate()),
                    true
            );

            throw new AlreadyReviewedException("Bạn đã đánh giá sản phẩm này rồi", myReview);
        }

        Books book = booksRepository.findById(request.getBook_id())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sách"));

        Review review = new Review();
        review.setReviewId("RV" + UUID.randomUUID().toString().replace("-", "").substring(0, 10).toUpperCase());
        review.setCustomer(user.getCustomer());
        review.setBook(book);
        review.setRating(request.getRating());
        review.setComment(request.getComment());
        review.setCreationDate(new Date());

//        reviewRepository.save(review);
//
//        if (request.getRating() == 5) {
//            String couponCode = "RVW" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
//            return new CreateReviewResponse(
//                    "Gửi đánh giá thành công",
//                    new CreateReviewResponse.RewardData("coupon", couponCode)
//            );
//        }
//
//        return new CreateReviewResponse(
//                "Gửi đánh giá thành công",
//                new CreateReviewResponse.RewardData("points", null)
//        );
        reviewRepository.save(review);

        if (request.getRating() == 5) {

            String couponCode = "RVW" + UUID.randomUUID().toString()
                    .replace("-", "")
                    .substring(0, 8)
                    .toUpperCase();

            // tránh trùng code
            while (couponRepository.existsByCodeIgnoreCase(couponCode)) {
                couponCode = "RVW" + UUID.randomUUID().toString()
                        .replace("-", "")
                        .substring(0, 8)
                        .toUpperCase();
            }

            Coupon coupon = new Coupon();
            coupon.setId("CP" + UUID.randomUUID().toString()
                    .replace("-", "")
                    .substring(0, 10)
                    .toUpperCase());
            coupon.setCode(couponCode);
            coupon.setDiscountPercent(10);
            coupon.setMinOrderValue(100000);
            coupon.setMaxDiscount(30000);
            coupon.setExpiryDate(LocalDateTime.now().plusDays(7));
            coupon.setUsageLimit(1);
            coupon.setUsedCount(0);
            coupon.setCustomer(user.getCustomer());

            couponRepository.save(coupon);

            return new CreateReviewResponse(
                    "Gửi đánh giá thành công",
                    new CreateReviewResponse.RewardData("coupon", couponCode)
            );
        }

        Integer currentPoints = user.getRewardPoints() != null ? user.getRewardPoints() : 0;
        user.setRewardPoints(currentPoints + 10);
        usersRepository.save(user);

        return new CreateReviewResponse(
                "Gửi đánh giá thành công",
                new CreateReviewResponse.RewardData("points", "10")
        );
    }

    @Transactional(readOnly = true)
    public MyReviewResponse getMyReview(String emailFromToken, String bookId, String orderId) {
        Users user = usersRepository.findByCustomer_Email(emailFromToken)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        String customerId = user.getCustomer().getCustomerId();

        Orders order = ordersRepository.findByOrderIdAndCustomer_CustomerId(orderId, customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        boolean boughtThisBook = orderDetailRepository.existsByOrder_OrderIdAndBook_BookId(
                order.getOrderId(),
                bookId
        );

        if (!boughtThisBook) {
            throw new RuntimeException("Sản phẩm này không thuộc đơn hàng");
        }

        Optional<Review> reviewOpt = reviewRepository.findByCustomer_CustomerIdAndBook_BookId(customerId, bookId);

        if (reviewOpt.isEmpty()) {
            return new MyReviewResponse(
                    null,
                    bookId,
                    orderId,
                    null,
                    null,
                    null,
                    false
            );
        }

        Review review = reviewOpt.get();

        return new MyReviewResponse(
                review.getReviewId(),
                review.getBook().getBookId(),
                orderId,
                review.getRating(),
                review.getComment(),
                formatDate(review.getCreationDate()),
                true
        );
    }

    private String normalizeReviewableStatus(String status) {
        if (status == null) return "pending";

        return switch (status.trim().toLowerCase()) {
            case "success", "completed", "hoan_thanh", "hoàn thành", "giao_thanh_cong" -> "success";
            case "cancelled", "da_huy", "đã hủy" -> "cancelled";
            case "shipping", "delivery", "dang_giao", "đang giao" -> "delivery";
            default -> "pending";
        };
    }

    private String formatDate(Date date) {
        if (date == null) return null;
        return new SimpleDateFormat("dd/MM/yyyy").format(date);
    }
}