import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notepad/src/constants.dart';
import 'package:notepad/src/router/route.dart';
import 'package:notepad/src/screen/splash/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: PRIMARY_COLOR,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        getPages: route(),
        initialRoute: Splash.routeName,
      ),
    );
  }
}
