package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.ProfileService;
import com.hcmute.bookstore.dto.ProfileResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/profile")
    public ProfileResponse getProfile(Authentication authentication) {
        String email = authentication.getName();
        return profileService.getProfileByEmail(email);
    }
}