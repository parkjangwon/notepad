import 'package:flutter/material.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(memo.title),
        subtitle: Text(
          memo.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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