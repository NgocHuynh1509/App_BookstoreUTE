package com.hcmute.bookstore.Export;

import com.hcmute.bookstore.Service.MeiliSearchService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CsvAutoScheduler {

    private final CsvExportService csvExportService;
    private final MeiliSearchService meiliSearchService;

    public CsvAutoScheduler(CsvExportService csvExportService, MeiliSearchService meiliSearchService) {
        this.csvExportService = csvExportService;
        this.meiliSearchService = meiliSearchService;
    }

    // fixedRate = 120,000ms = 2 phút (để bạn test cho nhanh)
    // Nếu muốn đúng 10 phút, hãy đổi thành: 600_000
//    @Scheduled(fixedRate = 120_000)
    public void autoSyncTask() {
        try {
            System.out.println("=== [BẮT ĐẦU] TIẾN TRÌNH TỰ ĐỘNG ĐỒNG BỘ ===");

            // Bước 1: Xuất dữ liệu từ Database ra file CSV
            csvExportService.exportBooksToCsv();
            System.out.println("-> Đã xuất file CSV thành công.");

            // Bước 2: Đẩy file CSV vừa xuất lên Meilisearch
            meiliSearchService.syncCsvToMeilisearch();
            System.out.println("-> Đã đồng bộ lên Meilisearch thành công.");

            System.out.println("=== [KẾT THÚC] TỰ ĐỘNG ĐỒNG BỘ HOÀN TẤT ===");

        } catch (Exception e) {
            System.err.println("❌ Lỗi trong quá trình tự động đồng bộ: " + e.getMessage());
            e.printStackTrace();
        }
    }
}