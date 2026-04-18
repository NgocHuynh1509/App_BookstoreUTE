package com.hcmute.bookstore.dto.admin;

public class PredictionJobResponse {
    private String jobId;
    private String status;
    private DashboardRevenuePredictionResponse prediction;
    private String message;

    public PredictionJobResponse() {
    }

    public PredictionJobResponse(String jobId, String status, DashboardRevenuePredictionResponse prediction, String message) {
        this.jobId = jobId;
        this.status = status;
        this.prediction = prediction;
        this.message = message;
    }

    public static PredictionJobResponse pending(String jobId) {
        return new PredictionJobResponse(jobId, "PENDING", null, null);
    }

    public static PredictionJobResponse done(String jobId, DashboardRevenuePredictionResponse prediction) {
        return new PredictionJobResponse(jobId, "DONE", prediction, null);
    }

    public static PredictionJobResponse failed(String jobId, String message) {
        return new PredictionJobResponse(jobId, "FAILED", null, message);
    }

    public String getJobId() {
        return jobId;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public DashboardRevenuePredictionResponse getPrediction() {
        return prediction;
    }

    public void setPrediction(DashboardRevenuePredictionResponse prediction) {
        this.prediction = prediction;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

