// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:printer/printer_selection_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'pdfviewer.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? pdfPath; // Stores received PDF path
  Stream<List<SharedMediaFile>>? _intentStreamSubscription;
  Printer? selectedPrinter; // Stores the selected printer

  @override
  void initState() {
    super.initState();
    loadSelectedPrinter();

    // Get the initially shared PDF when app starts
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          pdfPath = value.first.path;
        });
      }
    });

    // Listen for shared PDFs while the app is running
    _intentStreamSubscription = ReceiveSharingIntent.instance.getMediaStream();
    _intentStreamSubscription!.listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          pdfPath = value.first.path;
        });
      }
    }, onError: (err) {
      print("ERROR: $err");
    });
  }

  @override
  void dispose() {
    ReceiveSharingIntent.instance.reset(); // Reset sharing intent
    super.dispose();
  }

  // Load previously selected printer from SharedPreferences
  Future<void> loadSelectedPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? printerUrl = prefs.getString('selectedPrinterUrl');
    if (printerUrl != null) {
      setState(() {
        selectedPrinter = Printer(url: printerUrl, name: 'Saved Printer');
      });
    }
  }

  // Save selected printer
  Future<void> saveSelectedPrinter(Printer printer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPrinterUrl', printer.url ?? '');
    setState(() {
      selectedPrinter = printer;
    });
  }

  // Print the PDF directly to the selected printer
  Future<void> printToSelectedPrinter() async {
    if (selectedPrinter == null) {
      print("No printer selected!");
      return;
    }
    if (pdfPath == null) {
      print("No PDF file available!");
      return;
    }

    // final pdfBytes = File(pdfPath!).readAsBytesSync();
    // await Printing.directPrintPdf(
    //   printer: selectedPrinter!,
    //   onLayout: (_) async => pdfBytes,
    // );
    // print("Printing to ${selectedPrinter!.name}");

    try {
      final pdfBytes = await File(pdfPath!).readAsBytes();

      String printerUrl =
          selectedPrinter!.url!.replaceFirst("ipp://", "http://");

      print(printerUrl);

      // Send a raw IPP request (if printer supports IPP)
      final response = await http.post(
        Uri.parse(printerUrl), // Printer's IPP URL
        headers: {
          'Content-Type': 'application/pdf',
        },
        body: pdfBytes,
      );

      if (response.statusCode == 200) {
        print("Printing successful on ${selectedPrinter!.name}");
      } else {
        print("Printing failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while printing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom PDF Printer")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: pdfPath == null
                  ? const Center(child: Text("No PDF received"))
                  : PDFViewerScreen(pdfPath: pdfPath!),
            ),
            Container(
              height: 10,
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              color: Colors.green,
            ),
            selectedPrinter == null
                ? const Text("No printer selected")
                : Text("Selected Printer: ${selectedPrinter?.url ?? ""}"),
            ElevatedButton(
              onPressed: () async {
                final printer = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrinterSelectionScreen()),
                );
                if (printer != null) saveSelectedPrinter(printer);
              },
              child: const Text("Select Printer"),
            ),
            ElevatedButton(
              onPressed: printToSelectedPrinter,
              child: const Text("Print PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
