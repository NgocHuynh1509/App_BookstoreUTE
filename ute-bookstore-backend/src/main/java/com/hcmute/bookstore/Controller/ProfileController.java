package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Service.CurrentUserService;
import com.hcmute.bookstore.dto.ProfileResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ProfileController {

    private final CurrentUserService currentUserService;

    @GetMapping("/profile")
    public ProfileResponse getProfile(Authentication authentication) {
        Users user = currentUserService.getCurrentUser(authentication);

        return new ProfileResponse(
                user.getUserName(),
                user.getFullName(),
                user.getCustomer() != null ? user.getCustomer().getEmail() : null,
                user.getRole()
        );
    }
}