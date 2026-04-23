package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.ShippingAddress;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface ShippingAddressRepository extends JpaRepository<ShippingAddress, String> {
    // Tìm danh sách địa chỉ theo ID khách hàng
    List<ShippingAddress> findByCustomer_CustomerId(String customerId);

    // Tìm địa chỉ mặc định của một khách hàng
    @Query("SELECT s FROM ShippingAddress s WHERE s.customer.customerId = :customerId AND s.isDefault = true")
    Optional<ShippingAddress> findDefaultAddressByCustomerId(String customerId);

    // Trong ShippingAddressRepository
    List<ShippingAddress> findByCustomerCustomerIdOrderByCreatedAtAsc(String customerId);


}