package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.Review;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.OrderDetailRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.ReviewRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.CreateReviewRequest;
import com.hcmute.bookstore.dto.CreateReviewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final UsersRepository usersRepository;
    private final OrdersRepository ordersRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final BooksRepository booksRepository;

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

        boolean reviewed = reviewRepository
                .findByCustomer_CustomerIdAndBook_BookId(customerId, request.getBook_id())
                .isPresent();

        if (reviewed) {
            throw new RuntimeException("Bạn đã đánh giá sản phẩm này rồi");
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

        reviewRepository.save(review);

        if (request.getRating() == 5) {
            String couponCode = "RVW" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
            return new CreateReviewResponse(
                    "Gửi đánh giá thành công",
                    new CreateReviewResponse.RewardData("coupon", couponCode)
            );
        }

        return new CreateReviewResponse(
                "Gửi đánh giá thành công",
                new CreateReviewResponse.RewardData("points", null)
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
}