package com.hcmute.bookstore.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.ChatMessageRepository;
import com.hcmute.bookstore.Repository.OrderDetailRepository;
import com.hcmute.bookstore.Repository.OrdersRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.Entity.MessageStatus;
import com.hcmute.bookstore.Entity.Orders;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.dto.admin.DashboardBooksResponse;
import com.hcmute.bookstore.dto.admin.DashboardChartsResponse;
import com.hcmute.bookstore.dto.admin.DashboardRecentActivitiesResponse;
import com.hcmute.bookstore.dto.admin.DashboardRecentActivityResponse;
import com.hcmute.bookstore.dto.admin.DashboardRevenuePredictionResponse;
import com.hcmute.bookstore.dto.admin.DashboardRevenueResponse;
import com.hcmute.bookstore.dto.admin.DashboardSeriesPoint;
import com.hcmute.bookstore.dto.admin.DashboardStatusCountResponse;
import com.hcmute.bookstore.dto.admin.DashboardOrdersResponse;
import com.hcmute.bookstore.dto.admin.DashboardSummaryResponse;
import com.hcmute.bookstore.dto.admin.DashboardTopBookResponse;
import com.hcmute.bookstore.dto.admin.DashboardTopBooksResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private static final Logger log = LoggerFactory.getLogger(AdminDashboardService.class);
    private static final long PREDICTION_TIMEOUT_SECONDS = 30;
    private static final String WINDOWS_APPS_DIR = "windowsapps";
    private static final Pattern MISSING_MODULE_PATTERN = Pattern.compile("(?i)no module named ['\"]?([^'\"\\s]+)");

    private final BooksRepository booksRepository;
    private final OrdersRepository ordersRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final UsersRepository usersRepository;
    private final ObjectMapper objectMapper;

    private static final ExecutorService PREDICTION_EXECUTOR = Executors.newFixedThreadPool(2);
    private final Map<String, CompletableFuture<DashboardRevenuePredictionResponse>> predictionJobs = new ConcurrentHashMap<>();

    public DashboardSummaryResponse getSummary() {
        DashboardSummaryResponse response = new DashboardSummaryResponse();
        response.setTotalBooks(booksRepository.count());
        response.setTotalOrders(ordersRepository.count());
        response.setTotalUsers(usersRepository.count());
        response.setPendingOrders(ordersRepository.countByStatusIgnoreCase("PENDING"));
        response.setLowStockBooks(booksRepository.countByQuantityLessThanEqual(5));
        response.setUnreadMessages(chatMessageRepository.countByStatusNot(MessageStatus.SEEN));

        response.setRevenueDay(sumRevenueForRange(LocalDate.now(), LocalDate.now().plusDays(1)));
        response.setRevenueMonth(sumRevenueForRange(LocalDate.now().withDayOfMonth(1), LocalDate.now().plusDays(1)));
        response.setRevenueYear(sumRevenueForRange(LocalDate.now().withDayOfYear(1), LocalDate.now().plusDays(1)));
        response.setRevenueDayFormatted(formatCurrency(response.getRevenueDay()));
        response.setRevenueMonthFormatted(formatCurrency(response.getRevenueMonth()));
        response.setRevenueYearFormatted(formatCurrency(response.getRevenueYear()));
        return response;
    }

    public DashboardRevenueResponse getRevenue(String range) {
        RangeWindow window = resolveRange(range);
        RangeWindow previousWindow = window.previous();

        List<DashboardSeriesPoint> series = buildRevenueSeries(window);
        BigDecimal total = sumRevenueForRange(window.from, window.toExclusive);
        BigDecimal previousTotal = sumRevenueForRange(previousWindow.from, previousWindow.toExclusive);

        BigDecimal seriesTotal = sumSeries(series);
        if ((total == null || total.compareTo(BigDecimal.ZERO) == 0) && seriesTotal.compareTo(BigDecimal.ZERO) > 0) {
            total = seriesTotal;
        }

        DashboardRevenueResponse response = new DashboardRevenueResponse();
        response.setRange(window.label);
        response.setSeries(series);
        response.setTotal(total);
        response.setPreviousTotal(previousTotal);
        response.setChangePercent(calculateChangePercent(total, previousTotal));
        response.setTotalFormatted(formatCurrency(total));
        response.setPreviousTotalFormatted(formatCurrency(previousTotal));
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

    public DashboardTopBooksResponse getTopBooks(String range, int limit) {
        RangeWindow window = resolveRange(range);
        int safeLimit = Math.max(1, Math.min(50, limit));
        Date fromDate = toDate(window.from);
        Date toDate = toDate(window.toExclusive);

        List<Object[]> rows = orderDetailRepository.findTopBooks(fromDate, toDate, PageRequest.of(0, safeLimit));
        List<DashboardTopBookResponse> items = new ArrayList<>();
        for (Object[] row : rows) {
            DashboardTopBookResponse item = new DashboardTopBookResponse();
            item.setBookId(safeString(row[0]));
            item.setTitle(safeString(row[1]));
            item.setAuthor(safeString(row[2]));
            item.setImageUrl(row[3] != null ? row[3].toString() : null);
            item.setSoldQuantity(row[4] != null ? ((Number) row[4]).longValue() : 0L);
            item.setRevenue(toBigDecimal(row[5]));
            items.add(item);
        }

        DashboardTopBooksResponse response = new DashboardTopBooksResponse();
        response.setItems(items);
        return response;
    }

    public DashboardRecentActivitiesResponse getRecentActivities(int limit) {
        int safeLimit = Math.max(1, Math.min(30, limit));
        List<ActivityEntry> entries = new ArrayList<>();

        List<Orders> recentOrders = ordersRepository
                .findAllByOrderByOrderDateDesc(PageRequest.of(0, safeLimit * 2));
        for (Orders order : recentOrders) {
            Date orderDate = order.getOrderDate();
            if (orderDate == null) {
                continue;
            }
            DashboardRecentActivityResponse activity = new DashboardRecentActivityResponse();
            boolean cancelled = isCancelled(order.getStatus());
            activity.setType(cancelled ? "ORDER_CANCELLED" : "ORDER_NEW");
            activity.setTitle(cancelled ? "Đơn hàng bị hủy" : "Đơn hàng mới");

            String amount = formatCurrency(order.getTotalAmount());
            String subtitle = "Mã: " + order.getOrderId() + " · " + amount;
            if (order.getCustomer() != null && order.getCustomer().getFullName() != null) {
                subtitle = order.getCustomer().getFullName() + " · " + amount;
            }
            activity.setSubtitle(subtitle);
            activity.setTime(formatActivityTime(orderDate));
            entries.add(new ActivityEntry(orderDate, activity));
        }

        List<Users> recentUsers = usersRepository
                .findAllByOrderByCreatedAtDesc(PageRequest.of(0, safeLimit * 2));
        if (recentUsers.isEmpty()) {
            recentUsers = usersRepository.findAllByOrderByRegistrationDateDesc(PageRequest.of(0, safeLimit * 2));
        }
        for (Users user : recentUsers) {
            Date userTime = user.getCreatedAt();
            if (userTime == null && user.getRegistrationDate() != null) {
                userTime = Date.from(user.getRegistrationDate().atStartOfDay(ZoneId.systemDefault()).toInstant());
            }
            if (userTime == null) {
                continue;
            }
            DashboardRecentActivityResponse activity = new DashboardRecentActivityResponse();
            activity.setType("USER_NEW");
            activity.setTitle("Khách hàng mới");
            String subtitle = user.getFullName() != null ? user.getFullName() : user.getUserName();
            if (subtitle == null && user.getCustomer() != null) {
                subtitle = user.getCustomer().getFullName();
            }
            activity.setSubtitle(subtitle != null ? subtitle : "Tài khoản mới");
            activity.setTime(formatActivityTime(userTime));
            entries.add(new ActivityEntry(userTime, activity));
        }

        entries.sort((a, b) -> b.time.compareTo(a.time));
        DashboardRecentActivitiesResponse response = new DashboardRecentActivitiesResponse();
        List<DashboardRecentActivityResponse> items = new ArrayList<>();
        for (ActivityEntry entry : entries) {
            items.add(entry.activity);
            if (items.size() >= safeLimit) {
                break;
            }
        }
        response.setItems(items);
        return response;
    }

    public String startPredictionJob() {
        String jobId = UUID.randomUUID().toString();
        CompletableFuture<DashboardRevenuePredictionResponse> future = CompletableFuture
                .supplyAsync(this::getRevenuePrediction, PREDICTION_EXECUTOR);
        predictionJobs.put(jobId, future);
        return jobId;
    }

    public PredictionJobResult getPredictionJob(String jobId) {
        CompletableFuture<DashboardRevenuePredictionResponse> future = predictionJobs.get(jobId);
        if (future == null) {
            return PredictionJobResult.notFound();
        }
        if (!future.isDone()) {
            return PredictionJobResult.pending();
        }
        try {
            DashboardRevenuePredictionResponse prediction = future.getNow(null);
            if (prediction == null) {
                return PredictionJobResult.pending();
            }
            predictionJobs.remove(jobId);
            return PredictionJobResult.done(prediction);
        } catch (Exception ex) {
            predictionJobs.remove(jobId);
            return PredictionJobResult.failed(ex.getMessage());
        }
    }

    public DashboardRevenuePredictionResponse getRevenuePrediction() {
        try {
            PredictionMetrics metrics = runPrediction(resolvePredictionStart(), LocalDate.now().plusDays(1));
            return buildPredictionResponse(metrics, "model");
        } catch (RuntimeException ex) {
            return buildFallbackPrediction(ex.getMessage());
        }
    }

    private DashboardRevenuePredictionResponse buildPredictionResponse(PredictionMetrics metrics, String source) {
        YearMonth currentMonth = YearMonth.now();
        YearMonth nextMonth = currentMonth.plusMonths(1);

        BigDecimal predictedMonthTotal = BigDecimal.valueOf(metrics.tomorrowPrediction)
                .multiply(BigDecimal.valueOf(nextMonth.lengthOfMonth()));
        BigDecimal currentMonthTotal = sumRevenueForRange(currentMonth.atDay(1), currentMonth.plusMonths(1).atDay(1));
        if (currentMonthTotal == null) {
            currentMonthTotal = BigDecimal.ZERO;
        }
        double changePercent = calculateChangePercent(predictedMonthTotal, currentMonthTotal);
        double confidence = metrics.confidence > 0
                ? metrics.confidence
                : Math.max(0.0, Math.min(1.0, metrics.r2)) * 100.0;
        if (metrics.dataPoints >= 120 && confidence < 55) {
            confidence = 55;
        }

        List<DashboardSeriesPoint> series = buildPredictionSeries(currentMonth);
        String predictedLabel = nextMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));
        series.add(new DashboardSeriesPoint(predictedLabel, predictedMonthTotal));

        DashboardRevenuePredictionResponse response = new DashboardRevenuePredictionResponse();
        response.setPredictedAmount(predictedMonthTotal);
        response.setCurrentMonthTotal(currentMonthTotal);
        response.setPredictedAmountFormatted(formatCurrency(predictedMonthTotal));
        response.setCurrentMonthTotalFormatted(formatCurrency(currentMonthTotal));
        response.setChangePercent(changePercent);
        response.setConfidence(confidence);
        response.setMae(metrics.mae);
        response.setMse(metrics.mse);
        response.setRmse(metrics.rmse);
        response.setR2(metrics.r2);
        response.setPredictedLabel(predictedLabel);
        response.setForecastIndex(series.size() - 1);
        response.setSeries(series);
        response.setSuggestion(buildSuggestion(changePercent, confidence, metrics.dataPoints, metrics.spanDays)
                + " (" + source + ")");
        return response;
    }

    private DashboardRevenuePredictionResponse buildFallbackPrediction(String reason) {
        YearMonth currentMonth = YearMonth.now();
        YearMonth nextMonth = currentMonth.plusMonths(1);

        LocalDate fallbackFrom = LocalDate.now().minusDays(30);
        BigDecimal last30Days = sumRevenueForRange(fallbackFrom, LocalDate.now().plusDays(1));
        if (last30Days == null) {
            last30Days = BigDecimal.ZERO;
        }
        BigDecimal avgDaily = last30Days.divide(BigDecimal.valueOf(30), 4, java.math.RoundingMode.HALF_UP);
        BigDecimal predictedMonthTotal = avgDaily.multiply(BigDecimal.valueOf(nextMonth.lengthOfMonth()));

        BigDecimal currentMonthTotal = sumRevenueForRange(currentMonth.atDay(1), currentMonth.plusMonths(1).atDay(1));
        if (currentMonthTotal == null) {
            currentMonthTotal = BigDecimal.ZERO;
        }
        double changePercent = calculateChangePercent(predictedMonthTotal, currentMonthTotal);

        List<DashboardSeriesPoint> series = buildPredictionSeries(currentMonth);
        String predictedLabel = nextMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));
        series.add(new DashboardSeriesPoint(predictedLabel, predictedMonthTotal));

        DashboardRevenuePredictionResponse response = new DashboardRevenuePredictionResponse();
        response.setPredictedAmount(predictedMonthTotal);
        response.setCurrentMonthTotal(currentMonthTotal);
        response.setPredictedAmountFormatted(formatCurrency(predictedMonthTotal));
        response.setCurrentMonthTotalFormatted(formatCurrency(currentMonthTotal));
        response.setChangePercent(changePercent);
        response.setConfidence(0);
        response.setMae(0);
        response.setMse(0);
        response.setRmse(0);
        response.setR2(0);
        response.setPredictedLabel(predictedLabel);
        response.setForecastIndex(series.size() - 1);
        response.setSeries(series);
        response.setSuggestion("Du lieu du doan tam thoi, he thong dang cap nhat mo hinh. Ly do: " + reason);
        return response;
    }

    private List<DashboardSeriesPoint> buildPredictionSeries(YearMonth currentMonth) {
        LocalDate seriesFrom = currentMonth.minusMonths(5).atDay(1);
        LocalDate seriesToExclusive = currentMonth.plusMonths(1).atDay(1);
        return mapSeries(
                ordersRepository.sumRevenueByMonth(toDate(seriesFrom), toDate(seriesToExclusive)),
                DateTimeFormatter.ofPattern("yyyy-MM")
        );
    }

    private PredictionMetrics runPrediction(LocalDate from, LocalDate toExclusive) {
        Path scriptPath = resolvePredictionScriptPath();
        if (!Files.exists(scriptPath)) {
            throw new IllegalStateException("Prediction script not found: " + scriptPath);
        }

        List<String> pythonCommand = resolvePythonCommand()
                .orElseThrow(() -> new IllegalStateException("Python interpreter not found. Set PYTHON_BIN or install Python."));

        Path pythonDir = scriptPath.getParent();
        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            writePredictionCsv(pythonDir, from, toExclusive);

            List<String> command = new ArrayList<>(pythonCommand);
            command = ensureUnbuffered(command);
            command.add(scriptPath.toString());

            ProcessBuilder builder = new ProcessBuilder(command);
            builder.directory(pythonDir.toFile());
            builder.environment().putIfAbsent("PYTHONIOENCODING", "utf-8");
            builder.environment().putIfAbsent("PYTHONUTF8", "1");

            Process process = builder.start();
            Future<String> stdoutFuture = executor.submit(() -> readStream(process.getInputStream()));
            Future<String> stderrFuture = executor.submit(() -> readStream(process.getErrorStream()));

            boolean finished = process.waitFor(PREDICTION_TIMEOUT_SECONDS, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                throw new IllegalStateException("Prediction process timed out after " + PREDICTION_TIMEOUT_SECONDS + "s.");
            }

            String stdout = getFutureOutput(stdoutFuture, PREDICTION_TIMEOUT_SECONDS, "stdout");
            String stderr = getFutureOutput(stderrFuture, PREDICTION_TIMEOUT_SECONDS, "stderr");

            int exitCode = process.exitValue();
            if (exitCode != 0) {
                String message = buildPythonFailureMessage(stderr, stdout, exitCode, pythonCommand, scriptPath);
                throw new IllegalStateException(message);
            }

            String output = stdout.trim();
            if (output.isEmpty()) {
                throw new IllegalStateException("Prediction process returned empty output.");
            }
            JsonNode node = objectMapper.readTree(output);
            return new PredictionMetrics(
                    node.path("MAE").asDouble(0),
                    node.path("MSE").asDouble(0),
                    node.path("RMSE").asDouble(0),
                    node.path("R2").asDouble(0),
                    node.path("Tomorrow_Prediction").asDouble(0),
                    node.path("DataPoints").asInt(0),
                    node.path("SpanDays").asInt(0),
                    node.path("Confidence").asDouble(0),
                    node.path("ModelPrediction").asDouble(0),
                    node.path("TrendPrediction").asDouble(0),
                    node.path("WmaPrediction").asDouble(0),
                    node.path("GrowthRate").asDouble(0)
            );
        } catch (IOException ex) {
            throw new IllegalStateException("Prediction process error", ex);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Prediction process interrupted", ex);
        } finally {
            executor.shutdownNow();
        }
    }

    private void writePredictionCsv(Path pythonDir, LocalDate from, LocalDate toExclusive) throws IOException {
        Date fromDate = toDate(from);
        Date toDate = toDate(toExclusive);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        java.util.Map<LocalDate, DailyPredictionRow> daily = new java.util.LinkedHashMap<>();
        for (LocalDate day = from; day.isBefore(toExclusive); day = day.plusDays(1)) {
            daily.put(day, new DailyPredictionRow());
        }

        for (Object[] row : ordersRepository.sumRevenueByDay(fromDate, toDate)) {
            LocalDate day = toLocalDate(row[0]);
            DailyPredictionRow target = daily.get(day);
            if (target != null) {
                target.revenue = toBigDecimal(row[1]);
            }
        }

        for (Object[] row : ordersRepository.countOrdersByDay(fromDate, toDate)) {
            LocalDate day = toLocalDate(row[0]);
            DailyPredictionRow target = daily.get(day);
            if (target != null) {
                target.orderCount = ((Number) row[1]).longValue();
            }
        }

        for (Object[] row : orderDetailRepository.sumBookSoldByDay(fromDate, toDate)) {
            LocalDate day = toLocalDate(row[0]);
            DailyPredictionRow target = daily.get(day);
            if (target != null) {
                target.booksSold = ((Number) row[1]).longValue();
            }
        }

        for (Object[] row : ordersRepository.countCancelledAndTotalByDay(fromDate, toDate)) {
            LocalDate day = toLocalDate(row[0]);
            DailyPredictionRow target = daily.get(day);
            if (target != null) {
                target.cancelCount = ((Number) row[1]).longValue();
                if (target.orderCount == 0) {
                    target.orderCount = ((Number) row[2]).longValue();
                }
            }
        }

        for (Object[] row : ordersRepository.countDistinctCustomersByDay(fromDate, toDate)) {
            LocalDate day = toLocalDate(row[0]);
            DailyPredictionRow target = daily.get(day);
            if (target != null) {
                target.distinctCustomers = ((Number) row[1]).longValue();
            }
        }

        java.util.Map<LocalDate, Long> newCustomers = new java.util.HashMap<>();
        for (Object[] row : ordersRepository.findFirstOrderDateByCustomer()) {
            LocalDate day = toLocalDate(row[1]);
            if (day != null && !day.isBefore(from) && day.isBefore(toExclusive)) {
                newCustomers.merge(day, 1L, Long::sum);
            }
        }

        StringBuilder builder = new StringBuilder();
        builder.append("orderDate,totalAmount,orderCount,booksSold,cancelCount,distinctCustomers,newCustomers,returningCustomers\n");
        for (java.util.Map.Entry<LocalDate, DailyPredictionRow> entry : daily.entrySet()) {
            LocalDate day = entry.getKey();
            DailyPredictionRow row = entry.getValue();
            long newCustomerCount = newCustomers.getOrDefault(day, 0L);
            long returningCustomers = Math.max(0, row.distinctCustomers - newCustomerCount);
            builder.append(formatter.format(day))
                    .append(',').append(row.revenue)
                    .append(',').append(row.orderCount)
                    .append(',').append(row.booksSold)
                    .append(',').append(row.cancelCount)
                    .append(',').append(row.distinctCustomers)
                    .append(',').append(newCustomerCount)
                    .append(',').append(returningCustomers)
                    .append('\n');
        }
        Files.writeString(pythonDir.resolve("orders.csv"), builder.toString(), StandardCharsets.UTF_8);
    }

    private String getFutureOutput(Future<String> future, long timeoutSeconds, String label) {
        try {
            return future.get(Math.max(5, timeoutSeconds), TimeUnit.SECONDS);
        } catch (TimeoutException ex) {
            log.warn("Prediction {} stream timed out.", label);
            return "";
        } catch (Exception ex) {
            log.warn("Prediction {} stream read failed: {}", label, ex.getMessage());
            return "";
        }
    }

    private Optional<List<String>> resolvePythonCommand() {
        String configured = System.getenv("PYTHON_BIN");
        if (configured != null && !configured.isBlank()) {
            List<String> parsed = splitCommand(configured.trim());
            if (isExecutableAvailable(parsed) && probePython(parsed)) {
                return Optional.of(parsed);
            }
            log.warn("PYTHON_BIN not usable: {}", configured);
        }

        List<List<String>> candidates = new ArrayList<>();
        if (isWindows()) {
            candidates.add(List.of("py", "-3"));
        }
        candidates.add(List.of("python"));
        candidates.add(List.of("python3"));

        for (List<String> candidate : candidates) {
            if (probePython(candidate)) {
                return Optional.of(candidate);
            }
        }
        return Optional.empty();
    }

    private boolean probePython(List<String> baseCommand) {
        if (!isExecutableAvailable(baseCommand)) {
            return false;
        }
        ProbeOutput version = runCommand(appendArgs(baseCommand, "--version"), 5);
        String versionOutput = (version.stdout + " " + version.stderr).trim();
        if (versionOutput.contains("Microsoft Store") || versionOutput.contains("Python was not found")) {
            return false;
        }
        if (version.exitCode != 0 || !versionOutput.toLowerCase(Locale.ROOT).contains("python")) {
            return false;
        }

        ProbeOutput executable = runCommand(appendArgs(baseCommand, "-c", "import sys;print(sys.executable)"), 5);
        String executablePath = (executable.stdout + " " + executable.stderr).trim().toLowerCase(Locale.ROOT);
        if (executablePath.contains(WINDOWS_APPS_DIR)) {
            return false;
        }
        return true;
    }

    private ProbeOutput runCommand(List<String> command, long timeoutSeconds) {
        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            ProcessBuilder builder = new ProcessBuilder(command);
            builder.environment().putIfAbsent("PYTHONIOENCODING", "utf-8");
            builder.environment().putIfAbsent("PYTHONUTF8", "1");
            Process process = builder.start();
            Future<String> stdoutFuture = executor.submit(() -> readStream(process.getInputStream()));
            Future<String> stderrFuture = executor.submit(() -> readStream(process.getErrorStream()));

            boolean finished = process.waitFor(timeoutSeconds, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                return new ProbeOutput(-1, "", "timeout");
            }
            String stdout = getFutureOutput(stdoutFuture, timeoutSeconds, "stdout");
            String stderr = getFutureOutput(stderrFuture, timeoutSeconds, "stderr");
            return new ProbeOutput(process.exitValue(), stdout, stderr);
        } catch (IOException ex) {
            return new ProbeOutput(-1, "", ex.getMessage());
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            return new ProbeOutput(-1, "", "interrupted");
        } finally {
            executor.shutdownNow();
        }
    }

    private List<String> appendArgs(List<String> baseCommand, String... args) {
        List<String> command = new ArrayList<>(baseCommand);
        for (String arg : args) {
            command.add(arg);
        }
        return command;
    }

    private List<String> ensureUnbuffered(List<String> baseCommand) {
        if (baseCommand.contains("-u")) {
            return baseCommand;
        }
        List<String> command = new ArrayList<>(baseCommand);
        int insertIndex = command.size();
        if (command.size() >= 2 && "py".equalsIgnoreCase(command.get(0)) && command.get(1).startsWith("-")) {
            insertIndex = 2;
        }
        command.add(insertIndex, "-u");
        return command;
    }

    private boolean isExecutableAvailable(List<String> command) {
        if (command.isEmpty()) {
            return false;
        }
        Path path = Paths.get(command.get(0));
        return !path.isAbsolute() || Files.exists(path);
    }

    private List<String> splitCommand(String raw) {
        List<String> command = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean inQuotes = false;
        char quoteChar = 0;
        for (int i = 0; i < raw.length(); i++) {
            char ch = raw.charAt(i);
            if ((ch == '"' || ch == '\'') && !inQuotes) {
                inQuotes = true;
                quoteChar = ch;
                continue;
            }
            if (inQuotes && ch == quoteChar) {
                inQuotes = false;
                continue;
            }
            if (!inQuotes && Character.isWhitespace(ch)) {
                if (current.length() > 0) {
                    command.add(current.toString());
                    current.setLength(0);
                }
                continue;
            }
            current.append(ch);
        }
        if (current.length() > 0) {
            command.add(current.toString());
        }
        return command;
    }

    private String readStream(java.io.InputStream stream) throws IOException {
        byte[] bytes = stream.readAllBytes();
        return new String(bytes, StandardCharsets.UTF_8);
    }

    private String buildPythonFailureMessage(String stderr, String stdout, int exitCode, List<String> pythonCommand, Path scriptPath) {
        String combined = (stderr + "\n" + stdout).trim();
        String missingPackage = detectMissingPackage(combined);
        StringBuilder message = new StringBuilder("Prediction process failed (exit ")
                .append(exitCode)
                .append(") using ")
                .append(String.join(" ", pythonCommand))
                .append(" on script ")
                .append(scriptPath)
                .append(".");

        if (missingPackage != null) {
            message.append(" Missing Python package: ").append(missingPackage).append('.');
        }
        if (!combined.isBlank()) {
            message.append(" Output: ").append(trimMessage(combined));
        }
        log.warn(message.toString());
        return message.toString();
    }

    private String detectMissingPackage(String output) {
        if (output == null || output.isBlank()) {
            return null;
        }
        Matcher matcher = MISSING_MODULE_PATTERN.matcher(output);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private String trimMessage(String output) {
        int max = 500;
        if (output.length() <= max) {
            return output;
        }
        return output.substring(0, max) + "...";
    }

    private Path resolvePredictionScriptPath() {
        String configured = System.getProperty("prediction.scriptPath");
        if (configured == null || configured.isBlank()) {
            configured = System.getenv("PREDICT_SCRIPT_PATH");
        }
        if (configured != null && !configured.isBlank()) {
            Path configuredPath = Paths.get(configured).normalize();
            if (Files.exists(configuredPath)) {
                return configuredPath;
            }
        }

        Path currentDir = Paths.get(System.getProperty("user.dir"));
        Path resolved = findScriptUpwards(currentDir);
        if (resolved != null) {
            return resolved;
        }
        return currentDir.resolve("ute_bookstore_python").resolve("predict.py").normalize();
    }

    private Path findScriptUpwards(Path start) {
        Path cursor = start.toAbsolutePath();
        for (int i = 0; i < 6; i++) {
            Path candidate = cursor.resolve("ute_bookstore_python").resolve("predict.py");
            if (Files.exists(candidate)) {
                return candidate.normalize();
            }
            Path parent = cursor.getParent();
            if (parent == null) {
                break;
            }
            cursor = parent;
        }
        return null;
    }

    private LocalDate toLocalDate(Object value) {
        if (value instanceof java.sql.Date sqlDate) {
            return sqlDate.toLocalDate();
        }
        if (value instanceof Date date) {
            return date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        }
        if (value instanceof LocalDate localDate) {
            return localDate;
        }
        return null;
    }

    private String buildSuggestion(double changePercent, double confidence, int dataPoints, int spanDays) {
        if (dataPoints < 30 || spanDays < 30) {
            return "Du lieu chua du day, can thu thap them giao dich truoc khi ra quyet dinh.";
        }
        if (confidence < 50) {
            return "Xu huong dang dao dong, can theo doi them trong vai tuan toi.";
        }
        if (changePercent >= 10) {
            return "Doanh thu tang, nen tang ton kho va duy tri chien dich marketing.";
        }
        if (changePercent <= -10) {
            return "Doanh thu giam, xem xet tang khuyen mai va phan tich nhom san pham.";
        }
        return "Doanh thu on dinh, duy tri chat luong dich vu va theo doi sat sao.";
    }

    private LocalDate resolvePredictionStart() {
        LocalDate defaultFrom = LocalDate.now().minusDays(365);
        Date minOrderDate = ordersRepository.findMinOrderDate();
        if (minOrderDate == null) {
            return defaultFrom;
        }
        LocalDate minDate = minOrderDate.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        return minDate.isBefore(defaultFrom) ? minDate : defaultFrom;
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

    private BigDecimal sumSeries(List<DashboardSeriesPoint> series) {
        BigDecimal total = BigDecimal.ZERO;
        for (DashboardSeriesPoint point : series) {
            if (point != null && point.getValue() != null) {
                total = total.add(point.getValue());
            }
        }
        return total;
    }

    private String safeString(Object value) {
        return value != null ? value.toString() : "";
    }

    private boolean isCancelled(String status) {
        if (status == null) {
            return false;
        }
        return "CANCELLED".equalsIgnoreCase(status) || "CANCELED".equalsIgnoreCase(status);
    }

    private String formatActivityTime(Date dateTime) {
        if (dateTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return formatter.format(dateTime.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime());
    }

    private String formatCurrency(BigDecimal value) {
        BigDecimal safeValue = value == null ? BigDecimal.ZERO : value;
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(new Locale("vi", "VN"));
        symbols.setGroupingSeparator('.');
        symbols.setDecimalSeparator(',');
        DecimalFormat formatter = new DecimalFormat("#,###", symbols);
        formatter.setGroupingSize(3);
        formatter.setMaximumFractionDigits(0);
        formatter.setMinimumFractionDigits(0);
        return formatter.format(safeValue) + " đ";
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

    private boolean isWindows() {
        String os = System.getProperty("os.name", "").toLowerCase(Locale.ROOT);
        return os.contains("win");
    }

    private enum Bucket {
        DAY,
        MONTH
    }

    private static class PredictionMetrics {
        private final double mae;
        private final double mse;
        private final double rmse;
        private final double r2;
        private final double tomorrowPrediction;
        private final int dataPoints;
        private final int spanDays;
        private final double confidence;
        private final double modelPrediction;
        private final double trendPrediction;
        private final double wmaPrediction;
        private final double growthRate;

        private PredictionMetrics(
                double mae,
                double mse,
                double rmse,
                double r2,
                double tomorrowPrediction,
                int dataPoints,
                int spanDays,
                double confidence,
                double modelPrediction,
                double trendPrediction,
                double wmaPrediction,
                double growthRate
        ) {
            this.mae = mae;
            this.mse = mse;
            this.rmse = rmse;
            this.r2 = r2;
            this.tomorrowPrediction = tomorrowPrediction;
            this.dataPoints = dataPoints;
            this.spanDays = spanDays;
            this.confidence = confidence;
            this.modelPrediction = modelPrediction;
            this.trendPrediction = trendPrediction;
            this.wmaPrediction = wmaPrediction;
            this.growthRate = growthRate;
        }
    }

    private static class DailyPredictionRow {
        private BigDecimal revenue = BigDecimal.ZERO;
        private long orderCount;
        private long booksSold;
        private long cancelCount;
        private long distinctCustomers;
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

    private static class ActivityEntry {
        private final Date time;
        private final DashboardRecentActivityResponse activity;

        private ActivityEntry(Date time, DashboardRecentActivityResponse activity) {
            this.time = time;
            this.activity = activity;
        }
    }

    private static class ProbeOutput {
        private final int exitCode;
        private final String stdout;
        private final String stderr;

        private ProbeOutput(int exitCode, String stdout, String stderr) {
            this.exitCode = exitCode;
            this.stdout = stdout;
            this.stderr = stderr;
        }
    }

    public static class PredictionJobResult {
        private final String status;
        private final DashboardRevenuePredictionResponse prediction;
        private final String message;

        private PredictionJobResult(String status, DashboardRevenuePredictionResponse prediction, String message) {
            this.status = status;
            this.prediction = prediction;
            this.message = message;
        }

        public static PredictionJobResult pending() {
            return new PredictionJobResult("PENDING", null, null);
        }

        public static PredictionJobResult done(DashboardRevenuePredictionResponse prediction) {
            return new PredictionJobResult("DONE", prediction, null);
        }

        public static PredictionJobResult failed(String message) {
            return new PredictionJobResult("FAILED", null, message);
        }

        public static PredictionJobResult notFound() {
            return new PredictionJobResult("NOT_FOUND", null, "Prediction job not found.");
        }

        public String getStatus() {
            return status;
        }

        public DashboardRevenuePredictionResponse getPrediction() {
            return prediction;
        }

        public String getMessage() {
            return message;
        }
    }
}
