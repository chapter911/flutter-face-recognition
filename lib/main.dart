import 'package:face_recognition/helper/constant.dart';
import 'package:face_recognition/helper/sharedpreferences.dart';
import 'package:face_recognition/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: warnaPrimary,
        colorScheme: ColorScheme.fromSeed(seedColor: warnaPrimary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: warnaPrimary,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: warnaPrimary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    );
  }
}
