package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.ReturnRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;


@Repository
public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, String> {

    boolean existsByOrder_OrderId(String orderId);
    // Tìm yêu cầu hoàn trả theo mã đơn hàng
    Optional<ReturnRequest> findByOrder_OrderId(String orderId);


}