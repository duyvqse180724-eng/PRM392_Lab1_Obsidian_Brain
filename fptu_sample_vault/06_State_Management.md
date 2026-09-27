# 🎛️ Quản Lý Trạng Thái (State Management)

> **Công nghệ:** Provider, Bloc, Riverpod & ValueNotifier

---

## 1. Vai Trò Của State Management
Trong ứng dụng [[02_Flutter_Framework]], State đại diện cho toàn bộ dữ liệu phản ánh lên giao diện tại một thời điểm nhất định:
- Phân tách giao diện người dùng khỏi logic xử lý nghiệp vụ theo quy chuẩn [[05_Clean_Architecture]].
- Áp dụng mẫu Observer Pattern từ [[12_Design_Patterns]] để lắng nghe luồng dữ liệu biến thiên.

## 2. Liên Kết Hệ Thống
- Phản hồi nhanh với các sự kiện trong [[04_Android_Activity_Lifecycle]].
- Quản lý trạng thái bất đồng bộ khi gọi [[07_REST_API_Integration]].
- Giúp việc viết kiểm thử [[11_Unit_Testing_Guide]] trở nên độc lập mà không cần khởi tạo UI thật.
