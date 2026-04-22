package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.hcmute.bookstore.Service.SearchFilterService;
import com.hcmute.bookstore.Service.QueryUnderstandingService;
import com.hcmute.bookstore.Service.RankingService;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RecommendationService {
    private static final int MIN_SCORE = 120;
    private static final int MIN_SCORE_STRICT = 150;
    private final RankingService rankingService;
    private final SearchFilterService searchFilterService;

    public List<Books> rerank(List<Books> candidates, QueryUnderstandingService.UnderstoodQuery query, String userText, boolean strict) {
        // Step 1: Filter out semantic mismatches & out-of-scope books
        List<Books> filtered = searchFilterService.filterBySemanticContext(candidates, query, userText);

        // Step 2: Nếu strict mode, filter thêm theo category alignment
        if (strict && query.topic() != null && !query.topic().isBlank()) {
            filtered = searchFilterService.filterByCategoryAlignment(filtered, query.topic());
        }

        // Step 3: Build terms untuk ranking
        List<String> terms = List.of(
                userText == null ? "" : userText,
                query.topic() == null ? "" : query.topic(),
                query.mood() == null ? "" : query.mood(),
                query.style() == null ? "" : query.style(),
                query.goal() == null ? "" : query.goal(),
                query.problem() == null ? "" : query.problem()
        );

        // Step 4: Rank & filter theo score threshold
        int threshold = strict ? MIN_SCORE_STRICT : MIN_SCORE;
        List<Books> ranked = filtered.stream()
                .filter(book -> rankingService.score(book, terms) >= threshold)
                .sorted(Comparator.comparingInt((Books b) -> rankingService.score(b, terms)).reversed())
                .limit(5)
                .toList();

        return ranked;
    }
}
