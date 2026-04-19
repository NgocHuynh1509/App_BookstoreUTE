package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.ChatMessage;
import com.hcmute.bookstore.Entity.MessageStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, String> {

	long countByStatusNot(String status);

    @Query("SELECT COUNT(c) > 0 FROM ChatMessage c WHERE c.receiverName = 'admin' AND (c.status <> com.hcmute.bookstore.Entity.MessageStatus.SEEN OR c.isMarkedUnreadByAdmin = true)")
    boolean existsUnreadForAdmin();

    @Query("SELECT COUNT(c) > 0 FROM ChatMessage c WHERE LOWER(c.receiverName) = LOWER(:userName) AND (c.status <> com.hcmute.bookstore.Entity.MessageStatus.SEEN OR c.isMarkedUnreadByUser = true)")
    boolean existsUnreadForUser(@Param("userName") String userName);

    @Query("SELECT c FROM ChatMessage c LEFT JOIN FETCH c.replyTo WHERE " +
            "(c.userName = :userName AND c.receiverName = 'admin') OR " + // Khách gửi cho admin
            "(c.userName = 'admin' AND c.receiverName = :userName)")    // Admin phản hồi khách
    Page<ChatMessage> findChatHistoryForUser(@Param("userName") String userName, Pageable pageable);

    @Query("""
    SELECT c FROM ChatMessage c
    LEFT JOIN FETCH c.replyTo
    LEFT JOIN FETCH c.attachedBook
    LEFT JOIN FETCH c.attachedOrder
    WHERE
    (c.userName = :userName AND c.receiverName = 'admin')
    OR
    (c.userName = 'admin' AND c.receiverName = :userName)
    ORDER BY c.createdAt DESC
    """)
    List<ChatMessage> findByUserNameOrderByCreatedAtAsc(@Param("userName") String userName);

    @Query("SELECT c FROM ChatMessage c WHERE c.createdAt IN " +
            "(SELECT MAX(m.createdAt) FROM ChatMessage m " + 
            " WHERE m.userName != 'admin' " + 
            " GROUP BY m.userName) " +
            "AND c.userName != 'admin' " +      
            "ORDER BY c.createdAt DESC")
    List<ChatMessage> findAllChatThreads();

    // Đếm số tin nhắn chưa đọc từ một user cụ thể gửi cho admin
    long countByUserNameAndReceiverNameAndStatusNot(String userName, String receiverName, MessageStatus status);

    // Đánh dấu tất cả tin nhắn từ user gửi cho admin là SEEN
    @Transactional
    @Modifying
    @Query("UPDATE ChatMessage c SET c.status = 'SEEN', c.isMarkedUnreadByAdmin = false WHERE c.userName = :userName AND c.receiverName = 'admin' AND (c.status != 'SEEN' OR c.isMarkedUnreadByAdmin = true)")
    void markAllAsSeenByAdmin(@Param("userName") String userName);

    // Đánh dấu tất cả tin nhắn từ admin gửi cho user là SEEN
    @Transactional
    @Modifying
    @Query("UPDATE ChatMessage c SET c.status = 'SEEN', c.isMarkedUnreadByUser = false WHERE c.userName = 'admin' AND c.receiverName = :userName AND (c.status != 'SEEN' OR c.isMarkedUnreadByUser = true)")
    void markAllAsSeenByUser(@Param("userName") String userName);

    // Tìm tin nhắn mới nhất để đánh dấu chưa đọc thủ công
    ChatMessage findFirstByUserNameAndReceiverNameOrderByCreatedAtDesc(String userName, String receiverName);
}