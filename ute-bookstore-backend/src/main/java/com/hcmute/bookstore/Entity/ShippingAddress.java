package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;

@Entity
@Table(name = "shipping_addresses")
public class ShippingAddress {

    @Id
    @Column(name = "id", length = 50) // Đổi sang String
    private String id;

    @Column(name = "recipient_name", nullable = false, length = 120)
    @NotBlank
    @Size(max = 120)
    private String recipientName;

    @Column(name = "phone_number", nullable = false, length = 20)
    @NotBlank
    @Size(max = 20)
    private String phoneNumber;

    @Column(name = "province", nullable = false, length = 100)
    @NotBlank
    private String province;

    @Column(name = "district", nullable = false, length = 100)
    @NotBlank
    private String district;

    @Column(name = "ward", length = 100)
    private String ward;

    @Column(name = "specific_address", nullable = false, length = 255)
    @NotBlank
    private String specificAddress;

    @Column(name = "is_default")
    private Boolean isDefault = false;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    // Thiết lập mối quan hệ với Customer
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customerId", referencedColumnName = "customerId", nullable = false)
    private Customers customer;

    // Tự động gán thời gian khi tạo mới
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public ShippingAddress() {}

    // Getter và Setter cho ID kiểu String
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getSpecificAddress() { return specificAddress; }
    public void setSpecificAddress(String specificAddress) { this.specificAddress = specificAddress; }

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Customers getCustomer() { return customer; }
    public void setCustomer(Customers customer) { this.customer = customer; }
}