import 'package:get/get.dart';
import 'package:notepad/src/screen/home/controller/home_controller.dart';
import 'package:notepad/src/screen/home/home.dart';
import 'package:notepad/src/screen/memo/controller/memo_view_controller.dart';
import 'package:notepad/src/screen/memo/view/memo_view.dart';
import 'package:notepad/src/screen/splash/controller/splash_controller.dart';
import 'package:notepad/src/screen/splash/splash.dart';

List<GetPage> route() {
  return [
    GetPage(
        name: Splash.routeName,
        transition: Transition.fadeIn,
        page: () => const Splash(),
        binding: BindingsBuilder(() {
          Get.put(SplashController());
        })),
    GetPage(
        name: Home.routeName,
        transition: Transition.fadeIn,
        page: () => const Home(),
        binding: BindingsBuilder(() {
          Get.put(HomeController());
        })),
    GetPage(
        name: MemoView.routeName,
        transition: Transition.fadeIn,
        page: () => const MemoView(),
        binding: BindingsBuilder(() {
          Get.put(MemoViewController());
        }))
  ];
}
