import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_recognition/helper/constant.dart';
import 'package:face_recognition/helper/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../helper/Recognition.dart';
import '../helper/Recognizer.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  late List<CameraDescription> cameras;
  dynamic controller;
  late CameraDescription description = cameras[1];
  bool isBusy = false;
  CameraImage? frame;
  CameraLensDirection camDirec = CameraLensDirection.front;

  late Recognizer recognizer;
  late FaceDetector faceDetector;

  late List<Recognition> recognitions = [];
  // ignore: unused_field
  dynamic _scanResults;

  img.Image? image;

  late Size size;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  String _name = "", _similiarity = "";

  @override
  void initState() {
    super.initState();

    var options =
        FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    faceDetector = FaceDetector(options: options);
    recognizer = Recognizer(sapId: Get.arguments['sap_id'].toString());

    getAvailableCameras();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi"),
      ),
      body: Stack(
        children: [
          controller != null ? CameraPreview(controller) : Container(),
          Column(children: [
            Flexible(
              flex: 1,
              child: Container(),
            ),
            Flexible(
              flex: 1,
              child: Container(
                width: double.maxFinite,
                color: warnaPrimary,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Similiarity : $_similiarity %",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Treshold : ${Prefs.readDouble("treshold")! * 100} %",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      initializeCamera();
    }
  }

  initializeCamera() async {
    controller = CameraController(description, ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
        enableAudio: false);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        if (!isBusy) {
          setState(() {
            isBusy = true;
            frame = image;
          });
          doFaceDetectionOnFrame();
        }
      });
    });
  }

  doFaceDetectionOnFrame() async {
    InputImage? inputImage = getInputImage();
    List<Face> faces = await faceDetector.processImage(inputImage!);
    performFaceRecognition(faces);
  }

  InputImage? getInputImage() {
    final camera =
        camDirec == CameraLensDirection.front ? cameras[1] : cameras[0];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(frame!.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (frame!.planes.length != 1) return null;
    final plane = frame!.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();
    image = Platform.isIOS
        ? _convertBGRA8888ToImage(frame!) as img.Image?
        : _convertNV21(frame!);
    image = img.copyRotate(image!,
        angle: camDirec == CameraLensDirection.front ? 270 : 90);

    if (faces.isEmpty) {
      _name = "No Face Detected";
      _similiarity = "0.0";
    } else if (faces.length > 1) {
      _name = "Multiple Face Detected";
      _similiarity = "0.0";
    } else {
      for (Face face in faces) {
        Rect faceRect = face.boundingBox;
        img.Image croppedFace = img.copyCrop(image!,
            x: faceRect.left.toInt(),
            y: faceRect.top.toInt(),
            width: faceRect.width.toInt(),
            height: faceRect.height.toInt());

        Recognition recognition = recognizer.recognize(croppedFace, faceRect);
        double treshold = 5 - (Prefs.readDouble("treshold")! * 5);
        if (recognition.distance > treshold) {
          _name = "Unknown";
        } else {
          _name = recognition.name;
        }
        _similiarity =
            (((5.0 - recognition.distance) / 5) * 100).toStringAsFixed(2);
        recognitions.add(recognition);
      }
    }

    setState(() {
      isBusy = false;
      _scanResults = recognitions;
    });
  }

  static img.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    final plane = cameraImage.planes[0];

    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: plane.bytes.buffer,
      rowStride: plane.bytesPerRow,
      bytesOffset: 28,
      order: img.ChannelOrder.bgra,
    );
  }

  static img.Image _convertNV21(CameraImage image) {
    final width = image.width.toInt();
    final height = image.height.toInt();

    Uint8List yuv420sp = image.planes[0].bytes;

    final outImg = img.Image(height: height, width: width);
    final int frameSize = width * height;

    for (int j = 0, yp = 0; j < height; j++) {
      int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
      for (int i = 0; i < width; i++, yp++) {
        int y = (0xff & yuv420sp[yp]) - 16;
        if (y < 0) y = 0;
        if ((i & 1) == 0) {
          v = (0xff & yuv420sp[uvp++]) - 128;
          u = (0xff & yuv420sp[uvp++]) - 128;
        }
        int y1192 = 1192 * y;
        int r = (y1192 + 1634 * v);
        int g = (y1192 - 833 * v - 400 * u);
        int b = (y1192 + 2066 * u);

        if (r < 0) {
          r = 0;
        } else if (r > 262143) r = 262143;
        if (g < 0) {
          g = 0;
        } else if (g > 262143) g = 262143;
        if (b < 0) {
          b = 0;
        } else if (b > 262143) b = 262143;

        // I don't know how these r, g, b values are defined, I'm just copying what you had bellow and
        // getting their 8-bit values.
        outImg.setPixelRgb(i, j, ((r << 6) & 0xff0000) >> 16,
            ((g >> 2) & 0xff00) >> 8, (b >> 10) & 0xff);
      }
    }
    return outImg;
  }
}
