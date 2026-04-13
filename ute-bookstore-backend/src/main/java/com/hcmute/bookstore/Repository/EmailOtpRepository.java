package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.EmailOtp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

public interface EmailOtpRepository extends JpaRepository<EmailOtp, Long> {
    Optional<EmailOtp> findTopByEmailAndOtpTypeOrderByCreatedAtDesc(String email, String otpType);

    @Transactional
    void deleteByExpiredAtBefore(LocalDateTime time);
}