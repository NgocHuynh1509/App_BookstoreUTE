package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Repository.BooksRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Pageable;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SearchServiceTest {
    @Mock
    private BooksRepository booksRepository;
    @Mock
    private MeiliSearchService meiliSearchService;

    private SearchService searchService;

    @BeforeEach
    void setUp() {
        searchService = new SearchService(booksRepository, meiliSearchService);
        when(meiliSearchService.searchBookIds(ArgumentMatchers.anyString(), ArgumentMatchers.anyInt()))
                .thenReturn(List.of());
        when(booksRepository.searchForAi(ArgumentMatchers.anyString(), ArgumentMatchers.any(Pageable.class)))
                .thenReturn(List.of());
        when(booksRepository.findByIsActiveTrue()).thenReturn(List.of(new Books()));
    }

    @Test
    void shouldExpandSynonymsAndSearchWithoutCrash() {
        var query = new QueryUnderstandingService.UnderstoodQuery(
                "health nutrition", "stressed", "light", "beginner",
                "relax", "sleep better", List.of("mental_wellness"), false
        );
        assertDoesNotThrow(() -> searchService.searchHybrid("Tôi cần sách giúp ngủ ngon", query));
        verify(booksRepository, atLeastOnce()).searchForAi(ArgumentMatchers.anyString(), ArgumentMatchers.any(Pageable.class));
    }
}
