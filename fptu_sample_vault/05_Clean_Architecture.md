# 🏛️ Kiến Trúc Phân Tầng Clean Architecture

> **Chuyên đề:** Kiến trúc phần mềm chuẩn cho ứng dụng Enterprise

---

## 1. 3 Phân Tầng Cốt Lõi
Clean Architecture chia hệ thống thành các vòng tròn độc lập:
1. **Presentation Layer:** Chứa giao diện [[02_Flutter_Framework]] và các bộ quản lý trạng thái [[06_State_Management]].
2. **Domain Layer:** Chứa Business Rules, Use Cases và Entities độc lập hoàn toàn với Framework.
3. **Data Layer:** Chứa Repositories, Data Sources kết nối [[07_REST_API_Integration]] và lưu trữ cục bộ với [[13_Database_Design]].

## 2. Nguyên Tắc Thiết Kế
- Áp dụng triệt để 5 nguyên lý [[10_SOLID_Principles]].
- Sử dụng các mẫu thiết kế [[12_Design_Patterns]] như Repository Pattern, Factory Method.
- Tạo điều kiện viết kiểm thử dễ dàng trong [[11_Unit_Testing_Guide]].
- Là trụ cột kiến trúc trong [[01_Mobile_Development_Overview]].
