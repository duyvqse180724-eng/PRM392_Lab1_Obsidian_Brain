# Kiến Trúc Ứng Dụng Mobile Cross-Platform & Lifecycle (PRM392)

> **Môn học:** PRM392 - Mobile Programming  
> **Chủ đề:** Layered Architecture & Android/Flutter Lifecycle  
> **Liên kết đồ án:** [[SWP490_Capstone_Guide]]

---

## 1. Kiến Trúc Phân Lớp (Layered Architecture)

Trong các ứng dụng Flutter Desktop và Mobile hiện đại, kiến trúc ứng dụng được chia thành 3 tầng độc lập:

1. **Presentation Layer (UI):**
   - Chứa các Widgets, Screens, UI state.
   - Luôn sử dụng từ khóa `const` với các Widget bất biến để tối ưu hiệu năng cây Widget (Widget Tree).
2. **Domain Layer (Business Logic & Models):**
   - Chứa thực thể dữ liệu độc lập như `NoteFile`, các rule xử lý dữ liệu thuần Dart.
3. **Data / Service Layer (I/O & APIs):**
   - Chứa `FileService`, `AIService`, tương tác trực tiếp với hệ điều hành và REST API.
   - Mọi thao tác I/O bắt buộc phải bao bọc trong khối `try-catch` để chống crash.

---

## 2. Chu Kỳ Sống (Lifecycle)

### 2.1 Android Activity Lifecycle
- `onCreate()`: Khởi tạo dữ liệu giao diện ban đầu.
- `onStart()`: Activity hiển thị trên màn hình.
- `onResume()`: Ứng dụng sẵn sàng nhận tương tác (Foreground).
- `onPause()`: Bị che khuất một phần (gọi điện thoại, xuất hiện dialog).
- `onStop()`: Bị ẩn hoàn toàn xuống background, cần giải phóng tài nguyên.
- `onDestroy()`: Hoàn tất giải phóng tiến trình khỏi bộ nhớ RAM.

### 2.2 Flutter StatefulWidget Lifecycle
- `initState()`: Được kích hoạt duy nhất 1 lần khi State Object sinh ra.
- `build()`: Hàm bắt buộc để trả về cây Widget khi có `setState()`.
- `dispose()`: Dọn dẹp tài nguyên (Controllers, Listeners, Streams).

---

## 3. Ứng Dụng Vào Đồ Án Tốt Nghiệp

Kiến thức quản lý trạng thái và kiến trúc phân lớp ở môn PRM392 là nền tảng cốt lõi khi thiết kế đồ án tốt nghiệp trong môn [[SWP490_Capstone_Guide]].
