Nội dung được biên soạn chuẩn theo chương trình Kỹ thuật Phần mềm (SE) Đại học FPT, tích hợp kiến thức từ quy chuẩn đồ án Capstone SWP490 và các môn chuyên ngành. Bạn có thể copy toàn bộ đoạn dưới đây và lưu thành tệp FPTU_SE_Master_Knowledge_Base.md để test triệt để thanh cuộn, hiệu năng render và khả năng đọc hiểu ngữ cảnh của trợ lý AI:   Markdown# 🏛️ FPTU Software Engineering: Master Architectural Blueprint & Second Brain Guide

> **Mã định danh tài liệu:** FPTU-SE-KB-2026-v4.2  
> **Chuyên ngành:** Kỹ thuật Phần mềm (Software Engineering) - Đại học FPT  
> **Lĩnh vực bao phủ:** Mobile Programming (PRM392), Software Architecture (SWD392), Capstone Project (SWP490)  
> **Các tài liệu liên kết mạng lưới (Wikilinks):** [[SWP490_Capstone_Guide]], [[PRM392_Mobile_Architecture]], [[SE_Second_Brain_Tips]], [[Design_Patterns_Catalog]]

---

## 📑 Mục lục tương tác (Table of Contents)
1. [Giới thiệu tổng quan & Phương pháp Second Brain](#-1-giới-thiệu-tổng-quan--phương-pháp-second-brain)
2. [Vòng đời ứng dụng & Quản trị luồng thực thi (System Lifecycle)](#-2-vòng-đời-ứng-dụng--quản-trị-luồng-thực-thi-system-lifecycle)
3. [Kiến trúc phân lớp chuẩn mực (Clean Architecture & SOLID)](#-3-kiến-trúc-phân-lớp-chuẩn-mực-clean-architecture--solid)
4. [So sánh chuyên sâu các giải pháp Quản lý Trạng thái (State Management)](#-4-so-sánh-chuyên-sâu-các-giải-pháp-quản-lý-trạng-thái-state-management)
5. [Quy chuẩn 7 Báo cáo Kỹ thuật Đồ án Tốt nghiệp (SWP490 CPro Standards)](#-5-quy-chuẩn-7-báo-cáo-kỹ-thuật-đồ-án-tốt-nghiệp-swp490-cpro-standards)
6. [Hiện thực hóa mã nguồn mẫu: Xử lý I/O & Bắt lỗi an toàn](#-6-hiện-thực-hóa-mã-nguồn-mẫu-xử-lý-io--bắt-lỗi-an-toàn)
7. [Bảng kiểm định chất lượng mã nguồn (Code Quality Checklist)](#-7-bảng-kiểm-định-chất-lượng-mã-nguồn-code-quality-checklist)
8. [Bộ câu hỏi phản biện & Vấn đáp bảo vệ đồ án (Defense FAQ)](#-8-bộ-câu-hỏi-phản-biện--vấn-đáp-bảo-vệ-đồ-án-defense-faq)

---

## 🧠 1. Giới thiệu tổng quan & Phương pháp Second Brain

Trong kỷ nguyên bùng nổ thông tin và sự hỗ trợ mạnh mẽ của các công cụ lập trình tự động, thách thức lớn nhất của một kỹ sư phần mềm không còn là việc ghi nhớ cú pháp lệnh, mà là khả năng **tổ chức, kết nối và tái cấu trúc tri thức**. Phương pháp **Second Brain** xây dựng trên nền tảng **Zettelkasten** chia tri thức thành 3 cấp độ:

* **Fleeting Notes (Ghi chú tức thời):** Ý tưởng lóe lên trong giờ học lý thuyết, bug bất ngờ gặp phải khi build trên Windows.
* **Literature Notes (Ghi chú tài liệu):** Tóm tắt các điều khoản quy định từ cẩm nang sinh viên, slide bài giảng môn PRM.
* **Permanent Notes (Ghi chú vĩnh cửu / Nguyên tử):** Những nguyên lý thiết kế hệ thống, mô hình kiến trúc có thể tái sử dụng qua nhiều kỳ học từ PRN, SWD cho tới đồ án SWP490.

```text
[ Dữ liệu thô từ giảng đường ]
               │
               ▼
      ( Fleeting Notes ) ────► [ Sàng lọc & Đúc kết ]
                                      │
                                      ▼
                             ( Literature Notes )
                                      │
                                      ▼
                        [[ PERMANENT KNOWLEDGE GRAPH ]]
                                ┌─────┴─────┐
                                ▼           ▼
                           [PRM392]    [SWP490]
🔄 2. Vòng đời ứng dụng & Quản trị luồng thực thi (System Lifecycle)Mỗi nền tảng (Desktop Windows, Android, iOS) đều sở hữu hệ thống quản lý vòng đời tiến trình riêng biệt. Sự thiếu hiểu biết về vòng đời tiến trình là nguyên nhân trực tiếp dẫn đến rò rỉ tài nguyên bộ nhớ (Memory Leak), xung đột luồng và hiện tượng treo giao diện người dùng (UI Freezing).2.1. Chi tiết các giai đoạn thực thiGiai đoạn Khởi tạo (Initialization Phase):Nạp tệp cấu hình môi trường runtime.Thiết lập hệ thống Service Locator hoặc Dependency Injection (GetIt, Provider).Khởi chạy kết nối Database cục bộ (SQLite/Hive) hoặc mở kênh File Stream.Giai đoạn Hoạt động Tích cực (Active / Foreground Phase):Giao diện người dùng được dựng thành cây Widget/View hoàn chỉnh.Lắng nghe các luồng sự kiện I/O, thao tác chuột, bàn phím hoặc kết nối WebSocket.Giai đoạn Tạm dừng / Gián đoạn (Paused / Background Phase):Lưu trữ các trạng thái biểu mẫu chưa hoàn tất (Form Draft).Hủy các tác vụ chạy định kỳ tiêu tốn chu kỳ CPU (như Timer.periodic, GPS polling).Giai đoạn Hủy diệt (Disposal / Destruction Phase):Đóng toàn bộ các cổng Controller (TextEditingController, StreamController).Giải phóng bộ nhớ đệm hình ảnh và giải phóng handle file hệ thống.📐 3. Kiến trúc phân lớp chuẩn mực (Clean Architecture & SOLID)Nguyên lý kiến trúc phần mềm cốt lõi được áp dụng xuyên suốt các đồ án FPTU là đảm bảo Tính độc lập của logic nghiệp vụ (Business Logic Independence) đối với Framework và Giao diện người dùng.Plaintext+-------------------------------------------------------------------------+
|                        PRESENTATION LAYER                               |
|  - UI Components: Views, Widgets, Windows Shell                         |
|  - State Holders: BLoC, Cubit, ChangeNotifier, Controllers              |
+------------------------------------+------------------------------------+
                                     │ Phụ thuộc một chiều (Calls)
                                     ▼
+-------------------------------------------------------------------------+
|                           DOMAIN LAYER                                  |
|  - Business Entities: Plain Objects / Models cốt lõi                   |
|  - Use Cases / Interactors: Thực thi logic nghiệp vụ cụ thể             |
|  - Repository Interfaces: Hợp đồng trừu tượng (Abstract Contracts)     |
+------------------------------------+------------------------------------+
                                     ▲ Hiện thực hóa (Implements)
                                     │ 
+------------------------------------+------------------------------------+
|                            DATA LAYER                                   |
|  - Repository Implementations: Cầu nối dữ liệu                          |
|  - Data Sources:                                                        |
|      + Local: File System (Obsidian Vault I/O), Shared Preferences      |
|      + Remote: REST API Client (Gemini AI Service, Firebase)            |
+-------------------------------------------------------------------------+
3.1. Đối chiếu 5 nguyên lý SOLID trong Flutter DesktopS (Single Responsibility Principle): Một Widget chỉ đảm nhận việc hiển thị; toàn bộ logic đọc file .md phải đẩy sang FileService.O (Open/Closed Principle): Dễ dàng mở rộng thêm trình đọc định dạng .adoc hoặc .txt mà không phải sửa đổi cấu trúc hiển thị Markdown hiện tại.L (Liskov Substitution Principle): Các lớp Data Source cụ thể phải thay thế hoàn toàn được cho interface trừu tượng mà không làm sụp đổ hệ thống.I (Interface Segregation Principle): Chia nhỏ các interface: không gộp chung interface vừa đọc file vừa gọi API AI vào làm một.D (Dependency Inversion Principle): Presentation Layer phụ thuộc vào abstraction của Domain Layer, không phụ thuộc trực tiếp vào tầng Data I/O.📊 4. So sánh chuyên sâu các giải pháp Quản lý Trạng thái (State Management)Dưới đây là bảng đánh giá định lượng các giải pháp quản lý trạng thái phổ biến khi xây dựng ứng dụng máy tính đa bảng (Multi-panel Desktop App):Tiêu chí so sánhsetState() mặc địnhProvider / ChangeNotifierRiverpodBLoC / CubitĐường cong học tậpRất thấpThấpTrung bìnhCaoKhối lượng BoilerplateKhông đáng kểThấpRất ítNhiềuKhả năng Test (Unit Test)Cực kỳ khóTrung bìnhRất tốtXuất sắcTách biệt Logic và UITrộn lẫn hoàn toànKhá tốtTuyệt vờiTuyệt đốiPhù hợp ứng dụng Desktop đa cột❌ Dễ lag giao diện⚠️ Tốt cho app vừa✅ Rất linh hoạt✅ Hoàn hảo cho EnterpriseKhuyên dùng tại FPTUChỉ dùng bài tập trên lớpPhù hợp Lab 1 & Lab 2Dành cho ai thích FunctionalBắt buộc cho Đồ án Capstone📝 5. Quy chuẩn 7 Báo cáo Kỹ thuật Đồ án Tốt nghiệp (SWP490 CPro Standards)Căn cứ theo tài liệu hướng dẫn sinh viên làm đồ án tốt nghiệp CPro_StudentGuide_SWP490.pdf và bộ biểu mẫu kỹ thuật, quy trình phát triển phần mềm được chuẩn hóa thành 7 cột mốc báo cáo bắt buộc:   5.1. Bảng phân rã báo cáo chi tiếtReport 1 - Project Introduction: Định hình bài toán, phân tích tính khả thi, phân tích các đối thủ cạnh tranh trên thị trường và xác định đối tượng thụ hưởng.   Report 2 - Project Management Plan: Xây dựng cấu trúc phân rã công việc (WBS), thiết lập biểu đồ Gantt, phân định ma trận RACI và kế hoạch quản trị rủi ro.   Report 3 - Software Requirement Specification (SRS): Đặc tả ca sử dụng (Use Case Specifications), xây dựng sơ đồ UCD, ma trận truy vết yêu cầu (Traceability Matrix) và các yêu cầu phi chức năng (NFR) khắt khe.   Report 4 - Software Design Document (SDD): Bản vẽ chi tiết kiến trúc hệ thống (Layered/Microservices), thiết kế sơ đồ lớp (Class Diagram), sơ đồ tuần tự (Sequence Diagram) và sơ đồ quan hệ thực thể (ERD).   Report 5 - Test Documentation & Results: Kế hoạch kiểm thử (Test Plan), bảng ma trận Test Cases, kết quả Unit Test, Integration Test và biên bản kiểm thử chấp nhận người dùng (UAT).   Report 6 - User Guides & Deployment Manual: Hướng dẫn cấu hình môi trường, tài liệu cài đặt hệ thống và cẩm nang hướng dẫn thao tác dành cho người dùng cuối.   Report 7 - Final Project Report: Tổng hợp độ đo phần mềm (Metrics), tự kiểm điểm tiến độ thực tế so với kế hoạch ban đầu, đánh giá thiếu sót và định hướng phát triển trong tương lai.   💻 6. Hiện thực hóa mã nguồn mẫu: Xử lý I/O & Bắt lỗi an toànDưới đây là module hoàn chỉnh triển khai mẫu thiết kế Repository Pattern nhằm bảo đảm việc đọc thư mục Vault Obsidian trên hệ điều hành Windows diễn ra an toàn, không phong tỏa luồng giao diện chính:Dartimport 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Mô hình đại diện cho một ghi chú trong Obsidian Vault
class NoteFileEntity {
  final String fileName;
  final String fullPath;
  final int byteSize;
  final DateTime lastModified;
  final String content;

  const NoteFileEntity({
    required this.fileName,
    required this.fullPath,
    required this.byteSize,
    required this.lastModified,
    this.content = '',
  });

  NoteFileEntity copyWith({String? content}) {
    return NoteFileEntity(
      fileName: fileName,
      fullPath: fullPath,
      byteSize: byteSize,
      lastModified: lastModified,
      content: content ?? this.content,
    );
  }
}

/// Abstract contract tuân thủ nguyên lý Dependency Inversion (SOLID)
abstract class IVaultRepository {
  Future<List<NoteFileEntity>> scanMarkdownFiles(String directoryPath);
  Future<String> readNoteAsync(String filePath);
  Future<void> writeNoteAsync(String filePath, String newContent);
}

/// Hiện thực hóa việc truy xuất tệp cục bộ trên Windows
class LocalVaultRepository implements IVaultRepository {
  const LocalVaultRepository();

  @override
  Future<List<NoteFileEntity>> scanMarkdownFiles(String directoryPath) async {
    final rootDir = Directory(directoryPath);
    if (!await rootDir.exists()) {
      throw FileSystemException("Thư mục Vault không tồn tại", directoryPath);
    }

    final List<NoteFileEntity> collectedFiles = [];

    try {
      // Quét đệ quy toàn bộ thư mục con bên trong Vault
      final List<FileSystemEntity> entities = await rootDir.list(
        recursive: true,
        followLinks: false,
      ).toList();

      for (final entity in entities) {
        if (entity is File && p.extension(entity.path).toLowerCase() == '.md') {
          final stat = await entity.stat();
          collectedFiles.add(
            NoteFileEntity(
              fileName: p.basename(entity.path),
              fullPath: entity.path,
              byteSize: stat.size,
              lastModified: stat.modified,
            ),
          );
        }
      }

      // Sắp xếp theo tên A-Z
      collectedFiles.sort((a, b) => a.fileName.compareTo(b.fileName));
      return collectedFiles;
    } catch (e, stackTrace) {
      debugPrint("Chi tiết lỗi I/O khi quét Vault: $e\n$stackTrace");
      rethrow;
    }
  }

  @override
  Future<String> readNoteAsync(String filePath) async {
    final targetFile = File(filePath);
    if (!await targetFile.exists()) {
      throw FileNotFoundException("Không tìm thấy tệp tin: $filePath");
    }
    // Đọc bất đồng bộ bằng chuẩn UTF-8
    return await targetFile.readAsString();
  }

  @override
  Future<void> writeNoteAsync(String filePath, String newContent) async {
    final targetFile = File(filePath);
    // Ghi đè tệp tin và đẩy bộ đệm ngay lập tức xuống đĩa cứng (flush: true)
    await targetFile.writeAsString(newContent, flush: true);
  }
}

class FileNotFoundException implements Exception {
  final String message;
  const FileNotFoundException(this.message);

  @override
  String toString() => "FileNotFoundException: $message";
}
✅ 7. Bảng kiểm định chất lượng mã nguồn (Code Quality Checklist)Trước khi đem sản phẩm ra bảo vệ trước hội đồng giảng viên, toàn bộ mã nguồn phải vượt qua các tiêu chí kiểm định nghiêm ngặt sau:   [ ] Linter Check: Chạy lệnh flutter analyze và đạt kết quả No issues found!.[ ] Format Rules: Đã chuẩn hóa toàn bộ cấu trúc file bằng lệnh dart format ..[ ] Constructor Optimization: Sử dụng từ khóa const tại mọi vị trí Widget bất biến để giảm thiểu chi phí dựng khung hình.[ ] Memory Management: Tất cả các ScrollController, TextEditingController đều được giải phóng bằng hàm dispose().[ ] Thread Safety: Tuyệt đối không gọi các phương thức I/O đồng bộ như readAsStringSync() hay writeFileSync() trên Main Thread.[ ] Exception Handling: Mọi thao tác chọn file, gọi API hoặc render nội dung đều được bọc trong các khối try...catch đầy đủ.[ ] Git Synchronization: Tất cả máy tính của các thành viên đều đồng bộ commit mới nhất, build và chạy được độc lập trên máy thật.   ❓ 8. Bộ câu hỏi phản biện & Vấn đáp bảo vệ đồ án (Defense FAQ)Câu hỏi 1: Ứng dụng Desktop chạy Flutter khác gì so với Obsidian viết bằng Electron?Trả lời gợi ý: Obsidian chạy trên nền tảng Electron, thực chất là một trình duyệt Chromium đóng gói cùng môi trường Node.js nên chiếm dụng RAM đáng kể. Trong khi đó, Flutter Desktop biên dịch mã nguồn Dart trực tiếp ra mã máy nhị phân bản địa (Native x64 Machine Code) thông qua engine đồ họa C++, mang lại tốc độ khởi động nhanh hơn, chiếm ít tài nguyên hệ thống hơn và tối ưu hóa việc vẽ giao diện trực tiếp trên phần cứng.Câu hỏi 2: Tại sao ứng dụng của bạn không lưu trữ trực tiếp dữ liệu trên cơ sở dữ liệu quan hệ (SQL) mà lại chọn cấu trúc thư mục Markdown phẳng?Trả lời gợi ý: Đây chính là triết lý cốt lõi của phong trào Second Brain và phương pháp quản trị tri thức cá nhân (PKM). Lưu trữ bằng các tệp văn bản thuần (Plain-text .md) đảm bảo tính trường tồn của dữ liệu (Future-proof), không bị phụ thuộc vào một nhà cung cấp phần mềm duy nhất (Vendor Lock-in). Người dùng hoàn toàn có thể mở, chỉnh sửa tệp tin này bằng Notepad, VS Code hoặc bất kỳ công cụ nào khác mà không sợ mất mát dữ liệu khi hệ thống thay đổi.Câu hỏi 3: Làm thế nào để trợ lý AI trả lời chính xác dựa trên tài liệu mà không bị hiện tượng ảo giác (AI Hallucination)?Trả lời gợi ý: Hệ thống áp dụng kỹ thuật RAG (Retrieval-Augmented Generation) cục bộ: Khi người dùng đặt câu hỏi, hệ thống trích xuất nội dung văn bản của file .md hiện tại và gửi kèm vào Prompt dưới dạng ngữ cảnh bắt buộc (Context Window). Hệ thống chỉ thị rõ ràng cho AI chỉ được phép rút trích thông tin từ văn bản được cung cấp, nếu dữ liệu không đề cập thì thông báo không biết, từ đó triệt tiêu hoàn toàn hiện tượng tạo thông tin giả.