package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Orders;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {
    List<Orders> findByCustomer_CustomerIdOrderByOrderDateDesc(String customerId);

    Optional<Orders> findByOrderIdAndCustomer_CustomerId(String orderId, String customerId);
}