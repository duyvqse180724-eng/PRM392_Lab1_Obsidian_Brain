# Quy Chuẩn Đồ Án Tốt Nghiệp SWP490 / Capstone Project (FPTU)

> **Mã môn:** SWP490 / SEP490  
> **Áp dụng cho:** Sinh viên chuyên ngành Kỹ thuật Phần mềm (SE) - Đại học FPT

---

## 1. Yêu Cầu Hồ Sơ Tài Liệu Kỹ Thuật (SRS & SDD)

Mỗi nhóm đồ án cần chuẩn bị đầy đủ 2 tài liệu chuẩn IEEE trong suốt kỳ thực hiện:

### 1.1 Software Requirements Specification (SRS) - IEEE 830
- **Phạm vi sản phẩm (Product Scope):** Xác định ranh giới chức năng, đối tượng người dùng cuối và giá trị nghiệp vụ mang lại.
- **Yêu cầu chức năng (Functional Requirements):** 
  - Mô tả chi tiết từng Use Case theo chuẩn Actor - Precondition - Main Flow - Alternative Flow.
  - Phân rã độ ưu tiên theo phương pháp **MoSCoW** (Must have, Should have, Could have, Won't have).
- **Yêu cầu phi chức năng (Non-Functional Requirements):**
  - **Hiệu năng:** Thời gian phản hồi API < 500ms đối với 95% tác vụ.
  - **Bảo mật:** Xác thực JWT, mã hóa mật khẩu với BCrypt / Argon2, phân quyền Role-Based Access Control (RBAC).
  - **Tương thích:** Đáp ứng các nền tảng mục tiêu (Web Responsive, Mobile iOS/Android, Desktop Windows).

### 1.2 Software Design Document (SDD) - IEEE 1016
- **Kiến trúc hệ thống (High-Level Architecture):** Clean Architecture, Microservices hoặc Monolithic Modular.
- **Thiết kế cơ sở dữ liệu:** Sơ đồ quan hệ thực thể (ERD) đạt chuẩn chuẩn hóa 3NF.
- **Sơ đồ tuần tự (Sequence Diagram):** Minh họa luồng dữ liệu cho các tính năng quan trọng (Thanh toán, Đặt hàng, Đồng bộ hóa).

---

## 2. Các Mốc Đánh Giá & Bảo Vệ Đồ Án (Milestones)

Hội đồng chuyên môn FPTU đánh giá đồ án tốt nghiệp qua 4 giai đoạn gắt gao:

| Mốc Đánh Giá | Thời điểm | Nội dung thẩm định | Tỷ lệ trọng số |
| :--- | :--- | :--- | :--- |
| **Milestone 1** | Tuần 4 | Đề cương dự án, SRS V1.0, Wireframe/Figma UI prototype | **10%** |
| **Milestone 2** | Tuần 8 | SDD V1.0, Database Script, Hoàn thành 40% tính năng Core | **15%** |
| **Milestone 3** | Tuần 11 | Hoàn thành 85% hệ thống, Báo cáo Unit Test, SonarQube Code Quality | **25%** |
| **Final Defense** | Tuần 14 | Bảo vệ trước Hội đồng phản biện, Live Demo và Q&A chuyên sâu | **50%** |

---

## 3. Quy Định Về Code Quality & Quản Lý Mã Nguồn Git

1. **Quy chuẩn Git Flow:**
   - Nhánh `main`: Chỉ chứa code Production đã qua kiểm thử và release tag.
   - Nhánh `develop`: Tích hợp các tính năng đã pass CI/CD pipeline.
   - Các nhánh `feature/`, `bugfix/`: Tuân thủ đặt tên theo mã thẻ Jira/Trello (VD: `feature/SWP-102-auth-service`).
2. **Quy tắc Commit Message:**
   - Áp dụng chuẩn **Conventional Commits**:
     - `feat: add markdown live rendering module`
     - `fix: resolve file picker path separator on windows`
     - `docs: update srs non-functional requirements section`
3. **Kiểm thử tự động (Automated Testing):**
   - Mức độ bao phủ mã kiểm thử (Code Coverage) tối thiểu đạt **70%**.
   - Kiểm tra linter nghiêm ngặt không còn cảnh báo trước khi tạo Pull Request (`dart format` & `flutter analyze`).
