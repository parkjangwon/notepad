import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'memo.freezed.dart';
part 'memo.g.dart';

@freezed
class Memo with _$Memo {
  const Memo._();

  const factory Memo({
    required String id,
    required String title,
    required String content,
    String? richContent,
    @Default(false) bool isEncrypted,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Memo;

  factory Memo.fromJson(Map<String, dynamic> json) => _$MemoFromJson(json);

  factory Memo.fromSqlite(Map<String, dynamic> map) {
    final now = DateTime.now();
    final id = (map['id'] as String?) ?? const Uuid().v4();
    final title = (map['title'] as String?) ?? '';
    final content = (map['content'] as String?) ?? '';
    String? richContent;
    try {
      final raw = map['rich_content'];
      if (raw != null && raw is String && raw.isNotEmpty) {
        // 실제로 앱에서 rich_content를 jsonDecode 등으로 파싱한다면, 여기서 파싱 테스트 가능
        // 하지만 대부분 String 그대로 저장하므로, 일단 String으로만 처리
        richContent = raw;
      }
    } catch (e) {
      richContent = null;
    }
    final isEncrypted = map['is_encrypted'] == 1 || map['is_encrypted'] == true;
    final createdAtStr = map['created_at'] as String?;
    final updatedAtStr = map['updated_at'] as String?;
    DateTime createdAt;
    DateTime updatedAt;
    try {
      createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : now;
    } catch (_) {
      createdAt = now;
    }
    try {
      updatedAt = updatedAtStr != null ? DateTime.parse(updatedAtStr) : createdAt;
    } catch (_) {
      updatedAt = createdAt;
    }
    return Memo(
      id: id,
      title: title,
      content: content,
      richContent: richContent,
      isEncrypted: isEncrypted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Memo.create({
    required String title,
    required String content,
    String? richContent,
    bool isEncrypted = false,
  }) {
    final now = DateTime.now();
    return Memo(
      id: const Uuid().v4(),
      title: title,
      content: content,
      richContent: richContent,
      isEncrypted: isEncrypted,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'rich_content': richContent,
      'is_encrypted': isEncrypted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 