import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/core/di/injection.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';
import 'package:notepad/features/memo/domain/repositories/memo_repository.dart';

final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  return getIt<MemoRepository>();
});

final memoListProvider = StateNotifierProvider<MemoListNotifier, AsyncValue<List<Memo>>>((ref) {
  return MemoListNotifier(ref.watch(memoRepositoryProvider));
});

class MemoListNotifier extends StateNotifier<AsyncValue<List<Memo>>> {
  final MemoRepository _repository;

  MemoListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMemos();
  }

  Future<void> loadMemos() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.getAllMemos();
      state = result.fold(
        (failure) => AsyncValue.error(failure, StackTrace.current),
        (memos) => AsyncValue.data(memos),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadMemos();
  }
} 