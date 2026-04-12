package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Users;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsersRepository extends JpaRepository<Users, String> {
    Optional<Users> findByUserName(String userName);
    Optional<Users> findByCustomer_Email(String email);
    boolean existsByUserName(String userName);
}
