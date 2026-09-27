import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../models/note_file.dart';
import '../../models/quiz_question.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';

class _ChatMessage {
  final bool isUser;
  final String text;
  final List<QuizQuestion>? quizQuestions;

  const _ChatMessage({
    required this.isUser,
    required this.text,
    this.quizQuestions,
  });
}

/// Cột phải: AI Study Buddy chuẩn đồ họa cao cấp
/// - Chat Bubbles bất đối xứng:
///   + User: dải màu tím chuyển sắc, bo góc bất đối xứng, bóng đổ mềm
///   + AI: nền xám đen mờ hiệu ứng kính (#262626.withOpacity(0.8)), viền bạc, Avatar AI 3D phát sáng
/// - Nút "Tạo Quiz" & "Tóm tắt bài này" chuẩn 3D Gradient Button
class AIAssistantPanel extends StatefulWidget {
  final NoteFile? selectedFile;

  const AIAssistantPanel({super.key, required this.selectedFile});

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final AIService _aiService = const AIService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        isUser: false,
        text: 'Xin chào! Tôi là **AI Study Buddy** của bạn. Hãy chọn một tài liệu và sử dụng 2 nút hành động nhanh bên dưới để **✨ Tóm tắt** hoặc **🎲 Tạo Quiz**, hoặc đặt câu hỏi bất kỳ về bài học.',
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Hành động: Tóm tắt bài này
  Future<void> _handleSummarize() async {
    if (widget.selectedFile == null) {
      _showWarningSnackBar('Vui lòng chọn một file .md trước khi tóm tắt.');
      return;
    }

    final file = widget.selectedFile!;
    setState(() {
      _messages.add(
        _ChatMessage(
          isUser: true,
          text: '✨ Tóm tắt bài này: "${file.fileName}"',
        ),
      );
      _isProcessing = true;
    });
    _scrollToBottom();

    try {
      final summary = await _aiService.summarize(
        currentDocTitle: file.fileName,
        currentDocContent: file.content,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(isUser: false, text: summary));
        _history.add({
          'role': 'user',
          'text': '✨ Tóm tắt bài: ${file.fileName}',
        });
        _history.add({'role': 'model', 'text': summary});
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(isUser: false, text: '❌ Lỗi khi tóm tắt: $e'),
        );
        _isProcessing = false;
      });
    }
    _scrollToBottom();
  }

  /// Hành động: Tạo Quiz trắc nghiệm tương tác 3D
  Future<void> _handleGenerateQuiz() async {
    if (widget.selectedFile == null) {
      _showWarningSnackBar('Vui lòng chọn một file .md trước khi tạo Quiz.');
      return;
    }

    final file = widget.selectedFile!;
    final seedOffset = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _messages.add(
        _ChatMessage(
          isUser: true,
          text: '🎲 Tạo Quiz trắc nghiệm ôn tập từ: "${file.fileName}"',
        ),
      );
      _isProcessing = true;
    });
    _scrollToBottom();

    try {
      final questions = await _aiService.generateQuizQuestions(
        currentDocTitle: file.fileName,
        currentDocContent: file.content,
        seedOffset: seedOffset,
      );

      if (!mounted) return;

      if (questions.isNotEmpty) {
        setState(() {
          _messages.add(
            _ChatMessage(
              isUser: false,
              text:
                  '### 🎲 Bộ Câu Hỏi Trắc Nghiệm Ôn Tập (${questions.length} câu)\n'
                  'Hãy bấm chọn một đáp án bất kỳ bên dưới để hệ thống kiểm tra đúng / sai và mở khóa phần giải thích chi tiết!',
              quizQuestions: questions,
            ),
          );
          _history.add({
            'role': 'user',
            'text': '🎲 Tạo Quiz trắc nghiệm: ${file.fileName}',
          });
          _history.add({
            'role': 'model',
            'text': 'Đã tạo ${questions.length} câu hỏi trắc nghiệm tương tác.',
          });
          _isProcessing = false;
        });
      } else {
        setState(() {
          _messages.add(
            const _ChatMessage(
              isUser: false,
              text: '⚠️ Tài liệu đang mở chưa có đủ nội dung để biên soạn câu hỏi trắc nghiệm. Hãy bổ sung thêm nội dung vào tài liệu nhé!',
            ),
          );
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(isUser: false, text: '❌ Lỗi khi tạo quiz: $e'),
        );
        _isProcessing = false;
      });
    }
    _scrollToBottom();
  }

  /// Gửi câu hỏi tự do dựa trên ngữ cảnh file đang đọc
  Future<void> _handleSendQuery() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    _inputController.clear();

    // Nếu người dùng nhắn lệnh muốn tạo câu hỏi trắc nghiệm
    final lower = text.toLowerCase();
    if ((lower.contains('tạo quiz') ||
            lower.contains('trắc nghiệm') ||
            lower.contains('câu hỏi ôn tập')) &&
        widget.selectedFile != null) {
      _handleGenerateQuiz();
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _isProcessing = true;
    });
    _scrollToBottom();

    final file = widget.selectedFile;

    try {
      final answer = await _aiService.askAI(
        currentDocTitle: file?.fileName ?? 'Chưa mở tài liệu',
        currentDocContent: file?.content ?? '',
        userPrompt: text,
        history: List.unmodifiable(_history),
      );

      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(isUser: false, text: answer));
        _history.add({'role': 'user', 'text': text});
        _history.add({'role': 'model', 'text': answer});
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(isUser: false, text: '❌ Lỗi khi gọi AI: $e'),
        );
        _isProcessing = false;
      });
    }
    _scrollToBottom();
  }

  /// Mở hộp thoại cấu hình Gemini API Key với giao diện 3D
  Future<void> _showApiKeyDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final keyController = TextEditingController(text: AIService.apiKey ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1D2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.key_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cài Đặt Gemini API Key',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhập khóa API Gemini để kích hoạt mô hình AI trực tuyến. Nếu để trống, hệ thống sẽ tự động sử dụng bộ Smart Offline Engine.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: keyController,
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF14131D),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryPurple,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            GradientButton3D(
              onPressed: () => Navigator.of(dialogCtx).pop(keyController.text),
              icon: const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Lưu API Key',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ],
        );
      },
    );

    keyController.dispose();

    if (result != null) {
      AIService.apiKey = result;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AIService.hasApiKey
                ? 'Đã cập nhật Gemini API Key!'
                : 'Đã chuyển sang chế độ Smart Offline.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E1D2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppTheme.primaryPurple, width: 1.0),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showWarningSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.selectedFile?.fileName ?? '(Chưa chọn file)';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13121C),
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.06), width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card 3D: AI Assistant với nhãn ngữ cảnh thời gian thực
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1926),
              borderRadius: BorderRadius.circular(14),
              border: AppTheme.highlightBorder,
              boxShadow: AppTheme.cardSoftShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar AI 3D phát sáng
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.aiAvatarGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'AI Study Buddy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    _buildHeaderIconButton(
                      icon: Icons.settings_rounded,
                      tooltip: 'Cài đặt Gemini API Key',
                      iconColor: AIService.hasApiKey
                          ? const Color(0xFF4ADE80)
                          : Colors.white.withOpacity(0.6),
                      onTap: _showApiKeyDialog,
                    ),
                    const SizedBox(width: 4),
                    _buildHeaderIconButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Làm mới cuộc trò chuyện',
                      iconColor: Colors.white.withOpacity(0.6),
                      onTap: () {
                        setState(() {
                          _messages.clear();
                          _history.clear();
                          _messages.add(
                            const _ChatMessage(
                              isUser: false,
                              text: 'Đã làm mới cuộc hội thoại với AI Buddy.',
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nhãn ngữ cảnh thời gian thực có pulse glow
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14131F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4ADE80),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withOpacity(0.7),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Ngữ cảnh: $fileName',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Hàng nút hành động nhanh 3D: Nút "Tạo Quiz" & Nút "Tóm tắt"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton3D(
                    onPressed: _isProcessing ? null : _handleSummarize,
                    icon: const Icon(
                      Icons.summarize_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: const Text(
                      '✨ Tóm tắt bài',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    isSecondary: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GradientButton3D(
                    onPressed: _isProcessing ? null : _handleGenerateQuiz,
                    icon: const Icon(
                      Icons.casino_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: const Text(
                      '🎲 Tạo Quiz 3D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),

          // Khung hiển thị chat & kết quả AI với Chat Bubbles bất đối xứng
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),

          // Chỉ báo Loading khi AI đang suy nghĩ
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1A28),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI đang phân tích ngữ cảnh và sinh nội dung...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Ô nhập câu hỏi tự do kèm nút Gửi 3D
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF161522),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1A28),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: (_) => _handleSendQuery(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        hintText: 'Hỏi AI về bài học đang mở...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppTheme.primaryPurple.withOpacity(0.85),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HoverSendButton(
                  onTap: _isProcessing ? null : _handleSendQuery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 0.8,
            ),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
      ),
    );
  }

  /// Xây dựng tin nhắn Chat với tiêu chuẩn đồ họa cao cấp:
  /// - User: Nền màu tím chuyển sắc nhẹ (#7C3AED sang #6D28D9), bo góc bất đối xứng (16, 4, 16, 16), bóng đổ mềm.
  /// - AI: Nền xám đen mờ hiệu ứng kính (#262626.withOpacity(0.8)), viền mỏng sáng màu bạc, avatar AI 3D phát sáng.
  Widget _buildMessageItem(_ChatMessage msg) {
    if (msg.isUser) {
      // 1. User Message
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppTheme.userBubbleGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.0,
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    // 2. AI Message với Avatar 3D phát sáng & Glassmorphism Bubble
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar AI 3D phát sáng
        Container(
          margin: const EdgeInsets.only(top: 2, right: 9),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppTheme.aiAvatarGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.55),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: Colors.white,
          ),
        ),

        // Khung tin nhắn AI mờ kính
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626).withOpacity(0.82),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SelectionArea(
                  child: MarkdownBody(
                    data: msg.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 12,
                        height: 1.55,
                      ),
                      h3: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                      strong: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      em: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontStyle: FontStyle.italic,
                      ),
                      code: const TextStyle(
                        color: Color(0xFFA78BFA),
                        backgroundColor: Color(0xFF1A1926),
                        fontFamily: 'Consolas',
                        fontSize: 11.5,
                      ),
                      blockquote: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: const Color(0xFF1E1D2A),
                        borderRadius: BorderRadius.circular(6),
                        border: const Border(
                          left: BorderSide(
                            color: AppTheme.primaryPurple,
                            width: 3,
                          ),
                        ),
                      ),
                      listBullet: const TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                      a: const TextStyle(
                        color: Color(0xFFA78BFA),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              // Nếu có danh sách câu hỏi trắc nghiệm tương tác
              if (msg.quizQuestions != null &&
                  msg.quizQuestions!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InteractiveQuizListView(questions: msg.quizQuestions!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Danh sách câu hỏi trắc nghiệm tương tác
class _InteractiveQuizListView extends StatelessWidget {
  final List<QuizQuestion> questions;

  const _InteractiveQuizListView({required this.questions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < questions.length; i++) ...[
          _InteractiveQuizCard(
            question: questions[i],
            index: i,
            total: questions.length,
          ),
          if (i < questions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Thẻ câu hỏi trắc nghiệm tương tác chuẩn 3D Glassmorphism
/// Người dùng chọn đáp án mới hiện đúng/sai và giải thích!
class _InteractiveQuizCard extends StatefulWidget {
  final QuizQuestion question;
  final int index;
  final int total;

  const _InteractiveQuizCard({
    required this.question,
    required this.index,
    required this.total,
  });

  @override
  State<_InteractiveQuizCard> createState() => _InteractiveQuizCardState();
}

class _InteractiveQuizCardState extends State<_InteractiveQuizCard> {
  int? _selectedIndex;

  void _selectOption(int optionIndex) {
    if (_selectedIndex != null) return;
    setState(() {
      _selectedIndex = optionIndex;
    });
  }

  void _resetQuestion() {
    setState(() {
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswered = _selectedIndex != null;
    final isCorrect = _selectedIndex == widget.question.correctIndex;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAnswered
              ? (isCorrect
                    ? const Color(0xFF10B981).withOpacity(0.5)
                    : const Color(0xFFEF4444).withOpacity(0.5))
              : Colors.white.withOpacity(0.09),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (hasAnswered)
            BoxShadow(
              color: isCorrect
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : const Color(0xFFEF4444).withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header câu hỏi
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.quiz_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Câu ${widget.index + 1}/${widget.total}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (hasAnswered)
                GestureDetector(
                  onTap: _resetQuestion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Làm lại',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Nội dung câu hỏi
          Text(
            widget.question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),

          // 4 phương án lựa chọn (A, B, C, D)
          for (int i = 0; i < widget.question.options.length; i++) ...[
            _QuizOptionButton(
              optionIndex: i,
              optionText: widget.question.options[i],
              hasAnswered: hasAnswered,
              isSelected: _selectedIndex == i,
              isCorrectOption: i == widget.question.correctIndex,
              onTap: () => _selectOption(i),
            ),
            if (i < widget.question.options.length - 1)
              const SizedBox(height: 6),
          ],

          // PHẦN KẾT QUẢ VÀ GIẢI THÍCH (Chỉ hiện khi đã chọn đáp án!)
          if (hasAnswered) ...[
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF064E3B).withOpacity(0.35)
                    : const Color(0xFF7F1D1D).withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF10B981).withOpacity(0.6)
                      : const Color(0xFFEF4444).withOpacity(0.6),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 15,
                        color: isCorrect
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFF87171),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isCorrect
                              ? 'Chính xác! Bạn đã chọn đúng.'
                              : 'Chưa chính xác! Đáp án đúng là: ${String.fromCharCode(65 + widget.question.correctIndex)}',
                          style: TextStyle(
                            color: isCorrect
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFCA5A5),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.question.explanation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          size: 13,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.45,
                                color: Color(0xFFE2E8F0),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Giải thích: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFBBF24),
                                  ),
                                ),
                                TextSpan(text: widget.question.explanation),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Nút phương án trắc nghiệm với Hover và Feedback màu sắc
class _QuizOptionButton extends StatefulWidget {
  final int optionIndex;
  final String optionText;
  final bool hasAnswered;
  final bool isSelected;
  final bool isCorrectOption;
  final VoidCallback onTap;

  const _QuizOptionButton({
    required this.optionIndex,
    required this.optionText,
    required this.hasAnswered,
    required this.isSelected,
    required this.isCorrectOption,
    required this.onTap,
  });

  @override
  State<_QuizOptionButton> createState() => _QuizOptionButtonState();
}

class _QuizOptionButtonState extends State<_QuizOptionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + widget.optionIndex);

    Color backgroundColor;
    Color borderColor;
    Color letterBgColor;
    Color letterTextColor = Colors.white;
    Color textColor;
    Widget trailingIcon;

    if (!widget.hasAnswered) {
      // 1. Chưa chọn đáp án
      backgroundColor = _isHovered
          ? Colors.white.withOpacity(0.08)
          : const Color(0xFF13121F);
      borderColor = _isHovered
          ? AppTheme.primaryPurple.withOpacity(0.6)
          : Colors.white.withOpacity(0.09);
      letterBgColor = _isHovered
          ? AppTheme.primaryPurple
          : AppTheme.primaryPurple.withOpacity(0.25);
      letterTextColor = _isHovered ? Colors.white : const Color(0xFFC4B5FD);
      textColor = Colors.white.withOpacity(0.9);
      trailingIcon = Icon(
        Icons.radio_button_unchecked_rounded,
        size: 15,
        color: _isHovered
            ? AppTheme.primaryPurple
            : Colors.white.withOpacity(0.25),
      );
    } else {
      // 2. Đã chọn đáp án
      if (widget.isCorrectOption) {
        // Đáp án ĐÚNG: Xanh lá nổi bật
        backgroundColor = const Color(0xFF064E3B).withOpacity(0.5);
        borderColor = const Color(0xFF10B981);
        letterBgColor = const Color(0xFF10B981);
        letterTextColor = Colors.white;
        textColor = const Color(0xFFECFDF5);
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: Color(0xFF34D399),
        );
      } else if (widget.isSelected) {
        // Người dùng chọn SAI: Đỏ nổi bật
        backgroundColor = const Color(0xFF7F1D1D).withOpacity(0.5);
        borderColor = const Color(0xFFEF4444);
        letterBgColor = const Color(0xFFEF4444);
        letterTextColor = Colors.white;
        textColor = const Color(0xFFFEF2F2);
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          size: 16,
          color: Color(0xFFF87171),
        );
      } else {
        // Các phương án khác: Mờ đi
        backgroundColor = const Color(0xFF12111D).withOpacity(0.5);
        borderColor = Colors.white.withOpacity(0.04);
        letterBgColor = Colors.white.withOpacity(0.06);
        letterTextColor = Colors.white.withOpacity(0.4);
        textColor = Colors.white.withOpacity(0.4);
        trailingIcon = const SizedBox(width: 16);
      }
    }

    return MouseRegion(
      cursor: widget.hasAnswered
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.hasAnswered) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!widget.hasAnswered) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.hasAnswered ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              if (widget.hasAnswered && widget.isCorrectOption)
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge chữ cái A, B, C, D
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: letterBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: letterTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              // Văn bản đáp án
              Expanded(
                child: Text(
                  widget.optionText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.5,
                    fontWeight: widget.hasAnswered && widget.isCorrectOption
                        ? FontWeight.w600
                        : FontWeight.normal,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              trailingIcon,
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút Gửi câu hỏi có hiệu ứng 3D và Hover Glow
class _HoverSendButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _HoverSendButton({required this.onTap});

  @override
  State<_HoverSendButton> createState() => _HoverSendButtonState();
}

class _HoverSendButtonState extends State<_HoverSendButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return Tooltip(
      message: 'Gửi câu hỏi (Enter)',
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.12),
                      ],
                    ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered && isEnabled
                    ? AppTheme.primaryPurple
                    : Colors.white.withOpacity(0.12),
                width: 1.0,
              ),
              boxShadow: _isHovered && isEnabled
                  ? AppTheme.neonGlowShadow
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: const Icon(
              Icons.send_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
