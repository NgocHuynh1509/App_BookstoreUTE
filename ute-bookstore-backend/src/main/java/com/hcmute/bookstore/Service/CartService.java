package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.*;
import com.hcmute.bookstore.Repository.*;
import com.hcmute.bookstore.dto.CartItemDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CartService {

    @Autowired private CartDetailRepository cartDetailRepository;
    @Autowired private CartRepository cartRepository;
    @Autowired private BooksRepository booksRepository;
    @Autowired private CustomerRepository customerRepository;

    @Autowired
    private UsersRepository userRepository; // Repo của bảng User


    @Transactional(readOnly = true)
    public List<CartItemDTO> getCartByCustomerId(String identifier) {
        // 1. Tìm User dựa trên userName (Vì userName là @Id trong bảng Users)
        Users user = userRepository.findById(identifier) // identifier ở đây là "diemngoc"
                .orElseThrow(() -> new RuntimeException("Không tìm thấy User: " + identifier));

        // 2. Lấy Customer trực tiếp từ quan hệ @OneToOne đã có trong Entity Users
        Customers customer = user.getCustomer();

        if (customer == null) {
            throw new RuntimeException("Tài khoản này chưa có thông tin khách hàng!");
        }

        // 3. Tìm giỏ hàng từ customerId
        Cart cart = cartRepository.findByCustomer_CustomerId(customer.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Giỏ hàng trống"));

        // 4. Map sang DTO (Giữ nguyên phần return này)
        return cart.getCartDetails().stream().map(detail -> {
            String cartItemId = detail.getCartDetailId().getCartId() + "_" + detail.getCartDetailId().getBookId();
            return new CartItemDTO(
                    cartItemId,
                    detail.getBook().getBookId(),
                    detail.getBook().getTitle(),
                    detail.getUnitPrice(),
                    detail.getQuantity(),
                    detail.getBook().getPicture(),
                    detail.getBook().getQuantity()
            );
        }).collect(Collectors.toList());
    }

    @Transactional
    public void updateQuantityByUsername(String username, String bookId, int newQty) {
        // Tìm bằng đúng cột ID/userName của bảng Users
        Users user = userRepository.findById(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy User trong DB: " + username));

        Customers customer = user.getCustomer();
        if (customer == null) throw new RuntimeException("User chưa liên kết Customer");

        Cart cart = cartRepository.findByCustomer_CustomerId(customer.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Giỏ hàng không tồn tại"));

        CartDetailId id = new CartDetailId(cart.getCartId(), bookId);
        CartDetail detail = cartDetailRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sản phẩm không có trong giỏ"));

        if (newQty > detail.getBook().getQuantity()) {
            throw new RuntimeException("Số lượng vượt quá tồn kho");
        }

        detail.setQuantity(newQty);
        cartDetailRepository.save(detail);
    }

    @Transactional
    public void removeItemByUsername(String username, String bookId) {
        // 1. Tìm User từ username (diemngoc)
        Users user = userRepository.findById(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy User: " + username));

        // 2. Lấy Customer từ User
        Customers customer = user.getCustomer();
        if (customer == null) throw new RuntimeException("User chưa liên kết Customer");

        // 3. Tìm Cart của Customer đó
        Cart cart = cartRepository.findByCustomer_CustomerId(customer.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Giỏ hàng không tồn tại"));

        // 4. Xóa trực tiếp trong CartDetail bằng CartId và BookId
        CartDetailId id = new CartDetailId(cart.getCartId(), bookId);
        cartDetailRepository.deleteById(id);
    }
    // Trong CartService.java
    @Transactional
    public void addToCart(String customerId, String bookId, int quantity) {
        // 1. Tìm Customer dựa trên username từ Principal
        // Giả sử bạn có một CustomerRepository
        Customers customer = customerRepository.findByEmail(customerId) // hoặc findByUsername tùy logic của bạn
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin khách hàng"));

        // 2. Tìm Cart, nếu không thấy thì TẠO MỚI luôn
        Cart cart = cartRepository.findByCustomer_CustomerId(customer.getCustomerId())
                .orElseGet(() -> {
                    Cart newCart = new Cart();
                    newCart.setCartId("CART_" + customer.getCustomerId()); // Tạo ID duy nhất
                    newCart.setCustomer(customer);
                    newCart.setQuantity(0);
                    newCart.setTotalAmount(BigDecimal.ZERO);
                    return cartRepository.save(newCart);
                });

        // 2. Kiểm tra sách có tồn tại không
        Books book = booksRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Sách không tồn tại"));

        // 3. Kiểm tra tồn kho (quantity trong Entity Books)
        if (book.getQuantity() < quantity) {
            throw new RuntimeException("Số lượng tồn kho không đủ (Hiện có: " + book.getQuantity() + ")");
        }

        // 4. Tạo ID cho CartDetail (Composite Key)
        CartDetailId detailId = new CartDetailId(cart.getCartId(), bookId);

        // 5. Kiểm tra nếu đã có sách này trong giỏ thì cộng dồn, chưa có thì thêm mới
        CartDetail detail = cartDetailRepository.findById(detailId)
                .map(d -> {
                    d.setQuantity(d.getQuantity() + quantity);
                    return d;
                })
                .orElseGet(() -> {
                    CartDetail newDetail = new CartDetail();
                    newDetail.setCartDetailId(detailId);
                    newDetail.setCart(cart);
                    newDetail.setBook(book);
                    newDetail.setQuantity(quantity);
                    newDetail.setUnitPrice(book.getPrice());
                    return newDetail;
                });

        cartDetailRepository.save(detail);

        // 6. Cập nhật lại tổng tiền/tổng số lượng của Cart
        updateCartTotals(cart);
    }

    private void updateCartTotals(Cart cart) {
        // Ép Hibernate tải lại danh sách CartDetails mới nhất từ DB
        List<CartDetail> details = cartDetailRepository.findByCart_CartId(cart.getCartId());

        BigDecimal totalAmount = details.stream()
                .map(d -> d.getUnitPrice().multiply(new BigDecimal(d.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int totalQty = details.stream().mapToInt(CartDetail::getQuantity).sum();

        cart.setTotalAmount(totalAmount);
        cart.setQuantity(totalQty);
        cartRepository.save(cart);
    }
}