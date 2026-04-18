package com.hcmute.bookstore.dto;

public class CreateReviewResponse {
    private String message;
    private RewardData reward;

    public CreateReviewResponse(String message, RewardData reward) {
        this.message = message;
        this.reward = reward;
    }

    public String getMessage() {
        return message;
    }

    public RewardData getReward() {
        return reward;
    }

    public static class RewardData {
        private String type;
        private String code;

        public RewardData(String type, String code) {
            this.type = type;
            this.code = code;
        }

        public String getType() {
            return type;
        }

        public String getCode() {
            return code;
        }
    }
}