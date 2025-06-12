import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> subirArchivo(File archivo, String carpeta) async {
    try {
      String nombreArchivo = path.basename(archivo.path);
      Reference ref = _storage.ref('$carpeta/$nombreArchivo');
      UploadTask uploadTask = ref.putFile(archivo);
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Error subiendo archivo: $e");
      return null;
    }
  }
}
