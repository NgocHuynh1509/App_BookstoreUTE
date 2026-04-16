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

	Page<Orders> findByStatusIgnoreCase(String status, Pageable pageable);

	java.util.List<Orders> findByCustomer_CustomerIdOrderByOrderDateDesc(String customerId);

	java.util.Optional<Orders> findByOrderIdAndCustomer_CustomerId(String orderId, String customerId);

	long countByStatusIgnoreCase(String status);

	@Query("select coalesce(sum(o.totalAmount), 0) from Orders o where o.orderDate >= ?1 and o.orderDate < ?2")
	java.math.BigDecimal sumTotalAmountBetween(Date from, Date to);

	@Query("select function('date', o.orderDate), coalesce(sum(o.totalAmount), 0) " +
			"from Orders o where o.orderDate >= ?1 and o.orderDate < ?2 " +
			"group by function('date', o.orderDate) order by function('date', o.orderDate)")
	java.util.List<Object[]> sumRevenueByDay(Date from, Date to);

	@Query("select function('date_format', o.orderDate, '%Y-%m'), coalesce(sum(o.totalAmount), 0) " +
			"from Orders o where o.orderDate >= ?1 and o.orderDate < ?2 " +
			"group by function('date_format', o.orderDate, '%Y-%m') order by function('date_format', o.orderDate, '%Y-%m')")
	java.util.List<Object[]> sumRevenueByMonth(Date from, Date to);

	@Query("select function('date', o.orderDate), count(o) " +
			"from Orders o where o.orderDate >= ?1 and o.orderDate < ?2 " +
			"group by function('date', o.orderDate) order by function('date', o.orderDate)")
	java.util.List<Object[]> countOrdersByDay(Date from, Date to);

	@Query("select function('date_format', o.orderDate, '%Y-%m'), count(o) " +
			"from Orders o where o.orderDate >= ?1 and o.orderDate < ?2 " +
			"group by function('date_format', o.orderDate, '%Y-%m') order by function('date_format', o.orderDate, '%Y-%m')")
	java.util.List<Object[]> countOrdersByMonth(Date from, Date to);

	@Query("select o.status, count(o) from Orders o group by o.status")
	java.util.List<Object[]> countByStatusGroup();

	@Query("select min(o.orderDate) from Orders o")
	Date findMinOrderDate();

}