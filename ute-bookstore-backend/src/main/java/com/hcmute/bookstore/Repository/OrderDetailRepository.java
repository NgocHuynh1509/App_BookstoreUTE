package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.OrderDetail;
import com.hcmute.bookstore.Entity.OrderdetailId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface OrderDetailRepository extends JpaRepository<OrderDetail, OrderdetailId> {

}