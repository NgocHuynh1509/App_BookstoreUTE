package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;


@Repository
public interface CategoryRepository extends JpaRepository<Category, String> {
    boolean existsByCategoryNameIgnoreCase(String categoryName);

    boolean existsByCategoryNameIgnoreCaseAndCategoryIdNot(String categoryName, String categoryId);

    @Query("SELECT MAX(c.categoryId) FROM Category c")
    String findMaxCategoryId();

    Optional<Category> findByCategoryId(String categoryId);
}