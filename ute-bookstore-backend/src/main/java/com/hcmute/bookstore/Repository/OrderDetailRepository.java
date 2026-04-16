package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.OrderDetail;
import com.hcmute.bookstore.Entity.OrderdetailId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface OrderDetailRepository extends JpaRepository<OrderDetail, OrderdetailId> {
    List<OrderDetail> findByOrder_OrderId(String orderId);

    boolean existsByOrder_OrderIdAndBook_BookId(String orderId, String bookId);

    @org.springframework.data.jpa.repository.Query(
            "select coalesce(sum(od.quantity), 0) " +
            "from OrderDetail od where od.order.orderDate >= ?1 and od.order.orderDate < ?2"
    )
    Long sumQuantityBetween(java.util.Date from, java.util.Date to);

    @org.springframework.data.jpa.repository.Query(
            "select function('date', o.orderDate), coalesce(sum(od.quantity), 0) " +
            "from OrderDetail od join od.order o " +
            "where o.orderDate >= ?1 and o.orderDate < ?2 " +
            "group by function('date', o.orderDate) order by function('date', o.orderDate)"
    )
    java.util.List<Object[]> sumBookSoldByDay(java.util.Date from, java.util.Date to);

    @org.springframework.data.jpa.repository.Query(
            "select function('date_format', o.orderDate, '%Y-%m'), coalesce(sum(od.quantity), 0) " +
            "from OrderDetail od join od.order o " +
            "where o.orderDate >= ?1 and o.orderDate < ?2 " +
            "group by function('date_format', o.orderDate, '%Y-%m') order by function('date_format', o.orderDate, '%Y-%m')"
    )
    java.util.List<Object[]> sumBookSoldByMonth(java.util.Date from, java.util.Date to);
}