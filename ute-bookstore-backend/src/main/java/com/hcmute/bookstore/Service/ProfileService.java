package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.dto.ProfileResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UsersRepository usersRepository;

    public ProfileResponse getProfileByEmail(String email) {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        return new ProfileResponse(
                user.getCustomer() != null ? user.getCustomer().getCustomerId() : null,
                user.getUserName(),
                user.getFullName(),
                user.getCustomer() != null ? user.getCustomer().getEmail() : null,
                user.getCustomer() != null ? user.getCustomer().getPhone() : null,
                user.getCustomer() != null ? user.getCustomer().getAddress() : null,
                null, // nếu chưa có cột avatar thì để null
                user.getRewardPoints(),
                user.getRole()
        );
    }
}