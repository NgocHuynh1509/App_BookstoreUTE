package com.hcmute.bookstore.Controller;

import com.hcmute.bookstore.Service.WishlistService;
import com.hcmute.bookstore.dto.WishlistRequest;
import com.hcmute.bookstore.dto.WishlistResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;

    @GetMapping("/wishlist")
    public List<WishlistResponse> getWishlist(Authentication authentication) {
        String email = authentication.getName();
        return wishlistService.getWishlist(email);
    }

    @PostMapping("/wishlist")
    public Map<String, String> addWishlist(
            @RequestBody WishlistRequest request,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return Map.of("message", wishlistService.addWishlist(email, request.getBook_id()));
    }

    @DeleteMapping("/wishlist/{bookId}")
    public Map<String, String> removeWishlist(
            @PathVariable String bookId,
            Authentication authentication
    ) {
        String email = authentication.getName();
        return Map.of("message", wishlistService.removeWishlist(email, bookId));
    }
}