package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Repository.BooksRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class ChatResponseService {
    private static final Logger log = LoggerFactory.getLogger(ChatResponseService.class);

    private static final String ANON_USER = "anonymous";
    private static final ConcurrentHashMap<String, ChatContext> CONTEXTS = new ConcurrentHashMap<>();
    private static final int MAX_HISTORY = 12; // 6 turns

    private final ChatIntentService chatIntentService;
    private final BooksRepository booksRepository;
    private final GeminiService geminiService;

    public ChatService.AiChatResult respond(String message) {
        return respond(message, null);
    }

    public ChatService.AiChatResult respond(String message, String userName) {
        String text = message != null ? message.trim() : "";
        String userKey = (userName == null || userName.isBlank()) ? ANON_USER : userName.trim();
        if (text.isBlank()) {
            return new ChatService.AiChatResult("Xin lỗi, tôi chưa thể trả lời lúc này.", List.of());
        }

        ChatContext context = CONTEXTS.getOrDefault(userKey, ChatContext.empty());
        ChatIntentService.Intent intent = chatIntentService.detectIntent(text);
        log.info("AI_CHAT message='{}' intent={} user={}", text, intent, userKey);

        // Negative feedback → re-search with stricter filter on last topic
        if (isNegativeFeedback(text) && context.lastTopic() != null) {
            ChatService.AiChatResult retry = handleBookSearch(text, context.lastTopic(), true, userKey, context);
            String prefix = "Bạn nói đúng 👍 Để mình gợi ý lại chuẩn hơn nhé:\n";
            String fullReply = prefix + retry.reply();
            updateHistory(userKey, context, text, fullReply);
            return new ChatService.AiChatResult(fullReply, retry.books());
        }

        // Refinement query (context-aware follow-up)
        if (intent != ChatIntentService.Intent.BOOK_SEARCH
                && context.lastTopic() != null
                && isRefinementQuery(text)) {
            return handleBookSearch(text, context.lastTopic(), false, userKey, context);
        }

        return switch (intent) {
            case BOOK_SEARCH -> handleBookSearch(text, null, false, userKey, context);
            case ORDER_SUPPORT -> {
                String reply = "Bạn vui lòng vào mục Đơn hàng để kiểm tra trạng thái đơn nhé. " +
                        "Nếu cần hỗ trợ thêm mình luôn ở đây 😊";
                updateHistory(userKey, context, text, reply);
                yield new ChatService.AiChatResult(reply, List.of());
            }
            case GENERAL_CHAT -> {
                String reply = buildGeneralChatReply(text, context.history());
                updateHistory(userKey, context, text, reply);
                yield new ChatService.AiChatResult(reply, List.of());
            }
            case OUT_OF_SCOPE -> {
                String reply = buildOutOfScopeReply(text);
                updateHistory(userKey, context, text, reply);
                yield new ChatService.AiChatResult(reply, List.of());
            }
        };
    }

    // ── Book search ───────────────────────────────────────────────────────────

    private ChatService.AiChatResult handleBookSearch(String text, String forcedTopic,
                                                      boolean strict, String userKey,
                                                      ChatContext context) {
        String topic = (forcedTopic != null && !forcedTopic.isBlank())
                ? forcedTopic : extractTopic(text);

        // 1. Find candidates from DB
        List<Books> candidates = findAiCandidates(text);
        if (candidates.isEmpty()) {
            candidates = booksRepository.findByIsActiveTrue().stream()
                    .filter(b -> b.getQuantity() > 0)
                    .limit(50)
                    .toList();
        }

        // 2. Filter by topic keywords if topic is known
        List<String> topicKeywords = topicKeywords(topic);
        if (!topicKeywords.isEmpty()) {
            List<Books> filtered = filterByTopic(candidates, topicKeywords);
            if (!filtered.isEmpty()) {
                candidates = filtered;
            }
        }

        if (candidates.isEmpty()) {
            String reply = "Hiện tại mình chưa tìm thấy sách phù hợp, bạn thử từ khóa khác nhé 🔍";
            updateHistory(userKey, context, text, reply);
            return new ChatService.AiChatResult(reply, List.of());
        }

        // 3. Always use Gemini to pick best matches and generate natural reply
        GeminiService.GeminiResult gemini = geminiService.generateRecommendations(
                text, candidates, context.history());

        // 4. Map Gemini's chosen IDs to book objects
        List<Books> picked = List.of();
        if (!gemini.bookIds().isEmpty()) {
            picked = candidates.stream()
                    .filter(b -> gemini.bookIds().contains(String.valueOf(b.getBookId())))
                    .limit(5)
                    .toList();
        }

        // 5. Fallback: take first 5 candidates if Gemini picked nothing
        if (picked.isEmpty()) {
            picked = candidates.stream().limit(5).toList();
        }

        // 6. Build reply text
        String reply = (gemini.reply() != null && !gemini.reply().isBlank())
                ? gemini.reply()
                : buildFallbackBookReply(topic);

        List<ChatService.AiBookResult> books = picked.stream()
                .map(b -> new ChatService.AiBookResult(
                        b.getBookId(),
                        b.getTitle(),
                        b.getAuthor(),
                        b.getPrice(),
                        b.getPicture()))
                .toList();

        String topicToSave = (topic != null && !topic.isBlank()) ? topic : context.lastTopic();
        updateHistoryWithTopic(userKey, context, text, reply, topicToSave, books.size(), strict);
        log.info("AI_CHAT_RESULT books={} topic='{}' reply='{}'", books.size(), topicToSave, reply);
        return new ChatService.AiChatResult(reply, books);
    }

    // ── Candidate fetching ────────────────────────────────────────────────────

    private List<Books> findAiCandidates(String message) {
        List<String> keywords = new ArrayList<>(extractKeywords(message, true));
        List<String> rawKw = extractKeywords(message, false);
        for (String kw : rawKw) {
            if (!keywords.contains(kw)) keywords.add(kw);
        }
        if (keywords.isEmpty()) keywords = List.of(message);

        LinkedHashMap<String, Books> collected = new LinkedHashMap<>();
        for (String keyword : keywords) {
            List<Books> found = booksRepository.searchForAi(keyword, PageRequest.of(0, 30));
            for (Books book : found) {
                collected.putIfAbsent(String.valueOf(book.getBookId()), book);
                if (collected.size() >= 80) break;
            }
            if (collected.size() >= 80) break;
        }

        log.info("AI_CHAT_CANDIDATES keywords={} count={}", keywords, collected.size());
        return new ArrayList<>(collected.values());
    }

    private List<Books> filterByTopic(List<Books> candidates, List<String> topicKeywords) {
        return candidates.stream()
                .filter(book -> matchesTopic(book, topicKeywords))
                .toList();
    }

    private boolean matchesTopic(Books book, List<String> topicKeywords) {
        String combined = normalize(
                (book.getTitle() != null ? book.getTitle() : "") + " " +
                (book.getDescription() != null ? book.getDescription() : "") + " " +
                (book.getCategory() != null ? book.getCategory().getCategoryName() : "")
        );
        for (String kw : topicKeywords) {
            if (combined.contains(kw)) return true;
        }
        return false;
    }

    // ── Topic detection & keywords ────────────────────────────────────────────

    private String extractTopic(String message) {
        String n = normalize(message);
        if (n.contains("trinh tham")) return "trinh thám";
        if (n.contains("self help") || n.contains("selfhelp") || n.contains("ky nang")) return "self-help";
        if (n.contains("buon") || n.contains("cam dong") || n.contains("chua lanh")) return "cảm động";
        if (n.contains("lap trinh") || n.contains("java") || n.contains("python") || n.contains("coding")) return "lập trình";
        if (n.contains("tinh cam") || n.contains("lang man") || n.contains("romance")) return "tình cảm";
        if (n.contains("tieu thuyet")) return "tiểu thuyết";
        if (n.contains("kinh te") || n.contains("tai chinh")) return "kinh tế";
        if (n.contains("thieu nhi") || n.contains("tre em")) return "thiếu nhi";
        if (n.contains("lich su") || n.contains("lich su viet")) return "lịch sử";
        return "";
    }

    private List<String> topicKeywords(String topic) {
        if (topic == null || topic.isBlank()) return List.of();
        String n = normalize(topic);
        if (n.contains("trinh tham")) return List.of("trinh tham", "mystery", "detective", "crime", "suspense", "investigation", "tham tu");
        if (n.contains("self help") || n.contains("selfhelp") || n.contains("ky nang")) return List.of("self help", "selfhelp", "ky nang", "phat trien", "thanh cong");
        if (n.contains("tinh cam") || n.contains("lang man")) return List.of("tinh cam", "romance", "love", "lang man", "tinh yeu");
        if (n.contains("cam dong") || n.contains("chua lanh")) return List.of("cam dong", "buon", "chua lanh", "healing", "noi long");
        if (n.contains("lap trinh") || n.contains("java") || n.contains("python")) return List.of("lap trinh", "java", "python", "coding", "programming", "cong nghe");
        if (n.contains("kinh te") || n.contains("tai chinh")) return List.of("kinh te", "tai chinh", "dau tu", "kinh doanh");
        if (n.contains("thieu nhi")) return List.of("thieu nhi", "tre em", "nhi dong");
        if (n.contains("lich su")) return List.of("lich su", "su hoc", "truyen su");
        return List.of(n);
    }

    // ── Intent helpers ────────────────────────────────────────────────────────

    private boolean isNegativeFeedback(String message) {
        String n = normalize(message);
        return containsAny(n, List.of(
                "khong dung y", "khong dung", "chua chuan", "sai the loai", "do dau phai",
                "khong phai", "sach khac", "khong giong", "khong dung the loai", "chua dung",
                "dat lai", "thu lai", "khong hop", "sai roi", "kho nhu vay", "tim lai",
                "goi y lai", "cho minh sach khac", "khong thich", "khong hay",
                "dau phai trinh tham", "chang phai"
        ));
    }

    private boolean isRefinementQuery(String message) {
        String n = normalize(message);
        return containsAny(n, List.of(
                "viet nam", "ngan thoi", "ngan gon", "ngan hon", "loai buon hon",
                "plot twist", "buon hon", "nghe", "de doc", "kho", "sau sac",
                "co that", "gan day", "moi nhat", "cua tac gia", "cung tac gia",
                "tuong tu", "giong vay", "vay thoi", "them cuon nua"
        ));
    }

    // ── Reply builders ────────────────────────────────────────────────────────

    private String buildFallbackBookReply(String topic) {
        if (topic != null && !topic.isBlank()) {
            return "Mình tìm được vài cuốn " + topic + " hay cho bạn 📚";
        }
        return "Mình gợi ý một số sách phù hợp cho bạn 📚";
    }

    private String buildGeneralChatReply(String message, List<GeminiService.HistoryEntry> history) {
        String n = normalize(message);
        if (containsAny(n, List.of("xin chao", "chao", "hello", "hi", "hey"))) {
            return "Xin chào bạn! 😊 Mình là trợ lý AI của BookstoreUTE. Bạn muốn tìm sách gì hôm nay?";
        }
        if (containsAny(n, List.of("cam on", "thanks", "thank"))) {
            return "Không có gì 😊 Nếu bạn cần tìm thêm sách hay, mình luôn ở đây nhé!";
        }
        if (containsAny(n, List.of("ban la ai", "may la ai", "ai vay"))) {
            return "Mình là trợ lý AI của nhà sách BookstoreUTE 📚 Mình có thể giúp bạn tìm sách và hỗ trợ đơn hàng. Bạn cần gì nào?";
        }
        if (containsAny(n, List.of("ban khoe", "hom nay the nao", "sao roi"))) {
            return "Mình ổn lắm, cảm ơn bạn hỏi 😄 Bạn đang tìm loại sách gì để mình giúp nhé!";
        }
        return "Mình là trợ lý AI BookstoreUTE 📚 Bạn muốn tìm sách hay cần hỗ trợ đơn hàng gì không?";
    }

    private String buildOutOfScopeReply(String message) {
        String n = normalize(message);
        if (containsAny(n, List.of("bun bo", "pho", "bun", "an uong", "do an", "nau an", "mon ngon", "com", "chao"))) {
            return "Mình hiểu là bạn đang thèm món ăn rồi 😄 Tiếc là mình chỉ biết về sách thôi. Nếu bạn muốn tìm sách dạy nấu ăn hoặc truyện hay thì mình giúp ngay nhé 📚";
        }
        if (containsAny(n, List.of("thoi tiet", "troi", "mua", "nang", "lanh", "nong"))) {
            return "Thời tiết hôm nay thế nào thì đọc sách vẫn là ý hay nhỉ 📖 Mình có thể gợi ý sách phù hợp cho bạn không?";
        }
        if (containsAny(n, List.of("choi game", "game", "lien quan", "pubg", "genshin"))) {
            return "Nghe hay đấy 😄 Nhưng mình chỉ rành về sách thôi. Nếu bạn muốn tìm sách về game hoặc lập trình game thì mình giúp được nhé!";
        }
        if (containsAny(n, List.of("phim", "xem phim", "netflix", "youtube"))) {
            return "Phim cũng hay lắm 🎬 Nhưng mình chuyên sách hơn. Bạn có muốn mình gợi ý sách chuyển thể thành phim nổi tiếng không?";
        }
        if (containsAny(n, List.of("buon", "chan", "met", "stress", "ap luc"))) {
            return "Nghe có vẻ bạn đang không vui 😔 Mình biết có vài cuốn sách chữa lành hoặc truyền động lực rất hay — bạn muốn mình gợi ý không?";
        }
        if (containsAny(n, List.of("yeu", "tinh yeu", "nguoi yeu", "crush", "chia tay"))) {
            return "Chuyện tình cảm luôn phức tạp nhỉ 😊 Nếu bạn muốn đọc sách tình cảm hay hoặc sách tâm lý tình yêu, mình gợi ý cho nhé!";
        }
        return "Mình hiểu ý bạn 😊 Nhưng mình chuyên hỗ trợ sách và đơn hàng thôi. Nếu bạn muốn tìm sách hay, mình sẵn sàng giúp ngay 📚";
    }

    // ── Context management ────────────────────────────────────────────────────

    private void updateHistory(String userKey, ChatContext context, String userText, String aiReply) {
        List<GeminiService.HistoryEntry> hist = new ArrayList<>(context.history());
        hist.add(new GeminiService.HistoryEntry("USER", userText));
        hist.add(new GeminiService.HistoryEntry("AI", aiReply));
        if (hist.size() > MAX_HISTORY) hist = hist.subList(hist.size() - MAX_HISTORY, hist.size());
        CONTEXTS.put(userKey, new ChatContext(context.lastTopic(), context.lastBookCount(), context.strictMode(), hist));
    }

    private void updateHistoryWithTopic(String userKey, ChatContext context, String userText, String aiReply,
                                        String topic, int bookCount, boolean strict) {
        List<GeminiService.HistoryEntry> hist = new ArrayList<>(context.history());
        hist.add(new GeminiService.HistoryEntry("USER", userText));
        hist.add(new GeminiService.HistoryEntry("AI", aiReply));
        if (hist.size() > MAX_HISTORY) hist = hist.subList(hist.size() - MAX_HISTORY, hist.size());
        CONTEXTS.put(userKey, new ChatContext(topic, bookCount, strict, hist));
    }

    // ── Keyword extraction ────────────────────────────────────────────────────

    private List<String> extractKeywords(String message, boolean applyNormalize) {
        String source = applyNormalize ? normalize(message) : message.toLowerCase(Locale.ROOT);
        String[] parts = source.split("[^\\p{L}\\p{N}]+");
        Set<String> stopWords = Set.of(
                "toi", "muon", "can", "tim", "sach", "ve", "the", "loai", "goi", "y",
                "hay", "cho", "minh", "ban", "nhung", "nhieu", "nao", "mot", "xin",
                "duoc", "nhe", "a", "oi", "voi", "nay", "do", "gi"
        );
        List<String> keywords = new ArrayList<>();
        for (String part : parts) {
            if (part.length() < 2) continue;
            if (stopWords.contains(normalize(part))) continue;
            keywords.add(part);
            if (keywords.size() >= 6) break;
        }
        return keywords;
    }

    // ── Utils ─────────────────────────────────────────────────────────────────

    private String normalize(String input) {
        if (input == null) return "";
        String noAccent = Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        return noAccent.toLowerCase(Locale.ROOT).trim();
    }

    private boolean containsAny(String normalized, List<String> patterns) {
        for (String pattern : patterns) {
            if (normalized.contains(pattern)) return true;
        }
        return false;
    }

    // ── Context record ────────────────────────────────────────────────────────

    private record ChatContext(String lastTopic, int lastBookCount, boolean strictMode,
                               List<GeminiService.HistoryEntry> history) {
        private static ChatContext empty() {
            return new ChatContext(null, 0, false, new ArrayList<>());
        }
    }
}
