package com.hcmute.bookstore.Service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Collectors;

@Service
@Slf4j
public class BookRecommendService {

//    public String recommendBooks(String bookId) {
//        try {
//            String baseDir = System.getProperty("user.dir");
//            Path pythonDir = Paths.get(baseDir, "ute_bookstore_python");
//            Path scriptPath = pythonDir.resolve("ml.py");
//
//            ProcessBuilder pb = new ProcessBuilder("python", scriptPath.toString(), bookId);
//            pb.directory(pythonDir.toFile());
//
//            Process process = pb.start();
//            long start = System.currentTimeMillis();
//
//            String stdout;
//            try (BufferedReader reader = new BufferedReader(
//                    new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
//                stdout = reader.lines().collect(Collectors.joining("\n"));
//            }
//
//            String stderr;
//            try (BufferedReader reader = new BufferedReader(
//                    new InputStreamReader(process.getErrorStream(), StandardCharsets.UTF_8))) {
//                stderr = reader.lines().collect(Collectors.joining("\n"));
//            }
//
//            int exitCode = process.waitFor();
//            log.info("Thời gian Python chạy: {} ms", (System.currentTimeMillis() - start));
//
//            if (exitCode != 0) {
//                log.error("Python ML error: {}", stderr);
//                return "[]";
//            }
//
//            return stdout == null || stdout.isBlank() ? "[]" : stdout;
//
//        } catch (Exception e) {
//            log.error("Recommend error", e);
//            return "[]";
//        }
//    }

    public String recommendBooks(String bookId) {
        try {
            String baseDir = System.getProperty("user.dir");
            Path pythonDir = Paths.get(baseDir, "ute_bookstore_python");
            Path scriptPath = pythonDir.resolve("ml.py");
            Path simMatrixPath = pythonDir.resolve("sim_matrix.csv");

            // 1. KIỂM TRA TRƯỚC: Nếu không có file ma trận, không gọi Python làm gì cho tốn tài nguyên
            if (!Files.exists(simMatrixPath)) {
                log.warn("Bỏ qua gợi ý: sim_matrix.csv chưa được khởi tạo.");
                return "[]";
            }

            ProcessBuilder pb = new ProcessBuilder("python", scriptPath.toString(), bookId);
            pb.directory(pythonDir.toFile());

            Process process = pb.start();
            long start = System.currentTimeMillis();

            // 2. Đọc kết quả (STDOUT)
            String stdout;
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                stdout = reader.lines().collect(Collectors.joining("\n"));
            }

            // 3. Đọc log lỗi nếu có (STDERR)
            String stderr;
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getErrorStream(), StandardCharsets.UTF_8))) {
                stderr = reader.lines().collect(Collectors.joining("\n"));
            }

            int exitCode = process.waitFor();
            log.info("Gợi ý hoàn tất trong: {} ms", (System.currentTimeMillis() - start));

            if (exitCode != 0) {
                log.error("Python ML error: {}", stderr);
                return "[]";
            }

            return (stdout == null || stdout.isBlank()) ? "[]" : stdout;

        } catch (Exception e) {
            log.error("Recommend error", e);
            return "[]";
        }
    }


}