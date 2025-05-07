import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';
import 'package:notepad/features/memo/presentation/pages/memo_write_page.dart';
import 'package:notepad/features/memo/presentation/providers/memo_providers.dart';

class MemoDetailPage extends ConsumerStatefulWidget {
  final Memo memo;

  const MemoDetailPage({Key? key, required this.memo}) : super(key: key);

  @override
  ConsumerState<MemoDetailPage> createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends ConsumerState<MemoDetailPage> {
  late QuillController _quillController;
  late Memo _currentMemo;

  @override
  void initState() {
    super.initState();
    _currentMemo = widget.memo;
    _initializeQuillController();
  }

  void _initializeQuillController() {
    if (_currentMemo.richContent != null) {
      try {
        final doc = Document.fromJson(jsonDecode(_currentMemo.richContent!));
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = QuillController.basic();
        _quillController.document.insert(0, _currentMemo.content);
      }
    } else {
      _quillController = QuillController.basic();
      _quillController.document.insert(0, _currentMemo.content);
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final createdAt = dateFormat.format(_currentMemo.createdAt);
    final updatedAt = dateFormat.format(_currentMemo.updatedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentMemo.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedMemo = await Navigator.push<Memo>(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoWritePage(memo: _currentMemo),
                ),
              );
              
              if (updatedMemo != null) {
                setState(() {
                  _currentMemo = updatedMemo;
                  _initializeQuillController();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final result = await ref.read(memoRepositoryProvider).deleteMemo(_currentMemo.id);
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메모 삭제에 실패했습니다.')),
                ),
                (_) {
                  ref.read(memoListProvider.notifier).refresh();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '작성: $createdAt\n수정: $updatedAt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: _quillController,
                focusNode: FocusNode(),
                scrollController: ScrollController(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 