package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Users;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UsersRepository extends JpaRepository<Users, String> {
    Optional<Users> findByUserName(String userName);
    Optional<Users> findByCustomer_Email(String email);
    boolean existsByUserName(String userName);
    // Tìm User thông qua customerId của Customer entity liên kết
    Optional<Users> findByCustomer_CustomerId(String customerId);

    List<Users> findAllByOrderByCreatedAtDesc(Pageable pageable);
    List<Users> findAllByOrderByRegistrationDateDesc(Pageable pageable);
}
