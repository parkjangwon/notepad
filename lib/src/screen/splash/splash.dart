import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/constants.dart';
import 'package:notepad/src/screen/splash/controller/splash_controller.dart';

class Splash extends GetView<SplashController> {
  const Splash({super.key});

  static String routeName = "/splash";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              "🐟 메모장 🐢",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: PRIMARY_COLOR),
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: Text(COPY_RIGHT,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  )))
        ],
      ),
    );
  }
}
