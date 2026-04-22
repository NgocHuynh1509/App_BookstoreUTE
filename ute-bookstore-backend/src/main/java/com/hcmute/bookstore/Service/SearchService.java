package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Repository.BooksRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class SearchService {
    private final BooksRepository booksRepository;
    private final MeiliSearchService meiliSearchService;
    private static final Map<String, List<String>> SYNONYMS = buildSynonyms();

    public List<Books> searchHybrid(String userText, QueryUnderstandingService.UnderstoodQuery query) {
        List<String> terms = collectTerms(userText, query);
        String meiliFilter = buildMeiliFilter(query, userText);

        LinkedHashMap<String, Books> merged = new LinkedHashMap<>();

        // Pass 0: Category-specific search if topic is clear
        if (query.topic() != null && !query.topic().isBlank()) {
            String categoryKeyword = extractCategoryKeyword(query.topic());
            if (!categoryKeyword.isBlank()) {
                for (String term : terms) {
                    if (term == null || term.isBlank()) continue;
                    List<Books> found = booksRepository.searchByCategory(
                            categoryKeyword, term, PageRequest.of(0, 30));
                    found.stream()
                            .filter(b -> Boolean.TRUE.equals(b.getIsActive()) && b.getQuantity() > 0)
                            .forEach(b -> merged.putIfAbsent(b.getBookId(), b));
                    if (merged.size() >= 80) break;
                }
                if (merged.size() >= 80) return new ArrayList<>(merged.values());
            }
        }

        // Pass 1: MeiliSearch (best effort)
        for (String term : terms) {
            if (term == null || term.isBlank()) continue;
            List<String> meiliIds = meiliSearchService.searchBookIds(term, meiliFilter, 20);
            if (meiliIds.isEmpty()) continue;
            booksRepository.findAllById(meiliIds).stream()
                    .filter(b -> Boolean.TRUE.equals(b.getIsActive()) && b.getQuantity() > 0)
                    .forEach(b -> merged.putIfAbsent(b.getBookId(), b));
            if (merged.size() >= 100) break;
        }

        // Pass 2: SQL LIKE search
        for (String term : terms) {
            if (term == null || term.isBlank()) continue;
            List<Books> found = booksRepository.searchForAi(term, PageRequest.of(0, 40));
            for (Books b : found) {
                merged.putIfAbsent(b.getBookId(), b);
                if (merged.size() >= 100) break;
            }
            if (merged.size() >= 100) break;
        }

        // Pass 3: Phrase-based retrieval
        String fullPhrase = normalize(userText);
        if (!fullPhrase.isBlank()) {
            List<String> phraseMeiliIds = meiliSearchService.searchBookIds(fullPhrase, meiliFilter, 20);
            if (!phraseMeiliIds.isEmpty()) {
                booksRepository.findAllById(phraseMeiliIds).stream()
                        .filter(b -> Boolean.TRUE.equals(b.getIsActive()) && b.getQuantity() > 0)
                        .forEach(b -> merged.putIfAbsent(b.getBookId(), b));
            }
            List<Books> phraseFound = booksRepository.searchForAi(fullPhrase, PageRequest.of(0, 30));
            for (Books b : phraseFound) {
                merged.putIfAbsent(b.getBookId(), b);
                if (merged.size() >= 120) break;
            }
        }

        // Fallback: Popular books from category
        if (merged.isEmpty() && query.topic() != null && !query.topic().isBlank()) {
            String categoryKeyword = extractCategoryKeyword(query.topic());
            if (!categoryKeyword.isBlank()) {
                List<Books> popular = booksRepository.findByCategoryNameOrderBySoldQuantity(
                        categoryKeyword, PageRequest.of(0, 60));
                for (Books b : popular) {
                    merged.putIfAbsent(b.getBookId(), b);
                    if (merged.size() >= 80) break;
                }
            }
        }

        if (merged.isEmpty()) {
            booksRepository.findByIsActiveTrue().stream()
                    .filter(b -> b.getQuantity() > 0)
                    .limit(60)
                    .forEach(b -> merged.putIfAbsent(b.getBookId(), b));
        }
        return new ArrayList<>(merged.values());
    }

    /**
     * Extract category keyword from topic for precise search
     */
    private String extractCategoryKeyword(String topic) {
        if (topic == null || topic.isBlank()) return "";
        String n = normalize(topic);

        if (n.contains("suc khoe") || n.contains("health")) return "health";
        if (n.contains("trinh tham") || n.contains("mystery")) return "mystery";
        if (n.contains("nau an") || n.contains("cooking")) return "cooking";
        if (n.contains("kinh doanh") || n.contains("business")) return "business";
        if (n.contains("java") || n.contains("software")) return "programming";
        if (n.contains("tinh cam") || n.contains("romance")) return "romance";
        if (n.contains("giao duc")) return "giao duc";
        if (n.contains("thieu nhi")) return "thieu nhi";

        return n;
    }

    private List<String> collectTerms(String userText, QueryUnderstandingService.UnderstoodQuery query) {
        List<String> terms = new ArrayList<>();
        
        // Priority 1: userText (most specific)
        terms.addAll(tokenize(userText));
        
        // Priority 2: query fields
        terms.addAll(tokenize(query.topic()));
        terms.addAll(tokenize(query.goal()));
        terms.addAll(tokenize(query.problem()));
        terms.addAll(tokenize(query.style()));
        terms.addAll(tokenize(query.mood()));
        
        // Priority 3: signals
        terms.addAll(query.signals());

        // Expand with synonyms, remove duplicates
        List<String> expanded = new ArrayList<>();
        Set<String> seen = new HashSet<>();
        
        for (String term : terms) {
            if (term == null || term.isBlank() || seen.contains(term)) continue;
            seen.add(term);
            expanded.add(term);
            
            List<String> synonyms = expandSynonyms(term);
            for (String syn : synonyms) {
                if (!seen.contains(syn)) {
                    expanded.add(syn);
                    seen.add(syn);
                }
            }
            
            if (expanded.size() >= 50) break;
        }
        
        return expanded;
    }

    private String buildMeiliFilter(QueryUnderstandingService.UnderstoodQuery query, String userText) {
        String n = normalize((query.topic() == null ? "" : query.topic()) + " " + (userText == null ? "" : userText));
        if (containsAny(n, List.of("cong nghe", "technology", "tech", "java", "backend", "spring"))) {
            return "categoryName = \"Cong Nghe\"";
        }
        if (containsAny(n, List.of("trinh tham", "mystery", "detective", "crime", "thriller"))) {
            return "categoryName = \"Trinh Tham\"";
        }
        if (containsAny(n, List.of("suc khoe", "wellness", "healthy", "dinh duong", "giam can"))) {
            return "categoryName = \"Suc Khoe\"";
        }
        if (containsAny(n, List.of("fiction", "novel", "truyen"))) {
            return "categoryName = \"Fiction\"";
        }
        return null;
    }

    private List<String> tokenize(String text) {
        if (text == null || text.isBlank()) return List.of();
        String n = normalize(text);
        String[] parts = n.split("[^\\p{L}\\p{N}]+");
        List<String> out = new ArrayList<>();
        for (String p : parts) {
            if (p.length() >= 3) out.add(p);
            if (out.size() >= 8) break;
        }
        return out;
    }

    private String normalize(String input) {
        return Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .toLowerCase(Locale.ROOT)
                .trim();
    }

    private boolean containsAny(String value, List<String> keys) {
        for (String key : keys) if (value.contains(key)) return true;
        return false;
    }

    private List<String> expandSynonyms(String term) {
        String n = normalize(term);
        List<String> out = new ArrayList<>();
        for (Map.Entry<String, List<String>> entry : SYNONYMS.entrySet()) {
            if (n.contains(entry.getKey())) {
                out.addAll(entry.getValue());
            }
        }
        return out;
    }

    private static Map<String, List<String>> buildSynonyms() {
        Map<String, List<String>> map = new HashMap<>();

        // Health & Wellness
        map.put("suc khoe", List.of("health", "healthy", "wellness", "dinh duong", "nutrition"));
        map.put("mat ngu", List.of("sleep", "stress", "wellness", "relax", "rest"));
        map.put("chua lanh", List.of("healing", "self help", "mental wellness", "psychology"));
        map.put("stress", List.of("relaxation", "meditation", "wellness", "mental health"));

        // Mystery & Thriller
        map.put("trinh tham", List.of("mystery", "detective", "crime", "thriller"));
        map.put("mystery", List.of("detective", "crime", "thriller", "suspense"));
        map.put("tham tu", List.of("detective", "mystery", "crime", "investigation"));

        // Cooking & Food
        map.put("nau an", List.of("cooking", "recipe", "food", "cuisine"));
        map.put("cooking", List.of("recipe", "food", "cuisine", "kitchen"));
        map.put("recipe", List.of("cooking", "food", "cuisine", "kitchen"));

        // Business & Entrepreneurship
        map.put("kinh doanh", List.of("business", "startup", "entrepreneurship"));
        map.put("business", List.of("startup", "entrepreneurship", "management"));
        map.put("startup", List.of("business", "entrepreneurship", "technology"));

        // Programming & Software
        map.put("java", List.of("java programming", "coding", "software development", "backend"));
        map.put("backend", List.of("java", "software development", "coding", "programming"));
        map.put("coding", List.of("programming", "software", "development", "java"));
        map.put("software", List.of("programming", "development", "coding", "technology"));
        map.put("lap trinh", List.of("programming", "coding", "software", "java"));

        // Self-help & Personal Development
        map.put("phat trien", List.of("self-help", "personal development", "skills", "learning"));
        map.put("ky nang", List.of("skills", "learning", "development", "personal growth"));
        map.put("tay nghề", List.of("skills", "craft", "technique", "expertise"));

        // Romance & Relationships
        map.put("tinh cam", List.of("romance", "love", "relationship", "dating"));
        map.put("romance", List.of("love", "relationship", "tinh cam", "dating"));
        map.put("yeu", List.of("romance", "love", "relationship", "heart"));

        // Fiction & Literature
        map.put("truyen", List.of("fiction", "novel", "story", "tale"));
        map.put("fiction", List.of("novel", "story", "truyen", "literature"));
        map.put("novel", List.of("fiction", "story", "literature", "book"));
        map.put("tieu thuyet", List.of("fiction", "novel", "story", "truyen"));

        // Children & Education
        map.put("thieu nhi", List.of("children", "kids", "education", "learning"));
        map.put("giao duc", List.of("education", "learning", "school", "teaching"));

        // Travel & Exploration
        map.put("du lich", List.of("travel", "adventure", "exploration", "journey"));
        map.put("travel", List.of("adventure", "exploration", "journey", "vacation"));

        return map;
    }
}
