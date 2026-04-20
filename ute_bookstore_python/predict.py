import importlib
import subprocess
import sys

REQUIRED_PACKAGES = [
    ("pandas", "pandas"),
    ("matplotlib", "matplotlib"),
    ("joblib", "joblib"),
    ("scikit-learn", "sklearn"),
    ("numpy", "numpy"),
]


def ensure_pip():
    try:
        importlib.import_module("pip")
        return True
    except ModuleNotFoundError:
        pass
    try:
        subprocess.check_call([
            sys.executable,
            "-m",
            "ensurepip",
            "--upgrade",
        ])
    except Exception:
        return False
    return True


def ensure_packages():
    missing = []
    for package, module in REQUIRED_PACKAGES:
        try:
            importlib.import_module(module)
        except ModuleNotFoundError:
            missing.append((package, module))
    if not missing:
        return
    packages = [package for package, _ in missing]
    if not ensure_pip():
        raise RuntimeError("pip is not available to install packages: " + ", ".join(packages))
    try:
        subprocess.check_call([
            sys.executable,
            "-m",
            "pip",
            "install",
            "--disable-pip-version-check",
            "--no-input",
            *packages,
        ])
    except Exception as exc:
        raise RuntimeError("Missing Python package(s): " + ", ".join(packages)) from exc
    for _, module in missing:
        importlib.import_module(module)


ensure_packages()

import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import joblib

from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import numpy as np
import os
import json


def weighted_moving_average(values):
    if len(values) == 0:
        return 0.0
    weights = np.arange(1, len(values) + 1)
    return float(np.dot(values, weights) / weights.sum())


def add_missing_columns(df, columns):
    for col in columns:
        if col not in df.columns:
            df[col] = 0
    return df


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(BASE_DIR, "orders.csv")

df = pd.read_csv(csv_path, encoding="utf-8-sig")

required_cols = [
    "orderDate",
    "totalAmount",
    "orderCount",
    "booksSold",
    "cancelCount",
    "distinctCustomers",
    "newCustomers",
    "returningCustomers",
]
df = add_missing_columns(df, required_cols)

df["orderDate"] = pd.to_datetime(df["orderDate"], errors="coerce")
df = df.dropna(subset=["orderDate"]).sort_values("orderDate")

numeric_cols = [
    "totalAmount",
    "orderCount",
    "booksSold",
    "cancelCount",
    "distinctCustomers",
    "newCustomers",
    "returningCustomers",
]
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

if df.empty:
    print(json.dumps({
        "MAE": 0,
        "MSE": 0,
        "RMSE": 0,
        "R2": 0,
        "Tomorrow_Prediction": 0,
        "DataPoints": 0,
        "SpanDays": 0,
        "Confidence": 0,
        "ModelPrediction": 0,
        "TrendPrediction": 0,
        "WmaPrediction": 0,
        "GrowthRate": 0,
    }))
    sys.exit(0)

df = df.set_index("orderDate")
full_index = pd.date_range(df.index.min(), df.index.max(), freq="D")
df = df.reindex(full_index).fillna(0)

df["avgOrderValue"] = df["totalAmount"] / df["orderCount"].replace(0, np.nan)
df["avgOrderValue"] = df["avgOrderValue"].fillna(0)

df["cancelRate"] = df["cancelCount"] / df["orderCount"].replace(0, np.nan)
df["cancelRate"] = df["cancelRate"].fillna(0)

df["returningRate"] = df["returningCustomers"] / df["distinctCustomers"].replace(0, np.nan)
df["returningRate"] = df["returningRate"].fillna(0)

df["dayOfWeek"] = df.index.dayofweek
df["dayOfMonth"] = df.index.day
df["month"] = df.index.month
df["isWeekend"] = (df.index.dayofweek >= 5).astype(int)
df["isMonthEnd"] = df.index.is_month_end.astype(int)
df["isMonthStart"] = df.index.is_month_start.astype(int)

df["revenue_ma7"] = df["totalAmount"].rolling(7, min_periods=1).mean()
df["revenue_ma30"] = df["totalAmount"].rolling(30, min_periods=1).mean()
df["revenue_ma90"] = df["totalAmount"].rolling(90, min_periods=1).mean()
df["revenue_ema14"] = df["totalAmount"].ewm(span=14, adjust=False).mean()
df["order_ma7"] = df["orderCount"].rolling(7, min_periods=1).mean()
df["order_ma30"] = df["orderCount"].rolling(30, min_periods=1).mean()
df["books_ma7"] = df["booksSold"].rolling(7, min_periods=1).mean()
df["revenue_growth_7"] = df["revenue_ma7"].pct_change(7).fillna(0)
df["revenue_growth_30"] = df["revenue_ma30"].pct_change(30).fillna(0)

df["revenue_wma7"] = (
    df["totalAmount"].rolling(7, min_periods=1)
    .apply(lambda x: weighted_moving_average(np.array(x)), raw=True)
)

df["target"] = df["totalAmount"].shift(-1)
df_model = df.dropna(subset=["target"]).copy()

feature_cols = [
    "totalAmount",
    "orderCount",
    "booksSold",
    "cancelCount",
    "distinctCustomers",
    "newCustomers",
    "returningCustomers",
    "avgOrderValue",
    "cancelRate",
    "returningRate",
    "dayOfWeek",
    "dayOfMonth",
    "month",
    "isWeekend",
    "isMonthEnd",
    "isMonthStart",
    "revenue_ma7",
    "revenue_ma30",
    "revenue_ma90",
    "revenue_ema14",
    "order_ma7",
    "order_ma30",
    "books_ma7",
    "revenue_growth_7",
    "revenue_growth_30",
    "revenue_wma7",
]

data_points = int(len(df_model))
span_days = int((df.index.max() - df.index.min()).days) + 1

recent_values = df["totalAmount"].tail(14).values
wma_pred = weighted_moving_average(recent_values)

trend_window = df["totalAmount"].tail(30).values
if len(trend_window) >= 2:
    x = np.arange(len(trend_window))
    slope, intercept = np.polyfit(x, trend_window, 1)
    trend_pred = float(intercept + slope * (len(trend_window)))
else:
    trend_pred = float(df["totalAmount"].tail(1).values[0])

growth_rate = float(df["revenue_growth_7"].tail(1).values[0]) if len(df) >= 8 else 0.0

if data_points < 30:
    ensemble_pred = max(0.0, wma_pred * (1 + growth_rate))
    result = {
        "MAE": 0,
        "MSE": 0,
        "RMSE": 0,
        "R2": 0,
        "Tomorrow_Prediction": float(round(ensemble_pred, 2)),
        "DataPoints": data_points,
        "SpanDays": span_days,
        "Confidence": 0,
        "ModelPrediction": 0,
        "TrendPrediction": float(round(trend_pred, 2)),
        "WmaPrediction": float(round(wma_pred, 2)),
        "GrowthRate": float(round(growth_rate, 4)),
    }
    print(json.dumps(result))
    sys.exit(0)

X = df_model[feature_cols]
y = df_model["target"]

train_size = int(len(X) * 0.8)
X_train, X_test = X[:train_size], X[train_size:]
y_train, y_test = y[:train_size], y[train_size:]

model = LinearRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

joblib.dump({"model": model}, "linear_regression.joblib")

last_features = df.iloc[-1][feature_cols].values.reshape(1, -1)
model_pred = float(model.predict(last_features)[0])

r2 = float(r2_score(y_test, y_pred)) if len(y_test) > 1 else 0.0
model_weight = 0.4 + max(0.0, min(0.2, r2 * 0.2))
trend_weight = 0.2
wma_weight = 0.4
if r2 < 0.2:
    model_weight = 0.2
    wma_weight = 0.5
    trend_weight = 0.3

ensemble_pred = (
    model_pred * model_weight
    + trend_pred * trend_weight
    + wma_pred * wma_weight
)
ensemble_pred = max(0.0, float(ensemble_pred))

confidence = max(0.0, min(1.0, r2)) * 70 + min(1.0, data_points / 180) * 30

result = {
    "MAE": float(mean_absolute_error(y_test, y_pred)),
    "MSE": float(mean_squared_error(y_test, y_pred)),
    "RMSE": float(np.sqrt(mean_squared_error(y_test, y_pred))),
    "R2": r2,
    "Tomorrow_Prediction": float(round(ensemble_pred, 2)),
    "DataPoints": data_points,
    "SpanDays": span_days,
    "Confidence": float(round(confidence, 2)),
    "ModelPrediction": float(round(model_pred, 2)),
    "TrendPrediction": float(round(trend_pred, 2)),
    "WmaPrediction": float(round(wma_pred, 2)),
    "GrowthRate": float(round(growth_rate, 4)),
}

print(json.dumps(result))

plt.figure(figsize=(10, 5))
plt.plot(df.index[:train_size], df["totalAmount"][:train_size], label="Train")
plt.plot(df.index[train_size:len(y_pred) + train_size], df["totalAmount"][train_size:len(y_pred) + train_size], label="Actual")
plt.plot(df.index[train_size:len(y_pred) + train_size], y_pred, label="Predicted")
plt.legend()
plt.tight_layout()
plt.savefig(os.path.join(BASE_DIR, "output.png"))
plt.close()