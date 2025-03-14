package com.example.printer;

import de.gmuth.ipp.client.*;
import de.gmuth.ipp.core.*;

import java.io.File;
import java.io.FileInputStream;

import android.util.Log;

public class IPPPrinter {
    private String printerUrl; // Example: "http://192.168.1.100:631/ipp/print"
    private static final String TAG = "IPPPrinter";

    public IPPPrinter(String printerUrl) {
        this.printerUrl = printerUrl;
    }

    public boolean printPDF(String filePath) {
        try {
            // Connect to the IPP Printer
            IppPrinter printer = new IppPrinter(printerUrl);

            // Load the PDF file
            File file = new File(filePath);
            if (!file.exists()) {
                System.err.println("File not found: " + filePath);
                return false;
            }

            FileInputStream inputStream = new FileInputStream(file);
            byte[] pdfData = inputStream.readAllBytes();
            inputStream.close();

            // // Create the IPP print job
            // IppPrintJob printJob = new IppPrintJob(printer, pdfData);
            // printJob.addAttribute(new IppAttribute("copies", 1));  // Set number of copies
            // printJob.addAttribute(new IppAttribute("print-quality", IppTag.Enum, "high"));

            // // Send the print job
            // printer.printJob(printJob);

            printer.printJob(pdfData);

            System.out.println("Print job sent successfully.");
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Print job failed!", e);
            e.printStackTrace();
            return false;
        }
    }
}
