import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';

class MemoListItem extends StatelessWidget {
  final Memo memo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MemoListItem({
    super.key,
    required this.memo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final createdAt = dateFormat.format(memo.createdAt);
    final updatedAt = dateFormat.format(memo.updatedAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(memo.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memo.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '작성: $createdAt\n수정: $updatedAt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
} 