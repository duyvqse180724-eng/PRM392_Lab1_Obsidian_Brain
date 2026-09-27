import 'dart:math' as math;

import '../models/quiz_question.dart';

/// Ngân hàng câu hỏi tri thức chuyên sâu Kỹ thuật Phần mềm (FPTU SE & PRM392)
/// Đảm bảo tính nhất quán: 1 ĐÁP ÁN ĐÚNG DUY NHẤT, 3 phương án sai rõ ràng về mặt khái niệm
class QuizBank {
  static const List<_QuizTemplate> _allTemplates = [
    // ─── 1. Flutter Framework & Widgets ──────────────────────────────────────
    _QuizTemplate(
      question: 'Trong Flutter, phương thức nào của State object được gọi DUY NHẤT một lần khi State được đưa vào cây Widget?',
      correctAnswer: 'initState()',
      wrongAnswers: ['build()', 'dispose()', 'didUpdateWidget()'],
      explanation: 'initState() là phương thức khởi tạo vòng đời của State, chỉ được gọi đúng 1 lần duy nhất khi State được gắn vào cây Widget để nạp dữ liệu ban đầu.',
      keywords: [
        'flutter',
        'state',
        'initstate',
        'widget',
        'lifecycle',
        '02_flutter',
      ],
    ),
    _QuizTemplate(
      question: 'Điểm khác biệt cốt lõi nhất giữa StatefulWidget và StatelessWidget trong Flutter là gì?',
      correctAnswer: 'StatefulWidget có thể lưu giữ và cập nhật trạng thái dữ liệu thay đổi theo thời gian bằng setState().',
      wrongAnswers: [
        'StatelessWidget bắt buộc phải có phương thức initState().',
        'StatefulWidget không thể kết xuất lại (rebuild) giao diện khi dữ liệu thay đổi.',
        'StatelessWidget chỉ chạy được trên Android, không chạy được trên Windows Desktop.',
      ],
      explanation: 'StatefulWidget quản lý một đối tượng State riêng biệt, cho phép lưu trữ và thay đổi trạng thái giao diện một cách linh hoạt.',
      keywords: ['flutter', 'stateful', 'stateless', 'widget', '02_flutter'],
    ),
    _QuizTemplate(
      question: 'Tại sao trong Flutter lập trình viên PHẢI giải phóng các Controller (TextEditingController, AnimationController) trong hàm dispose()?',
      correctAnswer: 'Để tránh rò rỉ bộ nhớ (Memory Leak) và hủy các trình lắng nghe sự kiện khi widget bị xóa.',
      wrongAnswers: [
        'Để ép buộc ứng dụng tự động xóa file trên ổ cứng.',
        'Để ứng dụng tự khởi động lại từ màn hình Splash.',
        'Để tăng gấp đôi lượng RAM tiêu thụ của ứng dụng.',
      ],
      explanation: 'Các Controller và StreamSubscription giữ tham chiếu mạnh. Nếu không gọi dispose(), chúng sẽ tồn tại mãi trong RAM gây rò rỉ bộ nhớ nghiêm trọng.',
      keywords: [
        'lifecycle',
        'dispose',
        'android',
        'memory',
        '04_android',
        'controller',
      ],
    ),
    _QuizTemplate(
      question: 'Trên Android, khi một Activity bị che khuất một phần (như xuất hiện hộp thoại Dialog), callback nào sẽ được gọi?',
      correctAnswer: 'onPause()',
      wrongAnswers: ['onDestroy()', 'onCreate()', 'onRestart()'],
      explanation: 'Khi Activity mất tiêu điểm tương tác trực tiếp nhưng vẫn nhìn thấy một phần, hệ thống sẽ kích hoạt onPause() để tạm dừng các tác vụ nặng.',
      keywords: ['android', 'lifecycle', 'onpause', 'activity', '04_android'],
    ),

    // ─── 2. Clean Architecture & Design ──────────────────────────────────────
    _QuizTemplate(
      question: 'Trong mô hình Clean Architecture, phân tầng nào chứa các quy tắc nghiệp vụ cốt lõi (Business Rules & Use Cases) và KHÔNG phụ thuộc vào bất kỳ framework nào?',
      correctAnswer: 'Domain Layer',
      wrongAnswers: [
        'Presentation Layer (Tầng hiển thị giao diện)',
        'Data Layer (Tầng truy cập dữ liệu ngoại vi)',
        'Framework & Drivers Layer',
      ],
      explanation: 'Domain Layer là tầng trung tâm và độc lập nhất trong Clean Architecture, chứa Entities và Use Cases, hoàn toàn độc lập với UI hay Database.',
      keywords: [
        'clean',
        'architecture',
        'domain',
        'use case',
        '05_clean',
        'layer',
      ],
    ),
    _QuizTemplate(
      question: 'Quy tắc phụ thuộc (Dependency Rule) trong Clean Architecture quy định điều gì?',
      correctAnswer: 'Mã nguồn ở các tầng bên ngoài chỉ được phép phụ thuộc hướng vào các tầng bên trong.',
      wrongAnswers: [
        'Tầng Domain bên trong bắt buộc phải phụ thuộc vào giao diện Presentation Layer.',
        'Tất cả các tầng đều được phép gọi phụ thuộc vòng tròn (Circular Dependency) lẫn nhau.',
        'Tầng Data Layer không được phép triển khai các interface của Domain Layer.',
      ],
      explanation: 'Dependency Rule quy định mã nguồn chỉ được hướng vào trong: Presentation và Data Layer phụ thuộc vào Domain Layer; Domain Layer hoàn toàn độc lập.',
      keywords: ['clean', 'architecture', 'dependency', 'rule', '05_clean'],
    ),

    // ─── 3. SOLID Principles ─────────────────────────────────────────────────
    _QuizTemplate(
      question: 'Nguyên lý Single Responsibility Principle (SRP - chữ S trong SOLID) định nghĩa chuẩn xác điều gì?',
      correctAnswer: 'Một class hoặc module chỉ nên có duy nhất một lý do để thay đổi (đảm nhận một trách nhiệm duy nhất).',
      wrongAnswers: [
        'Mỗi class bắt buộc chỉ được phép chứa duy nhất 1 hàm (function).',
        'Tất cả các class trong project đều phải kế thừa từ cùng một class cha duy nhất.',
        'Cho phép sửa trực tiếp mã nguồn cũ bất cứ khi nào cần thêm tính năng mới.',
      ],
      explanation: 'SRP phát biểu: "A class should have one, and only one, reason to change", nhằm đảm bảo tính đơn nhiệm và dễ bảo trì cho mã nguồn.',
      keywords: [
        'solid',
        'srp',
        'single',
        'responsibility',
        '10_solid',
        'principle',
      ],
    ),
    _QuizTemplate(
      question: 'Nguyên lý Dependency Inversion Principle (DIP - chữ D trong SOLID) khuyến nghị điều gì?',
      correctAnswer: 'Các module cấp cao không nên phụ thuộc vào module cấp thấp; cả hai nên phụ thuộc vào Abstraction (Interface).',
      wrongAnswers: [
        'Module cấp cao phải khởi tạo trực tiếp instance cụ thể của module cấp thấp bằng từ khóa new.',
        'Tuyệt đối không được phép sử dụng Interface hoặc Abstract Class trong toàn bộ hệ thống.',
        'Đảo ngược toàn bộ logic điều kiện từ if sang while để tăng tốc độ thực thi.',
      ],
      explanation: 'DIP giúp giảm thiểu sự phụ thuộc chặt (tight coupling) bằng cách đưa Interface vào giữa: Business Logic gọi Interface, Data Source triển khai Interface đó.',
      keywords: [
        'solid',
        'dip',
        'dependency',
        'inversion',
        '10_solid',
        'interface',
      ],
    ),

    // ─── 4. Dart & OOP ───────────────────────────────────────────────────────
    _QuizTemplate(
      question: 'Trong ngôn ngữ lập trình Dart với Null Safety, toán tử nào được đặt sau kiểu dữ liệu để khai báo biến có thể nhận giá trị null?',
      correctAnswer: 'Toán tử chấm hỏi ? (Ví dụ: String?)',
      wrongAnswers: [
        'Toán tử chấm than ! (Ví dụ: String!)',
        'Từ khóa dynamic bắt buộc cho mọi biến',
        'Toán tử gạch dưới _ (Ví dụ: _String)',
      ],
      explanation: 'Trong Dart Null Safety, việc thêm ? sau kiểu dữ liệu (như int?, String?) chỉ định biến đó là nullable, cho phép chứa giá trị null an toàn.',
      keywords: ['dart', 'null', 'safety', '03_dart', 'programming'],
    ),
    _QuizTemplate(
      question: 'Tính kế thừa (Inheritance) trong Lập trình hướng đối tượng (OOP) mang lại lợi ích chính nào?',
      correctAnswer: 'Cho phép lớp con tái sử dụng thuộc tính, phương thức của lớp cha và mở rộng tính năng mà không cần viết lại.',
      wrongAnswers: [
        'Ẩn hoàn toàn tất cả mã nguồn không cho các lập trình viên khác xem.',
        'Bắt buộc tất cả các đối tượng phải chia sẻ cùng một địa chỉ ô nhớ RAM.',
        'Ngăn chặn việc mở rộng hoặc ghi đè hành vi của phương thức cũ.',
      ],
      explanation: 'Kế thừa giúp lớp con kế thừa lại các trường và phương thức từ lớp cha, tối ưu hóa khả năng tái sử dụng mã nguồn theo nguyên tắc DRY.',
      keywords: ['oop', 'object', 'oriented', 'inheritance', '09_object'],
    ),

    // ─── 5. State Management ─────────────────────────────────────────────────
    _QuizTemplate(
      question: 'Lợi ích lớn nhất khi sử dụng giải pháp State Management (như Provider/Bloc) trong Flutter là gì?',
      correctAnswer: 'Tách biệt UI khỏi Business Logic và chia sẻ dữ liệu xuyên suốt cây widget mà không cần truyền prop thủ công.',
      wrongAnswers: [
        'Bắt buộc toàn bộ ứng dụng chỉ được chạy trên duy nhất 1 luồng đơn.',
        'Loại bỏ hoàn toàn sự cần thiết của hàm main() trong ứng dụng.',
        'Tự động dịch mã Dart sang mã nguồn Java mà không cần kiểm thử.',
      ],
      explanation: 'State Management giúp chia sẻ trạng thái cho nhiều màn hình cùng dùng mà không cần truyền prop qua nhiều tầng widget trung gian (tránh Prop Drilling).',
      keywords: ['state', 'management', 'provider', 'bloc', '06_state'],
    ),

    // ─── 6. REST API & Networking ────────────────────────────────────────────
    _QuizTemplate(
      question: 'Trong chuẩn RESTful API, phương thức HTTP nào được dùng để truy vấn đọc dữ liệu từ server mà không làm thay đổi trạng thái tài nguyên?',
      correctAnswer: 'Phương thức GET',
      wrongAnswers: [
        'Phương thức POST',
        'Phương thức DELETE',
        'Phương thức PATCH',
      ],
      explanation: 'Phương thức GET là phương thức an toàn và bất biến (Safe & Idempotent), dùng để truy vấn dữ liệu từ server mà không sinh tác dụng phụ.',
      keywords: ['api', 'rest', 'http', 'get', 'post', '07_rest'],
    ),

    // ─── 7. Testing & Quality ────────────────────────────────────────────────
    _QuizTemplate(
      question: 'Trong quy trình Test-Driven Development (TDD), thứ tự đúng của chu trình 3 bước cốt lõi là gì?',
      correctAnswer: '1. Viết test thất bại (Red) -> 2. Viết code để test vượt qua (Green) -> 3. Tối ưu hóa mã nguồn (Refactor).',
      wrongAnswers: [
        '1. Viết code hoàn chỉnh -> 2. Viết test -> 3. Bỏ qua nếu có lỗi.',
        '1. Refactor code cũ -> 2. Xóa các bài test -> 3. Đổi màu nút sang đỏ.',
        '1. Viết test luôn pass -> 2. Không cần viết code thực tế -> 3. Kết thúc.',
      ],
      explanation: 'TDD thúc đẩy thiết kế module tốt bằng cách viết test trước (Red), sau đó viết code tối thiểu để pass (Green), rồi dọn dẹp cấu trúc (Refactor).',
      keywords: ['test', 'testing', 'unit', 'tdd', '11_unit'],
    ),

    // ─── 8. Database & Local Storage ─────────────────────────────────────────
    _QuizTemplate(
      question: 'Hệ quản trị cơ sở dữ liệu SQLite thường được sử dụng trong ứng dụng di động dưới hình thức nào?',
      correctAnswer: 'Hệ CSDL nhúng không cần server (Serverless Embedded Database), lưu toàn bộ dữ liệu trong một tệp tin cục bộ.',
      wrongAnswers: [
        'Một máy chủ dịch vụ đám mây khổng lồ đòi hỏi kết nối mạng 24/7.',
        'Một hệ cơ sở dữ liệu đồ thị phân tán chạy trên nhiều cụm máy chủ.',
        'Một phần mềm độc lập bắt buộc người dùng cài đặt riêng bằng file .exe.',
      ],
      explanation: 'SQLite là hệ CSDL nhúng serverless, đọc ghi trực tiếp lên một file trên đĩa cục bộ, cực kỳ nhẹ và phù hợp hoàn hảo cho ứng dụng di động.',
      keywords: ['database', 'sqlite', 'sql', 'db', '13_database', 'storage'],
    ),

    // ─── 9. Git & DevOps ─────────────────────────────────────────────────────
    _QuizTemplate(
      question: 'Khái niệm Continuous Integration (CI) trong quy trình DevOps mang ý nghĩa cốt lõi nào?',
      correctAnswer: 'Tự động hóa việc kiểm tra, build và chạy kiểm thử mỗi khi lập trình viên tích hợp mã nguồn mới vào kho chứa chung.',
      wrongAnswers: [
        'Viết code liên tục 24 giờ không nghỉ của các kỹ sư phần mềm.',
        'Xóa toàn bộ kho lưu trữ mã nguồn sau mỗi tuần làm việc.',
        'Ngăn cấm lập trình viên commit mã nguồn lên GitHub.',
      ],
      explanation: 'CI giúp phát hiện lỗi xung đột và lỗi logic sớm thông qua các kịch bản chạy tự động (automated test runner, linter) ngay khi có code mới.',
      keywords: ['git', 'devops', 'ci', 'cd', '14_git', '15_devops'],
    ),

    // ─── 10. Obsidian & Knowledge Graph ──────────────────────────────────────
    _QuizTemplate(
      question: 'Cú pháp liên kết hai chiều (Bi-directional Link / Wikilink) tiêu chuẩn được sử dụng trong Obsidian là gì?',
      correctAnswer: '[[Tên_Ghi_Chú]]',
      wrongAnswers: ['{{Tên_Ghi_Chú}}', '<<Tên_Ghi_Chú>>', '((Tên_Ghi_Chú))'],
      explanation: 'Cú pháp [[...]] (Double Square Brackets) là chuẩn Wikilink kinh điển được Obsidian dùng để tạo kết nối tự động giữa các tệp ghi chú Markdown.',
      keywords: ['obsidian', 'graph', 'wikilink', 'link', 'brain'],
    ),
    _QuizTemplate(
      question: 'Tác dụng lớn nhất của sơ đồ đồ thị tri thức (Knowledge Graph View) trong ứng dụng Second Brain là gì?',
      correctAnswer: 'Trực quan hóa mạng lưới liên kết giữa các bài học, giúp phát hiện các chủ đề cốt lõi và mối liên hệ kiến thức.',
      wrongAnswers: [
        'Thay thế hoàn toàn bộ nhớ RAM của máy tính để bàn.',
        'Tự động xóa các file ghi chú cũ không có liên kết.',
        'Biến toàn bộ tài liệu thành các tập tin hình ảnh không thể chỉnh sửa.',
      ],
      explanation: 'Knowledge Graph mô phỏng mạng nơ-ron liên kết, hiển thị các nốt (bài học) và cạnh nối (liên kết), giúp nhìn thấy cấu trúc tri thức tổng quan.',
      keywords: ['graph', 'knowledge', 'network', 'obsidian', 'brain'],
    ),

    // ─── 11. Design Patterns ─────────────────────────────────────────────────
    _QuizTemplate(
      question: 'Mẫu thiết kế Singleton Pattern trong kỹ thuật phần mềm nhằm giải quyết bài toán nào?',
      correctAnswer: 'Đảm bảo một class chỉ có duy nhất một instance hoạt động và cung cấp một điểm truy cập toàn cục tới nó.',
      wrongAnswers: [
        'Tạo ra hàng nghìn bản sao ngẫu nhiên của một đối tượng trong bộ nhớ.',
        'Bắt buộc tất cả các class phải có ít nhất 10 phương thức con.',
        'Chuyển đổi kiểu dữ liệu int thành String trong thời gian thực.',
      ],
      explanation: 'Singleton Pattern giới hạn việc khởi tạo của một class chỉ ở duy nhất 1 instance, rất hữu ích cho các đối tượng chia sẻ chung như Database Helper hoặc Logger.',
      keywords: ['design', 'pattern', 'singleton', '12_design'],
    ),
  ];

  /// Sinh danh sách câu hỏi phù hợp nhất với tài liệu đang mở
  static List<QuizQuestion> generateQuestions({
    required String currentDocTitle,
    required String currentDocContent,
    required int seedOffset,
  }) {
    final titleLower = currentDocTitle.toLowerCase();
    final contentLower = currentDocContent.toLowerCase();

    // Chấm điểm độ liên quan của từng câu hỏi với tài liệu
    final scored = _allTemplates.map((t) {
      var score = 0;
      for (final kw in t.keywords) {
        if (titleLower.contains(kw)) score += 5;
        if (contentLower.contains(kw)) score += 2;
      }
      return MapEntry(t, score);
    }).toList();

    // Sắp xếp câu hỏi có điểm cao nhất lên trước
    scored.sort((a, b) => b.value.compareTo(a.value));

    // Lấy top ứng viên có liên quan
    final topCandidates = scored.take(6).map((e) => e.key).toList();
    final rng = math.Random(seedOffset);
    topCandidates.shuffle(rng);

    final selected = topCandidates.take(3).toList();

    // Dự phòng nếu không đủ 3 câu
    var fallbackIdx = 0;
    while (selected.length < 3 && fallbackIdx < _allTemplates.length) {
      final item = _allTemplates[fallbackIdx];
      if (!selected.contains(item)) {
        selected.add(item);
      }
      fallbackIdx++;
    }

    // Xây dựng List<QuizQuestion> với 1 ĐÁP ÁN ĐÚNG CỐ ĐỊNH, shuffle ngẫu nhiên vị trí A, B, C, D
    final List<QuizQuestion> result = [];
    for (var i = 0; i < selected.length; i++) {
      final t = selected[i];
      final options = [t.correctAnswer, ...t.wrongAnswers];

      // Đảo thứ tự các phương án A, B, C, D
      final optRng = math.Random(seedOffset + i * 37);
      options.shuffle(optRng);

      final correctIndex = options.indexOf(t.correctAnswer);

      result.add(
        QuizQuestion(
          question: t.question,
          options: options,
          correctIndex: correctIndex >= 0 ? correctIndex : 0,
          explanation: t.explanation,
        ),
      );
    }

    return result;
  }
}

class _QuizTemplate {
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation;
  final List<String> keywords;

  const _QuizTemplate({
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.explanation,
    required this.keywords,
  });
}
