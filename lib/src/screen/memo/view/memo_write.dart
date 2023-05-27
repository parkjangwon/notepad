import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/screen/memo/controller/memo_write_controller.dart';

// ignore: must_be_immutable
class MemoWrite extends GetView<MemoWriteController> {
  String title = '';
  String text = '';

  static String routeName = "/memo/write";

  MemoWrite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐟 메모 쓰기! 🐢",
        ),
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
}
