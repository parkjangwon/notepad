import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/constants.dart';
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
        backgroundColor: PRIMARY_COLOR,
        title: const Text(
          "🐟 메모 읽어요! 🐢",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print('삭제 아이콘 클릭 : $controller.id');
              //showAlertDialog();
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
      body: Padding(padding: EdgeInsets.all(20), child: loadBuilder()),
    );
  }

  loadBuilder() {
    return FutureBuilder<List<MemoDTO>>(
      future: MemoService().loadMemo(controller.memo.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            child: Text('데이터를 불러올 수 없습니다.'),
          );
        } else {
          MemoDTO? memo = snapshot.data?[0];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                memo!.title,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
              Text(
                '작성 시간 : ${memo.createdTime.split(".")[0]}',
                style: TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Text(
                '수정 시간 : ${memo.editedTime.split(".")[0]}',
                style: TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Padding(
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
}
