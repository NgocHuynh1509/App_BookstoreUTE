package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDate;
import java.util.Date;

@Entity
@Builder
@AllArgsConstructor
@Table(name = "Users")
public class Users {

    @Id
    @Column(name = "userName", length = 100)
    private String userName;

    @NotBlank
    @Column(name = "password", length = 255, nullable = false)
    private String password;

    @NotBlank
    @Column(name = "role", length = 20, nullable = false)
    private String role;

    @NotBlank
    @Column(name = "fullName", length = 50, nullable = false)
    private String fullName;

    @Temporal(TemporalType.DATE)
    @Column(name = "registrationDate")
    private LocalDate registrationDate;

    @Column(name = "avatar", length = 255)
    private String avatar;

    @Column(name = "reward_points")
    private Integer rewardPoints = 0;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", insertable = false, updatable = false)
    private Date createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Date updatedAt;

    @Column(name = "enabled")
    private Boolean enabled;

    @Column(name = "email_verified")
    private Boolean emailVerified;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "customerId",
            referencedColumnName = "customerId",
            foreignKey = @ForeignKey(name = "FK_User_Customer")
    )
    private Customers customer;

    public Users() {
    }

    public Users(String userName, String password, String role, String fullName, LocalDate registrationDate) {
        this.userName = userName;
        this.password = password;
        this.role = role;
        this.fullName = fullName;
        this.registrationDate = registrationDate;
    }

    public Users(String userName, String password, String role, String fullName,
                 LocalDate registrationDate, String avatar, Integer rewardPoints, Customers customer) {
        this.userName = userName;
        this.password = password;
        this.role = role;
        this.fullName = fullName;
        this.registrationDate = registrationDate;
        this.avatar = avatar;
        this.rewardPoints = rewardPoints;
        this.customer = customer;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public LocalDate getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(LocalDate registrationDate) {
        this.registrationDate = registrationDate;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public Integer getRewardPoints() {
        return rewardPoints;
    }

    public void setRewardPoints(Integer rewardPoints) {
        this.rewardPoints = rewardPoints;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public Customers getCustomer() {
        return customer;
    }

    public void setCustomer(Customers customer) {
        this.customer = customer;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }
    public Boolean getEnabled() {
        return enabled;
    }
    public void setEmailVerified(Boolean emailVerified) {
        this.emailVerified = emailVerified;

    }
    public Boolean getEmailVerified() {
        return emailVerified;
    }


}