import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemoListController extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    // Timer(const Duration(milliseconds: 150),);
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
