package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.UserFcmToken;
import com.hcmute.bookstore.Entity.Users;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserFcmTokenRepository extends JpaRepository<UserFcmToken, Long> {
    List<UserFcmToken> findByUser(Users user);

    boolean existsByToken(String token);
}