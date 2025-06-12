import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EvidenciaPicker {
  static Future<File?> seleccionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) return File(file.path);
    return null;
  }

  static Future<File?> seleccionarVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.camera);
    if (file != null) return File(file.path);
    return null;
  }
}
