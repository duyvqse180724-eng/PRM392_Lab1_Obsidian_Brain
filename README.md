# 🧠 FPTU Obsidian Second Brain

> **Môn học:** PRM392 / PRM393 - Mobile & Cross-Platform Development  
> **Đồ án:** Lab 1 - Ứng Dụng Quản Lý Tri Thức Cá Nhân (Second Brain) & Trợ Lý Học Tập AI Copilot  
> **Nền tảng:** Flutter Desktop (Windows) & Mobile Cross-Platform  

---

## 🌟 1. Giới Thiệu Đồ Án
**FPTU Obsidian Second Brain** là giải pháp quản lý tri thức cá nhân chuyên sâu dành cho sinh viên ngành Kỹ thuật Phần mềm (SE) Đại học FPT. Ứng dụng mô phỏng theo mô hình Obsidian.md, vận hành trên nền tảng tệp tin Markdown thuần túy (`.md`), liên kết hai chiều (Wikilinks) và tích hợp mạng đồ thị tri thức 3D cùng AI Study Buddy hỗ trợ học tập thông minh.

---

## 🚀 2. Các Tính Năng Cốt Lõi

### ① Quản Lý Tập Tin & Vault Trên Windows
- Quét đệ quy toàn bộ ghi chú `.md` trong thư mục Vault (`FileService`).
- Hỗ trợ tạo mới ghi chú, lưu ghi chú với phím tắt `Ctrl + S`.
- Hiển thị danh sách file với bộ đếm thời gian sửa đổi và phân loại thư mục.

### ② Trình Soạn Thảo & Xem Trước Markdown Nâng Cao
- Chuyển đổi linh hoạt giữa chế độ **Preview** và **Editor**.
- Render đầy đủ các thành phần Markdown: Tiêu đề H1-H6, danh sách việc cần làm (Task list), khối mã nguồn (Code syntax highlighting), bảng biểu và hình ảnh.
- Nhận diện và liên kết hai chiều **Wikilinks `[[Tên_Ghi_Chú]]`**: Click vào link để nhảy ngay đến tài liệu tương ứng.

### ③ Đồ Thị Tri Thức 3D (Knowledge Graph View)
- Mô phỏng vật lý mạng nơ-ron (Force-Directed Graph: Lực đẩy Coulomb + Lực kéo đàn hồi Hooke).
- Nhận diện các "Knowledge Hubs" (nốt to và phát sáng khi có nhiều liên kết).
- Tương tác trực quan: Zoom in/out, Pan kéo thả, điều chỉnh khoảng cách liên kết (+/- 40px), kéo thả nốt và click nốt để mở bài học.

### ④ Trợ Lý AI Học Tập 3D (AI Study Buddy)
- **✨ Tóm tắt bài học:** Trích xuất các điểm cốt lõi của bài học bằng Markdown.
- **💬 Hỏi đáp ngữ cảnh:** Trả lời trực tiếp các câu hỏi dựa trên nội dung tài liệu đang mở.
- **🎲 Quiz Trắc Nghiệm Tương Tác:**
  - Tạo 3 câu hỏi trắc nghiệm với 4 phương án lựa chọn A, B, C, D.
  - Ban đầu ẩn kết quả và lời giải thích.
  - Khi bấm chọn: Nút đổi màu trực quan (Xanh lá nếu đúng, Đỏ nếu sai), tự động làm nổi bật đáp án đúng và mở khóa phần **Giải thích chi tiết**.
  - Tích hợp cả 2 chế độ: **Gemini AI Online** và **Smart Offline Bank** (ngân hàng kiến thức chuẩn mực chuyên ngành SE).

### ⑤ Giao Diện Đồ Họa Cao Cấp (Premium 3D Glassmorphism)
- Bố cục 3 cột chuyên nghiệp: Sidebar - Editor/Graph - AI Panel.
- Thanh kéo dãn chia cột (Resizable Split View) với tay cầm 3D và hiệu ứng chống giật lag.
- Hiệu ứng đổ bóng đa tầng (Layered Shadows), viền sáng Neon Glow và dải màu chuyển sắc tím hiện đại.

---

## 🏗️ 3. Kiến Trúc Mã Nguồn (Layered Architecture)

Dự án tuân thủ nghiêm ngặt nguyên lý **Clean Architecture** và cấu trúc phân tầng:

```
lib/
├── models/                     # Domain Layer (Dữ liệu bất biến)
│   ├── graph_data.dart         # Graph Nodes & Edges model
│   ├── note_file.dart          # Markdown File entity
│   └── quiz_question.dart      # Interactive Quiz model
├── services/                   # Data & Service Layer
│   ├── ai_service.dart         # Gemini REST API & Copilot service
│   ├── file_service.dart       # Windows I/O, FilePicker & scanning
│   ├── graph_service.dart      # Wikilink parser & Graph builder
│   └── quiz_bank.dart          # Curated SE Knowledge Bank
├── theme/                      # Presentation Styling
│   └── app_theme.dart          # Color tokens, Gradients & 3D Shadows
└── views/                      # Presentation Layer
    ├── home_screen.dart        # 3-column Shell & Resizable dividers
    └── widgets/
        ├── ai_assistant_panel.dart    # AI Copilot & Interactive Quiz UI
        ├── editor_preview_view.dart   # Markdown Editor & Viewer
        ├── knowledge_graph_view.dart  # Interactive 2D/3D Canvas Graph
        ├── resizable_divider.dart     # Custom dragging divider
        └── sidebar_view.dart          # Vault Explorer & Search
```

---

## 🔒 4. Cấu Hình Bảo Mật API Key (.env)
Dự án áp dụng cơ chế bảo mật khóa API qua biến môi trường:
1. Tạo file `.env` ở thư mục gốc:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
2. File `.env` đã được đưa vào `.gitignore` để tránh rò rỉ key khi đẩy lên GitHub.
3. Dự án có sẵn file mẫu `.env.example`.
4. Nếu chưa có API Key hoặc mất mạng, ứng dụng **hoàn toàn không bị lỗi**, tự động chuyển sang chế độ **Smart Offline**.

---

## 💻 5. Hướng Dẫn Chạy Dự Án

### Yêu cầu môi trường:
- Flutter SDK >= 3.6.0
- Dart SDK >= 3.6.0
- Visual Studio với C++ Desktop Workload (để chạy trên Windows Desktop)

### Các lệnh thực thi:
```bash
# 1. Cài đặt các gói phụ thuộc
flutter pub get

# 2. Kiểm tra chất lượng mã nguồn
flutter analyze

# 3. Chạy kiểm thử tự động
flutter test

# 4. Khởi chạy ứng dụng trên Windows Desktop
flutter run -d windows
```
