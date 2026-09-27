import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/note_file.dart';

/// Dịch vụ xử lý I/O hệ sinh thái tập tin trên Windows Desktop
class FileService {
  const FileService();

  /// Mở hộp thoại chọn thư mục Vault trên Windows
  Future<String?> pickVaultDirectory() async {
    try {
      final selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Chọn Thư Mục FPTU Knowledge Vault',
      );
      return selectedDirectory;
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi mở hộp thoại chọn thư mục: $e\n$stackTrace');
      return null;
    }
  }

  /// Quét đệ quy thư mục để lấy danh sách tất cả các file có định dạng `.md`.
  /// Bỏ qua thư mục ẩn (tên bắt đầu bằng `.`). Sắp xếp A-Z.
  Future<List<NoteFile>> scanMarkdownFiles(String dirPath) async {
    final List<NoteFile> markdownFiles = [];

    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        debugPrint('Thư mục không tồn tại: $dirPath');
        return markdownFiles;
      }

      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        // Bỏ qua thư mục ẩn (các thành phần path bắt đầu bằng '.')
        final segments = p.split(entity.path);
        final isHidden = segments.any(
          (seg) => seg.startsWith('.') && seg.length > 1,
        );
        if (isHidden) continue;

        if (entity is File && p.extension(entity.path).toLowerCase() == '.md') {
          try {
            final fileStat = await entity.stat();
            final fileName = p.basename(entity.path);
            markdownFiles.add(
              NoteFile(
                fileName: fileName,
                fullPath: entity.path,
                lastModified: fileStat.modified,
              ),
            );
          } catch (e) {
            debugPrint('Không thể đọc thông tin file ${entity.path}: $e');
          }
        }
      }

      // Sắp xếp danh sách file theo bảng chữ cái A-Z
      markdownFiles.sort(
        (a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi quét thư mục $dirPath: $e\n$stackTrace');
    }

    return markdownFiles;
  }

  /// Đọc bất đồng bộ toàn bộ nội dung văn bản của file Markdown
  Future<String> readNoteContent(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return '# Lỗi: Tập tin không tồn tại\nĐường dẫn: `$filePath`';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi đọc file $filePath: $e\n$stackTrace');
      return '# Không thể đọc tập tin\n\n**Chi tiết lỗi:**\n```\n$e\n```';
    }
  }

  /// Lưu/Ghi đè nội dung mới vào file Markdown trên ổ đĩa, kèm `flush: true`
  Future<bool> saveFile(String path, String content) async {
    try {
      final file = File(path);
      await file.writeAsString(content, flush: true);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi ghi file $path: $e\n$stackTrace');
      return false;
    }
  }

  /// Tạo một file `.md` mới an toàn trong thư mục Vault
  Future<NoteFile?> createNewNote(String dirPath, String name) async {
    try {
      var cleanName = name.trim();
      if (!cleanName.toLowerCase().endsWith('.md')) {
        cleanName = '$cleanName.md';
      }

      final fullPath = p.join(dirPath, cleanName);
      final file = File(fullPath);

      if (await file.exists()) {
        debugPrint('File đã tồn tại: $fullPath');
        return null;
      }

      final titleName = cleanName.replaceAll(
        RegExp(r'\.md$', caseSensitive: false),
        '',
      );
      final initialContent =
          '# $titleName\n\n_Bắt đầu ghi chú mới tại đây..._\n';

      await file.writeAsString(initialContent, flush: true);
      final stat = await file.stat();

      return NoteFile(
        fileName: cleanName,
        fullPath: fullPath,
        content: initialContent,
        lastModified: stat.modified,
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi tạo file mới: $e\n$stackTrace');
      return null;
    }
  }
}
