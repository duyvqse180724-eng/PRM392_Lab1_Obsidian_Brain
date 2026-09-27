# 🗄️ Thiết Kế Cơ Sở Dữ Liệu & Bộ Nhớ Đệm (Database Design)

> **Công nghệ:** SQLite (sqflite), Isar, Hive, SharedPreferences

---

## 1. Lưu Trữ Dữ Liệu Cục Bộ (Local Storage)
Trong môi trường di động, khả năng hoạt động Offline-First là tiêu chí sống còn:
- Sử dụng SQLite / Isar để lưu trữ danh sách dữ liệu có quan hệ phức tạp.
- Sử dụng Key-Value Store (SharedPreferences) để lưu cài đặt người dùng hoặc API Key.
- Đồng bộ hóa dữ liệu hai chiều với máy chủ từ xa qua [[07_REST_API_Integration]].

## 2. Liên Kết Hệ Thống
- Đặt tại tầng Data Layer của kiến trúc [[05_Clean_Architecture]].
- Áp dụng Singleton và Repository Pattern từ [[12_Design_Patterns]].
- Kiểm soát phiên bản cơ sở dữ liệu qua các script được quản lý bằng [[14_Git_Version_Control]].
