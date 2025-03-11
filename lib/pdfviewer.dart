import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  PDFViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: pdfPath.isEmpty || !File(pdfPath).existsSync()
          ? Center(child: Text("Invalid PDF file"))
          : PdfPreview(
              useActions: false,
              build: (format) => File(pdfPath).readAsBytesSync(),
            ),
    );
  }
}
