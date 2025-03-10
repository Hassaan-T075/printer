import android.printservice.PrintDocument;
import android.printservice.PrintJob;
import android.printservice.PrintService;
import android.print.PrinterId;
import android.print.PrinterInfo;
import android.printservice.PrinterDiscoverySession;

import java.util.List;

public class MyPrintService extends PrintService {
    @Override
    protected void onConnected() {
        super.onConnected();
    }

    @Override
    protected void onDisconnected() {
        super.onDisconnected();
    }

        @Override
    public PrinterDiscoverySession onCreatePrinterDiscoverySession() {
        return new PrinterDiscoverySession() {
            @Override
            public void onStartPrinterDiscovery(List<PrinterId> priorityList) {
                // Start discovering printers
            }

            @Override
            public void onStopPrinterDiscovery() {
                // Stop discovering printers
            }

            @Override
            public void onValidatePrinters(List<PrinterId> printerIds) {
                // Validate printers
            }

            @Override
            public void onStartPrinterStateTracking(PrinterId printerId) {
                // Start tracking printer state
            }

            @Override
            public void onStopPrinterStateTracking(PrinterId printerId) {
                // Stop tracking printer state
            }

            @Override
            public void onDestroy() {
                // Clean up resources
            }
        };
    }

// @Override
// public PrinterDiscoverySession onCreatePrinterDiscoverySession() {
//     return new PrinterDiscoverySession() {
//         @Override
//         public void onStartPrinterDiscovery(List<PrinterId> priorityList) {
//             // Start discovering printers
//         }

//         @Override
//         public void onStopPrinterDiscovery() {
//             // Stop discovering printers
//         }

//         @Override
//         public void onValidatePrinters(List<PrinterId> printerIds) {
//             // Validate printers
//         }

//         @Override
//         public void onStartPrinterStateTracking(PrinterId printerId) {
//             // Start tracking printer state
//         }

//         @Override
//         public void onStopPrinterStateTracking(PrinterId printerId) {
//             // Stop tracking printer state
//         }

//         @Override
//         public void onDestroy() {
//             // Clean up resources
//         }
//     };
// }


    @Override
    public void onRequestCancelPrintJob(PrintJob printJob) {
        // Handle print job cancellation
    }

    @Override
    public void onPrintJobQueued(PrintJob printJob) {
        // Handle print job
    }
}
