package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Customers;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Repository.CustomerRepository;
import com.hcmute.bookstore.dto.admin.AdminCustomerResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminCustomerService {

    private final CustomerRepository customerRepository;

    public List<AdminCustomerResponse> getCustomers(String keyword, Boolean enabled) {
        List<Customers> customers = customerRepository.findAll();

        return customers.stream()
                .filter(c -> {
                    if (keyword == null || keyword.isBlank()) return true;
                    String kw = keyword.trim().toLowerCase();

                    boolean matchCustomer =
                            (c.getCustomerId() != null && c.getCustomerId().toLowerCase().contains(kw)) ||
                                    (c.getFullName() != null && c.getFullName().toLowerCase().contains(kw)) ||
                                    (c.getPhone() != null && c.getPhone().toLowerCase().contains(kw)) ||
                                    (c.getEmail() != null && c.getEmail().toLowerCase().contains(kw)) ||
                                    (c.getAddress() != null && c.getAddress().toLowerCase().contains(kw));

                    boolean matchUser =
                            c.getUser() != null &&
                                    c.getUser().getUserName() != null &&
                                    c.getUser().getUserName().toLowerCase().contains(kw);

                    return matchCustomer || matchUser;
                })
                .filter(c -> {
                    if (enabled == null) return true;
                    Users u = c.getUser();
                    return u != null && enabled.equals(u.getEnabled());
                })
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public AdminCustomerResponse getCustomerDetail(String customerId) {
        Customers customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khách hàng với mã: " + customerId));

        return toResponse(customer);
    }

    public void updateCustomerStatus(String customerId, Boolean enabled) {
        if (enabled == null) {
            throw new RuntimeException("Trạng thái enabled không được để trống");
        }

        Customers customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy khách hàng với mã: " + customerId));

        Users user = customer.getUser();
        if (user == null) {
            throw new RuntimeException("Khách hàng này chưa liên kết tài khoản user");
        }

        user.setEnabled(enabled);

        customerRepository.save(customer);
    }

    private AdminCustomerResponse toResponse(Customers c) {
        Users u = c.getUser();

        return new AdminCustomerResponse(
                c.getCustomerId(),
                u != null ? u.getUserName() : null,
                c.getFullName(),
                c.getDateOfBirth() != null ? c.getDateOfBirth().toString() : null,
                c.getPhone(),
                c.getEmail(),
                c.getAddress(),
                u != null && u.getRegistrationDate() != null
                        ? u.getRegistrationDate().toString()
                        : null,
                u != null && u.getRewardPoints() != null ? u.getRewardPoints() : 0,
                u != null && Boolean.TRUE.equals(u.getEnabled()),
                c.getOrders() != null ? c.getOrders().size() : 0
        );
    }
}