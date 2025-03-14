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
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? pdfPath; // stores received pdf path
  Stream<List<SharedMediaFile>>? _intentStreamSubscription;
  Printer? selectedPrinter;

  @override
  void initState() {
    super.initState();
    loadSelectedPrinter();

    // get the initially shared pdf when app starts
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          pdfPath = value.first.path;
        });
      }
    });

    // listen for shared pdf while app is running
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
    ReceiveSharingIntent.instance.reset();
    super.dispose();
  }

  Future<void> loadSelectedPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? printerUrl = prefs.getString('selectedPrinterUrl');
    if (printerUrl != null) {
      setState(() {
        selectedPrinter = Printer(url: printerUrl, name: 'Saved Printer');
      });
    }
  }

  Future<void> saveSelectedPrinter(Printer printer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPrinterUrl', printer.url ?? '');
    setState(() {
      selectedPrinter = printer;
    });
  }

  Future<void> printToSelectedPrinter() async {
    if (selectedPrinter == null) {
      print("No printer selected!");
      return;
    }
    if (pdfPath == null) {
      print("No PDF file available!");
      return;
    }

    try {
      String printerUrl = selectedPrinter!.url!;

      Uri uri = Uri.parse(printerUrl);

      bool success = await AutoPrint.printPDF(pdfPath!, printerUrl);

      if (success) {
        print("Printing started successfully!");
      } else {
        print("Failed to start printing.");
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
