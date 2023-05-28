import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/screen/memo/controller/memo_update_controller.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/service/memo_service.dart';
import 'package:notepad/src/screen/memo/view/memo_list.dart';

// ignore: must_be_immutable
class MemoUpdate extends GetView<MemoUpdateController> {
  MemoUpdate({super.key});

  static String routeName = "/memo/update";

  String title = '';
  String text = '';

  MemoService serivce = MemoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐟 메모 수정하기! 🐢",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              showAlertDialog(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(
                  text: controller.memo.title,
                ),
                onChanged: (String title) {
                  this.title = title;
                },
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: '제목을 입력하세요.'),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              TextField(
                controller: TextEditingController(
                  text: controller.memo.text,
                ),
                onChanged: (String text) {
                  this.text = text;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: '내용을 입력하세요.'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('️확인'),
          content: const Text('메모를 수정하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.pop(context, '수정');
                MemoDTO update = MemoDTO(
                  id: controller.memo.id,
                  title: this.title,
                  text: this.text,
                  createdTime: controller.memo.createdTime,
                  editedTime: DateTime.now().toString(),
                );

                if (this.title == '') {
                  update.title = controller.memo.title;
                }

                if (this.text == '') {
                  update.text = controller.memo.text;
                }

                serivce.updateMemo(update);
                Get.offAllNamed(MemoList.routeName);
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
