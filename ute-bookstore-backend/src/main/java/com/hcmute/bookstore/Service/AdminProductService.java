package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.Category;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.CategoryRepository;
import com.hcmute.bookstore.Repository.ReviewRepository;
import com.hcmute.bookstore.dto.admin.AdminBookRequest;
import com.hcmute.bookstore.dto.admin.AdminBookResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminProductService {

    private final BooksRepository booksRepository;
    private final CategoryRepository categoryRepository;
    private final ReviewRepository reviewRepository;

    // 1. Tiêm thêm 2 Service này vào
    private final com.hcmute.bookstore.Export.CsvExportService csvExportService;
    private final com.hcmute.bookstore.Service.MeiliSearchService meiliSearchService;

    public Page<AdminBookResponse> getBooks(String search, String categoryId, Pageable pageable) {
        Page<Books> page;
        if (search != null && !search.isBlank() && categoryId != null && !categoryId.isBlank()) {
            page = booksRepository.findByTitleContainingIgnoreCaseAndCategory_CategoryId(
                    search.trim(),
                    categoryId.trim(),
                    pageable
            );
        } else if (search != null && !search.isBlank()) {
            page = booksRepository.findByTitleContainingIgnoreCase(search.trim(), pageable);
        } else if (categoryId != null && !categoryId.isBlank()) {
            page = booksRepository.findByCategory_CategoryId(categoryId.trim(), pageable);
        } else {
            page = booksRepository.findAll(pageable);
        }

        // Bước 2: Thực hiện chuỗi đồng bộ dữ liệu
//        try {
//            log.info("Bắt đầu đồng bộ dữ liệu cho sách mới: {}");
//
//            // Xuất dữ liệu từ DB ra file books_latest.csv
//            csvExportService.exportBooksToCsv();
//
//            // Đẩy dữ liệu CSV lên Meilisearch
//            meiliSearchService.syncCsvToMeilisearch();
//
//            // Cuối cùng mới gọi Python để build lại ma trận từ file CSV mới
//            triggerPythonBuild();
//
//            log.info("Hoàn tất toàn bộ tiến trình đồng bộ và build ML.");
//        } catch (Exception e) {
//            // Log lỗi nhưng không chặn việc trả về response (vì DB đã lưu xong)
//            log.error("Lỗi trong quá trình đồng bộ sau khi tạo sách: ", e);
//        }

        return page.map(this::toResponse);
    }

    private void triggerPythonBuild() {
        try {
            String baseDir = System.getProperty("user.dir");
            Path pythonDir = Paths.get(baseDir, "ute_bookstore_python");
            Path scriptPath = pythonDir.resolve("ml.py");

            ProcessBuilder pb = new ProcessBuilder("python", scriptPath.toString(), "BUILD_ONLY");
            pb.directory(pythonDir.toFile());

            Process process = pb.start();

            // 1. Đọc log thông thường từ Python (print)
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("[Python STDOUT]: " + line);
                    log.info("Python: {}", line);
                }
            }

            // 2. Đọc log lỗi hoặc log sys.stderr từ Python
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getErrorStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.err.println("[Python STDERR]: " + line);
                    log.error("Python Error: {}", line);
                }
            }

            int exitCode = process.waitFor();
            if (exitCode == 0) {
                log.info("Python ML: Hoàn tất cập nhật sim_matrix.csv");
            } else {
                log.warn("Python ML: Kết thúc với mã lỗi {}", exitCode);
            }

        } catch (Exception e) {
            log.error("Lỗi thực thi lệnh build ML: ", e);
        }
    }

    public AdminBookResponse create(AdminBookRequest request) {
        if (booksRepository.existsById(request.getBookId())) {
            throw new RuntimeException("BookId đã tồn tại");
        }

        Books book = new Books();
        book.setBookId(request.getBookId());
        applyRequest(book, request);



        return toResponse(booksRepository.save(book));
    }

    public AdminBookResponse update(String bookId, AdminBookRequest request) {
        Books book = booksRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sách"));

        applyRequest(book, request);
        return toResponse(booksRepository.save(book));
    }

    public void delete(String bookId) {
        if (!booksRepository.existsById(bookId)) {
            throw new RuntimeException("Không tìm thấy sách");
        }
        booksRepository.deleteById(bookId);
    }

    private void applyRequest(Books book, AdminBookRequest request) {
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thể loại"));

        book.setTitle(request.getTitle());
        book.setAuthor(request.getAuthor());
        book.setPublisher(request.getPublisher());
        book.setPublicationYear(request.getPublicationYear());
        book.setDescription(request.getDescription());
        book.setPrice(request.getPrice());
        book.setOriginalPrice(request.getOriginalPrice());
        book.setQuantity(request.getQuantity());
        book.setPicture(request.getPicture());
        book.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);
        book.setCategory(category);
    }

    private AdminBookResponse toResponse(Books book) {
        AdminBookResponse response = new AdminBookResponse();
        response.setBookId(book.getBookId());
        response.setTitle(book.getTitle());
        response.setAuthor(book.getAuthor());
        response.setPublisher(book.getPublisher());
        response.setPublicationYear(book.getPublicationYear());
        response.setDescription(book.getDescription());
        response.setPrice(book.getPrice());
        response.setOriginalPrice(book.getOriginalPrice());
        response.setQuantity(book.getQuantity());
        response.setSoldQuantity(book.getSoldQuantity());
        response.setIsActive(book.getIsActive());
        response.setPicture(book.getPicture());
        if (book.getCategory() != null) {
            response.setCategoryId(book.getCategory().getCategoryId());
            response.setCategoryName(book.getCategory().getCategoryName());
        }
        final Double averageRating = reviewRepository.findAverageRatingByBookId(book.getBookId());
        final int reviewCount = reviewRepository.countByBook_BookId(book.getBookId());
        response.setAverageRating(averageRating != null ? averageRating : 0.0);
        response.setReviewCount(reviewCount);
        return response;
    }

    public void syncBooksAndRebuildMl() {
        try {
            log.info("Bắt đầu đồng bộ dữ liệu sách sang CSV + Meilisearch + Python ML");

            csvExportService.exportBooksToCsv();
            meiliSearchService.syncCsvToMeilisearch();
            triggerPythonBuild();

            log.info("Hoàn tất toàn bộ tiến trình đồng bộ và build ML.");
        } catch (Exception e) {
            log.error("Lỗi trong quá trình đồng bộ dữ liệu sách: ", e);
            throw new RuntimeException("Đồng bộ dữ liệu thất bại: " + e.getMessage(), e);
        }
    }
}
