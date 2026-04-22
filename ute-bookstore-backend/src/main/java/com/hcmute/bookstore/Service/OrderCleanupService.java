package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.OrderDetail;
import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.Payment;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderCleanupService {

    private final OrdersRepository ordersRepository;
    private final PaymentRepository paymentRepository;
    private final BooksRepository booksRepository; // Inject thêm repository của Books

    @Scheduled(fixedRate = 1800000) // 5 phút quét 1 lần (5 * 60 * 1000)
    @Transactional
    public void autoCancelExpiredVnpayOrders() {
        // 1 ngày = 24 giờ * 60 phút * 60 giây * 1000 ms = 86,400,000
        long oneDayAgoMillis = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
        Date expiryDate = new Date(oneDayAgoMillis);

        List<Orders> expiredOrders = ordersRepository.findExpiredVnPayOrders(expiryDate);

        if (!expiredOrders.isEmpty()) {
            System.out.println("⏰ [Hệ thống] Đang xử lý hoàn kho cho " + expiredOrders.size() + " đơn quá hạn...");

            for (Orders order : expiredOrders) {
                // --- BƯỚC HOÀN KHO ---
                List<OrderDetail> details = order.getOrderDetail_Order();
                if (details != null) {
                    for (OrderDetail detail : details) {
                        Books book = detail.getBook();
                        int qty = detail.getQuantity();

                        // Cộng lại kho
                        book.setQuantity(book.getQuantity() + qty);

                        // Trừ số lượng đã bán (nhớ check để không bị âm số bán)
                        int newSoldQty = book.getSoldQuantity() - qty;
                        book.setSoldQuantity(Math.max(newSoldQty, 0));

                        booksRepository.save(book);
                        System.out.println("   📦 Hoàn kho: " + book.getTitle() + " (+" + qty + ")");
                    }
                }

                // Cập nhật trạng thái đơn và thanh toán
                order.setStatus("CANCELLED");
                order.setNote((order.getNote() != null ? order.getNote() : "") + " | Hủy tự động & Hoàn kho.");

                Payment payment = order.getPayment();
                if (payment != null) {
                    payment.setStatus("FAILED");
                    paymentRepository.save(payment);
                }

                ordersRepository.save(order);
            }
            System.out.println("✅ [Hệ thống] Đã hoàn thành hoàn kho và hủy đơn.");
        }
    }
}