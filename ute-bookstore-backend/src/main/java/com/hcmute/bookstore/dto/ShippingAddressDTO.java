package com.hcmute.bookstore.dto;

import lombok.Data;

@Data // Nếu bạn dùng Lombok, không thì tạo Getter/Setter thủ công
public class ShippingAddressDTO {
    private String id;
    private String recipientName;
    private String phoneNumber;
    private String province;
    private String district;
    private String ward;
    private String specificAddress;
    private Boolean isDefault;

    // Constructor để chuyển từ Entity sang DTO nhanh
    public ShippingAddressDTO(com.hcmute.bookstore.Entity.ShippingAddress entity) {
        if (entity != null) {
            this.id = entity.getId();
            this.recipientName = entity.getRecipientName();
            this.phoneNumber = entity.getPhoneNumber();
            this.province = entity.getProvince();
            this.district = entity.getDistrict();
            this.ward = entity.getWard();
            this.specificAddress = entity.getSpecificAddress();
            this.isDefault = entity.getIsDefault();
        }
    }
}