package com.hcmute.bookstore.Entity;

public enum NotificationType {
    ORDER_CREATED,
    ORDER_CONFIRMED,
    ORDER_SHIPPING,
    ORDER_COMPLETED,
    ORDER_CANCELLED,
    ORDER_RETURNED,

    PAYMENT_SUCCESS,
    PAYMENT_FAILED,
    PAYMENT_REMINDER
}