# ⚡ Tích Hợp & Phân Phối Tự Động (DevOps & CI/CD)

> **Công cụ:** GitHub Actions, Fastlane, Docker

---

## 1. Tự Động Hóa Vòng Đời Phần Mềm
Quy trình CI/CD giúp giảm thiểu sai sót do con người và rút ngắn thời gian phát hành:
- **Continuous Integration (CI):** Mỗi khi có commit mới trên [[14_Git_Version_Control]], hệ thống tự động tải thư viện, phân tích mã nguồn và chạy toàn bộ bài kiểm thử từ [[11_Unit_Testing_Guide]].
- **Continuous Delivery / Deployment (CD):** Tự động đóng gói bản cài đặt (APK, AAB cho Android, EXE / MSIX cho Windows Desktop) và tải lên môi trường thử nghiệm hoặc Store.

## 2. Kết Nối Toàn Diện
- Hoàn thiện chu trình phát triển sản phẩm [[01_Mobile_Development_Overview]].
- Đảm bảo các quy chuẩn kiến trúc [[05_Clean_Architecture]] được tuân thủ nghiêm ngặt trước khi hợp nhất mã nguồn.
