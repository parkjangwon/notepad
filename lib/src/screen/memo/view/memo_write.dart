import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/screen/home/home.dart';
import 'package:notepad/src/screen/memo/controller/memo_write_controller.dart';
import 'package:notepad/src/screen/memo/service/memo_service.dart';

// ignore: must_be_immutable
class MemoWrite extends GetView<MemoWriteController> {
  String title = '';
  String text = '';

  static String routeName = "/memo/write";

  MemoService serivce = MemoService();

  MemoWrite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐟 메모 쓰기! 🐢",
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
          content: const Text('메모를 추가하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('추가'),
              onPressed: () {
                Navigator.pop(context, '추가');
                serivce.saveDB(title, text);
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
