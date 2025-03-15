import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSelectionScreen extends StatefulWidget {
  const PrinterSelectionScreen({super.key});

  @override
  PrinterSelectionScreenState createState() => PrinterSelectionScreenState();
}

class PrinterSelectionScreenState extends State<PrinterSelectionScreen> {
  List<Printer> printers = [];
  TextEditingController ipController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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
        printers = savedPrinters.map((p) {
          List<String> parts = p.split('|'); // Split name and IP
          return Printer(url: parts[1], name: parts[0]);
        }).toList();
      });
    }
  }

  Future<void> savePrinter(String name, String ip) async {
    if (name.isEmpty || ip.isEmpty) {
      _showSnackBar("Both fields are required.");
      return;
    }
    if (name.contains('|')) {
      _showSnackBar("Printer name cannot contain '|'.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      printers.add(Printer(url: "ipp://$ip/ipp/printer", name: name));
    });

    FocusScope.of(context).unfocus();
    nameController.clear();
    ipController.clear();

    List<String> printerEntries =
        printers.map((p) => "${p.name}|${p.url}").toList();
    await prefs.setStringList('printers', printerEntries);
  }

  Future<void> deletePrinter(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      printers.removeAt(index);
    });

    List<String> printerEntries =
        printers.map((p) => "${p.name}|${p.url}").toList();
    await prefs.setStringList('printers', printerEntries);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Printer")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Enter Printer Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ipController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "Enter Printer IP"),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny('-'),
                    FilteringTextInputFormatter.deny(' '),
                    FilteringTextInputFormatter.deny(','),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    savePrinter(
                        nameController.text.trim(), ipController.text.trim());
                  },
                  child: const Text(
                    "Add Printer",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: printers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(printers[index].name),
                    subtitle: Text(printers[index].url ?? ""),
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
          ),
        ],
      ),
    );
  }
}
