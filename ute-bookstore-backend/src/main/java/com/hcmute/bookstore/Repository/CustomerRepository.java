package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Customers;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customers, String> {
    Optional<Customers> findByEmail(String email);
    boolean existsByEmail(String email);
}