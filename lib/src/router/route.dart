import 'package:get/get.dart';
import 'package:notepad/src/screen/memo/controller/memo_list_controller.dart';
import 'package:notepad/src/screen/memo/controller/memo_update_controller.dart';
import 'package:notepad/src/screen/memo/controller/memo_view_controller.dart';
import 'package:notepad/src/screen/memo/view/memo_list.dart';
import 'package:notepad/src/screen/memo/view/memo_update.dart';
import 'package:notepad/src/screen/memo/view/memo_view.dart';
import 'package:notepad/src/screen/splash/controller/splash_controller.dart';
import 'package:notepad/src/screen/splash/splash.dart';

List<GetPage> route() {
  return [
    GetPage(
        name: Splash.routeName,
        transition: Transition.fadeIn,
        page: () => const Splash(),
        popGesture: true,
        binding: BindingsBuilder(() {
          Get.put(SplashController());
        })),
    GetPage(
        name: MemoList.routeName,
        transition: Transition.fadeIn,
        page: () => const MemoList(),
        popGesture: true,
        binding: BindingsBuilder(() {
          Get.put(MemoListController());
        })),
    GetPage(
        name: MemoView.routeName,
        transition: Transition.fadeIn,
        page: () => const MemoView(),
        popGesture: true,
        binding: BindingsBuilder(() {
          Get.put(MemoViewController());
        })),
    GetPage(
        name: MemoUpdate.routeName,
        transition: Transition.fadeIn,
        page: () => MemoUpdate(),
        popGesture: true,
        binding: BindingsBuilder(() {
          Get.put(MemoUpdateController());
        })),
  ];
}
