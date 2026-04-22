package com.hcmute.bookstore.Service;

import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets; // Thêm import này
@Service
public class MeiliSearchService {

    public void syncCsvToMeilisearch() {
        try {
            // 1. Đọc nội dung file CSV của bạn
            String baseDir = System.getProperty("user.dir");
            Path folder = Paths.get(baseDir, "ute_bookstore_python");
            Path csvPath = folder.resolve("books_latest.csv");
            // SỬA DÒNG NÀY: Ép đọc bằng StandardCharsets.UTF_8
            String csvContent = Files.readString(csvPath, StandardCharsets.UTF_8);

            // 2. Cấu hình RestTemplate
            RestTemplate restTemplate = new RestTemplate();

            // URL mặc định của Meilisearch (books là tên index)
            String url = "http://localhost:7700/indexes/books/documents?primaryKey=bookId";

            HttpHeaders headers = new HttpHeaders();
            // SỬA DÒNG NÀY: Thêm charset=utf-8 vào Header để Meilisearch biết đường xử lý
            headers.setContentType(MediaType.parseMediaType("text/csv; charset=utf-8"));
            // Nếu bạn chạy meili.exe mà không đặt master key thì không cần dòng này
            // headers.set("Authorization", "Bearer your_master_key");

            HttpEntity<String> entity = new HttpEntity<>(csvContent, headers);

            // 3. Gửi Request POST để đẩy dữ liệu
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

            if (response.getStatusCode().is2xxSuccessful()) {
                System.out.println("✅ Đồng bộ Meilisearch thành công qua API!");
            }

        } catch (Exception e) {
            System.err.println("❌ Lỗi đồng bộ: " + e.getMessage());
        }
    }

    // Stub for searchBookIds
    public java.util.List<String> searchBookIds(String query, String filter, int limit) {
        return java.util.Collections.emptyList();
    }
}
