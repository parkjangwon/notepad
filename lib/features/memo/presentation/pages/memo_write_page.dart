import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notepad/features/memo/domain/entities/memo.dart';
import 'package:notepad/features/memo/presentation/providers/memo_providers.dart';
import 'package:uuid/uuid.dart';

class MemoWritePage extends ConsumerStatefulWidget {
  final Memo? memo;

  const MemoWritePage({Key? key, this.memo}) : super(key: key);

  @override
  ConsumerState<MemoWritePage> createState() => _MemoWritePageState();
}

class _MemoWritePageState extends ConsumerState<MemoWritePage> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title ?? '');
    
    if (widget.memo?.richContent != null) {
      try {
        final doc = Document.fromJson(jsonDecode(widget.memo!.richContent!));
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = QuillController.basic();
        _quillController.document.insert(0, widget.memo?.content ?? '');
      }
    } else {
      _quillController = QuillController.basic();
      if (widget.memo?.content != null) {
        _quillController.document.insert(0, widget.memo!.content);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 작성'),
        actions: [
          TextButton(
            onPressed: () async {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목을 입력해주세요.')),
                );
                return;
              }

              final content = _quillController.document.toPlainText();
              if (content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('내용을 입력해주세요.')),
                );
                return;
              }

              final richContent = jsonEncode(_quillController.document.toDelta().toJson());
              
              final memo = Memo(
                id: widget.memo?.id ?? const Uuid().v4(),
                title: _titleController.text,
                content: content,
                richContent: richContent,
                createdAt: widget.memo?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
                isEncrypted: false,
              );

              final result = widget.memo == null
                  ? await ref.read(memoRepositoryProvider).saveMemo(memo)
                  : await ref.read(memoRepositoryProvider).saveMemo(memo);

              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('저장에 실패했습니다.')),
                ),
                (_) {
                  ref.read(memoListProvider.notifier).refresh();
                  Navigator.pop(context, memo);
                },
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              autofocus: false,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () => _quillController.formatSelection(Attribute.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.format_italic),
                  onPressed: () => _quillController.formatSelection(Attribute.italic),
                ),
                IconButton(
                  icon: const Icon(Icons.format_underline),
                  onPressed: () => _quillController.formatSelection(Attribute.underline),
                ),
                IconButton(
                  icon: const Icon(Icons.format_strikethrough),
                  onPressed: () => _quillController.formatSelection(Attribute.strikeThrough),
                ),
                const VerticalDivider(width: 16),
                
                IconButton(
                  icon: const Icon(Icons.format_align_left),
                  onPressed: () => _quillController.formatSelection(Attribute.align),
                ),
                const VerticalDivider(width: 16),
                
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  onPressed: () => _quillController.formatSelection(Attribute.ul),
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_numbered),
                  onPressed: () => _quillController.formatSelection(Attribute.ol),
                ),
                IconButton(
                  icon: const Icon(Icons.format_quote),
                  onPressed: () => _quillController.formatSelection(Attribute.blockQuote),
                ),
                const VerticalDivider(width: 16),
                
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {
                    final selection = _quillController.selection;
                    if (selection.isValid) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('링크 추가'),
                          content: TextField(
                            decoration: const InputDecoration(
                              hintText: 'URL을 입력하세요',
                            ),
                            onSubmitted: (url) {
                              _quillController.formatSelection(
                                Attribute.fromKeyValue('link', url),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                
                IconButton(
                  icon: const Icon(Icons.code),
                  onPressed: () => _quillController.formatSelection(Attribute.codeBlock),
                ),
                
                IconButton(
                  icon: const Icon(Icons.format_clear),
                  onPressed: () {
                    final selection = _quillController.selection;
                    if (selection.isValid) {
                      _quillController.formatSelection(Attribute.clone(Attribute.link, null));
                      _quillController.formatSelection(Attribute.clone(Attribute.bold, null));
                      _quillController.formatSelection(Attribute.clone(Attribute.italic, null));
                      _quillController.formatSelection(Attribute.clone(Attribute.underline, null));
                      _quillController.formatSelection(Attribute.clone(Attribute.strikeThrough, null));
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: QuillEditor.basic(
                controller: _quillController,
                focusNode: _contentFocusNode,
                scrollController: ScrollController(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_size),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('폰트 크기'),
                        content: StatefulBuilder(
                          builder: (context, setState) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Slider(
                                value: _fontSize,
                                min: 8,
                                max: 32,
                                divisions: 12,
                                label: _fontSize.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _fontSize = value;
                                  });
                                },
                              ),
                              Text('${_fontSize.round()}pt'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              final selection = _quillController.selection;
                              if (selection.isValid) {
                                _quillController.formatSelection(
                                  Attribute.fromKeyValue('size', _fontSize.round().toString()),
                                );
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('적용'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 