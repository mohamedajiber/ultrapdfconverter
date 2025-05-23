import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PDFGenerator {
  static Future<String?> generatePDFfromImages(List<File> images) async {
    try {
      final pdf = pw.Document();

      for (var imageFile in images) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());

        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(child: pw.Image(image)),
        ));
      }

      final output = await getApplicationDocumentsDirectory();
      final filePath =
          '${output.path}/converted_images_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      return null;
    }
  }
}
