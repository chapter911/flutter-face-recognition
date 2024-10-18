import 'dart:developer';
import 'dart:io';

import 'package:face_recognition/helper/constant.dart';
import 'package:face_recognition/page/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      cekPermission();
    }
    Future.delayed(const Duration(seconds: 2)).then((value) {
      Get.offAll(() => const HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/app_logo.png',
              scale: 3,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              appName,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const CupertinoActivityIndicator()
          ],
        ),
      ),
    );
  }

  void cekPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.camera,
    ].request();
    log(statuses.toString());
  }
}
