# 📚 UTE Bookstore Mobile App

Ứng dụng bán sách trên nền tảng di động được phát triển trong môn **Lập trình di động nâng cao**.

---

## Giới thiệu

UTE Bookstore là ứng dụng giúp người dùng:
- Tìm kiếm sách nhanh chóng
- Xem chi tiết sách
- Thêm vào giỏ hàng, đặt hàng
- Xem đánh giá sản phẩm
- Nhận gợi ý sách thông minh
- Chat với người bán

---

## 🧱 Công nghệ sử dụng

### Backend
- Spring Boot
- Spring Security (JWT, OAuth2)
- MySQL
- JPA / Hibernate

### Mobile
- React Native (Expo)
- Flutter (Admin)

### Search & AI
- MeiliSearch (Search Engine)
- Python (Recommendation System)

---

## Cài đặt hệ thống

### Backend (Spring Boot)

1. Clone project:
```bash
git clone git clone https://github.com/NgocHuynh1509/App_BookstoreUTE.git
```

2. Cấu hình application.properties
3. Chạy server. Server chạy tại: http://localhost:8080

4. Mở docker và chạy lệnh sau trong cmd:
```bash
docker run -it --rm ^
 -p 7700:7700 ^
 -v %cd%/meili_data:/meili_data ^
 getmeili/meilisearch:latest
```

---

### Frontend Customer (React Native)

1. Cài dependencies:  
Mở terminal và chạy lệnh sau:
```bash
cd my-app
npm install
```

2. Cấu hình địa chỉ kết nối backend:  
Thay địa chỉ IPv4 trong file cấu hình app/json: chạy lệnh:
```bash
ipconfig
```

3. Build development app  
Để hỗ trợ notification, nhóm sử dụng Expo Development Build thay vì Expo Go.
```bash
npx eas-cli build --profile development --platform android
```

Khởi động Metro bundler:
```bash
npx expo start --dev-client
```

4. Chạy ứng dụng trên thiết bị

---

### Frontend Admin (Flutter)

1. Cài dependencies:
```bash
flutter pub get
```

2. Chạy app:
```bash
flutter run
```
