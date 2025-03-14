// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printer/printer_selection_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'auto_printer.dart';
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

      String printerUrl = selectedPrinter!.url!;

      // String printerUrl =
      //     selectedPrinter!.url!.replaceFirst("ipp://", "http://");

      // print(printerUrl);

      // // Send a raw IPP request (if printer supports IPP)
      // final response = await http.put(
      //   Uri.parse(printerUrl), // Printer's IPP URL
      //   headers: {
      //     'Content-Type': 'application/pdf',
      //   },
      //   body: pdfBytes,
      // );

      Uri uri = Uri.parse(printerUrl);

      // Construct IPP request headers
      // final Uint8List ippRequest = buildIppPrintRequest(pdfBytes);

      List<int> ippRequest = [
        0x01, 0x01, // IPP version 1.1
        0x00, 0x0F, // Identify-Printer operation (0x000F)
        0x00, 0x01, // Request ID
        0x01, // Operation attributes tag
        ...encodeAttribute('printer-uri', selectedPrinter!.url!),
        0x03, // End of attributes
      ];

      bool success = await AutoPrint.printPDF(pdfPath!, printerUrl);

      if (success) {
        print("Printing started successfully!");
      } else {
        print("Failed to start printing.");
      }

      // final response = await http.post(
      //   uri,
      //   headers: {
      //     'Content-Type': 'application/ipp', // IPP requires this content type
      //   },
      //   // body: ippRequest, // Properly formatted IPP request
      //   body: Uint8List.fromList(ippRequest),
      // );

      // if (response.statusCode == 200) {
      //   // print("Printing successful on ${selectedPrinter!.name}");
      //   print("Printing failed: ${response.bodyBytes}");
      // } else {
      //   print("Printing failed: ${response.statusCode}");
      // }
    } catch (e) {
      print("Error while printing: $e");
    }
  }

  Uint8List buildIppPrintRequest(Uint8List pdfData) {
    List<int> request = [];

    // IPP Header (Version 1.1, Print-Job operation)
    request.addAll([0x01, 0x01]); // IPP version 1.1
    request.addAll([0x00, 0x02]); // Print-Job operation (0x0002)
    request.addAll([0x00, 0x01]); // Request ID

    // Operation attributes
    request.add(0x01); // Operation attributes tag
    request.addAll(encodeAttribute('attributes-charset', 'utf-8'));
    request.addAll(encodeAttribute('attributes-natural-language', 'en'));
    request.addAll(encodeAttribute('printer-uri', selectedPrinter!.url!));
    request.addAll(encodeAttribute('requesting-user-name', 'FlutterApp'));
    request.addAll(encodeAttribute('document-format', 'application/pdf'));
    request.addAll(
        encodeAttribute('content-type', 'application/x-www-form-urlencoded'));

    // End of attributes
    request.add(0x03);

    // Document content
    request.addAll(pdfData);

    return Uint8List.fromList(request);
  }

// Helper function to encode IPP attributes
  List<int> encodeAttribute(String name, String value) {
    List<int> data = [];
    data.add(0x47); // String attribute type
    data.add(name.length);
    data.addAll(name.codeUnits);
    data.add(value.length);
    data.addAll(value.codeUnits);
    return data;
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
