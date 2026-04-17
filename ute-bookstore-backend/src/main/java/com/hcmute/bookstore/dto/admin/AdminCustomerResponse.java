package com.hcmute.bookstore.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AdminCustomerResponse {
    private String customerId;
    private String userName;
    private String fullName;
    private String dateOfBirth;
    private String phone;
    private String email;
    private String address;
    private String registrationDate;
    private Integer rewardPoints;
    private Boolean enabled;
    private Integer totalOrders;
}