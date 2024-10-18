import 'package:face_recognition/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as g;

import '../login_page.dart';
import 'sharedpreferences.dart';

class Api {
  String? status, message;
  List<dynamic>? data;

  Api({this.status, this.message, this.data});

  factory Api.result(dynamic object) {
    return Api(
      status: object['status'],
      message: object['message'],
      data: object['data'],
    );
  }

  static Future<Api?> getData(BuildContext context, String url) async {
    EasyLoading.show(
      status: 'Mohon Tunggu',
      dismissOnTap: false,
    );
    late String? username = Prefs.readString("username");
    late String? apikey = Prefs.readString("apikey");

    String baseUrl = "$linkApi$url";

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: "application/json;charset=utf-8",
      headers: {"username": username, "apikey": apikey},
    );

    Dio dio = Dio(options);

    Api? returnData;

    try {
      Response response = await dio.get(baseUrl);

      if (response.statusCode == 200) {
        dynamic listData = response.data;

        returnData = Api.result(listData);
      } else {
        dynamic listData = {
          "status": "failed",
          "message": "Koneksi Bermasalah",
          "data": null
        };

        returnData = Api.result(listData);
      }
    } catch (e) {
      dynamic listData = {
        "status": "failed",
        "message": "Terdapat Masalah Saat Melakukan Koneksi ke Server",
        "data": null
      };

      returnData = Api.result(listData);
    }

    if (returnData.status != "success") {
      g.Get.snackbar(
        returnData.status!,
        returnData.message!,
        colorText: Colors.white,
        backgroundColor: Colors.red[900],
      );
    }

    if (returnData.status == "logout") {
      Prefs().clearData();
      g.Get.offAll(() => const LoginPage());
    }
    EasyLoading.dismiss();
    return returnData;
  }

  static Future<Api?> postData(
      BuildContext context, String url, var data) async {
    EasyLoading.show(
      status: 'Mohon Tunggu',
      dismissOnTap: false,
    );
    late String? username = Prefs.readString("username");
    late String? apikey = Prefs.readString("apikey");

    String baseUrl = "$linkApi$url";

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: "application/json;charset=utf-8",
      headers: {"username": username, "apikey": apikey},
    );

    Dio dio = Dio(options);

    Api? returnData;

    try {
      Response response = await dio.post(baseUrl, data: data);

      if (response.statusCode == 200) {
        dynamic listData = response.data;

        returnData = Api.result(listData);
      } else {
        dynamic listData = {
          "status": "failed",
          "message": "Koneksi Bermasalah",
          "data": null
        };

        returnData = Api.result(listData);
      }
    } catch (e) {
      dynamic listData = {
        "status": "failed",
        "message": "Terdapat Masalah Saat Melakukan Koneksi ke Server",
        "data": null
      };

      returnData = Api.result(listData);
    }

    if (returnData.status != "success") {
      g.Get.snackbar(
        returnData.status!,
        returnData.message!,
        colorText: Colors.white,
        backgroundColor: Colors.red[900],
      );
    }

    if (returnData.status == "logout") {
      Prefs().clearData();
      g.Get.offAll(() => const LoginPage());
    }
    EasyLoading.dismiss();
    return returnData;
  }

  static Future<Api?> postDataMultiPart(
      BuildContext context, String url, FormData formData) async {
    EasyLoading.show(
      status: 'Mohon Tunggu',
      dismissOnTap: false,
    );
    late String? username = Prefs.readString("username");
    late String? apikey = Prefs.readString("apikey");

    String baseUrl = "$linkApi$url";

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: "application/json;charset=utf-8",
      headers: {"username": username, "apikey": apikey},
    );

    Dio dio = Dio(options);

    Api? returnData;

    try {
      Response response = await dio.post(
        baseUrl,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        dynamic listData = response.data;

        returnData = Api.result(listData);
      } else {
        dynamic listData = {
          "status": "failed",
          "message": "Koneksi Bermasalah",
          "data": null
        };

        returnData = Api.result(listData);
      }
    } catch (e) {
      dynamic listData = {
        "status": "failed",
        "message": "Terdapat Masalah Saat Melakukan Koneksi ke Server",
        "data": null
      };

      returnData = Api.result(listData);
    }

    if (returnData.status != "success") {
      g.Get.snackbar(
        returnData.status!,
        returnData.message!,
        colorText: Colors.white,
        backgroundColor: Colors.red[900],
      );
    }

    if (returnData.status == "logout") {
      Prefs().clearData();
      g.Get.offAll(() => const LoginPage());
    }
    EasyLoading.dismiss();
    return returnData;
  }
}
