package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;



@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {
    Payment findByOrder_OrderId(String orderId);




}