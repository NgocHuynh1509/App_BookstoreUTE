package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Orders;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {
    List<Orders> findByCustomer_CustomerIdOrderByOrderDateDesc(String customerId);
}