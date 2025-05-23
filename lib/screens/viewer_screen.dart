import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class ViewerScreen extends StatefulWidget {
  final String pdfPath;

  const ViewerScreen({super.key, required this.pdfPath});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool isReady = false;
  int totalPages = 0;
  int currentPage = 0;
  late PDFViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer (${currentPage + 1}/$totalPages)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (currentPage > 0) {
                controller.setPage(currentPage - 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              if (currentPage + 1 < totalPages) {
                controller.setPage(currentPage + 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.shareFiles([widget.pdfPath],
                  text: 'Check out this PDF file!');
            },
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            autoSpacing: true,
            enableSwipe: true,
            swipeHorizontal: false,
            pageSnap: true,
            fitEachPage: true,
            onViewCreated: (PDFViewController pdfController) {
              controller = pdfController;
            },
            onRender: (pages) {
              setState(() {
                totalPages = pages ?? 0;
                isReady = true;
              });
            },
            onPageChanged: (page, _) {
              setState(() {
                currentPage = page ?? 0;
              });
            },
            onError: (error) {
              debugPrint('PDF error: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load PDF: $error')),
              );
            },
          ),
          if (!isReady)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
