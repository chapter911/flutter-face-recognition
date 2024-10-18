import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:face_recognition/helper/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../helper/common_task.dart';
import '../helper/constant.dart';
import '../style/style.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _sapId = TextEditingController();
  final TextEditingController _name = TextEditingController();

  final List<Widget> _employeeList = [];
  File? photo;

  @override
  void initState() {
    super.initState();
    getEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Page"),
        actions: [
          IconButton(
            onPressed: () {
              getEmployee();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _employeeList,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            photo = null;
            _sapId.clear();
            _name.clear();
          });
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setStateB) => AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  title: Container(
                    padding: const EdgeInsets.all(10),
                    color: warnaPrimary,
                    child: const Center(
                      child: Text(
                        "Add Employee",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: photo == null
                            ? const Icon(Icons.person)
                            : Image.file(photo!),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              photo = await ambilFoto(ImageSource.gallery);
                              setStateB(() {});
                            },
                            child: const Text("Galery"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              if (Platform.isAndroid || Platform.isIOS) {
                                photo = await ambilFoto(ImageSource.camera);
                                setStateB(() {});
                              } else {
                                Get.snackbar(
                                  "Error",
                                  "Camera hanya untuk android dan IOs",
                                  backgroundColor: Colors.red[800],
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: const Text("Camera"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _sapId,
                        decoration: Style().dekorasiInput(hint: "SAP ID"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _name,
                        decoration: Style().dekorasiInput(hint: "Name"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        insertEmployee();
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.person_add),
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
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("${value.data![i]['nama']}"),
                      content: Text("${value.data![i]['sap_id']}"),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text("Tutup"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Api.postData(
                              context,
                              "karyawan/delete",
                              {"sap_id": value.data![i]['sap_id']},
                            ).then((value) {
                              Get.back();
                              getEmployee();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Hapus"),
                        ),
                      ],
                    ),
                  );
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

  insertEmployee() async {
    if (photo == null) {
      Get.snackbar("Failed", "Photo is required");
    } else if (_sapId.text == "" || _name.text == "") {
      Get.snackbar("Failed", "All field is required");
    } else {
      Get.back();
      d.FormData formData = d.FormData.fromMap({
        "sap_id": _sapId.text,
        "name": _name.text,
        "created_by": "system",
        "photo": await d.MultipartFile.fromFile(
          photo!.path,
          filename: photo!.path.split('/').last,
        )
      });
      sendData(formData);
    }
  }

  void sendData(formData) {
    Api.postDataMultiPart(context, "karyawan/insert", formData).then((value) {
      if (value!.status == "success") {
        getEmployee();
      }
    });
  }
}
