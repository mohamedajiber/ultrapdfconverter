import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:vibration/vibration.dart'; // For more vibration control
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfConverterScreen extends StatefulWidget {
  final List<File> imageFiles;
  const PdfConverterScreen({super.key, required this.imageFiles});

  @override
  State<PdfConverterScreen> createState() => _PdfConverterScreenState();
}

class _PdfConverterScreenState extends State<PdfConverterScreen> {
  bool _isCompleted = false;
  double _progress = 0.0;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _startConversion();
  }

  Future<void> _startConversion() async {
    try {
      final savedPath = await _convertToPdf(widget.imageFiles, (p) {
        if (mounted) setState(() => _progress = p);
      });

      // Vibrate on success - using both packages as examples
      try {
        // Option 1: Using flutter's built-in haptics
        await HapticFeedback.mediumImpact();

        // Option 2: Using vibration package (more control)
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 200, amplitude: 100);
        }
      } catch (e) {
        debugPrint("Vibration error: $e");
      }

      if (mounted) {
        setState(() {
          _isCompleted = true;
          _savedFilePath = savedPath;
        });
      }
    } catch (e) {
      debugPrint("Conversion error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF conversion failed: ${e.toString()}")),
        );
      }
    }
  }

  Future<String> _convertToPdf(
    List<File> images,
    ValueChanged<double> onProgressUpdate,
  ) async {
    final dir = await getTemporaryDirectory();
    final outputPath =
        '${dir.path}/output_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Simulate conversion progress
    for (int i = 0; i < images.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      onProgressUpdate((i + 1) / images.length);
    }

    // Create dummy PDF file
    final pdfFile = File(outputPath);
    await pdfFile.writeAsBytes(List.generate(100, (index) => index % 256));

    return outputPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isCompleted
                        ? Icons.check_circle_outline
                        : Icons.picture_as_pdf,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isCompleted
                        ? "PDF Created Successfully!"
                        : "Converting to PDF...",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  LinearProgressIndicator(
                    value: _isCompleted ? 1.0 : _progress,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 30),
                  if (_isCompleted && _savedFilePath != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await OpenFile.open(_savedFilePath!);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Failed to open PDF: ${e.toString()}")),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Open PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
