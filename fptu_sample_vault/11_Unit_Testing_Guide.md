# 🧪 Hướng Dẫn Kiểm Thử Tự Động (Unit Testing & TDD)

> **Môn học:** SWT301 - Software Testing

---

## 1. Tầm Quan Trọng Của Testing
Kiểm thử tự động bảo vệ hệ sinh thái mã nguồn khỏi các lỗi hồi quy (Regression Bugs):
- **Unit Test:** Kiểm thử các hàm độc lập, Use Case và Bloc/Notifier trong [[06_State_Management]].
- **Widget Test:** Xác minh phản ứng giao diện trên [[02_Flutter_Framework]].
- **Integration Test:** Kiểm tra toàn bộ luồng hoạt động từ UI đến [[07_REST_API_Integration]].

## 2. Liên Kết Kiến Trúc
- Chỉ có thể kiểm thử hiệu quả khi áp dụng nguyên lý đảo ngược phụ thuộc từ [[10_SOLID_Principles]].
- Tận dụng cấu trúc phân tầng rõ ràng của [[05_Clean_Architecture]] để Mock Repositories.
- Được kích hoạt tự động trong quy trình kiểm định chất lượng [[15_DevOps_CI_CD]].
- Sử dụng công cụ test runner tích hợp sẵn của [[03_Dart_Programming]].
