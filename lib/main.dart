import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(PrintServiceApp());
}

class PrintServiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Print Service',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final pdfController = PdfController(
    document: PdfDocument.openAsset('assets/sample.pdf'), // Add a sample PDF
  );

  void sendToPrinters() {
    // Implement sending logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sending PDF to printers...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Print Service")),
      body: Column(
        children: [
          Expanded(
            child: PdfView(controller: pdfController),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: sendToPrinters,
              child: Text("Send to Printers"),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrintersScreen()),
          );
        },
        child: Icon(Icons.print),
      ),
    );
  }
}

class PrintersScreen extends StatefulWidget {
  @override
  _PrintersScreenState createState() => _PrintersScreenState();
}

class _PrintersScreenState extends State<PrintersScreen> {
  List<String> printers = [];

  @override
  void initState() {
    super.initState();
    loadPrinters();
  }

  Future<void> loadPrinters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      printers = prefs.getStringList('printers') ?? [];
    });
  }

  Future<void> addPrinter() async {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Printer"),
        content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter Printer IP")),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  printers.add(controller.text);
                  prefs.setStringList('printers', printers);
                });
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> removePrinter(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      printers.removeAt(index);
      prefs.setStringList('printers', printers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Printers"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Back button functionality
        ),
      ),
      body: ListView.builder(
        itemCount: printers.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(printers[index]),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => removePrinter(index),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPrinter,
        child: Icon(Icons.add),
      ),
    );
  }
}


class PrintService {
  static const platform = MethodChannel('print_service');

  static Future<void> startPrintJob() async {
    try {
      await platform.invokeMethod('startPrintJob');
    } on PlatformException catch (e) {
      print("Failed to start print job: '${e.message}'.");
    }
  }
}

