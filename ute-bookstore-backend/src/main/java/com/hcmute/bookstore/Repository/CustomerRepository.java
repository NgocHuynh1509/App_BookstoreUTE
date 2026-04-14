package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Customers;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customers, String> {
    Optional<Customers> findByEmail(String email);
    boolean existsByEmail(String email);
    // Tìm Customer dựa trên ID của bảng User liên kết

}