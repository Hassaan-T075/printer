// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:printer/printer_selection_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'auto_printer.dart';
import 'pdfviewer.dart';

void main() {
  runApp(
    const MaterialApp(
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
  List<Printer> printers = [];
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();

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

  Future<void> loadPrinters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPrinters = prefs.getStringList('printers');

    if (savedPrinters != null) {
      setState(() {
        printers = savedPrinters.map((p) {
          List<String> parts = p.split('|');
          return Printer(url: parts[1], name: parts[0]);
        }).toList();
      });
    }
  }

  Future<void> printToSelectedPrinter() async {
    if (pdfPath == null) {
      print("No PDF file available!");
      return;
    }

    setState(() {
      isPrinting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    await loadPrinters();

    try {
      for (Printer printer in printers) {
        bool success = await AutoPrint.printPDF(pdfPath!, printer.url);

        if (success) {
          print("Printing started successfully!");
        } else {
          print("Failed to start printing.");
        }
      }
    } catch (e) {
      print("Error while printing: $e");
    } finally {
      setState(() {
        isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "OCTAL ",
                  style: TextStyle(
                    fontFamily: "Lalezar",
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color(0xFF192044),
                  ),
                ),
                TextSpan(
                  text: "CONNECT",
                  style: TextStyle(
                    fontFamily: "Lalezar",
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Color(0xFF00CC99),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: pdfPath == null
                  ? const Center(child: Text("No PDF received"))
                  : PDFViewerScreen(pdfPath: pdfPath ?? ""),
            ),
            Container(
              height: 10,
              width: double.infinity,
              color: const Color(0xFF192044),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192044),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrinterSelectionScreen()),
                  );
                },
                child: const Text(
                  "Manage Printers",
                  style: TextStyle(color: Color(0xFF00CC99)),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192044),
              ),
              onPressed: printToSelectedPrinter,
              child: const Text(
                "Print PDF",
                style: TextStyle(color: Color(0xFF00CC99)),
              ),
            ),
            (isPrinting)
                ? const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Printing",
                          style:
                              TextStyle(fontSize: 15, color: Color(0xFF192044)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00CC99),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
