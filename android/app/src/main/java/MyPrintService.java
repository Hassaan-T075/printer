package com.example.printer;

import android.printservice.PrintService;
import android.printservice.PrintJob;
import android.printservice.PrinterDiscoverySession;
import android.print.PrinterId;
import android.print.PrinterInfo;
import android.util.Log;

import java.util.List;
import java.util.ArrayList;

public class MyPrintService extends PrintService {

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("MyPrintService", "Print Service Created");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("MyPrintService", "Print Service Destroyed");
    }

    @Override
    public void onPrintJobQueued(PrintJob printJob) {
        Log.d("MyPrintService", "Print job queued: " + printJob.getId());
        // Handle print job processing
    }

    @Override
    public void onRequestCancelPrintJob(PrintJob printJob) {
        printJob.cancel();
        Log.d("MyPrintService", "Print job canceled");
    }

    @Override
    public PrinterDiscoverySession onCreatePrinterDiscoverySession() {
        return new PrinterDiscoverySession() {
            private final List<PrinterInfo> printers = new ArrayList<>();

            @Override
            public void onStartPrinterDiscovery(List<PrinterId> priorityList) {
                Log.d("MyPrintService", "Printer discovery started");
                
                PrinterId printerId = generatePrinterId("My Custom Printer");
                PrinterInfo printerInfo = new PrinterInfo.Builder(printerId, "My Custom Printer", PrinterInfo.STATUS_IDLE).build();
                
                printers.add(printerInfo);
                addPrinters(printers);
            }

            @Override
            public void onStopPrinterDiscovery() {
                Log.d("MyPrintService", "Printer discovery stopped");
            }

            @Override
            public void onValidatePrinters(List<PrinterId> printerIds) {
                Log.d("MyPrintService", "Validating printers...");
            }

            @Override
            public void onStartPrinterStateTracking(PrinterId printerId) {
                Log.d("MyPrintService", "Tracking printer state for: " + printerId);
            }

            @Override
            public void onStopPrinterStateTracking(PrinterId printerId) {
                Log.d("MyPrintService", "Stopped tracking printer state for: " + printerId);
            }

            @Override
            public void onDestroy() {
                Log.d("MyPrintService", "Printer discovery session destroyed");
                printers.clear();
            }
        };
    }
}


// ----------------------------------------------------

// package com.example.printer;

// import android.printservice.PrintDocument;
// import android.printservice.PrintJob;
// import android.printservice.PrintService;
// import android.print.PrinterId;
// import android.print.PrinterInfo;
// import android.printservice.PrinterDiscoverySession;

// import java.util.List;

// public class MyPrintService extends PrintService {
//     @Override
//     protected void onConnected() {
//         super.onConnected();
//     }

//     @Override
//     protected void onDisconnected() {
//         super.onDisconnected();
//     }

//         @Override
//     public PrinterDiscoverySession onCreatePrinterDiscoverySession() {
//         return new PrinterDiscoverySession() {
//             @Override
//             public void onStartPrinterDiscovery(List<PrinterId> priorityList) {
//                 // Start discovering printers
//             }

//             @Override
//             public void onStopPrinterDiscovery() {
//                 // Stop discovering printers
//             }

//             @Override
//             public void onValidatePrinters(List<PrinterId> printerIds) {
//                 // Validate printers
//             }

//             @Override
//             public void onStartPrinterStateTracking(PrinterId printerId) {
//                 // Start tracking printer state
//             }

//             @Override
//             public void onStopPrinterStateTracking(PrinterId printerId) {
//                 // Stop tracking printer state
//             }

//             @Override
//             public void onDestroy() {
//                 // Clean up resources
//             }
//         };
//     }

// // @Override
// // public PrinterDiscoverySession onCreatePrinterDiscoverySession() {
// //     return new PrinterDiscoverySession() {
// //         @Override
// //         public void onStartPrinterDiscovery(List<PrinterId> priorityList) {
// //             // Start discovering printers
// //         }

// //         @Override
// //         public void onStopPrinterDiscovery() {
// //             // Stop discovering printers
// //         }

// //         @Override
// //         public void onValidatePrinters(List<PrinterId> printerIds) {
// //             // Validate printers
// //         }

// //         @Override
// //         public void onStartPrinterStateTracking(PrinterId printerId) {
// //             // Start tracking printer state
// //         }

// //         @Override
// //         public void onStopPrinterStateTracking(PrinterId printerId) {
// //             // Stop tracking printer state
// //         }

// //         @Override
// //         public void onDestroy() {
// //             // Clean up resources
// //         }
// //     };
// // }


//     @Override
//     public void onRequestCancelPrintJob(PrintJob printJob) {
//         // Handle print job cancellation
//     }

//     @Override
//     public void onPrintJobQueued(PrintJob printJob) {
//         // Handle print job
//     }
// }

// package com.example.printer;

// import android.print.PrintDocumentAdapter;
// import android.printservice.PrintJob;
// import android.printservice.PrintService;
// import android.printservice.PrinterDiscoverySession;
// import android.print.PrinterId;
// import android.print.PrinterInfo;
// import android.print.PrinterCapabilitiesInfo;
// import android.os.ParcelFileDescriptor;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.embedding.engine.dart.DartExecutor;
// import io.flutter.plugin.common.MethodChannel;

// import java.util.List;
// import java.util.ArrayList;

// public class MyPrintService extends PrintService {
//     private static final String CHANNEL = "printer_service";

//     @Override
//     protected void onPrintJobQueued(PrintJob printJob) {
//         // Send the print job file path to Flutter
//         String filePath = printJob.getDocument().getData().toString();

//         FlutterEngine engine = new FlutterEngine(this);
//         new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onPrintJobReceived", filePath);

//         printJob.complete();
//     }

//     @Override
//     protected PrinterDiscoverySession onCreatePrinterDiscoverySession() {
//         return new PrinterDiscoverySession() {
//             @Override
//             public void onStartPrinterDiscovery(List<PrinterId> priorityList) {
//                 List<PrinterInfo> printers = new ArrayList<>();
//                 PrinterId myPrinterId = generatePrinterId("My_Custom_Printer");
//                 printers.add(new PrinterInfo.Builder(myPrinterId, "My Custom Printer", PrinterInfo.STATUS_IDLE).build());
//                 addPrinters(printers);
//             }

//             @Override
//             public void onStopPrinterDiscovery() {}

//             @Override
//             public void onValidatePrinters(List<PrinterId> printerIds) {}

//             @Override
//             public void onStartPrinterStateTracking(PrinterId printerId) {}

//             @Override
//             public void onStopPrinterStateTracking(PrinterId printerId) {}

//             @Override
//             public void onDestroy() {}
//         };
//     }

//     @Override
//     protected void onRequestCancelPrintJob(PrintJob printJob) {
//         printJob.cancel();
//     }
// }
