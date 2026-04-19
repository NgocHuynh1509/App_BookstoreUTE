package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Notification;
import com.hcmute.bookstore.Entity.Users;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    Page<Notification> findByUserOrderByCreatedAtDesc(Users user, Pageable pageable);
    long countByUserAndIsReadFalse(Users user);
    Optional<Notification> findByIdAndUser(Long id, Users user);
    List<Notification> findByUserAndIsReadFalse(Users user);
}