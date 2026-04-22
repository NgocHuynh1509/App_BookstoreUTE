package com.hcmute.bookstore.Service;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class QueryUnderstandingServiceTest {

    private final QueryUnderstandingService service = new QueryUnderstandingService(new GeminiService());

    @Test
    void shouldDetectSleepStressNeed() {
        var result = service.understand("Tôi cần sách giúp ngủ ngon, dạo này stress quá", List.of());
        assertTrue(result.signals().contains("mental_wellness"));
        assertTrue(result.topic().contains("mental"));
        assertFalse(result.ambiguous());
    }

    @Test
    void shouldDetectStressLightReadingNeed() {
        var result = service.understand("Dạo này căng thẳng quá, muốn đọc gì đó nhẹ đầu", List.of());
        assertTrue(result.signals().contains("mental_wellness"));
        assertTrue(result.style().contains("light"));
    }

    @Test
    void shouldDetectBusinessGiftNeed() {
        var result = service.understand("Tôi cần quà tặng cho người thích kinh doanh", List.of());
        assertTrue(result.signals().contains("business"));
        assertTrue(result.goal().contains("gift"));
    }

    @Test
    void shouldDetectBackendBeginnerNeed() {
        var result = service.understand("Muốn học code backend từ đầu", List.of());
        assertTrue(result.signals().contains("programming"));
        assertTrue(result.level().contains("beginner"));
    }
}
