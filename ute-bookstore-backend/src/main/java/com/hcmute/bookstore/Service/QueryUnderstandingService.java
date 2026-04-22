package com.hcmute.bookstore.Service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class QueryUnderstandingService {
    private final GeminiService geminiService;

    public static class SemanticQuery {
        public String rawQuery;
        public String keyword;
        public String category;
        public String author;
        public Double minPrice;
        public Double maxPrice;
        public String intent;
        public boolean valid;

        public SemanticQuery() {}
    }

    public record UnderstoodQuery(
            String topic,
            String mood,
            String style,
            String level,
            String goal,
            String problem,
            List<String> signals,
            boolean ambiguous
    ) {}

    public UnderstoodQuery understand(String userText, List<GeminiService.HistoryEntry> history) {
        SemanticQuery semantic = understandUserQuery(userText, history);
        String normalized = normalize(userText);
        List<String> signals = extractSignals(normalized);

        String topic = firstNonBlank(semantic.category, inferTopicFromSignals(signals, normalized));
        String mood = inferMood(normalized);
        String style = inferStyle(normalized);
        String level = inferLevel(normalized);
        String goal = firstNonBlank(semantic.intent, inferGoal(normalized));
        String problem = inferProblem(normalized);

        boolean ambiguous = (topic == null || topic.isBlank())
                && !containsAny(normalized, List.of("sach", "doc", "truyen", "book"));
        return new UnderstoodQuery(topic, mood, style, level, goal, problem, signals, ambiguous);
    }

    public SemanticQuery understandUserQuery(String query, List<GeminiService.HistoryEntry> history) {
        SemanticQuery fallback = localParse(query);
        try {
            SemanticQuery aiParsed = geminiService.understandUserQuery(query, history);
            if (aiParsed != null && aiParsed.valid) {
                // Keep fallback values when AI misses fields.
                if (isBlank(aiParsed.keyword)) aiParsed.keyword = fallback.keyword;
                if (isBlank(aiParsed.category)) aiParsed.category = fallback.category;
                if (isBlank(aiParsed.author)) aiParsed.author = fallback.author;
                if (isBlank(aiParsed.intent)) aiParsed.intent = fallback.intent;
                if (aiParsed.minPrice == null) aiParsed.minPrice = fallback.minPrice;
                if (aiParsed.maxPrice == null) aiParsed.maxPrice = fallback.maxPrice;
                aiParsed.rawQuery = query;
                return aiParsed;
            }
        } catch (Exception ignored) {
            // Fallback parser below
        }
        return fallback;
    }

    private SemanticQuery localParse(String query) {
        String n = normalize(query);
        SemanticQuery parsed = new SemanticQuery();
        parsed.rawQuery = query;
        parsed.keyword = query == null ? "" : query.trim();
        parsed.intent = "BOOK_SEARCH";
        parsed.valid = query != null && !query.isBlank();

        if (containsAny(n, List.of("java", "backend", "spring", "lap trinh"))) parsed.category = "Cong Nghe";
        else if (containsAny(n, List.of("trinh tham", "mystery", "detective", "crime"))) parsed.category = "Trinh Tham";
        else if (containsAny(n, List.of("suc khoe", "dinh duong", "giam can", "wellness"))) parsed.category = "Suc Khoe";
        else if (containsAny(n, List.of("kinh doanh", "business", "startup"))) parsed.category = "Kinh Doanh";
        else parsed.category = "";

        if (n.contains("nguyen nhat anh")) parsed.author = "Nguyen Nhat Anh";
        else parsed.author = "";

        return parsed;
    }

    private List<String> extractSignals(String normalized) {
        List<String> out = new ArrayList<>();
        if (containsAny(normalized, List.of("stress", "met", "cang thang", "lo au", "mat ngu"))) out.add("mental_wellness");
        if (containsAny(normalized, List.of("chia tay", "that tinh", "co don", "chua lanh"))) out.add("healing");
        if (containsAny(normalized, List.of("pha an", "hack nao", "truy tim", "manh moi"))) out.add("detective");
        if (containsAny(normalized, List.of("backend", "lap trinh", "java", "code", "software"))) out.add("programming");
        if (containsAny(normalized, List.of("cong nghe", "technology", "tech"))) out.add("technology");
        if (containsAny(normalized, List.of("trinh tham", "mystery", "crime", "detective"))) out.add("detective");
        if (containsAny(normalized, List.of("healthy", "dinh duong", "an lanh manh", "suc khoe"))) out.add("health");
        if (containsAny(normalized, List.of("giao tiep", "thuyet phuc", "noi chuyen"))) out.add("communication");
        if (containsAny(normalized, List.of("kinh doanh", "khoi nghiep", "quan tri"))) out.add("business");
        if (containsAny(normalized, List.of("nguyen nhat anh"))) out.add("author_nguyen_nhat_anh");
        return out;
    }

    private String inferTopicFromSignals(List<String> signals, String normalized) {
        if (signals.contains("mental_wellness") || signals.contains("healing")) return "mental wellness";
        if (signals.contains("detective")) return "mystery thriller";
        if (signals.contains("technology")) return "technology";
        if (signals.contains("programming")) return "software development";
        if (signals.contains("health")) return "health nutrition";
        if (signals.contains("communication")) return "communication skills";
        if (signals.contains("business")) return "business";
        if (containsAny(normalized, List.of("hay", "nen doc gi", "doc gi do"))) return "";
        return "";
    }

    private String inferMood(String normalized) {
        if (containsAny(normalized, List.of("stress", "met", "cang thang", "ap luc"))) return "stressed";
        if (containsAny(normalized, List.of("buon", "co don", "chia tay"))) return "sad";
        if (containsAny(normalized, List.of("hao hung", "muon hoc", "quyet tam"))) return "motivated";
        return "";
    }

    private String inferStyle(String normalized) {
        if (containsAny(normalized, List.of("nhe dau", "de doc", "don gian", "nhe nhang"))) return "light";
        if (containsAny(normalized, List.of("hack nao", "sau sac", "chuyen sau"))) return "deep";
        return "";
    }

    private String inferLevel(String normalized) {
        if (containsAny(normalized, List.of("tu dau", "moi bat dau", "it doc sach"))) return "beginner";
        if (containsAny(normalized, List.of("nang cao", "chuyen sau"))) return "advanced";
        return "";
    }

    private String inferGoal(String normalized) {
        if (containsAny(normalized, List.of("thu gian", "ngu ngon", "chua lanh"))) return "relax and recover";
        if (containsAny(normalized, List.of("hoc code", "hoc backend", "hoc java"))) return "learn coding";
        if (containsAny(normalized, List.of("qua tang"))) return "gift";
        return "";
    }

    private String inferProblem(String normalized) {
        if (containsAny(normalized, List.of("stress", "mat ngu", "chia tay"))) return "emotional pressure";
        if (containsAny(normalized, List.of("khong biet bat dau", "it doc sach"))) return "no reading habit";
        return "";
    }

    private String normalize(String input) {
        if (input == null) return "";
        return Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .toLowerCase(Locale.ROOT)
                .trim();
    }

    private boolean containsAny(String value, List<String> keys) {
        for (String key : keys) if (value.contains(key)) return true;
        return false;
    }

    private String firstNonBlank(String first, String fallback) {
        if (first != null && !first.isBlank()) return first;
        return fallback == null ? "" : fallback;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
