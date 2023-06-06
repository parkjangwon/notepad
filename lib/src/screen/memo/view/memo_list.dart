import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:notepad/src/constants.dart';
import 'package:notepad/src/screen/memo/controller/memo_list_controller.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/service/memo_service.dart';
import 'package:notepad/src/screen/memo/view/memo_view.dart';
import 'package:notepad/src/screen/memo/view/memo_write.dart';

class MemoList extends GetView<MemoListController> {
  const MemoList({super.key});

  static String routeName = "/list";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🐟 메모장 🐢",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: () {
              MemoService().backupDB();
              showToast('다운로드 폴더\n 백업 파일 : "memos.db"');
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              restoreDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 40,
              bottom: 20,
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MemoWrite()));
        },
        tooltip: '+',
        label: const Text('메모 추가'),
        icon: const Icon(Icons.add),
      ),
    );
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
                  Get.toNamed(MemoView.routeName, arguments: memo);
                },
                onLongPress: () {
                  deleteDialog(parentContext, memo.id);
                },
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.only(
                    left: 20,
                    top: 0,
                    bottom: 15,
                    right: 20,
                  ),
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 0,
                    bottom: 15,
                    right: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: PRIMARY_COLOR,
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: PRIMARY_COLOR,
                        blurRadius: 3,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
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

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.TOP,
        backgroundColor: PRIMARY_COLOR,
        fontSize: 20,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }

  void deleteDialog(BuildContext context, String id) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('️경고️️'),
          content: const Text('삭제된 메모는 복구되지 않습니다.'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                MemoService().deleteMemo(id);
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

  void restoreDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('️경고️️'),
          content: const Text('복구를 할 경우, 기존 데이터가 덮어써집니다.'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                MemoService().restoreDB();
                showToast('데이터 복구 후, 앱을 재기동해주세요.\n 새로고침 기능은 나중에.. 🥲');
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
