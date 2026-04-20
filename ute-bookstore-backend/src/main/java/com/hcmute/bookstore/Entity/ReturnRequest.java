package com.hcmute.bookstore.Entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.util.Date;

@Entity
@Table(name = "return_requests")
public class ReturnRequest {

    @Id
    @Column(name = "returnId", length = 50)
    private String returnId;

    // Liên kết với đơn hàng cần hoàn tiền
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "orderId", referencedColumnName = "orderId", unique = true)
    private Orders order;

    @Column(name = "reason", length = 1000)
    @NotNull
    private String reason; // Lý do hủy/hoàn hàng

    @Column(name = "image_evidence", length = 255)
    private String imageEvidence; // Lưu đường dẫn hoặc URL của ảnh đính kèm

    // --- THÔNG TIN NGÂN HÀNG ĐỂ HOÀN TIỀN ---
    @Column(name = "bank_name", length = 100)
    private String bankName; // Tên ngân hàng (Vcb, Mb, ...)

    @Column(name = "account_holder", length = 100)
    private String accountHolder; // Tên chủ tài khoản

    @Column(name = "account_number", length = 50)
    private String accountNumber; // Số tài khoản

    // --- TRẠNG THÁI XỬ LÝ ---
    @Column(name = "status", length = 50)
    private String status; // PENDING (Chờ), APPROVED (Đã duyệt), REFUNDED (Đã trả tiền), REJECTED (Từ chối)

    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt = new Date();

    public ReturnRequest() {}

    // Getter và Setter
    public String getReturnId() { return returnId; }
    public void setReturnId(String returnId) { this.returnId = returnId; }

    public Orders getOrder() { return order; }
    public void setOrder(Orders order) { this.order = order; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getImageEvidence() { return imageEvidence; }
    public void setImageEvidence(String imageEvidence) { this.imageEvidence = imageEvidence; }

    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }

    public String getAccountHolder() { return accountHolder; }
    public void setAccountHolder(String accountHolder) { this.accountHolder = accountHolder; }

    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
