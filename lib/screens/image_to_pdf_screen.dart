import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_generator.dart';
import '../widgets/custom_button.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  bool isLoading = false;
  String? pdfPath;

  Future<void> pickAndConvertImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final images = result.paths.map((path) => File(path!)).toList();

    setState(() {
      isLoading = true;
      pdfPath = null;
    });

    try {
      final convertedPath = await PDFGenerator.generatePDFfromImages(images);
      if (!mounted) return;

      setState(() {
        pdfPath = convertedPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            convertedPath != null
                ? 'PDF created successfully!'
                : 'PDF creation failed',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images to PDF Converter'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    onPressed: pickAndConvertImages,
                    text: 'Select Images & Convert',
                  ),
                  if (pdfPath != null) ...[
                    const SizedBox(height: 20),
                    Text('PDF saved at:\n$pdfPath',
                        textAlign: TextAlign.center),
                  ],
                ],
              ),
      ),
    );
  }
}
