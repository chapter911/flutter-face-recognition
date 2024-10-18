import 'dart:io';
import 'dart:typed_data';

import 'package:face_recognition/helper/Recognition.dart';
import 'package:face_recognition/helper/sharedpreferences.dart';
import 'package:face_recognition/page/absensi_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../helper/Recognizer.dart';
import '../helper/api.dart';
import '../helper/constant.dart';
import '../helper/database_helper.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<Widget> _employeeList = [];

  File? photo;
  FaceDetector? faceDetector;
  late Recognizer? recognizer;

  @override
  void initState() {
    super.initState();
    getEmployee();

    var options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
    );
    faceDetector = FaceDetector(options: options);
    recognizer = Recognizer();

    if (Prefs.checkData("treshold") == false) {
      Prefs().saveDouble("treshold", 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        actions: [
          IconButton(
            onPressed: () {
              getEmployee();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: _employeeList,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateB) => AlertDialog(
                  title: const Text("Set Treshold"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Slider(
                        value: Prefs.readDouble("treshold") ?? 1.0,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: "${Prefs.readDouble("treshold") ?? 1.0}",
                        onChanged: (val) {
                          Prefs().saveDouble("treshold", val);
                          setStateB(() {});
                        },
                      ),
                      Text(
                          "Treshold Value: ${Prefs.readDouble("treshold")! * 100}%"),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("Tutup"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(
          Icons.settings,
        ),
      ),
    );
  }

  void getEmployee() {
    setState(() {
      _employeeList.clear();
    });
    Api.getData(context, "karyawan/getEmployee/*").then((value) {
      if (value!.status == "success") {
        for (var i = 0; i < value.data!.length; i++) {
          _employeeList.add(
            SizedBox(
              width: double.maxFinite,
              child: InkWell(
                onTap: () {
                  DataBaseHelper.getWhere(
                          "employee", "sap_id = '${value.data![i]['sap_id']}'")
                      .then((data) {
                    if (data.isEmpty) {
                      doFaceDetect(value.data![i]);
                    } else {
                      Get.to(() => const AbsensiPage(),
                          arguments: value.data![i]);
                    }
                  });
                },
                onLongPress: () {
                  DataBaseHelper.deleteWhere(
                      "employee", "sap_id", value.data![i]['sap_id']);
                  Get.snackbar("Information", "Employee Reseted");
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: 100,
                        height: 100,
                        color: warnaPrimary,
                        child: CircleAvatar(
                          child: Image.network(linkApi +
                              value.data![i]['photo_location'] +
                              value.data![i]['photo_name']),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(children: [
                                const Text("SAP ID"),
                                const Text(":"),
                                Expanded(
                                  child: Text(
                                    "${value.data![i]['sap_id']}",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ]),
                              TableRow(children: [
                                const Text("Nama"),
                                const Text(":"),
                                Expanded(
                                  child: Text(
                                    "${value.data![i]['nama']}",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        setState(() {
          _employeeList;
        });
      }
    });
  }

  doFaceDetect(var param) async {
    final http.Response responseData = await http.get(
        Uri.parse(linkApi + param['photo_location'] + param['photo_name']));
    Uint8List uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    photo = await File('${tempDir.path}/img').writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    InputImage inputImage = InputImage.fromFile(photo!);
    List<Face> faces = await faceDetector!.processImage(inputImage);

    dynamic image = await photo?.readAsBytes();
    image = await decodeImageFromList(image);

    if (faces.isEmpty) {
      Get.snackbar("Maaf", "Tidak Ada Wajah Terdeteksi");
    } else {
      for (Face face in faces) {
        final Rect boundingBox = face.boundingBox;

        num left = boundingBox.left < 0 ? 0 : boundingBox.left;
        num top = boundingBox.top < 0 ? 0 : boundingBox.top;
        num right = boundingBox.right > image.width
            ? image.width - 1
            : boundingBox.right;
        num bottom = boundingBox.bottom > image.height
            ? image.height - 1
            : boundingBox.bottom;
        num width = right - left;
        num height = bottom - top;

        final bytes = photo!.readAsBytesSync();
        img.Image? faceImg = img.decodeImage(bytes);
        img.Image croppedFace = img.copyCrop(
          faceImg!,
          x: left.toInt(),
          y: top.toInt(),
          width: width.toInt(),
          height: height.toInt(),
        );

        Recognition recognition =
            recognizer!.recognize(croppedFace, boundingBox);
        dialogRegistrasi(
            param, Uint8List.fromList(img.encodeBmp(croppedFace)), recognition);
      }
      setState(() {
        faces;
      });
    }
  }

  void dialogRegistrasi(
      var param, Uint8List cropedFace, Recognition recognition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          color: warnaPrimary,
          padding: const EdgeInsets.all(10),
          child: const Center(
            child: Text(
              "This Face Is Not Registered",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.memory(
              cropedFace,
              width: 200,
              height: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            Text("${param['sap_id']}"),
            const SizedBox(
              height: 10,
            ),
            Text("${param['nama']}"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              DataBaseHelper.insert("employee", {
                "sap_id": param['sap_id'],
                "name": param['nama'],
                "photoEmbedding": recognition.embeddings.join(",")
              });
              Get.back();
              Get.snackbar("Information", "Face Registered");
            },
            child: const Text("Register"),
          ),
        ],
      ),
    );
  }
}
