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
    return Memo(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      richContent: map['rich_content'] as String?,
      isEncrypted: map['is_encrypted'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
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