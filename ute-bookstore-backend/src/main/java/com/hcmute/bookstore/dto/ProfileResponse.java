package com.hcmute.bookstore.dto;

public class ProfileResponse {
    private String userName;
    private String fullName;
    private String email;
    private String role;

    public ProfileResponse() {
    }

    public ProfileResponse(String userName, String fullName, String email, String role) {
        this.userName = userName;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}