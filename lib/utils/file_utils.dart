import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  static Future<String> savePdfToDownloads(
      String assetPath, String fileName) async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }

    // Load asset
    final byteData = await rootBundle.load(assetPath);
    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      throw Exception('Downloads directory not found');
    }

    // Write file
    final file = File('${downloadsDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file.path;
  }
}
