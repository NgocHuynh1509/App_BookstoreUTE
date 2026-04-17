package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Untils.EncryptionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatMediaController {

    private final EncryptionUtils encryptionUtils; // Class đã viết ở trên

    @PostMapping("/upload")
    public ResponseEntity<String> uploadMedia(@RequestParam("file") MultipartFile file) {
        try {
            // 1. Mã hóa nội dung file
            byte[] encryptedData = encryptionUtils.encrypt(file.getBytes());

            // 2. Lưu file đã mã hóa vào thư mục (Ví dụ: uploads/chat/)
            String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
            Path path = Paths.get("uploads/chat/" + fileName);
            Files.createDirectories(path.getParent());
            Files.write(path, encryptedData);

            // 3. Trả về URL để Client gửi qua WebSocket
            return ResponseEntity.ok("/chat/media/" + fileName);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Upload failed: " + e.getMessage());
        }
    }
    @GetMapping("/media/{fileName}")
    public ResponseEntity<byte[]> getMedia(@PathVariable String fileName) {
        try {
            Path path = Paths.get("uploads/chat/" + fileName);
            byte[] encryptedData = Files.readAllBytes(path);

            // Giải mã dữ liệu
            byte[] decryptedData = encryptionUtils.decrypt(encryptedData);

            // Xác định loại file (image/png, video/mp4...)
            String contentType = Files.probeContentType(path);

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .body(decryptedData);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
