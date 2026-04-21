package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Category;
import com.hcmute.bookstore.Repository.CategoryRepository;
import com.hcmute.bookstore.dto.admin.CategoryRequest;
import com.hcmute.bookstore.dto.admin.CategoryResponse;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
public class AdminCategoryService {

    private final CategoryRepository categoryRepository;

    public AdminCategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<CategoryResponse> getAll() {
        return categoryRepository.findAll()
                .stream()
                .sorted(Comparator.comparing(Category::getCategoryId))
                .map(this::toResponse)
                .toList();
    }

    public CategoryResponse getById(String id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy danh mục: " + id));
        return toResponse(category);
    }

    @Transactional
    public CategoryResponse create(CategoryRequest request) {
        String categoryName = request.getCategoryName() != null
                ? request.getCategoryName().trim()
                : "";

        if (categoryName.isEmpty()) {
            throw new IllegalArgumentException("Tên danh mục không được để trống");
        }

        if (categoryRepository.existsByCategoryNameIgnoreCase(categoryName)) {
            throw new IllegalArgumentException("Tên danh mục đã tồn tại");
        }

        Category category = new Category();
        category.setCategoryId(generateNextCategoryId());
        category.setCategoryName(categoryName);

        Category saved = categoryRepository.save(category);
        return toResponse(saved);
    }

    @Transactional
    public CategoryResponse update(String id, CategoryRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy danh mục: " + id));

        String categoryName = request.getCategoryName() != null
                ? request.getCategoryName().trim()
                : "";

        if (categoryName.isEmpty()) {
            throw new IllegalArgumentException("Tên danh mục không được để trống");
        }

        if (categoryRepository.existsByCategoryNameIgnoreCaseAndCategoryIdNot(categoryName, id)) {
            throw new IllegalArgumentException("Tên danh mục đã tồn tại");
        }

        category.setCategoryName(categoryName);
        Category saved = categoryRepository.save(category);
        return toResponse(saved);
    }

    @Transactional
    public void delete(String id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy danh mục: " + id));

        int bookCount = category.getBooks() != null ? category.getBooks().size() : 0;

        if (bookCount > 0) {
            throw new IllegalArgumentException("Không thể xóa danh mục vì vẫn còn sách trong danh mục này");
        }

        categoryRepository.delete(category);
    }

    private CategoryResponse toResponse(Category category) {
        int bookCount = category.getBooks() != null ? category.getBooks().size() : 0;
        return new CategoryResponse(
                category.getCategoryId(),
                category.getCategoryName(),
                bookCount
        );
    }

    private String generateNextCategoryId() {
        String maxId = categoryRepository.findMaxCategoryId();

        if (maxId == null || maxId.isBlank()) {
            return "CAT01";
        }

        String numberPart = maxId.replaceAll("[^0-9]", "");
        int nextNumber = numberPart.isBlank() ? 1 : Integer.parseInt(numberPart) + 1;

        return String.format("CAT%02d", nextNumber);
    }
}