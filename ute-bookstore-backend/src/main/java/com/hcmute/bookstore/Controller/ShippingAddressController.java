package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.ShippingAddress;
import com.hcmute.bookstore.Repository.ShippingAddressRepository;
import com.hcmute.bookstore.Service.ShippingAddressService;
import com.hcmute.bookstore.dto.ShippingAddressDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/addresses")
public class ShippingAddressController {

    @Autowired
    private ShippingAddressService addressService;

    @Autowired
    private ShippingAddressRepository addressRepository;

    // Sửa Endpoint 1: Trả về DTO thay vì Entity
    @GetMapping("/default/{userId}")
    public ResponseEntity<?> getDefaultAddress(@PathVariable String userId) {
        ShippingAddress address = addressService.getDefaultAddress(userId);
        if (address == null) return ResponseEntity.ok(null);

        return ResponseEntity.ok(new ShippingAddressDTO(address));
    }

    // Sửa Endpoint 2: Trả về List DTO
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ShippingAddressDTO>> getAllAddresses(@PathVariable String userId) {
        List<ShippingAddress> addresses = addressService.getAllAddressesByUser(userId);
        List<ShippingAddressDTO> dtos = addresses.stream()
                .map(ShippingAddressDTO::new)
                .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @PostMapping("/add")
    public ResponseEntity<?> addAddress(@RequestBody ShippingAddress address) {
        Map<String, Object> response = new HashMap<>();
        try {
            if (address.getCustomer() == null || address.getCustomer().getCustomerId() == null) {
                response.put("message", "Thiếu thông tin khách hàng");
                return ResponseEntity.badRequest().body(response);
            }

            String customerId = address.getCustomer().getCustomerId();

            // 1. Lấy danh sách địa chỉ hiện tại của user
            List<ShippingAddress> existingAddresses = addressService.getAllAddressesByUser(customerId);

            // 2. Logic xử lý isDefault:
            // Nếu là địa chỉ đầu tiên HOẶC địa chỉ mới này được set là mặc định
            if (existingAddresses.isEmpty()) {
                address.setIsDefault(true);
            } else if (address.getIsDefault() != null && address.getIsDefault()) {
                // Nếu địa chỉ mới gửi lên có isDefault = true,
                // ta duyệt qua danh sách cũ để bỏ tick mặc định
                for (ShippingAddress oldAddr : existingAddresses) {
                    if (oldAddr.getIsDefault()) {
                        oldAddr.setIsDefault(false);
                        addressRepository.save(oldAddr); // Lưu lại trạng thái không còn mặc định
                    }
                }
            }

            // 3. Thiết lập ID nếu chưa có
            if (address.getId() == null) {
                address.setId("ADDR" + System.currentTimeMillis());
            }

            // 4. Lưu địa chỉ mới
            ShippingAddress savedAddress = addressRepository.save(address);

            response.put("status", "success");
            response.put("data", new ShippingAddressDTO(savedAddress));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("message", "Lỗi Server: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}