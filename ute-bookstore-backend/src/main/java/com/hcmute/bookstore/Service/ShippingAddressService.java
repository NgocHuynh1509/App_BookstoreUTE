package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.ShippingAddress;
import com.hcmute.bookstore.Repository.ShippingAddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ShippingAddressService {

    @Autowired
    private ShippingAddressRepository addressRepository;

    // Lấy địa chỉ mặc định
    public ShippingAddress getDefaultAddress(String customerId) {
        return addressRepository.findDefaultAddressByCustomerId(customerId).orElse(null);
    }

    // Lấy tất cả địa chỉ của user
    public List<ShippingAddress> getAllAddressesByUser(String customerId) {
        return addressRepository.findByCustomer_CustomerId(customerId);
    }
}