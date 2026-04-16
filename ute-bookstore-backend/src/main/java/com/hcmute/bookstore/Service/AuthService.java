package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Customers;
import com.hcmute.bookstore.Entity.EmailOtp;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.CustomerRepository;
import com.hcmute.bookstore.Repository.EmailOtpRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.Security.JwtService;
import com.hcmute.bookstore.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsersRepository appUserRepository;
    private final CustomerRepository customerRepository;
    private final EmailOtpRepository emailOtpRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    @Transactional
    public String register(RegisterRequest request) {
        if (appUserRepository.existsByUserName(request.getUserName())) {
            throw new RuntimeException("Username đã tồn tại");
        }

        if (customerRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã tồn tại");
        }

        String customerId = generateCustomerId();

        Customers customer = Customers.builder()
                .customerId(customerId)
                .fullName(request.getFullName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .address(request.getAddress())
                .dateOfBirth(
                        request.getDateOfBirth() != null && !request.getDateOfBirth().isBlank()
                                ? LocalDate.parse(request.getDateOfBirth())
                                : null
                )
                .build();

        customerRepository.save(customer);

        Users user = Users.builder()
                .userName(request.getUserName())
                .password(passwordEncoder.encode(request.getPassword()))
                .role("ROLE_CUSTOMER")
                .fullName(request.getFullName())
                .registrationDate(LocalDate.now())
                .customer(customer)
                .rewardPoints(0)
                .enabled(false)
                .emailVerified(false)
                .build();

        appUserRepository.save(user);

        createAndSendOtp(request.getEmail(), "REGISTER");
        return "Đăng ký thành công. OTP đã được gửi về email.";
    }

    @Transactional
    public String verifyRegisterOtp(OtpVerifyRequest request) {
        EmailOtp emailOtp = emailOtpRepository
                .findTopByEmailAndOtpTypeOrderByCreatedAtDesc(request.getEmail(), "REGISTER")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy OTP đăng ký"));

        validateOtp(emailOtp, request.getOtp());

        emailOtp.setVerified(true);
        emailOtpRepository.save(emailOtp);

        Users user = appUserRepository.findByCustomer_Email(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        user.setEnabled(true);
        user.setEmailVerified(true);
        appUserRepository.save(user);

        return "Xác thực email thành công";
    }

    @Transactional
    public String resendOtp(String email, String otpType) {
        if (!"REGISTER".equalsIgnoreCase(otpType) && !"FORGOT_PASSWORD".equalsIgnoreCase(otpType)) {
            throw new RuntimeException("otpType không hợp lệ");
        }

        Users user = appUserRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Email chưa đăng ký"));

        if ("REGISTER".equalsIgnoreCase(otpType) && Boolean.TRUE.equals(user.getEnabled())) {
            throw new RuntimeException("Tài khoản đã kích hoạt");
        }

        if ("FORGOT_PASSWORD".equalsIgnoreCase(otpType) && !Boolean.TRUE.equals(user.getEnabled())) {
            throw new RuntimeException("Tài khoản chưa kích hoạt");
        }

        createAndSendOtp(email, otpType.toUpperCase());
        return "Gửi lại OTP thành công";
    }

    @Transactional
    public String sendForgotPasswordOtp(ForgotPasswordRequest request) {
        Users user = appUserRepository.findByCustomer_Email(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Email chưa đăng ký"));

        if (!Boolean.TRUE.equals(user.getEnabled())) {
            throw new RuntimeException("Tài khoản chưa kích hoạt");
        }

        createAndSendOtp(request.getEmail(), "FORGOT_PASSWORD");
        return "OTP quên mật khẩu đã được gửi về email.";
    }

    @Transactional
    public String resetPassword(ResetPasswordRequest request) {
        if (request.getNewPassword() == null || request.getNewPassword().length() < 6) {
            throw new RuntimeException("Mật khẩu mới phải có ít nhất 6 ký tự");
        }

        EmailOtp emailOtp = emailOtpRepository
                .findTopByEmailAndOtpTypeOrderByCreatedAtDesc(request.getEmail(), "FORGOT_PASSWORD")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy OTP quên mật khẩu"));

        validateOtp(emailOtp, request.getOtp());

        Users user = appUserRepository.findByCustomer_Email(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        appUserRepository.save(user);

        emailOtp.setVerified(true);
        emailOtpRepository.save(emailOtp);

        return "Đổi mật khẩu thành công";
    }

    public AuthResponse login(LoginRequest request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (DisabledException e) {
            throw new RuntimeException("Tài khoản chưa xác thực email");
        } catch (BadCredentialsException e) {
            throw new RuntimeException("Sai email hoặc mật khẩu");
        }

        Users user = appUserRepository.findByCustomer_Email(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Email không tồn tại"));

        UserDetails userDetails = org.springframework.security.core.userdetails.User
                .withUsername(user.getCustomer().getEmail())   // subject = email
                .password(user.getPassword())
                .authorities(user.getRole())
                .build();

        String token = jwtService.generateToken(userDetails, user.getRole());

        return new AuthResponse(
                token,
                user.getCustomer().getCustomerId(),
                user.getUserName(),   // vẫn trả username nếu m muốn app dùng
                user.getRole(),
                "Login thành công"
        );
    }

    public AuthResponse me(String email) {
        Users user = appUserRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Email không tồn tại"));

        return new AuthResponse(
                "",
                user.getCustomer().getCustomerId(),
                user.getUserName(),
                user.getRole(),
                "OK"
        );
    }

    private void validateOtp(EmailOtp emailOtp, String otp) {
        if (Boolean.TRUE.equals(emailOtp.getVerified())) {
            throw new RuntimeException("OTP đã được sử dụng");
        }

        if (emailOtp.getExpiredAt().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("OTP đã hết hạn");
        }

        if (!emailOtp.getOtpCode().equals(otp)) {
            throw new RuntimeException("OTP không đúng");
        }
    }

    private void createAndSendOtp(String email, String otpType) {
        emailOtpRepository.deleteByExpiredAtBefore(LocalDateTime.now());

        String otp = generateOtp();

        EmailOtp emailOtp = EmailOtp.builder()
                .email(email)
                .otpCode(otp)
                .otpType(otpType)
                .expiredAt(LocalDateTime.now().plusMinutes(5))
                .verified(false)
                .build();

        emailOtpRepository.save(emailOtp);
        emailService.sendOtpEmail(email, otp, otpType);
    }

    private String generateOtp() {
        int otp = 100000 + new Random().nextInt(900000);
        return String.valueOf(otp);
    }

    private String generateCustomerId() {
        long count = customerRepository.count() + 1;
        return String.format("CU%02d", count);
    }
}

