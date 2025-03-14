import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSelectionScreen extends StatefulWidget {
  const PrinterSelectionScreen({super.key});

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

  Future<void> savePrinter(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String printerUrl = "ipp://$ip/ipp/printer";

    setState(() {
      printers.add(Printer(url: printerUrl, name: "Custom Printer"));
    });

    List<String> printerUrls = printers.map((p) => p.url ?? "").toList();
    await prefs.setStringList('printers', printerUrls);
  }

  Future<void> deletePrinter(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      printers.removeAt(index);
    });

    List<String> printerUrls = printers.map((p) => p.url ?? "").toList();
    await prefs.setStringList('printers', printerUrls);
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
