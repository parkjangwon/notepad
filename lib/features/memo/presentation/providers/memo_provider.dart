import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/core/di/injection.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';
import 'package:notepad/features/memo/domain/repositories/memo_repository.dart';

final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  return getIt<MemoRepository>();
});

final memoProvider = FutureProvider<List<Memo>>((ref) async {
  final repository = ref.watch(memoRepositoryProvider);
  final result = await repository.getAllMemos();
  return result.fold(
    (failure) => throw failure,
    (memos) => memos,
  );
}); 