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

## Debug 401/403 (JWT)

- Ensure you logged in with an admin account and the app stored a non-empty token.
- The app sends `Authorization: Bearer <token>` automatically via Dio interceptor.
- Use `flutter run --dart-define=API_BASE_URL=http://localhost:8080` to point to your backend.
- Backend returns 401 for missing/expired token and 403 for insufficient role.

## Preview PDF

In-app preview uses a shared PDF file for all books. The preview screen loads the direct download link (Google Drive `uc?export=download`), so it stays inside the app.

Example:

- View link: `https://drive.google.com/file/d/FILE_ID/view`
- Direct download: `https://drive.google.com/uc?export=download&id=FILE_ID`

Preview flow:

- Book list -> Product detail -> Doc thu
