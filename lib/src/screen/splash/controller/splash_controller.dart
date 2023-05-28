import 'dart:async';

import 'package:get/get.dart';
import 'package:notepad/src/screen/memo/view/memo_list.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    Timer(const Duration(milliseconds: 500), route);
  }

  void route() async {
    Get.offAllNamed(MemoList.routeName);
    return;
  }
}
