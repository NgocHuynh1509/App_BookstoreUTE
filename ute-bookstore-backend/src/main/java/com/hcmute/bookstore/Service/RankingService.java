package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class RankingService {
    private final ReviewRepository reviewRepository;
    private final ConcurrentHashMap<String, Double> ratingCache = new ConcurrentHashMap<>();

    public int score(Books b, List<String> terms) {
        String category = normalize(b.getCategory() != null ? b.getCategory().getCategoryName() : "");
        String title = normalize(b.getTitle());
        String subtitle = normalize(b.getPublisher()); // subtitle/tags proxy
        String description = normalize(b.getDescription());
        String author = normalize(b.getAuthor());

        int score = 0;
        for (String term : terms) {
            if (term == null || term.isBlank()) continue;
            for (String token : term.split("[^\\p{L}\\p{N}]+")) {
                if (token.length() < 2) continue;
                if (category.equals(token) || category.contains(token)) score += 120;
                if (title.equals(token) || title.contains(" " + token + " ") || title.startsWith(token + " ")) score += 90;
                else if (title.contains(token)) score += 70;
                if (subtitle.contains(token)) score += 60;
                if (description.contains(token)) score += 50;
                if (author.contains(token)) score += 30;
            }
        }

        score += popularityScore(b);
        score -= mismatchPenalty(category, terms);
        return score;
    }

    private int mismatchPenalty(String category, List<String> terms) {
        String joined = normalize(String.join(" ", terms));
        
        // Penalty loại 1: Health queries nhưng category giáo dục, thiếu nhi
        if (containsAny(joined, List.of("health", "wellness", "nutrition", "suc khoe", "healthy", "mat ngu"))
                && containsAny(category, List.of("giao duc", "thieu nhi", "tinh cam"))) {
            return 100; // tăng từ 80
        }
        
        // Penalty loại 2: Mystery queries nhưng category sai lạc
        if (containsAny(joined, List.of("mystery", "detective", "crime", "thriller", "trinh tham"))
                && containsAny(category, List.of("tinh cam", "romance", "thieu nhi", "giao duc"))) {
            return 90;
        }
        
        // Penalty loại 3: Programming/Java queries nhưng category không phù hợp
        if (containsAny(joined, List.of("java", "backend", "software development", "coding", "programming"))
                && containsAny(category, List.of("ky nang song", "tinh cam", "thieu nhi", "giao duc"))) {
            return 110; // tăng từ 90
        }
        
        // Penalty loại 4: Cooking queries nhưng category không liên quan
        if (containsAny(joined, List.of("cooking", "recipe", "food", "nau an", "cuisine"))
                && containsAny(category, List.of("giao duc", "thieu nhi", "java", "programming"))) {
            return 80;
        }
        
        return 0;
    }

    private int popularityScore(Books b) {
        int score = 0;
        Double avgRating = ratingCache.computeIfAbsent(b.getBookId(),
                id -> {
                    Double r = reviewRepository.findAverageRatingByBookId(id);
                    return r == null ? 0.0 : r;
                });
        if (avgRating >= 4.5) score += 20;
        else if (avgRating >= 4.0) score += 15;
        else if (avgRating >= 3.5) score += 10;

        int sold = b.getSoldQuantity();
        if (sold >= 500) score += 10;
        else if (sold >= 100) score += 6;
        else if (sold >= 20) score += 3;
        return score;
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
}
