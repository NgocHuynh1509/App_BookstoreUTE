package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.dto.admin.ChatMessageDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, String> {

	long countByStatusNot(String status);

    // Thêm dòng này để Spring JPA tự động tạo câu query:
    @Query("SELECT c FROM ChatMessage c WHERE " +
            "(c.userName = :userName AND c.receiverName = 'admin') OR " + // Khách gửi cho admin
            "(c.userName = 'admin' AND c.receiverName = :userName)")    // Admin phản hồi khách
    Page<ChatMessage> findChatHistoryForUser(@Param("userName") String userName, Pageable pageable);

//    @Query("SELECT c FROM ChatMessage c WHERE " +
//            "(c.userName = :userName AND c.receiverName = 'admin') OR " + // Khách gửi cho admin
//            "(c.userName = 'admin' AND c.receiverName = :userName) " +    // Admin gửi cho khách
//            "ORDER BY c.createdAt DESC") // Để DESC vì Flutter dùng reverse: true
//    List<ChatMessage> findByUserNameOrderByCreatedAtAsc(@Param("userName") String userName);
    // Tại ChatMessageRepository.java
    @Query("SELECT c FROM ChatMessage c WHERE " +
            "(c.userName = :userName AND c.receiverName = 'admin') OR " +
            "(c.userName = 'admin' AND c.receiverName = :userName) " +
            "ORDER BY c.createdAt DESC")
    List<ChatMessage> findByUserNameOrderByCreatedAtAsc(@Param("userName") String userName);

    @Query("SELECT c FROM ChatMessage c WHERE c.createdAt IN " +
            "(SELECT MAX(m.createdAt) FROM ChatMessage m " +
            " WHERE m.userName != 'admin' " + // Loại bỏ tin nhắn mà người gửi là admin
            " GROUP BY m.userName) " +
            "AND c.userName != 'admin' " +      // Đảm bảo kết quả cuối không chứa admin
            "ORDER BY c.createdAt DESC")
    List<ChatMessage> findAllChatThreads();

}