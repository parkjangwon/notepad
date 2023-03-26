import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/constants.dart';
import 'package:notepad/src/screen/home/controller/home_controller.dart';
import 'package:notepad/src/screen/memo/service/memo_service.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/view/memo_view.dart';
import 'package:notepad/src/screen/memo/view/memo_write.dart';

class Home extends GetView<HomeController> {
  static String routeName = "/home";

  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        title: const Text(
          "🐟 메모장 🐢",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 40, bottom: 20),
            child: Container(
              child: Text(
                '메모 리스트',
                style: TextStyle(fontSize: 36, color: PRIMARY_COLOR),
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: memoBuilder(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          print('[+ 메모 추가 액션버튼] 클릭');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MemoWrite()));
        },
        tooltip: '+',
        label: Text('메모 추가'),
        icon: Icon(Icons.add),
      ),
    );
  }

  void showAlertDialog(BuildContext context, String id) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('️삭제 경고️️'),
            content: Text('삭제된 메모는 복구되지 않습니다.'),
            actions: [
              TextButton(
                  child: Text('삭제'),
                  onPressed: () {
                    Navigator.pop(context, '삭제');
                    MemoService().deleteMemo(id);
                    Get.offAllNamed(Home.routeName); // -_-.... 이러면 안된다!
                  }),
              TextButton(
                  child: Text('취소'),
                  onPressed: () {
                    Navigator.pop(context, '취소');
                  })
            ],
          );
        });
  }

  Widget memoBuilder(BuildContext parentContext) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              '저장된 메모가 없습니다.',
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              MemoDTO? memo = snapshot.data?[index];
              return InkWell(
                onTap: () {
                  print('탭 클릭');
                  Get.toNamed(MemoView.routeName, arguments: memo);
                },
                onLongPress: () {
                  print('길게 누름');
                  showAlertDialog(parentContext, memo.id);
                },
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.only(
                      left: 20, top: 0, bottom: 15, right: 20),
                  padding: const EdgeInsets.only(
                      left: 15, top: 0, bottom: 15, right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: PRIMARY_COLOR, width: 1),
                    boxShadow: const [
                      BoxShadow(color: PRIMARY_COLOR, blurRadius: 3),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '수정 시간 : ${memo?.editedTime.split('.')[0]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '제목 : ${memo?.title}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          memo!.text,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      future: MemoService().loadMemos(),
    );
  }
}
