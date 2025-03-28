package com.example.printer;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "auto_print";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("printPDF")) {
                        String filePath = call.argument("filePath");
                        String printerUrl = call.argument("printerUrl");
                        if (filePath != null && printerUrl != null) {
                            IPPPrinter ippPrinter = new IPPPrinter(printerUrl);
                            // boolean success = ippPrinter.printPDF(filePath);
                            ippPrinter.printPDF(filePath, new IPPPrinter.PrintCallback() {
                            @Override
                            public void onPrintCompleted(boolean success) {
                                result.success(success);
                            }
                        });
                            // result.success(success);
                        } else {
                            result.error("INVALID_ARGUMENTS", "File path or Printer URL is null", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleIncomingIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIncomingIntent(intent);
    }

    private void handleIncomingIntent(Intent intent) {
        String action = intent.getAction();
        String type = intent.getType();

        if (Intent.ACTION_VIEW.equals(action) && type != null && "application/pdf".equals(type)) {
            Uri uri = intent.getData();
            if (uri != null) {
                Log.d("PrintService", "Opening PDF: " + uri.toString());
            }
        } else if (Intent.ACTION_SEND.equals(action) && "application/pdf".equals(type)) {
            Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
            if (uri != null) {
                Log.d("PrintService", "Receiving PDF via Share: " + uri.toString());
            }
        }
    }
}
