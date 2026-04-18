package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.dto.admin.DashboardSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final BooksRepository booksRepository;
    private final OrdersRepository ordersRepository;
    private final ChatMessageRepository chatMessageRepository;

    public DashboardSummaryResponse getSummary() {
        DashboardSummaryResponse response = new DashboardSummaryResponse();
        response.setTotalBooks(booksRepository.count());
        response.setTotalOrders(ordersRepository.count());
        response.setPendingOrders(ordersRepository.countByStatusIgnoreCase("PENDING"));
        response.setLowStockBooks(booksRepository.countByQuantityLessThanEqual(5));
        response.setUnreadMessages(chatMessageRepository.countByStatusNot("SEEN"));

        response.setRevenueDay(sumRevenueForRange(LocalDate.now(), LocalDate.now().plusDays(1)));
        response.setRevenueMonth(sumRevenueForRange(LocalDate.now().withDayOfMonth(1), LocalDate.now().plusDays(1)));
        response.setRevenueYear(sumRevenueForRange(LocalDate.now().withDayOfYear(1), LocalDate.now().plusDays(1)));
        return response;
    }

    private BigDecimal sumRevenueForRange(LocalDate from, LocalDate toExclusive) {
        Date fromDate = Date.from(from.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date toDate = Date.from(toExclusive.atStartOfDay(ZoneId.systemDefault()).toInstant());
        return ordersRepository.sumTotalAmountBetween(fromDate, toDate);
    }
}

