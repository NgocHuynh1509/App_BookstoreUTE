package com.hcmute.bookstore.dto.admin;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class DashboardRevenuePredictionResponse {
    private BigDecimal predictedAmount;
    private BigDecimal currentMonthTotal;
    private String predictedAmountFormatted;
    private String currentMonthTotalFormatted;
    private double changePercent;
    private double confidence;
    private double mae;
    private double mse;
    private double rmse;
    private double r2;
    private String suggestion;
    private String predictedLabel;
    private int forecastIndex;
    private List<DashboardSeriesPoint> series = new ArrayList<>();

    public BigDecimal getPredictedAmount() {
        return predictedAmount;
    }

    public void setPredictedAmount(BigDecimal predictedAmount) {
        this.predictedAmount = predictedAmount;
    }

    public BigDecimal getCurrentMonthTotal() {
        return currentMonthTotal;
    }

    public void setCurrentMonthTotal(BigDecimal currentMonthTotal) {
        this.currentMonthTotal = currentMonthTotal;
    }

    public String getPredictedAmountFormatted() {
        return predictedAmountFormatted;
    }

    public void setPredictedAmountFormatted(String predictedAmountFormatted) {
        this.predictedAmountFormatted = predictedAmountFormatted;
    }

    public String getCurrentMonthTotalFormatted() {
        return currentMonthTotalFormatted;
    }

    public void setCurrentMonthTotalFormatted(String currentMonthTotalFormatted) {
        this.currentMonthTotalFormatted = currentMonthTotalFormatted;
    }

    public double getChangePercent() {
        return changePercent;
    }

    public void setChangePercent(double changePercent) {
        this.changePercent = changePercent;
    }

    public double getConfidence() {
        return confidence;
    }

    public void setConfidence(double confidence) {
        this.confidence = confidence;
    }

    public double getMae() {
        return mae;
    }

    public void setMae(double mae) {
        this.mae = mae;
    }

    public double getMse() {
        return mse;
    }

    public void setMse(double mse) {
        this.mse = mse;
    }

    public double getRmse() {
        return rmse;
    }

    public void setRmse(double rmse) {
        this.rmse = rmse;
    }

    public double getR2() {
        return r2;
    }

    public void setR2(double r2) {
        this.r2 = r2;
    }

    public String getSuggestion() {
        return suggestion;
    }

    public void setSuggestion(String suggestion) {
        this.suggestion = suggestion;
    }

    public String getPredictedLabel() {
        return predictedLabel;
    }

    public void setPredictedLabel(String predictedLabel) {
        this.predictedLabel = predictedLabel;
    }

    public int getForecastIndex() {
        return forecastIndex;
    }

    public void setForecastIndex(int forecastIndex) {
        this.forecastIndex = forecastIndex;
    }

    public List<DashboardSeriesPoint> getSeries() {
        return series;
    }

    public void setSeries(List<DashboardSeriesPoint> series) {
        this.series = series;
    }
}
