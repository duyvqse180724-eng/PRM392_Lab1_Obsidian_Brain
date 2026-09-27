/// Model đại diện cho một tập tin ghi chú Markdown (.md)
class NoteFile {
  final String fileName;
  final String fullPath;
  final String content;
  final DateTime lastModified;

  const NoteFile({
    required this.fileName,
    required this.fullPath,
    this.content = '',
    required this.lastModified,
  });

  NoteFile copyWith({
    String? fileName,
    String? fullPath,
    String? content,
    DateTime? lastModified,
  }) {
    return NoteFile(
      fileName: fileName ?? this.fileName,
      fullPath: fullPath ?? this.fullPath,
      content: content ?? this.content,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Định dạng ngày cập nhật gần nhất
  String get formattedDate {
    final d = lastModified;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteFile && other.fullPath == fullPath;
  }

  @override
  int get hashCode => fullPath.hashCode;

  @override
  String toString() =>
      'NoteFile(fileName: $fileName, fullPath: $fullPath, lastModified: $lastModified)';
}
