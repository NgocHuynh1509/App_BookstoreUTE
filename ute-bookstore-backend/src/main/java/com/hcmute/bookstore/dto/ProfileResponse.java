package com.hcmute.bookstore.dto;

public class ProfileResponse {
    private String id;
    private String username;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private String avatar;
    private Integer reward_points;
    private String role;

    public ProfileResponse(
            String id,
            String username,
            String fullName,
            String email,
            String phone,
            String address,
            String avatar,
            Integer reward_points,
            String role
    ) {
        this.id = id;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.avatar = avatar;
        this.reward_points = reward_points;
        this.role = role;
    }

    public String getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }

    public String getAvatar() {
        return avatar;
    }

    public Integer getReward_points() {
        return reward_points;
    }

    public String getRole() {
        return role;
    }
}