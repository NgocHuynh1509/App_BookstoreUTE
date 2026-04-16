package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.stereotype.Repository;


@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, String> {

	long countByStatusNot(String status);


}