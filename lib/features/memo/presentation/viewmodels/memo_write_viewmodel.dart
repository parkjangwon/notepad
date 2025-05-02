import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/core/error/failures.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';
import 'package:notepad/features/memo/domain/repositories/memo_repository.dart';

final memoWriteViewModelProvider = Provider((ref) {
  final repository = ref.watch(memoRepositoryProvider);
  return MemoWriteViewModel(repository);
});

class MemoWriteViewModel {
  final MemoRepository _repository;

  MemoWriteViewModel(this._repository);

  Future<String?> saveMemo(String title, String content) async {
    if (title.isEmpty) {
      return '제목을 입력해주세요';
    }
    if (content.isEmpty) {
      return '내용을 입력해주세요';
    }

    final memo = Memo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.saveMemo(memo);
    return result.fold(
      (failure) => failure is CacheFailure ? '메모 저장에 실패했습니다' : '알 수 없는 오류가 발생했습니다',
      (_) => '메모가 저장되었습니다',
    );
  }
} 