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
