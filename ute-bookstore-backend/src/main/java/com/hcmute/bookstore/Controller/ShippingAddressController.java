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

        if (address == null) {
            // Trả về 200 kèm body null hoặc 404 tùy theo logic Frontend của bạn
            return ResponseEntity.ok(null);
        }

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

    // Xóa địa chỉ
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAddress(@PathVariable String id) {
        try {
            ShippingAddress address = addressRepository.findById(id).orElse(null);
            if (address == null) {
                return ResponseEntity.notFound().build();
            }
            if (address.getIsDefault()) {
                return ResponseEntity.badRequest().body("Không thể xóa địa chỉ mặc định");
            }
            addressRepository.deleteById(id);
            return ResponseEntity.ok().body("Đã xóa địa chỉ thành công");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi: " + e.getMessage());
        }
    }

    // Lấy chi tiết 1 địa chỉ (Dùng khi bấm Chỉnh sửa)
    @GetMapping("/{id}")
    public ResponseEntity<?> getAddressById(@PathVariable String id) {
        return addressRepository.findById(id)
                .map(addr -> ResponseEntity.ok(new ShippingAddressDTO(addr)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAddress(@PathVariable String id, @RequestBody ShippingAddress addressUpdates) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 1. Tìm địa chỉ cũ trong Database
            ShippingAddress existingAddress = addressRepository.findById(id).orElse(null);
            if (existingAddress == null) {
                response.put("message", "Không tìm thấy địa chỉ cần cập nhật");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            // 2. Logic xử lý nếu người dùng muốn đặt địa chỉ này làm mặc định
            if (addressUpdates.getIsDefault() != null && addressUpdates.getIsDefault()) {
                String customerId = existingAddress.getCustomer().getCustomerId();
                List<ShippingAddress> userAddresses = addressService.getAllAddressesByUser(customerId);

                for (ShippingAddress addr : userAddresses) {
                    if (addr.getIsDefault() && !addr.getId().equals(id)) {
                        addr.setIsDefault(false);
                        addressRepository.save(addr); // Bỏ mặc định các địa chỉ khác
                    }
                }
                existingAddress.setIsDefault(true);
            } else {
                // Nếu địa chỉ đang là mặc định mà cố tình bỏ tick,
                // có thể giữ nguyên hoặc xử lý tùy logic (thường địa chỉ mặc định không cho bỏ tick trực tiếp)
                existingAddress.setIsDefault(addressUpdates.getIsDefault());
            }

            // 3. Cập nhật các thông tin khác
            existingAddress.setRecipientName(addressUpdates.getRecipientName());
            existingAddress.setPhoneNumber(addressUpdates.getPhoneNumber());
            existingAddress.setProvince(addressUpdates.getProvince());
            existingAddress.setDistrict(addressUpdates.getDistrict());
            existingAddress.setWard(addressUpdates.getWard());
            existingAddress.setSpecificAddress(addressUpdates.getSpecificAddress());

            // 4. Lưu lại
            ShippingAddress updated = addressRepository.save(existingAddress);

            response.put("status", "success");
            response.put("data", new ShippingAddressDTO(updated));
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("message", "Lỗi khi cập nhật: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}