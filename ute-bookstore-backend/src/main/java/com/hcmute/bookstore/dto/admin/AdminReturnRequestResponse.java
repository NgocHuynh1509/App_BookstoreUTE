package com.hcmute.bookstore.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data // Tự động tạo Getter, Setter, toString, equals, và hashCode
@NoArgsConstructor // Tạo constructor không đối số
@AllArgsConstructor // Tạo constructor đầy đủ đối số
@Builder // Hỗ trợ tạo object theo pattern Builder (rất tiện khi viết code logic)
public class AdminReturnRequestResponse {

    private String reason;
    private String reply;
    private String status;
    private List<String> images;
    private String bankName;
    private String accountHolder;
    private String accountNumber;

}
