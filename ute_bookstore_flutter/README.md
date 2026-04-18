# ute_bookstore_flutter

Flutter admin client for the Bookstore system (mobile-first). It uses JWT auth and a 4-tab bottom navigation layout.

## Prerequisites

- Flutter SDK 3.11+
- Backend running on `http://localhost:8080`

## Configure API base URL

Use the default platform mapping, or override:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080
```

## Install dependencies

```bash
flutter pub get
```

## Run

```bash
flutter run -d windows
```

## Admin tabs

- Dashboard
- Sản phẩm
- Đơn hàng
- Khác
