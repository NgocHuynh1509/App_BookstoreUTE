package com.hcmute.bookstore.dto;

public class UpdateProfileInfoRequest {
    private String full_name;
    private String address;
    private String phone;

    public String getFull_name() { return full_name; }
    public void setFull_name(String full_name) { this.full_name = full_name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}