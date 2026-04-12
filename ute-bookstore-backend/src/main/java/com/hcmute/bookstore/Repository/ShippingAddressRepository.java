package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.ShippingAddress;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.stereotype.Repository;


@Repository
public interface ShippingAddressRepository extends JpaRepository<ShippingAddress, String> {


}