package com.hcmute.bookstore.Service;

import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.List;

@Service
public class ChatIntentService {

    public enum Intent {
        BOOK_SEARCH,
        ORDER_SUPPORT,
        GENERAL_CHAT,
        OUT_OF_SCOPE
    }

    public Intent detectIntent(String message) {
        if (message == null || message.isBlank()) {
            return Intent.OUT_OF_SCOPE;
        }

        String normalized = normalize(message);

        // Order-related
        if (containsAny(normalized, List.of(
                "don hang", "kiem tra don", "huy don", "tra hang", "giao hang",
                "van chuyen", "order", "thanh toan", "hoa don", "ship", "shipper",
                "doi hang", "bao hanh", "hoan tien"
        ))) {
            return Intent.ORDER_SUPPORT;
        }

        // General greeting / small talk
        if (containsAny(normalized, List.of(
                "xin chao", "chao ban", "hello", "hi ban", "hey", "chao buoi",
                "ban la ai", "may la ai", "cam on", "thank", "bạn khỏe", "ban khoe",
                "hom nay the nao", "sao roi", "ban gioi", "tuyet voi"
        ))) {
            return Intent.GENERAL_CHAT;
        }

        // Out-of-scope topics (detect before book search to avoid false matches)
        if (containsAny(normalized, List.of(
                "bun bo", "pho", "banh mi", "do an", "nau an", "mon an", "thuc pham",
                "choi game", "game online", "lien quan", "pubg", "genshin",
                "xem phim", "netflix", "youtube", "tik tok", "mang xa hoi",
                "thoi tiet", "nhiet do", "bao cao su", "thoi su"
        ))) {
            return Intent.OUT_OF_SCOPE;
        }

        // Emotional / mood (can lead to book suggestion)
        if (containsAny(normalized, List.of(
                "buon qua", "chan qua", "stress qua", "met qua", "ap luc qua",
                "that vong", "co don", "khong vui", "dang buon"
        ))) {
            return Intent.BOOK_SEARCH;
        }

        // Book-related
        if (containsAny(normalized, List.of(
                "sach", "book", "truyen", "tieu thuyet", "trinh tham", "self help", "selfhelp",
                "lap trinh", "java", "python", "coding", "cam dong", "buon", "tinh cam",
                "ky nang", "kinh te", "tai chinh", "dau tu", "mystery", "detective",
                "crime", "suspense", "investigation", "tham tu", "lang man", "romance",
                "thieu nhi", "lich su", "khoa hoc", "tam ly", "van hoc", "ngu phap",
                "doc sach", "goi y sach", "tim sach", "nen doc", "hay nhat", "best seller",
                "tac gia", "nha xuat ban", "the loai"
        ))) {
            return Intent.BOOK_SEARCH;
        }

        return Intent.OUT_OF_SCOPE;
    }

    private String normalize(String input) {
        String noAccent = Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        return noAccent.toLowerCase();
    }

    private boolean containsAny(String normalized, List<String> patterns) {
        for (String pattern : patterns) {
            if (normalized.contains(pattern)) {
                return true;
            }
        }
        return false;
    }
}
