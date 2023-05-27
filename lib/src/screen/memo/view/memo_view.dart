import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/screen/home/home.dart';
import 'package:notepad/src/screen/memo/controller/memo_view_controller.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/service/memo_service.dart';

class MemoView extends GetView<MemoViewController> {
  static String routeName = "/memo/view";

  const MemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐟 메모 읽어요! 🐢",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showAlertDialog(context, controller.memo.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              print('수정');
              // Get.toNamed(MemoEdit.routeName, arguments: controller.memo);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loadBuilder(),
      ),
    );
  }

  loadBuilder() {
    return FutureBuilder<List<MemoDTO>>(
      future: MemoService().loadMemo(controller.memo.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('데이터를 불러올 수 없습니다.');
        } else {
          MemoDTO? memo = snapshot.data?[0];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                memo!.title,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
              Text(
                '작성 시간 : ${memo.createdTime.split(".")[0]}',
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Text(
                '수정 시간 : ${memo.editedTime.split(".")[0]}',
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              // Text(memo.text),
              Expanded(
                child: Text(memo.text),
              )
            ],
          );
        }
      },
    );
  }

  void showAlertDialog(BuildContext context, String id) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('️경고️️'),
          content: const Text('삭제된 메모는 복구되지 않습니다.'),
          actions: [
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.pop(context, '삭제');
                MemoService().deleteMemo(id);
                Get.offAllNamed(Home.routeName);
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.pop(context, '취소');
              },
            )
          ],
        );
      },
    );
  }
}
