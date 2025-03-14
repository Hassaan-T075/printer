package com.example.printer;

import de.gmuth.ipp.client.*;
import de.gmuth.ipp.core.*;

import java.io.File;
import java.io.FileInputStream;

import android.util.Log;

import android.os.AsyncTask;

public class IPPPrinter {
    private String printerUrl;
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
                Log.d(TAG, "Attempting to print: " + filePath);
                Log.d(TAG, "Connecting to printer at: " + printerUrl);

                File file = new File(filePath);
                if (!file.exists()) {
                    Log.e(TAG, "ERROR: File not found: " + filePath);
                    return false;
                }

                FileInputStream inputStream = new FileInputStream(file);
                byte[] pdfData = inputStream.readAllBytes();
                inputStream.close();

                IppPrinter printer = new IppPrinter(printerUrl);
                printer.printJob(pdfData);

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

    public interface PrintCallback {
        void onPrintCompleted(boolean success);
    }
}
