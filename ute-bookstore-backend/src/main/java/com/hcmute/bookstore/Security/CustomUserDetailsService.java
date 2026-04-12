package com.hcmute.bookstore.Security;

import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UsersRepository appUserRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Users user = appUserRepository.findByUserName(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return new User(
                user.getUserName(),
                user.getPassword(),
                user.getEnabled() != null && user.getEnabled(),
                true,
                true,
                true,
                // Bỏ đoạn "ROLE_" + đi, chỉ để user.getRole()
                List.of(new SimpleGrantedAuthority(user.getRole()))
        );
    }
}