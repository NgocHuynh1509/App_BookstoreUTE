package com.hcmute.bookstore.Service;

import com.hcmute.bookstore.Entity.Books;
import com.hcmute.bookstore.Entity.Users;
import com.hcmute.bookstore.Entity.Wishlist;
import com.hcmute.bookstore.Repository.BooksRepository;
import com.hcmute.bookstore.Repository.UsersRepository;
import com.hcmute.bookstore.Repository.WishlistRepository;
import com.hcmute.bookstore.dto.WishlistResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WishlistService {

    private final WishlistRepository wishlistRepository;
    private final UsersRepository usersRepository;
    private final BooksRepository bookRepository;

    public List<WishlistResponse> getWishlist(String email) {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        return wishlistRepository.findByCustomer_CustomerId(user.getCustomer().getCustomerId())
                .stream()
                .map(w -> new WishlistResponse(w.getBook().getBookId()))
                .toList();
    }

    @Transactional
    public String addWishlist(String email, String bookId) {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        boolean exists = wishlistRepository
                .findByCustomer_CustomerIdAndBook_BookId(user.getCustomer().getCustomerId(), bookId)
                .isPresent();

        if (exists) return "Sách đã có trong wishlist";

        Books book = bookRepository.findById(bookId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sách"));

        Wishlist wishlist = new Wishlist();
        wishlist.setCustomer(user.getCustomer());
        wishlist.setBook(book);
        wishlistRepository.save(wishlist);

        return "Đã thêm vào wishlist";
    }

    @Transactional
    public String removeWishlist(String email, String bookId) {
        Users user = usersRepository.findByCustomer_Email(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        wishlistRepository.deleteByCustomer_CustomerIdAndBook_BookId(
                user.getCustomer().getCustomerId(),
                bookId
        );
        return "Đã xóa khỏi wishlist";
    }
}