import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/features/memo/presentation/pages/memo_detail_page.dart';
import 'package:notepad/features/memo/presentation/pages/memo_write_page.dart';
import 'package:notepad/features/memo/presentation/providers/memo_providers.dart';
import 'package:notepad/features/memo/presentation/widgets/memo_list_item.dart';
import 'package:notepad/features/memo/data/db_backup_helper.dart';

class MemoListPage extends ConsumerWidget {
  const MemoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoState = ref.watch(memoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐟 메모장 🐢'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            tooltip: '백업',
            onPressed: () async {
              final file = await DbBackupHelper.backupDb();
              if (file != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('백업 완료: ${file.path}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('백업 실패')), 
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: '복구',
            onPressed: () async {
              final restored = await DbBackupHelper.restoreDb();
              if (restored) {
                ref.read(memoListProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('복구 완료')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('복구 실패(파일 확인 필요)')),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(memoListProvider.notifier).refresh(),
        child: memoState.when(
          data: (memos) => ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              return MemoListItem(
                memo: memo,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MemoDetailPage(memo: memo),
                    ),
                  );
                },
                onDelete: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('메모 삭제'),
                      content: const Text('정말로 이 메모를 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );

                  if (result == true) {
                    final repository = ref.read(memoRepositoryProvider);
                    final deleteResult = await repository.deleteMemo(memo.id);
                    
                    deleteResult.fold(
                      (failure) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('메모 삭제에 실패했습니다.')),
                      ),
                      (_) => ref.read(memoListProvider.notifier).refresh(),
                    );
                  }
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('에러가 발생했습니다: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MemoWritePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 