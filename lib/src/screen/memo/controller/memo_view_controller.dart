import 'package:get/get.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';

class MemoViewController extends GetxController {
  late MemoDTO memo;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    memo = Get.arguments;
  }
}
