package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Entity.Cart;
import com.hcmute.bookstore.Repository.CartRepository;
import com.hcmute.bookstore.Service.CartService;
import com.hcmute.bookstore.dto.AddToCartRequest;
import com.hcmute.bookstore.dto.CartItemDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;


import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/cart")
public class CartController {

    @Autowired private CartService cartService;

    @GetMapping("/{identifier}")
    public ResponseEntity<List<CartItemDTO>> getCart(
            @PathVariable("identifier") String identifier, // Chỉ định rõ tên mapping
            Principal principal
    ) {
        System.out.println("🚀 Backend nhận identifier: " + identifier);
        return ResponseEntity.ok(cartService.getCartByCustomerId(identifier));
    }

    @PutMapping("/update-quantity")
    public ResponseEntity<?> updateQuantity(@RequestBody Map<String, Object> body) {
        try {
            // Lấy username từ body mà Frontend vừa gửi lên
            String username = body.get("username").toString();
            String cartItemCombo = body.get("cartItemId").toString();
            int quantity = Integer.parseInt(body.get("quantity").toString());

            // Tách bookId từ chuỗi "CART01_BOOK02"
            String bookId = cartItemCombo.contains("_") ? cartItemCombo.split("_")[1] : cartItemCombo;

            cartService.updateQuantityByUsername(username, bookId, quantity);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(400).body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/remove/{cartItemId}")
    public ResponseEntity<?> removeItem(
            @PathVariable String cartItemId,
            @RequestParam("username") String username // Truyền username qua Query Param cho an toàn
    ) {
        try {
            // Tách lấy bookId từ chuỗi "CART01_BOOK02"
            String bookId = cartItemId.contains("_") ? cartItemId.split("_")[1] : cartItemId;

            cartService.removeItemByUsername(username, bookId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(400).body(Map.of("message", e.getMessage()));
        }
    }
    @PostMapping("/add")
    public ResponseEntity<?> addToCart(Principal principal, @RequestBody AddToCartRequest request) {
        // Lấy customerId (thường là username hoặc email) từ JWT Token thông qua Principal
        String customerId = principal.getName();

        try {
            cartService.addToCart(customerId, request.getBookId(), request.getQuantity());
            return ResponseEntity.ok(Map.of("message", "Thêm vào giỏ hàng thành công"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}