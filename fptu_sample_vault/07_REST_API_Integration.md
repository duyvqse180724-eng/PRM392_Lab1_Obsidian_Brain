# 🌐 Tích Hợp Dịch Vụ RESTful API (REST API Integration)

> **Giao thức:** HTTP/HTTPS, JSON, WebSocket

---

## 1. Giao Tiếp Client - Server
Một ứng dụng [[01_Mobile_Development_Overview]] hiện đại luôn cần kết nối với backend để trao đổi dữ liệu:
- Sử dụng package `http` hoặc `dio` trong [[02_Flutter_Framework]] để thực hiện các phương thức GET, POST, PUT, DELETE.
- Chuyển đổi qua lại giữa chuỗi JSON và Dart Model thông qua `fromJson` và `toJson`.
- Lưu trữ bộ đệm (Caching) dữ liệu ngoại tuyến qua [[13_Database_Design]].

## 2. Chuẩn Hóa Kiến Trúc
- Nằm trong tầng Data Layer của mô hình [[05_Clean_Architecture]].
- Được kích hoạt và hiển thị trạng thái qua [[06_State_Management]].
- Dễ dàng Mock dữ liệu khi chạy kiểm thử tự động [[11_Unit_Testing_Guide]].
