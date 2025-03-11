// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pdfx/pdfx.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(PrintServiceApp());
// }

// class PrintServiceApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Print Service',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: MainScreen(),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   final pdfController = PdfController(
//     document: PdfDocument.openAsset('assets/sample.pdf'), // Add a sample PDF
//   );

//   void sendToPrinters() {
//     // Implement sending logic
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Sending PDF to printers...")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Print Service")),
//       body: Column(
//         children: [
//           Expanded(
//             child: PdfView(controller: pdfController),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: sendToPrinters,
//               child: Text("Send to Printers"),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => PrintersScreen()),
//           );
//         },
//         child: Icon(Icons.print),
//       ),
//     );
//   }
// }

// class PrintersScreen extends StatefulWidget {
//   @override
//   _PrintersScreenState createState() => _PrintersScreenState();
// }

// class _PrintersScreenState extends State<PrintersScreen> {
//   List<String> printers = [];

//   @override
//   void initState() {
//     super.initState();
//     loadPrinters();
//   }

//   Future<void> loadPrinters() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       printers = prefs.getStringList('printers') ?? [];
//     });
//   }

//   Future<void> addPrinter() async {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Add Printer"),
//         content: TextField(
//             controller: controller,
//             decoration: InputDecoration(hintText: "Enter Printer IP")),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               if (controller.text.isNotEmpty) {
//                 final prefs = await SharedPreferences.getInstance();
//                 setState(() {
//                   printers.add(controller.text);
//                   prefs.setStringList('printers', printers);
//                 });
//               }
//               Navigator.pop(context);
//             },
//             child: Text("Add"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> removePrinter(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       printers.removeAt(index);
//       prefs.setStringList('printers', printers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Printers"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context), // Back button functionality
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: printers.length,
//         itemBuilder: (context, index) => ListTile(
//           title: Text(printers[index]),
//           trailing: IconButton(
//             icon: Icon(Icons.delete, color: Colors.red),
//             onPressed: () => removePrinter(index),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: addPrinter,
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// class PrintService {
//   static const platform = MethodChannel('print_service');

//   static Future<void> startPrintJob() async {
//     try {
//       await platform.invokeMethod('startPrintJob');
//     } on PlatformException catch (e) {
//       print("Failed to start print job: '${e.message}'.");
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:printing/printing.dart';
// import 'dart:io';

// void main() {
//   runApp(MaterialApp(home: PrintScreen()));
// }

// class PrintScreen extends StatefulWidget {
//   @override
//   _PrintScreenState createState() => _PrintScreenState();
// }

// class _PrintScreenState extends State<PrintScreen> {
//   static const platform = MethodChannel("printing_channel");
//   String? filePath;

//   @override
//   void initState() {
//     super.initState();
//     platform.setMethodCallHandler((call) async {
//       if (call.method == "printDocument") {
//         setState(() {
//           filePath = call.arguments;
//         });
//         if (filePath != null) {
//           printPDF(filePath!);
//         }
//       }
//     });
//   }

//   void printPDF(String path) async {
//     final file = File(path);
//     if (await file.exists()) {
//       Printing.layoutPdf(
//         onLayout: (format) => file.readAsBytes(),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Custom Print Service")),
//       body: Center(
//         child: Text(filePath == null ? "Waiting for file..." : "Printing: $filePath"),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:printing/printing.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? pdfPath;
  Stream<List<SharedMediaFile>>? _intentStreamSubscription;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("PDF Viewer")),
        body: pdfPath == null
            ? Center(child: Text("No PDF received"))
            : PDFViewerScreen(pdfPath: pdfPath!), // Show PDF preview
      ),
    );
  }
}

// ✅ PDF Viewer Screen using `printing`
class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  PDFViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview PDF")),
      body: pdfPath.isEmpty || !File(pdfPath).existsSync()
          ? Center(child: Text("Invalid PDF file"))
          : PdfPreview(
              build: (format) => File(pdfPath).readAsBytesSync(),
            ),
    );
  }
}
