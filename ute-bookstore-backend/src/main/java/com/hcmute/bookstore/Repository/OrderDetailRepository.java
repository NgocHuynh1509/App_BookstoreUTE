package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.OrderDetail;
import com.hcmute.bookstore.Entity.OrderdetailId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface OrderDetailRepository extends JpaRepository<OrderDetail, OrderdetailId> {
    List<OrderDetail> findByOrder_OrderId(String orderId);

}