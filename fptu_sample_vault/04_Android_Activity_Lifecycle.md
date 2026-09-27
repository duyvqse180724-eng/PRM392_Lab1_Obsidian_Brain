# 🔄 Vòng Đời Ứng Dụng (Android & Flutter Lifecycle)

> **Môn học:** PRM392 - Mobile Architecture & Lifecycle

---

## 1. Chu Trình Hoạt Động
Vòng đời ứng dụng là nhân tố quyết định hiệu năng và trải nghiệm người dùng trong [[01_Mobile_Development_Overview]].
- `onCreate()` -> `onStart()` -> `onResume()`: Kích hoạt ứng dụng lên Foreground.
- `onPause()` -> `onStop()` -> `onDestroy()`: Thu hồi tài nguyên và lưu trữ trạng thái.

## 2. Ánh Xạ Sang Flutter
- Trong [[02_Flutter_Framework]], vòng đời gắn liền với `StatefulWidget`: `initState()`, `didChangeDependencies()`, `build()`, và `dispose()`.
- Việc giải phóng controller trong `dispose()` giúp ứng dụng không bị rò rỉ bộ nhớ khi chuyển màn hình.
- Phối hợp với [[06_State_Management]] để phục hồi dữ liệu khi người dùng chuyển tab hoặc xoay màn hình.
