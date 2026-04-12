package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.AuthService;
import com.hcmute.bookstore.dto.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public Map<String, String> register(@Valid @RequestBody RegisterRequest request) {
        return Map.of("message", authService.register(request));
    }

    @PostMapping("/verify-register-otp")
    public Map<String, String> verifyRegisterOtp(@Valid @RequestBody OtpVerifyRequest request) {
        return Map.of("message", authService.verifyRegisterOtp(request));
    }

    @PostMapping("/resend-otp")
    public Map<String, String> resendOtp(@RequestParam String email,
                                         @RequestParam String otpType) {
        return Map.of("message", authService.resendOtp(email, otpType));
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/forgot-password")
    public Map<String, String> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        return Map.of("message", authService.sendForgotPasswordOtp(request));
    }

    @PostMapping("/reset-password")
    public Map<String, String> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        return Map.of("message", authService.resetPassword(request));
    }
}