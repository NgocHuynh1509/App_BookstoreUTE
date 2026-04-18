package com.hcmute.bookstore.Entity;

import com.fasterxml.jackson.annotation.JsonCreator;

public enum ReactionType {
    LIKE,    // Thích (Thường là icon 👍)
    LOVE,    // Yêu thích (Thường là icon ❤️)
    HAHA,
    WOW,   // Cười (Thường là icon 😂)
    SAD,     // Buồn (Thường là icon 😢)
    ANGRY;    // Phẫn nộ (Thường là icon 😡)
    @JsonCreator
    public static ReactionType from(String value) {
        return ReactionType.valueOf(value.toUpperCase());
    }
}
