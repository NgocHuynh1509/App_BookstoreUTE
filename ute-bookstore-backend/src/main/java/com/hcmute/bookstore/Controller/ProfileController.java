package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.ProfileService;
import com.hcmute.bookstore.dto.ProfileResponse;
import com.hcmute.bookstore.dto.SendOtpChangeEmailRequest;
import com.hcmute.bookstore.dto.UpdateProfileInfoRequest;
import com.hcmute.bookstore.dto.VerifyOtpChangeEmailRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/profile")
    public ProfileResponse getProfile(Authentication authentication) {
        String email = authentication.getName();
        return profileService.getProfileByEmail(email);
    }

    @PutMapping("/profile/info")
    public Map<String, String> updateProfileInfo(
            @RequestBody UpdateProfileInfoRequest request,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return Map.of("message", profileService.updateProfileInfo(email, request));
    }

    @PutMapping(value = "/profile/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Map<String, String> updateAvatar(
            @RequestPart("avatar") MultipartFile avatar,
            Authentication authentication
    ) throws IOException {
        String email = authentication.getName();
        String filename = profileService.updateAvatar(email, avatar);
        return Map.of("avatar", filename, "message", "Đổi avatar thành công");
    }

    @PostMapping("/profile/send-otp")
    public Map<String, String> sendOtpChangeEmail(
            @RequestBody SendOtpChangeEmailRequest request,
            Authentication authentication
    ) {
        String currentEmail = authentication.getName();
        String otp = profileService.sendOtpToNewEmail(currentEmail, request.getNew_email());
        return Map.of("message", "Đã gửi OTP", "otp", otp);
    }

    @PostMapping("/profile/verify-otp")
    public Map<String, String> verifyOtpChangeEmail(
            @RequestBody VerifyOtpChangeEmailRequest request,
            Authentication authentication
    ) {
        String currentEmail = authentication.getName();
        return profileService.verifyAndChangeEmail(
                currentEmail,
                request.getOtp_client(),
                request.getOtp_server(),
                request.getNew_email()
        );
    }
}