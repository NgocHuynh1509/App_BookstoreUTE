package com.hcmute.bookstore.dto;

public class VerifyOtpChangeEmailRequest {
    private String otp_client;
    private String otp_server;
    private String new_email;

    public String getOtp_client() { return otp_client; }
    public void setOtp_client(String otp_client) { this.otp_client = otp_client; }

    public String getOtp_server() { return otp_server; }
    public void setOtp_server(String otp_server) { this.otp_server = otp_server; }

    public String getNew_email() { return new_email; }
    public void setNew_email(String new_email) { this.new_email = new_email; }
}