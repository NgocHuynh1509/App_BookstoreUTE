package com.hcmute.bookstore.Controller.Admin;

import com.hcmute.bookstore.Service.AdminProductService;
import com.hcmute.bookstore.dto.admin.AdminBookRequest;
import com.hcmute.bookstore.dto.admin.AdminBookResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping({"/admin/products", "/products"})
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','STAFF')")
public class AdminProductController {

    private final AdminProductService adminProductService;

    @GetMapping
    public Page<AdminBookResponse> getProducts(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return adminProductService.getBooks(
                search,
                categoryId,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "bookId"))
        );
    }

    @PostMapping
    public AdminBookResponse create(@Valid @RequestBody AdminBookRequest request) {
        return adminProductService.create(request);
    }

    @PutMapping("/{bookId}")
    public AdminBookResponse update(
            @PathVariable String bookId,
            @Valid @RequestBody AdminBookRequest request
    ) {
        return adminProductService.update(bookId, request);
    }

    @DeleteMapping("/{bookId}")
    public void delete(@PathVariable String bookId) {
        adminProductService.delete(bookId);
    }

    @PostMapping("/sync-search")
    public ResponseEntity<?> syncSearchAndMl() {
        adminProductService.syncBooksAndRebuildMl();
        return ResponseEntity.ok(
                Map.of(
                        "success", true,
                        "message", "Đồng bộ CSV, Meilisearch và build ML thành công"
                )
        );
    }
}
