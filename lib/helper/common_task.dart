import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> ambilFoto(ImageSource source) async {
  File? foto;
  await ImagePicker()
      .pickImage(source: source, imageQuality: 100)
      .then((value) {
    if (value!.path.isNotEmpty) {
      foto = File(value.path);
    }
  }).catchError((err) {});
  return foto;
}
