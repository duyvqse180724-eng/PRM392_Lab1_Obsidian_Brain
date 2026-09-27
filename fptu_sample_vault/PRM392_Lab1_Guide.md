# Hướng Dẫn Kiến Trúc Ứng Dụng Mobile/Desktop & Lifecycle (PRM392)

> **Môn học:** PRM392 / PRM393 - Mobile Programming  
> **Chủ đề:** Lab 1 - Cấu trúc dự án Cross-Platform Desktop & Android Lifecycle

---

## 1. Tổng Quan Về Kiến Trúc Ứng Dụng Cross-Platform

Trong phát triển ứng dụng di động và desktop hiện đại, kiến trúc phân lớp (**Layered Architecture**) giúp tách biệt rõ ràng giữa giao diện hiển thị, logic nghiệp vụ và tầng truy cập dữ liệu (I/O):

```
+-------------------------------------------------------+
|                    Presentation Layer                 |
|       (UI Widgets, State Management, Screens)        |
+-------------------------------------------------------+
                           |
                           v
+-------------------------------------------------------+
|                     Domain Layer                      |
|            (Models, Entities, Business Rules)         |
+-------------------------------------------------------+
                           |
                           v
+-------------------------------------------------------+
|                   Data / Service Layer                |
|        (File I/O, REST API, Database, FilePicker)     |
+-------------------------------------------------------+
```

### Các nguyên tắc cốt lõi:
- **Single Responsibility Principle (SRP):** Mỗi class hoặc widget chỉ đảm nhận một nhiệm vụ duy nhất (Ví dụ: `FileService` chỉ lo việc đọc/ghi tập tin).
- **Immutability (Bất biến):** Sử dụng các thuộc tính `final` và constructor `const` trong Flutter nhằm tối ưu hóa hiệu năng render widget tree.
- **Fail-Safe I/O:** Mọi tác vụ đọc ghi file từ hệ thống Windows phải bọc trong khối `try-catch` để tránh làm crash ứng dụng khi người dùng chọn file bị khóa hoặc không đủ quyền truy cập.

---

## 2. Vòng Đời Ứng Dụng (Application & Activity Lifecycle)

### 2.1 Chu trình sống của Android Activity
Khi triển khai ứng dụng trên nền tảng Android, hệ thống quản lý trạng thái thông qua các callback:

| Giai đoạn | Callback | Mô tả chi tiết |
| :--- | :--- | :--- |
| **Khởi tạo** | `onCreate()` | Khởi tạo giao diện, ràng buộc dữ liệu ban đầu. |
| **Bắt đầu** | `onStart()` | Activity hiển thị trên màn hình nhưng chưa thể tương tác. |
| **Tương tác** | `onResume()` | Activity sẵn sàng nhận tương tác từ người dùng (Foreground). |
| **Tạm dừng** | `onPause()` | Bị che khuất một phần (VD: xuất hiện Dialog, nhận cuộc gọi). |
| **Dừng** | `onStop()` | Bị ẩn hoàn toàn dưới nền. Cần giải phóng tài nguyên nặng. |
| **Hủy** | `onDestroy()` | Tiến trình chuẩn bị bị giải phóng hoàn toàn khỏi bộ nhớ RAM. |

### 2.2 Vòng đời Widget trong Flutter (`StatefulWidget`)
Tương tự Android Activity, trong Flutter State có chu kỳ sống như sau:
1. `initState()`: Được gọi chính xác 1 lần khi State Object được đưa vào cây Widget. Dùng để đăng ký listener, nạp cấu hình ban đầu.
2. `didChangeDependencies()`: Kích hoạt khi đối tượng phụ thuộc thay đổi (`InheritedWidget`).
3. `build()`: Hàm bắt buộc để trả về cây Widget hiển thị.
4. `dispose()`: Dọn dẹp tài nguyên (hủy `StreamController`, `TextEditingController`, `AnimationController`).

```dart
@override
void dispose() {
  _searchController.removeListener(_onSearchChanged);
  _searchController.dispose();
  super.dispose();
}
```

---

## 3. Quản Lý File I/O Trên Windows Desktop

Khác với môi trường Sandbox trên iOS/Android, Flutter Desktop trên Windows có quyền truy cập trực tiếp vào hệ thống tệp tin NTFS:
- Sử dụng `package:file_picker` để gọi Win32 File Dialog nguyên bản.
- Sử dụng `dart:io` và `package:path` để chuẩn hóa dấu phân cách thư mục (`\` trên Windows và `/` trên Unix).
- Quét đệ quy `dir.listSync(recursive: true)` để lập chỉ mục các file Markdown trong Obsidian Vault.

> **Lưu ý quan trọng:** Luôn kiểm tra `dir.exists()` trước khi duyệt để tránh ngoại lệ `FileSystemException`.
