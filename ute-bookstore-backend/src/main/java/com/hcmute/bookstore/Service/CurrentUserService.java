package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.UsersRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CurrentUserService {

    private final UsersRepository usersRepository;

    public Users getCurrentUser(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("Chưa đăng nhập");
        }

        String principal = authentication.getName();

        return usersRepository.findByCustomer_Email(principal)
                .orElseGet(() -> usersRepository.findByUserName(principal)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy user hiện tại")));
    }
}