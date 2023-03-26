import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/constants.dart';
import 'package:notepad/src/screen/home/home.dart';
import 'package:notepad/src/screen/memo/controller/memo_write_controller.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/repository/database_helper.dart';

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
        backgroundColor: PRIMARY_COLOR,
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                print("삭제 버튼");
              }),
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                print("저장 버튼");
                saveDB();
                Get.offAllNamed(Home.routeName);
              })
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (String title) {
                this.title = title;
              },
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(hintText: '제목을 입력하세요.'),
            ),
            Padding(padding: EdgeInsets.all(10)),
            TextField(
              onChanged: (String text) {
                this.text = text;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(hintText: '내용을 입력하세요.'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveDB() async {
    DatabaseHelper helper = DatabaseHelper();
    var memo = MemoDTO(
        id: convertStr2Sha512(DateTime.now().toString()),
        title: title,
        text: text,
        createdTime: DateTime.now().toString(),
        editedTime: DateTime.now().toString());

    await helper.insertMemo(memo);
    print('저장하기');
  }

  String convertStr2Sha512(String text) {
    var bytes = utf8.encode(text);
    var digest = sha512.convert(bytes);
    print('[SHA512] ORG : $text');
    print('[SHA512] HASH : $digest');

    return digest.toString();
  }
}
