package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import com.hcmute.bookstore.Repository.OrderDetailRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.admin.DashboardBooksResponse;
import com.hcmute.bookstore.dto.admin.DashboardChartsResponse;
import com.hcmute.bookstore.dto.admin.DashboardRevenueResponse;
import com.hcmute.bookstore.dto.admin.DashboardSeriesPoint;
import com.hcmute.bookstore.dto.admin.DashboardStatusCountResponse;
import com.hcmute.bookstore.dto.admin.DashboardOrdersResponse;
import com.hcmute.bookstore.dto.admin.DashboardSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final BooksRepository booksRepository;
    private final OrdersRepository ordersRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final UsersRepository usersRepository;

    public DashboardSummaryResponse getSummary() {
        DashboardSummaryResponse response = new DashboardSummaryResponse();
        response.setTotalBooks(booksRepository.count());
        response.setTotalOrders(ordersRepository.count());
        response.setTotalUsers(usersRepository.count());
        response.setPendingOrders(ordersRepository.countByStatusIgnoreCase("PENDING"));
        response.setLowStockBooks(booksRepository.countByQuantityLessThanEqual(5));
        response.setUnreadMessages(chatMessageRepository.countByStatusNot("SEEN"));

        response.setRevenueDay(sumRevenueForRange(LocalDate.now(), LocalDate.now().plusDays(1)));
        response.setRevenueMonth(sumRevenueForRange(LocalDate.now().withDayOfMonth(1), LocalDate.now().plusDays(1)));
        response.setRevenueYear(sumRevenueForRange(LocalDate.now().withDayOfYear(1), LocalDate.now().plusDays(1)));
        return response;
    }

    public DashboardRevenueResponse getRevenue(String range) {
        RangeWindow window = resolveRange(range);
        RangeWindow previousWindow = window.previous();

        List<DashboardSeriesPoint> series = buildRevenueSeries(window);
        BigDecimal total = sumRevenueForRange(window.from, window.toExclusive);
        BigDecimal previousTotal = sumRevenueForRange(previousWindow.from, previousWindow.toExclusive);

        DashboardRevenueResponse response = new DashboardRevenueResponse();
        response.setRange(window.label);
        response.setSeries(series);
        response.setTotal(total);
        response.setPreviousTotal(previousTotal);
        response.setChangePercent(calculateChangePercent(total, previousTotal));
        return response;
    }

    public DashboardBooksResponse getBooks(String range) {
        RangeWindow window = resolveRange(range);
        DashboardBooksResponse response = new DashboardBooksResponse();
        response.setRange(window.label);
        response.setTotalBooks(booksRepository.count());
        response.setLowStockBooks(booksRepository.countByQuantityLessThanEqual(5));

        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);
        Long soldBooks = orderDetailRepository.sumQuantityBetween(fromDate, toDate);
        Long stockBooks = booksRepository.sumStockQuantity();
        response.setSoldBooks(soldBooks != null ? soldBooks : 0L);
        response.setStockBooks(stockBooks != null ? stockBooks : 0L);
        return response;
    }

    public DashboardOrdersResponse getOrders(String range) {
        RangeWindow window = resolveRange(range);
        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);

        DashboardOrdersResponse response = new DashboardOrdersResponse();
        response.setRange(window.label);
        response.setTotalOrders(countOrdersForRange(fromDate, toDate));

        List<DashboardStatusCountResponse> statusCounts = new ArrayList<>();
        long completedCount = 0;
        long total = 0;
        for (Object[] row : ordersRepository.countByStatusGroup()) {
            String status = row[0] != null ? row[0].toString() : "UNKNOWN";
            long count = ((Number) row[1]).longValue();
            statusCounts.add(new DashboardStatusCountResponse(status, count));
            total += count;
            if ("COMPLETED".equalsIgnoreCase(status)) {
                completedCount = count;
            }
        }

        response.setStatusCounts(statusCounts);
        response.setCompletionRate(total == 0 ? 0 : (completedCount * 100.0 / total));
        return response;
    }

    public DashboardChartsResponse getCharts(String range) {
        RangeWindow window = resolveRange(range);
        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);

        DashboardChartsResponse response = new DashboardChartsResponse();
        response.setRange(window.label);

        List<DashboardStatusCountResponse> orderStatus = new ArrayList<>();
        for (Object[] row : ordersRepository.countByStatusGroup()) {
            String status = row[0] != null ? row[0].toString() : "UNKNOWN";
            long count = ((Number) row[1]).longValue();
            orderStatus.add(new DashboardStatusCountResponse(status, count));
        }
        response.setOrderStatus(orderStatus);

        List<DashboardStatusCountResponse> categories = new ArrayList<>();
        for (Object[] row : booksRepository.countBooksByCategory()) {
            String name = row[0] != null ? row[0].toString() : "Unknown";
            long count = ((Number) row[1]).longValue();
            categories.add(new DashboardStatusCountResponse(name, count));
        }
        response.setCategoryBreakdown(categories);

        response.setRevenueSeries(buildRevenueSeries(window));
        response.setOrdersSeries(buildOrderSeries(window));
        response.setBooksSoldSeries(buildBooksSoldSeries(window));
        return response;
    }

    private BigDecimal sumRevenueForRange(LocalDate from, LocalDate toExclusive) {
        Date fromDate = Date.from(from.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date toDate = Date.from(toExclusive.atStartOfDay(ZoneId.systemDefault()).toInstant());
        return ordersRepository.sumTotalAmountBetween(fromDate, toDate);
    }

    private long countOrdersForRange(Date fromDate, Date toDate) {
        List<Object[]> items = ordersRepository.countOrdersByDay(fromDate, toDate);
        long total = 0;
        for (Object[] row : items) {
            total += ((Number) row[1]).longValue();
        }
        return total;
    }

    private List<DashboardSeriesPoint> buildRevenueSeries(RangeWindow window) {
        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);
        if (window.bucket == Bucket.DAY) {
            return mapSeries(ordersRepository.sumRevenueByDay(fromDate, toDate), DateTimeFormatter.ofPattern("MM-dd"));
        }
        return mapSeries(ordersRepository.sumRevenueByMonth(fromDate, toDate), DateTimeFormatter.ofPattern("yyyy-MM"));
    }

    private List<DashboardSeriesPoint> buildOrderSeries(RangeWindow window) {
        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);
        if (window.bucket == Bucket.DAY) {
            return mapSeries(ordersRepository.countOrdersByDay(fromDate, toDate), DateTimeFormatter.ofPattern("MM-dd"));
        }
        return mapSeries(ordersRepository.countOrdersByMonth(fromDate, toDate), DateTimeFormatter.ofPattern("yyyy-MM"));
    }

    private List<DashboardSeriesPoint> buildBooksSoldSeries(RangeWindow window) {
        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);
        if (window.bucket == Bucket.DAY) {
            return mapSeries(orderDetailRepository.sumBookSoldByDay(fromDate, toDate), DateTimeFormatter.ofPattern("MM-dd"));
        }
        return mapSeries(orderDetailRepository.sumBookSoldByMonth(fromDate, toDate), DateTimeFormatter.ofPattern("yyyy-MM"));
    }

    private List<DashboardSeriesPoint> mapSeries(List<Object[]> rows, DateTimeFormatter formatter) {
        List<DashboardSeriesPoint> series = new ArrayList<>();
        for (Object[] row : rows) {
            Object labelObject = row[0];
            String label;
            if (labelObject instanceof java.sql.Date sqlDate) {
                label = formatter.format(sqlDate.toLocalDate());
            } else if (labelObject instanceof Date date) {
                label = formatter.format(date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate());
            } else if (labelObject instanceof LocalDate localDate) {
                label = formatter.format(localDate);
            } else {
                label = labelObject != null ? labelObject.toString() : "";
            }
            BigDecimal value = toBigDecimal(row[1]);
            series.add(new DashboardSeriesPoint(label, value));
        }
        return series;
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        if (value instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }
        return BigDecimal.ZERO;
    }

    private double calculateChangePercent(BigDecimal total, BigDecimal previousTotal) {
        if (previousTotal == null || previousTotal.compareTo(BigDecimal.ZERO) == 0) {
            return total != null && total.compareTo(BigDecimal.ZERO) > 0 ? 100.0 : 0.0;
        }
        BigDecimal diff = total.subtract(previousTotal);
        return diff.divide(previousTotal, 4, java.math.RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .doubleValue();
    }

    private RangeWindow resolveRange(String range) {
        String normalized = range == null ? "month" : range.trim().toLowerCase(Locale.ROOT);
        LocalDate today = LocalDate.now();
        if ("week".equals(normalized)) {
            return new RangeWindow("week", today.minusDays(6), today.plusDays(1), Bucket.DAY);
        }
        if ("year".equals(normalized)) {
            return new RangeWindow("year", today.minusMonths(11).withDayOfMonth(1), today.plusDays(1), Bucket.MONTH);
        }
        if ("all".equals(normalized)) {
            Date minDate = ordersRepository.findMinOrderDate();
            LocalDate from = minDate == null ? today.minusMonths(11).withDayOfMonth(1)
                    : minDate.toInstant().atZone(ZoneId.systemDefault()).toLocalDate().withDayOfMonth(1);
            return new RangeWindow("all", from, today.plusDays(1), Bucket.MONTH);
        }
        return new RangeWindow("month", today.minusDays(29), today.plusDays(1), Bucket.DAY);
    }

    private Date toDate(LocalDate date) {
        return Date.from(date.atStartOfDay(ZoneId.systemDefault()).toInstant());
    }

    private enum Bucket {
        DAY,
        MONTH
    }

    private static class RangeWindow {
        private final String label;
        private final LocalDate from;
        private final LocalDate toExclusive;
        private final Bucket bucket;

        private RangeWindow(String label, LocalDate from, LocalDate toExclusive, Bucket bucket) {
            this.label = label;
            this.from = from;
            this.toExclusive = toExclusive;
            this.bucket = bucket;
        }

        private RangeWindow previous() {
            if (bucket == Bucket.DAY) {
                long days = java.time.temporal.ChronoUnit.DAYS.between(from, toExclusive);
                return new RangeWindow(label, from.minusDays(days), toExclusive.minusDays(days), bucket);
            }
            long months = java.time.temporal.ChronoUnit.MONTHS.between(YearMonth.from(from), YearMonth.from(toExclusive.minusDays(1))) + 1;
            LocalDate prevTo = from;
            LocalDate prevFrom = from.minusMonths(months);
            return new RangeWindow(label, prevFrom, prevTo, bucket);
        }
    }
}

