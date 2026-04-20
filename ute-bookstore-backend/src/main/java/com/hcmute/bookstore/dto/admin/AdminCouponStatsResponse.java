package com.hcmute.bookstore.dto.admin;

public class AdminCouponStatsResponse {
    private long activeCount;
    private long expiringSoonCount;
    private long totalUsedCount;
    private String topUsedCode;
    private long topUsedCount;

    public long getActiveCount() {
        return activeCount;
    }

    public void setActiveCount(long activeCount) {
        this.activeCount = activeCount;
    }

    public long getExpiringSoonCount() {
        return expiringSoonCount;
    }

    public void setExpiringSoonCount(long expiringSoonCount) {
        this.expiringSoonCount = expiringSoonCount;
    }

    public long getTotalUsedCount() {
        return totalUsedCount;
    }

    public void setTotalUsedCount(long totalUsedCount) {
        this.totalUsedCount = totalUsedCount;
    }

    public String getTopUsedCode() {
        return topUsedCode;
    }

    public void setTopUsedCode(String topUsedCode) {
        this.topUsedCode = topUsedCode;
    }

    public long getTopUsedCount() {
        return topUsedCount;
    }

    public void setTopUsedCount(long topUsedCount) {
        this.topUsedCount = topUsedCount;
    }
}

