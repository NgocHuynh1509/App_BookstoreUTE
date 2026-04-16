package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Orders;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.Optional;


@Repository
public interface OrdersRepository extends JpaRepository<Orders, String> {
    List<Orders> findByCustomer_CustomerIdOrderByOrderDateDesc(String customerId);

	Page<Orders> findByStatusIgnoreCase(String status, Pageable pageable);

	long countByStatusIgnoreCase(String status);

	@Query("select coalesce(sum(o.totalAmount), 0) from Orders o where o.orderDate >= ?1 and o.orderDate < ?2")
	java.math.BigDecimal sumTotalAmountBetween(Date from, Date to);

	Optional<Orders> findByOrderIdAndCustomer_CustomerId(String orderId, String customerId);
}