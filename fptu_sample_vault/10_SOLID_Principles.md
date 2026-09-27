# 📐 5 Nguyên Lý Thiết Kế Phần Mềm SOLID (SOLID Principles)

> **Môn học:** SWD392 - Software Architecture & Design

---

## 1. Chi Tiết 5 Nguyên Lý
- **S - Single Responsibility Principle:** Mỗi lớp chỉ chịu một trách nhiệm thay đổi duy nhất.
- **O - Open/Closed Principle:** Mở rộng tính năng nhưng đóng với việc sửa đổi mã nguồn gốc.
- **L - Liskov Substitution Principle:** Lớp con phải thay thế được hoàn toàn lớp cha mà không phá vỡ tính đúng đắn.
- **I - Interface Segregation Principle:** Không ép buộc client phụ thuộc vào interface mà họ không sử dụng.
- **D - Dependency Inversion Principle:** Phụ thuộc vào trừu tượng hóa (Abstraction), không phụ thuộc vào chi tiết cụ thể (Concrete).

## 2. Ứng Dụng Trong Hệ Thống
- Nâng cấp từ nền tảng [[09_Object_Oriented_Programming]].
- Là kim chỉ nam khi xây dựng [[05_Clean_Architecture]].
- Được cụ thể hóa thông qua các mẫu thiết kế [[12_Design_Patterns]].
- Giúp việc viết bài kiểm thử [[11_Unit_Testing_Guide]] dễ dàng nhờ Dependency Injection.
