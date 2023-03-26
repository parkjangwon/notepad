import 'package:get/get.dart';
import 'package:notepad/src/screen/memo/view/memo_write.dart';

class MemoWriteController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    // Timer(const Duration(milliseconds: 150),);
  }

  void writePage() async {
    Get.offAllNamed(MemoWrite.routeName);
  }
}
