package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Export.CsvExportService;
import com.hcmute.bookstore.Service.MeiliSearchService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController

@RequestMapping("/books/search")
public class SearchController {

    private final MeiliSearchService meiliSearchService;
    private final CsvExportService csvExportService;

    public SearchController(MeiliSearchService meiliSearchService, CsvExportService csvExportService) {
        this.meiliSearchService = meiliSearchService;
        this.csvExportService = csvExportService;
    }

    @PostMapping("/sync")
    public ResponseEntity<String> fullSync() {
        // 1. Export từ DB ra CSV mới nhất
        csvExportService.exportBooksToCsv();
        // 2. Đẩy CSV đó lên Meilisearch
        meiliSearchService.syncCsvToMeilisearch();

        return ResponseEntity.ok("Sync completed!");
    }
}
