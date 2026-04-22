package com.hcmute.bookstore.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hcmute.bookstore.Entity.Books;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class GeminiService {
    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    private static final String ENDPOINT =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

    private final ObjectMapper objectMapper = new ObjectMapper();

    public record HistoryEntry(String role, String text) {}

    public GeminiResult generateRecommendations(String userText, List<Books> candidates) {
        return generateRecommendations(userText, candidates, List.of());
    }

    public GeminiResult generateRecommendations(String userText, List<Books> candidates,
                                                 List<HistoryEntry> history) {
        String prompt = buildPrompt(userText, candidates, history);
        String raw = callGemini(prompt);
        return parseGeminiResponse(raw);
    }

    private String buildPrompt(String userText, List<Books> candidates, List<HistoryEntry> history) {
        List<Map<String, Object>> list = candidates.stream().limit(100)
                .map(b -> {
                    Map<String, Object> map = new java.util.LinkedHashMap<>();
                    map.put("id", String.valueOf(b.getBookId()));
                    map.put("title", b.getTitle() != null ? b.getTitle() : "");
                    map.put("author", b.getAuthor() != null ? b.getAuthor() : "");
                    map.put("category", b.getCategory() != null ? b.getCategory().getCategoryName() : "");
                    String desc = b.getDescription() != null ? b.getDescription() : "";
                    map.put("description", desc.length() > 120 ? desc.substring(0, 120) : desc);
                    map.put("price", b.getPrice() != null ? b.getPrice().doubleValue() : 0.0);
                    return map;
                })
                .toList();

        String booksJson = safeJson(list);

        StringBuilder sb = new StringBuilder();
        sb.append("Bạn là nhân viên tư vấn sách thân thiện của nhà sách BookstoreUTE.\n");
        sb.append("Phong cách: tự nhiên, ấm áp, dùng emoji vừa phải.\n\n");

        sb.append("HƯỚNG DẪN QUAN TRỌNG:\n");
        sb.append("- Chỉ gợi ý sách có trong DANH SÁCH SÁCH bên dưới, không bịa đặt.\n");
        sb.append("- Chọn tối đa 5 sách phù hợp nhất với yêu cầu khách.\n");
        sb.append("- Phản hồi bằng tiếng Việt, ngắn gọn, không dài dòng.\n");
        sb.append("- Nếu câu hỏi ngoài phạm vi sách (ví dụ: hỏi về thức ăn, thời tiết, giải trí): ");
        sb.append("nhận biết ý khách một cách thân thiện, sau đó nhẹ nhàng hướng về sách. bookIds trả về [].\n");
        sb.append("- Nếu khách phản hồi 'không đúng', 'chưa chuẩn', 'sách khác đi': xin lỗi ngắn và gợi ý lại đúng hơn.\n");
        sb.append("- Dựa vào LỊCH SỬ HỘI THOẠI để hiểu ngữ cảnh câu hỏi tiếp theo.\n\n");

        sb.append("ĐỊNH DẠNG TRẢ LỜI (JSON thuần, KHÔNG dùng Markdown, không thêm văn bản ngoài JSON):\n");
        sb.append("{\"reply\":\"câu trả lời tự nhiên bằng tiếng Việt\",\"bookIds\":[\"id1\",\"id2\"]}\n\n");

        if (!history.isEmpty()) {
            sb.append("LỊCH SỬ HỘI THOẠI GẦN ĐÂY:\n");
            for (HistoryEntry h : history) {
                sb.append(h.role().equals("USER") ? "Khách: " : "Tư vấn: ");
                sb.append(h.text()).append("\n");
            }
            sb.append("\n");
        }

        if (!candidates.isEmpty()) {
            sb.append("DANH SÁCH SÁCH CÓ SẴN:\n").append(booksJson).append("\n\n");
        }

        sb.append("Câu hỏi của khách: ").append(userText);
        return sb.toString();
    }

    private String callGemini(String prompt) {
        if (geminiApiKey == null || geminiApiKey.isBlank()) {
            return "";
        }

        try {
            SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
            requestFactory.setConnectTimeout(6000);
            requestFactory.setReadTimeout(7000);

            RestTemplate restTemplate = new RestTemplate(requestFactory);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> body = Map.of(
                    "contents", List.of(
                            Map.of("role", "user", "parts", List.of(Map.of("text", prompt)))
                    ),
                    "generationConfig", Map.of(
                            "temperature", 0.7,
                            "maxOutputTokens", 900
                    )
            );

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            String url = ENDPOINT + "?key=" + geminiApiKey;
            String response = restTemplate.postForObject(url, entity, String.class);
            return response != null ? response : "";
        } catch (Exception e) {
            return "";
        }
    }

    private GeminiResult parseGeminiResponse(String raw) {
        try {
            if (raw == null || raw.isBlank()) {
                return new GeminiResult("", List.of());
            }
            JsonNode root = objectMapper.readTree(raw);
            JsonNode parts = root.path("candidates").path(0).path("content").path("parts");
            String combined = "";
            if (parts.isArray()) {
                StringBuilder sb = new StringBuilder();
                for (JsonNode p : parts) {
                    sb.append(p.path("text").asText(""));
                }
                combined = sb.toString().trim();
            }

            if (combined.isBlank()) {
                return new GeminiResult("", List.of());
            }

            String json = extractJson(combined);
            JsonNode parsed = objectMapper.readTree(json);
            String reply = parsed.path("reply").asText("").trim();
            List<String> ids = new ArrayList<>();
            JsonNode arr = parsed.path("bookIds");
            if (arr.isArray()) {
                for (JsonNode id : arr) {
                    ids.add(id.asText());
                }
            }
            return new GeminiResult(reply, ids);
        } catch (Exception e) {
            return new GeminiResult("", List.of());
        }
    }

    private String extractJson(String text) {
        String cleaned = text.replaceAll("```json", "").replaceAll("```", "").trim();
        int start = cleaned.indexOf('{');
        int end = cleaned.lastIndexOf('}');
        if (start >= 0 && end > start) {
            return cleaned.substring(start, end + 1);
        }
        return cleaned;
    }

    private String safeJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            return "[]";
        }
    }

    public record GeminiResult(String reply, List<String> bookIds) {}
}
