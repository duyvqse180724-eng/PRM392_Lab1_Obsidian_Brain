import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/quiz_question.dart';
import 'quiz_bank.dart';

/// Dịch vụ AI Copilot hỗ trợ học tập tri thức SE FPTU
class AIService {
  static String? _geminiApiKey;

  const AIService();

  /// Kiểm tra chuỗi key có phải là hợp lệ không (không rỗng, không phải placeholder)
  static bool _isValidKey(String? key) {
    if (key == null) return false;
    final trimmed = key.trim();
    return trimmed.isNotEmpty &&
        trimmed != 'your_gemini_api_key_here' &&
        !trimmed.startsWith('YOUR_');
  }

  /// Đọc hoặc cập nhật Gemini API Key
  /// Ưu tiên key do người dùng cấu hình runtime, nếu không thì lấy từ file .env
  static String? get apiKey {
    if (_isValidKey(_geminiApiKey)) {
      return _geminiApiKey!.trim();
    }
    if (dotenv.isInitialized) {
      final envKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (_isValidKey(envKey)) {
        return envKey.trim();
      }
    }
    return null;
  }

  static set apiKey(String? key) => _geminiApiKey = key?.trim();

  /// Kiểm tra đã cấu hình API Key hợp lệ hay chưa
  static bool get hasApiKey => _isValidKey(apiKey);

  /// Hỏi đáp AI theo ngữ cảnh tài liệu đang mở với lịch sử hội thoại
  Future<String> askAI({
    required String currentDocTitle,
    required String currentDocContent,
    required String userPrompt,
    required List<Map<String, String>> history,
  }) async {
    if (hasApiKey) {
      try {
        final systemInstruction =
            'Bạn là FPTU SE AI Study Buddy. Bạn PHẢI trả lời dựa CHÍNH XÁC vào phân cảnh/nội dung của tài liệu [$currentDocTitle] đang được cung cấp: [$currentDocContent]. '
            'Phân tích ngữ cảnh trực tiếp để trả lời đúng trọng tâm câu hỏi của sinh viên. '
            'TUYỆT ĐỐI không trả lời bằng văn mẫu chung chung. '
            'Nếu tài liệu không chứa thông tin đó, hãy nói rõ tài liệu này không đề cập và giải thích ngắn gọn dựa trên kiến thức SE.';

        final List<Map<String, dynamic>> contents = [];

        // Thêm lịch sử hội thoại
        for (final msg in history) {
          final role = msg['role'] ?? 'user';
          final text = msg['text'] ?? '';
          if (text.isNotEmpty) {
            contents.add({
              'role': role,
              'parts': [
                {'text': text},
              ],
            });
          }
        }

        // Thêm câu hỏi hiện tại
        contents.add({
          'role': 'user',
          'parts': [
            {'text': userPrompt},
          ],
        });

        final response = await _callGeminiApi(
          contents: contents,
          systemInstruction: systemInstruction,
          temperature: 0.7,
        );
        if (response != null && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        debugPrint('Gemini askAI failed, falling back to smart mock: $e');
      }
    }

    // Fallback offline: phân tích ngữ cảnh từ nội dung file
    return _mockAnswerAI(
      currentDocTitle: currentDocTitle,
      currentDocContent: currentDocContent,
      userQuestion: userPrompt,
    );
  }

  /// Tóm tắt nhanh nội dung của file đang mở
  Future<String> summarize({
    required String currentDocTitle,
    required String currentDocContent,
  }) async {
    if (currentDocContent.trim().isEmpty) {
      return '⚠️ Ghi chú này hiện đang trống, vui lòng chọn hoặc nhập nội dung để tóm tắt.';
    }

    if (hasApiKey) {
      try {
        final prompt =
            'Bạn là trợ lý AI học tập ngành Kỹ thuật Phần mềm FPTU. Hãy tóm tắt tài liệu [$currentDocTitle] sau thành 3-4 điểm cốt lõi quan trọng nhất cho sinh viên ôn tập:\n---\n$currentDocContent\n---\nĐịnh dạng bằng Markdown đẹp mắt với các icon nổi bật.';
        final response = await _callGeminiApi(
          contents: [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          temperature: 0.6,
        );
        if (response != null && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        debugPrint('Gemini summarize failed, falling back to mock: $e');
      }
    }

    return _mockSummarize(currentDocTitle, currentDocContent);
  }

  /// Sinh câu hỏi Quiz động mỗi lần KHÁC NHAU với seedOffset
  Future<String> generateDynamicQuiz({
    required String currentDocTitle,
    required String currentDocContent,
    required int seedOffset,
  }) async {
    if (currentDocContent.trim().isEmpty) {
      return '⚠️ Tài liệu đang trống. Vui lòng mở một ghi chú có nội dung để tạo quiz.';
    }

    if (hasApiKey) {
      try {
        final prompt =
            'Bạn là trợ lý AI học tập FPTU. Dựa vào tài liệu [$currentDocTitle]:\n---\n$currentDocContent\n---\n'
            'Tạo CHÍNH XÁC 3 câu hỏi trắc nghiệm KHÁC NHAU (seed: $seedOffset) dựa vào các chi tiết, ví dụ, hoặc ca sử dụng CỤ THỂ trong tài liệu này.\n'
            'Yêu cầu định dạng CHÍNH XÁC cho mỗi câu:\n'
            '**Câu N:** [Nội dung câu hỏi]\n'
            'A. [Đáp án A]\nB. [Đáp án B]\nC. [Đáp án C]\nD. [Đáp án D]\n'
            '> 🎯 **Đáp án:** [Chữ cái đúng]\n'
            '> 💡 **Giải thích:** [Giải thích dựa vào tài liệu]\n\n'
            'TUYỆT ĐỐI không dùng câu hỏi chung chung. Hãy đào sâu vào các chi tiết ĐẶC THÙ của bài này.';

        final response = await _callGeminiApi(
          contents: [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          temperature: 0.9,
          seedOffset: seedOffset,
        );
        if (response != null && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        debugPrint('Gemini generateDynamicQuiz failed, using offline: $e');
      }
    }

    // Fallback offline: trích xuất động từ nội dung file, dùng seedOffset để random
    return _offlineGenerateQuiz(
      currentDocTitle: currentDocTitle,
      currentDocContent: currentDocContent,
      seedOffset: seedOffset,
    );
  }

  /// Sinh danh sách câu hỏi trắc nghiệm tương tác (Interactive Quiz)
  /// Mỗi câu gồm câu hỏi, 4 phương án, chỉ số đáp án đúng và lời giải thích chi tiết
  Future<List<QuizQuestion>> generateQuizQuestions({
    required String currentDocTitle,
    required String currentDocContent,
    required int seedOffset,
  }) async {
    if (currentDocContent.trim().isEmpty) {
      return const [];
    }

    if (hasApiKey) {
      try {
        final prompt =
            'Bạn là chuyên gia khảo thí và trợ lý AI học tập ngành Kỹ thuật Phần mềm FPTU.\n'
            'Dựa CHÍNH XÁC vào nội dung tài liệu [$currentDocTitle] sau:\n---\n$currentDocContent\n---\n'
            'Hãy biên soạn đúng 3 câu hỏi trắc nghiệm ôn tập (seed: $seedOffset) với độ phân hóa tốt, đào sâu vào chi tiết trong bài.\n'
            'BẮT BUỘC chỉ trả về DUY NHẤT một mảng JSON thuần túy (không kèm lời chào hay giải thích ngoài JSON) theo cấu trúc sau:\n'
            '[\n'
            '  {\n'
            '    "question": "Nội dung câu hỏi trắc nghiệm?",\n'
            '    "options": ["Nội dung đáp án A", "Nội dung đáp án B", "Nội dung đáp án C", "Nội dung đáp án D"],\n'
            '    "correctIndex": 0,\n'
            '    "explanation": "Giải thích chi tiết vì sao đáp án này đúng dựa theo tài liệu..."\n'
            '  }\n'
            ']\n'
            'Lưu ý quan trọng: "correctIndex" là số nguyên từ 0 đến 3 (tương ứng với A=0, B=1, C=2, D=3). "options" phải có đúng 4 phần tử.';

        final response = await _callGeminiApi(
          contents: [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          temperature: 0.8,
          seedOffset: seedOffset,
        );

        if (response != null && response.isNotEmpty) {
          final questions = _parseQuizQuestionsFromJson(response);
          if (questions.isNotEmpty) {
            return questions;
          }
        }
      } catch (e) {
        debugPrint(
          'Gemini generateQuizQuestions lỗi, chuyển sang fallback: $e',
        );
      }
    }

    // Fallback Offline: trích xuất câu hỏi từ tiêu đề và nội dung tài liệu
    return _offlineGenerateQuizQuestions(
      currentDocTitle: currentDocTitle,
      currentDocContent: currentDocContent,
      seedOffset: seedOffset,
    );
  }

  // ─── Private: Gọi Gemini REST API ─────────────────────────────────────────

  Future<String?> _callGeminiApi({
    required List<Map<String, dynamic>> contents,
    String? systemInstruction,
    double temperature = 0.7,
    int? seedOffset,
  }) async {
    final key = apiKey;
    if (key == null || key.isEmpty) return null;

    final isBearerToken = key.startsWith('AQ.') || key.startsWith('ya29.');

    final candidateModels = [
      'gemini-1.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-2.0-flash',
      'gemini-pro',
    ];

    for (final model in candidateModels) {
      try {
        final url = isBearerToken
            ? Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
              )
            : Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key',
              );

        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (isBearerToken) 'Authorization': 'Bearer $key',
          if (!isBearerToken) 'x-goog-api-key': key,
        };

        final body = <String, dynamic>{
          'contents': contents,
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': 1500,
            if (seedOffset != null) 'seed': seedOffset % 2147483647,
          },
        };

        if (systemInstruction != null && systemInstruction.isNotEmpty) {
          body['systemInstruction'] = {
            'parts': [
              {'text': systemInstruction},
            ],
          };
        }

        final response = await http
            .post(url, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              return parts[0]['text'] as String?;
            }
          }
        } else if (response.statusCode == 404) {
          debugPrint('Model $model 404, thử model tiếp theo...');
          continue;
        } else {
          debugPrint(
            'Gemini API error ($model) ${response.statusCode}: ${response.body}',
          );
          break;
        }
      } catch (e) {
        debugPrint('Gemini API call failed for $model: $e');
      }
    }
    return null;
  }

  // ─── Private: Offline Fallback ────────────────────────────────────────────

  /// Sinh quiz offline từ nội dung file (không bao giờ crash)
  String _offlineGenerateQuiz({
    required String currentDocTitle,
    required String currentDocContent,
    required int seedOffset,
  }) {
    try {
      final rng = math.Random(seedOffset);
      final buffer = StringBuffer();
      buffer.writeln(
        '### 📝 Quiz Nhanh: $currentDocTitle\n*(Chế độ Offline - Trích xuất từ tài liệu)*\n',
      );

      // 1. Thu thập headings (##)
      final headingRegex = RegExp(r'^##\s+(.+)$', multiLine: true);
      final headings = headingRegex
          .allMatches(currentDocContent)
          .map((m) => m.group(1)?.trim() ?? '')
          .where((h) => h.isNotEmpty)
          .toList();

      // 2. Thu thập các đoạn văn dài (>40 chars)
      final paragraphs = currentDocContent
          .split('\n')
          .map((l) => l.trim())
          .where(
            (l) =>
                l.isNotEmpty &&
                !l.startsWith('#') &&
                !l.startsWith('```') &&
                !l.startsWith('|') &&
                l.length > 40,
          )
          .toList();

      if (paragraphs.isEmpty && headings.isEmpty) {
        return '⚠️ Tài liệu quá ngắn để tạo câu hỏi. Hãy thêm nội dung vào ghi chú!';
      }

      // Shuffle để mỗi lần khác nhau
      paragraphs.shuffle(rng);
      headings.shuffle(rng);

      int questionCount = 0;

      // Tạo câu hỏi từ headings
      if (headings.length >= 2) {
        final correctHeading = headings[0];
        final wrongHeadings = headings.sublist(1).take(3).toList();
        while (wrongHeadings.length < 3) {
          wrongHeadings.add('Không có mục này trong tài liệu');
        }
        wrongHeadings.shuffle(rng);
        final allOptions = [correctHeading, ...wrongHeadings];
        allOptions.shuffle(rng);
        final correctIndex = allOptions.indexOf(correctHeading);

        questionCount++;
        buffer.writeln(
          '**Câu $questionCount:** Đề mục nào sau đây có trong tài liệu "$currentDocTitle"?',
        );
        for (var i = 0; i < allOptions.length; i++) {
          final letter = String.fromCharCode(65 + i);
          buffer.writeln('$letter. ${allOptions[i]}');
        }
        buffer.writeln(
          '> 🎯 **Đáp án:** ${String.fromCharCode(65 + correctIndex)}',
        );
        buffer.writeln(
          '> 💡 **Giải thích:** Đây là một trong các mục chính được trình bày trong tài liệu.\n',
        );
      }

      // Tạo câu hỏi từ đoạn văn
      final usedParagraphs = paragraphs.take(4).toList();
      for (
        var idx = 0;
        idx < usedParagraphs.length && questionCount < 3;
        idx++
      ) {
        final para = usedParagraphs[idx];
        final cleanPara = para
            .replaceAll(RegExp(r'^[-*\d.]+\s*'), '')
            .replaceAll(RegExp(r'\*+'), '')
            .replaceAll(RegExp(r'`+'), '')
            .trim();

        if (cleanPara.length < 30) continue;

        final display = cleanPara.length > 80
            ? '${cleanPara.substring(0, 80)}...'
            : cleanPara;

        // Tìm các câu sai từ các đoạn khác
        final wrongOptions = paragraphs
            .where((p) => p != para && p.length > 20)
            .map((p) => p.replaceAll(RegExp(r'^[-*\d.]+\s*'), '').trim())
            .where((p) => p.isNotEmpty)
            .toList();
        wrongOptions.shuffle(rng);
        final wrongs = wrongOptions.take(3).toList();
        while (wrongs.length < 3) {
          wrongs.add('Không có trong tài liệu này');
        }

        final correctDisplay = display.length > 80
            ? '${display.substring(0, 80)}...'
            : display;
        final allOpts = [
          correctDisplay,
          ...wrongs.map((w) => w.length > 80 ? '${w.substring(0, 80)}...' : w),
        ];
        allOpts.shuffle(rng);
        final correctIdx = allOpts.indexOf(correctDisplay);
        final safeIdx = correctIdx < 0 ? 0 : correctIdx;

        questionCount++;
        buffer.writeln(
          '**Câu $questionCount:** Nhận định nào sau đây được nêu CHÍNH XÁC trong tài liệu "$currentDocTitle"?',
        );
        for (var i = 0; i < allOpts.length; i++) {
          final letter = String.fromCharCode(65 + i);
          buffer.writeln('$letter. ${allOpts[i]}');
        }
        buffer.writeln('> 🎯 **Đáp án:** ${String.fromCharCode(65 + safeIdx)}');
        buffer.writeln('> 💡 **Giải thích:** Trích từ tài liệu: "$display"\n');
      }

      if (questionCount == 0) {
        return '⚠️ Không thể tạo câu hỏi từ nội dung hiện tại. Hãy thêm thêm nội dung cho tài liệu.';
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Lỗi trong _offlineGenerateQuiz: $e');
      return '⚠️ Đã xảy ra lỗi khi tạo quiz offline. Vui lòng thử lại.';
    }
  }

  /// Trả lời câu hỏi offline, phân tích ngữ cảnh thực tế từ tài liệu
  String _mockAnswerAI({
    required String currentDocTitle,
    required String currentDocContent,
    required String userQuestion,
  }) {
    final q = userQuestion.toLowerCase().trim();

    // Tóm tắt qua ô chat
    if (q.contains('tóm tắt') ||
        q.contains('summary') ||
        q.contains('tổng quan')) {
      return _mockSummarize(currentDocTitle, currentDocContent);
    }

    // Tìm đoạn liên quan trong tài liệu
    if (currentDocContent.trim().isNotEmpty) {
      final relevantSection = _findRelevantSection(
        currentDocContent,
        userQuestion,
      );
      if (relevantSection != null && relevantSection.isNotEmpty) {
        return '### 🤖 Trả lời từ tài liệu: *$currentDocTitle*\n\n'
            '$relevantSection\n\n'
            '---\n*💡 Nhấn **🎲 Tạo Quiz mới** để ôn tập về nội dung này!*';
      }
    }

    // Phản hồi mặc định
    return '### 🤖 Về câu hỏi: "$userQuestion"\n\n'
        'Dựa trên tài liệu **$currentDocTitle** đang mở:\n\n'
        '- Tài liệu này không đề cập trực tiếp đến nội dung bạn hỏi.\n'
        '- Bạn có thể thử:\n'
        '  - *"Tóm tắt bài này"*\n'
        '  - *"Tạo câu hỏi ôn tập"*\n'
        '  - Hỏi về các đề mục cụ thể trong tài liệu.';
  }

  /// Tóm tắt mock thông minh từ tài liệu
  String _mockSummarize(String title, String content) {
    final lines = content.split('\n');
    final headings = lines
        .where((l) => l.trim().startsWith('#'))
        .map((l) => l.replaceAll(RegExp(r'^#+\s*'), '').trim())
        .where((h) => h.isNotEmpty)
        .take(5)
        .toList();

    final paragraphs = lines
        .map((l) => l.trim())
        .where(
          (l) =>
              l.isNotEmpty &&
              !l.startsWith('#') &&
              !l.startsWith('```') &&
              l.length > 50,
        )
        .take(3)
        .toList();

    final buffer = StringBuffer();
    buffer.writeln('### 📌 Tóm Tắt: *$title*\n');

    if (headings.isNotEmpty) {
      buffer.writeln('**📚 Các đề mục chính:**');
      for (final h in headings) {
        buffer.writeln('- $h');
      }
      buffer.writeln();
    }

    if (paragraphs.isNotEmpty) {
      buffer.writeln('**🔑 Nội dung cốt lõi:**');
      for (final p in paragraphs) {
        final display = p.length > 150 ? '${p.substring(0, 150)}...' : p;
        buffer.writeln('> $display');
      }
      buffer.writeln();
    }

    if (headings.isEmpty && paragraphs.isEmpty) {
      buffer.writeln(
        '_Tài liệu có ít nội dung. Hãy thêm nội dung để tóm tắt chính xác hơn._',
      );
    }

    buffer.writeln(
      '\n💡 *Cài đặt Gemini API Key để nhận tóm tắt AI thông minh hơn!*',
    );
    return buffer.toString();
  }

  /// Trích xuất đoạn văn liên quan nhất từ nội dung ghi chú
  String? _findRelevantSection(String content, String query) {
    final queryWords = query
        .toLowerCase()
        .replaceAll(RegExp(r'[?.,!]'), '')
        .split(' ')
        .where((w) => w.length > 2)
        .toList();

    if (queryWords.isEmpty) return null;

    final sections = content.split(RegExp(r'\n(?=##?\s)'));
    String? bestSection;
    int maxMatches = 0;

    for (final sec in sections) {
      final secLower = sec.toLowerCase();
      int matches = 0;
      for (final word in queryWords) {
        if (secLower.contains(word)) matches++;
      }
      if (matches > maxMatches) {
        maxMatches = matches;
        bestSection = sec.trim();
      }
    }

    if (maxMatches > 0 && bestSection != null) {
      return bestSection.length > 600
          ? '${bestSection.substring(0, 600)}...\n\n*(Xem thêm chi tiết trong khung đọc bên trái)*'
          : bestSection;
    }

    return null;
  }

  /// Parse mảng JSON câu hỏi trắc nghiệm an toàn
  List<QuizQuestion> _parseQuizQuestionsFromJson(String raw) {
    try {
      String clean = raw.trim();
      // Loại bỏ khối markdown nếu có
      if (clean.contains('```json')) {
        final start = clean.indexOf('```json') + 7;
        final end = clean.indexOf('```', start);
        if (end != -1) {
          clean = clean.substring(start, end).trim();
        }
      } else if (clean.contains('```')) {
        final start = clean.indexOf('```') + 3;
        final end = clean.indexOf('```', start);
        if (end != -1) {
          clean = clean.substring(start, end).trim();
        }
      }

      // Lấy đoạn mảng [...]
      final firstBracket = clean.indexOf('[');
      final lastBracket = clean.lastIndexOf(']');
      if (firstBracket != -1 &&
          lastBracket != -1 &&
          lastBracket > firstBracket) {
        clean = clean.substring(firstBracket, lastBracket + 1);
      }

      final dynamic decoded = jsonDecode(clean);
      if (decoded is List) {
        final List<QuizQuestion> result = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final q = QuizQuestion.fromJson(item);
            if (q.options.isNotEmpty) {
              result.add(q);
            }
          }
        }
        return result;
      }
    } catch (e) {
      debugPrint('Lỗi parse quiz JSON: $e');
    }
    return const [];
  }

  /// Tự động trích xuất các câu hỏi trắc nghiệm đa lựa chọn offline từ ghi chú
  List<QuizQuestion> _offlineGenerateQuizQuestions({
    required String currentDocTitle,
    required String currentDocContent,
    required int seedOffset,
  }) {
    return QuizBank.generateQuestions(
      currentDocTitle: currentDocTitle,
      currentDocContent: currentDocContent,
      seedOffset: seedOffset,
    );
  }
}
