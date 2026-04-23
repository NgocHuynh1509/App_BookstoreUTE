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
        // 1. Tìm địa chỉ mặc định trước
        return addressRepository.findDefaultAddressByCustomerId(customerId)
                .orElseGet(() -> {
                    // 2. Nếu không có mặc định, lấy danh sách tất cả địa chỉ
                    List<ShippingAddress> addresses = addressRepository.findByCustomerCustomerIdOrderByCreatedAtAsc(customerId);
                    // Trả về địa chỉ đầu tiên nếu danh sách không trống, ngược lại trả về null
                    return addresses.isEmpty() ? null : addresses.get(0);
                });
    }

    // Lấy tất cả địa chỉ của user
    public List<ShippingAddress> getAllAddressesByUser(String customerId) {
        return addressRepository.findByCustomer_CustomerId(customerId);
    }
}