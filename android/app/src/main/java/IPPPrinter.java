package com.example.printer;

import de.gmuth.ipp.client.*;
import de.gmuth.ipp.core.*;

import java.io.File;
import java.io.FileInputStream;

import android.util.Log;

import android.os.AsyncTask;

public class IPPPrinter {
    private String printerUrl; // Example: "http://192.168.1.100:631/ipp/print"
    private static final String TAG = "IPPPrinter";

    public IPPPrinter(String printerUrl) {
        this.printerUrl = printerUrl;
    }

    public void printPDF(String filePath, PrintCallback callback) {
        new PrintTask(printerUrl, callback).execute(filePath);
    }

        private static class PrintTask extends AsyncTask<String, Void, Boolean> {
        private final String printerUrl;
        private final PrintCallback callback;

        PrintTask(String printerUrl, PrintCallback callback) {
            this.printerUrl = printerUrl;
            this.callback = callback;
        }

        @Override
        protected Boolean doInBackground(String... params) {
            try {
                String filePath = params[0];
                Log.d(TAG, "📄 Attempting to print: " + filePath);
                Log.d(TAG, "🖨 Connecting to printer at: " + printerUrl);

                File file = new File(filePath);
                if (!file.exists()) {
                    // Log.e(TAG, "❌ ERROR: File not found: " + filePath);
                    return false;
                }

                FileInputStream inputStream = new FileInputStream(file);
                byte[] pdfData = inputStream.readAllBytes();
                inputStream.close();

                // Log.d(TAG, "✅ PDF loaded successfully, sending print job...");

                IppPrinter printer = new IppPrinter(printerUrl);
                printer.printJob(pdfData);

                // Log.d(TAG, "🎉 Print job sent successfully!");
                return true;

            } catch (Exception e) {
                Log.e(TAG, "🚨 Print job failed!", e);
                return false;
            }
        }

        @Override
        protected void onPostExecute(Boolean result) {
            if (callback != null) {
                callback.onPrintCompleted(result);
            }
        }
    }

    // public boolean printPDF(String filePath) {
    //     try {
    //         // Connect to the IPP Printer
    //         IppPrinter printer = new IppPrinter(printerUrl);

    //         // Load the PDF file
    //         File file = new File(filePath);
    //         if (!file.exists()) {
    //             System.err.println("File not found: " + filePath);
    //             return false;
    //         }

    //         FileInputStream inputStream = new FileInputStream(file);
    //         byte[] pdfData = inputStream.readAllBytes();
    //         inputStream.close();

    //         // // Create the IPP print job
    //         // IppPrintJob printJob = new IppPrintJob(printer, pdfData);
    //         // printJob.addAttribute(new IppAttribute("copies", 1));  // Set number of copies
    //         // printJob.addAttribute(new IppAttribute("print-quality", IppTag.Enum, "high"));

    //         // // Send the print job
    //         // printer.printJob(printJob);

    //         printer.printJob(pdfData);

    //         System.out.println("Print job sent successfully.");
    //         return true;
    //     } catch (Exception e) {
    //         Log.e(TAG, "Print job failed!", e);
    //         e.printStackTrace();
    //         return false;
    //     }
    // }

    public interface PrintCallback {
        void onPrintCompleted(boolean success);
    }
}
