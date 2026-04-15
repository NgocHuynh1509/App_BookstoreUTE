package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Customers;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.CustomerRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.Security.JwtService;
import com.hcmute.bookstore.dto.ChangePasswordRequest;
import com.hcmute.bookstore.dto.ProfileResponse;
import com.hcmute.bookstore.dto.UpdateProfileInfoRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UsersRepository usersRepository;
    private final CustomerRepository customerRepository;
    private final EmailService emailService;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;


    public ProfileResponse getProfileByEmail(String email) {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        Customers customer = user.getCustomer();

        return new ProfileResponse(
                customer != null ? customer.getCustomerId() : null,
                user.getUserName(),
                user.getFullName(),
                customer != null ? customer.getEmail() : null,
                customer != null ? customer.getPhone() : null,
                customer != null ? customer.getAddress() : null,
                user.getAvatar(),
                user.getRewardPoints(),
                user.getRole()
        );
    }

    @Transactional
    public String updateProfileInfo(String email, UpdateProfileInfoRequest request) {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        Customers customer = user.getCustomer();
        if (customer == null) {
            throw new RuntimeException("Không tìm thấy thông tin khách hàng");
        }

        if (request.getFull_name() != null && !request.getFull_name().isBlank()) {
            user.setFullName(request.getFull_name());
            customer.setFullName(request.getFull_name());
        }

        customer.setPhone(request.getPhone());
        customer.setAddress(request.getAddress());

        usersRepository.save(user);
        customerRepository.save(customer);

        return "Cập nhật thông tin thành công";
    }

//    @Transactional
//    public String updateAvatar(String email, MultipartFile file) throws IOException {
//        Users user = usersRepository.findByCustomer_Email(email)
//                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));
//
//        if (file == null || file.isEmpty()) {
//            throw new RuntimeException("File ảnh không hợp lệ");
//        }
//
//        String uploadDir = "uploads/";
//        File dir = new File(uploadDir);
//        if (!dir.exists()) dir.mkdirs();
//
//        String originalFilename = file.getOriginalFilename();
//        String ext = "";
//
//        if (originalFilename != null && originalFilename.contains(".")) {
//            ext = originalFilename.substring(originalFilename.lastIndexOf("."));
//        }
//
//        String newFilename = UUID.randomUUID() + ext;
//        File dest = new File(uploadDir + newFilename);
//        file.transferTo(dest);
//
//        user.setAvatar(newFilename);
//        usersRepository.save(user);
//
//        return newFilename;
//    }

    @Transactional
    public String updateAvatar(String email, MultipartFile file) throws IOException {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        if (file == null || file.isEmpty()) {
            throw new RuntimeException("File ảnh không hợp lệ");
        }

        // Chọn 1 thư mục cố định trên máy
        String uploadDir = System.getProperty("user.dir") + File.separator + "uploads";
        File dir = new File(uploadDir);

        if (!dir.exists() && !dir.mkdirs()) {
            throw new RuntimeException("Không thể tạo thư mục uploads");
        }

        String originalFilename = file.getOriginalFilename();
        String ext = "";

        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String newFilename = UUID.randomUUID() + ext;
        File dest = new File(dir, newFilename);

        file.transferTo(dest);

        user.setAvatar(newFilename);
        usersRepository.save(user);

        return newFilename;
    }

    public String sendOtpToNewEmail(String currentEmail, String newEmail) {
        if (newEmail == null || newEmail.isBlank()) {
            throw new RuntimeException("Email mới không hợp lệ");
        }

        if (customerRepository.existsByEmail(newEmail)) {
            throw new RuntimeException("Email mới đã được sử dụng");
        }

        String otp = String.valueOf((int)(100000 + Math.random() * 900000));
        emailService.sendOtpEmail(newEmail, otp, "CHANGE_EMAIL");
        return otp;
    }

    @Transactional
    public Map<String, String> verifyAndChangeEmail(String currentEmail, String otpClient, String otpServer, String newEmail) {
        if (otpClient == null || otpServer == null || !otpClient.equals(otpServer)) {
            throw new RuntimeException("OTP không chính xác");
        }

        Users user = usersRepository.findByCustomer_Email(currentEmail)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        Customers customer = user.getCustomer();
        if (customer == null) {
            throw new RuntimeException("Không tìm thấy thông tin khách hàng");
        }

        if (customerRepository.existsByEmail(newEmail)) {
            throw new RuntimeException("Email mới đã được sử dụng");
        }

        customer.setEmail(newEmail);
        customerRepository.save(customer);

        UserDetails userDetails = org.springframework.security.core.userdetails.User
                .withUsername(newEmail)
                .password(user.getPassword())
                .authorities(user.getRole())
                .build();

        String newToken = jwtService.generateToken(userDetails, user.getRole());

        return Map.of(
                "message", "Đổi email thành công",
                "token", newToken
        );
    }

    @Transactional
    public String changePassword(String email, ChangePasswordRequest request) {
        if (request.getOld_password() == null || request.getOld_password().isBlank()
                || request.getNew_password() == null || request.getNew_password().isBlank()) {
            throw new RuntimeException("Vui lòng nhập đầy đủ mật khẩu cũ và mật khẩu mới");
        }

        if (request.getNew_password().length() < 6) {
            throw new RuntimeException("Mật khẩu mới phải có ít nhất 6 ký tự");
        }

        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        if (!passwordEncoder.matches(request.getOld_password(), user.getPassword())) {
            throw new RuntimeException("Mật khẩu hiện tại không đúng");
        }

        if (passwordEncoder.matches(request.getNew_password(), user.getPassword())) {
            throw new RuntimeException("Mật khẩu mới không được trùng mật khẩu cũ");
        }

        user.setPassword(passwordEncoder.encode(request.getNew_password()));
        usersRepository.save(user);

        return "Đổi mật khẩu thành công";
    }
}