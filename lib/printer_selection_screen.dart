import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';

class PrinterSelectionScreen extends StatefulWidget {
  @override
  _PrinterSelectionScreenState createState() => _PrinterSelectionScreenState();
}

class _PrinterSelectionScreenState extends State<PrinterSelectionScreen> {
  List<Printer> printers = [];
  TextEditingController ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPrinters();
  }

  // ✅ Load saved printers from SharedPreferences
  Future<void> loadPrinters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPrinters = prefs.getStringList('printers');

    if (savedPrinters != null) {
      setState(() {
        printers = savedPrinters
            .map((p) => Printer(url: p, name: "Custom Printer"))
            .toList();
      });
    }
  }

  // ✅ Save a new printer by IP
  Future<void> savePrinter(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String printerUrl = "ipp://$ip/ipp/printer";

    setState(() {
      printers.add(Printer(url: printerUrl, name: "Custom Printer"));
    });

    List<String> printerUrls = printers.map((p) => p.url ?? "").toList();
    await prefs.setStringList('printers', printerUrls);
  }

  // ✅ Delete a printer from the list
  Future<void> deletePrinter(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      printers.removeAt(index);
    });

    List<String> printerUrls = printers.map((p) => p.url ?? "").toList();
    await prefs.setStringList('printers', printerUrls);
  }

  // ✅ Print a test document
  Future<void> printTest(Printer printer) async {
    try {
      await Printing.directPrintPdf(
        format: PdfPageFormat.a3,
        printer: printer,
        onLayout: (format) async => await generatePdf(),
      );
    } catch (e) {
      print("Error printing: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Printing failed!")));
    }
  }

  // ✅ Generate a PDF for testing
  Future<Uint8List> generatePdf() async {
    return Uint8List.fromList(await pdfDocument());
  }

  // ✅ Dummy PDF content
  Future<List<int>> pdfDocument() async {
    return await Printing.convertHtml(
      format: PdfPageFormat.a4,
      html: "<h1>Test Print</h1><p>Hello, this is a test print!</p>",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Printer")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ipController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Enter Printer IP"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (ipController.text.isNotEmpty) {
                      savePrinter(ipController.text);
                      ipController.clear();
                    }
                  },
                  child: const Text("Add"),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: printers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(printers[index].name),
                  subtitle: Text(printers[index].url ?? ""),
                  onTap: () {
                    Navigator.pop(
                        context, printers[index]); // return selected printer
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: () => printTest(printers[index]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePrinter(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
