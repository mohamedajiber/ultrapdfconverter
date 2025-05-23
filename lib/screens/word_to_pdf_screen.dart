import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/word_converter.dart';
import '../widgets/custom_button.dart';

class WordToPdfScreen extends StatefulWidget {
  const WordToPdfScreen({super.key});

  @override
  State<WordToPdfScreen> createState() => _WordToPdfScreenState();
}

class _WordToPdfScreenState extends State<WordToPdfScreen> {
  bool isLoading = false;
  String? pdfPath;

  Future<void> pickAndConvertWord() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
    );
    if (result == null) return;

    final wordFile = File(result.files.single.path!);

    setState(() {
      isLoading = true;
      pdfPath = null;
    });

    try {
      final convertedPath = await WordConverter.convertWordToPDF(wordFile);
      if (!mounted) return;

      setState(() {
        pdfPath = convertedPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            convertedPath != null
                ? 'Conversion Successful!'
                : 'Conversion failed',
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
        title: const Text('Word to PDF Converter'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    onPressed: pickAndConvertWord,
                    text: 'Select Word File & Convert',
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
