import 'dart:io';

import 'package:face_recognition/helper/constant.dart';
import 'package:face_recognition/page/attendance_page.dart';
import 'package:face_recognition/page/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => const RegisterPage());
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/register.png',
                                scale: 5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              color: warnaPrimary,
                              width: double.maxFinite,
                              child: const Center(
                                child: Text(
                                  "REGISTER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      if (Platform.isAndroid || Platform.isIOS) {
                        Get.to(() => const AttendancePage());
                      } else {
                        Get.snackbar(
                          "Maaf",
                          "Menu Ini Hanya untuk Android atau IOs",
                          backgroundColor: Colors.red[900],
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/attendance.png',
                                scale: 5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              color: warnaPrimary,
                              width: double.maxFinite,
                              child: const Center(
                                child: Text(
                                  "ATENDANCE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
