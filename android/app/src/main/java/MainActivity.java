package com.example.printer;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

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
                // TODO: Pass this URI to Flutter (MethodChannel)
            }
        } else if (Intent.ACTION_SEND.equals(action) && "application/pdf".equals(type)) {
            Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
            if (uri != null) {
                Log.d("PrintService", "Receiving PDF via Share: " + uri.toString());
                // TODO: Pass this URI to Flutter (MethodChannel)
            }
        }
    }
}



// package com.example.printer;

// import android.content.Intent;
// import android.net.Uri;
// import android.os.Bundle;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.plugin.common.MethodChannel;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "printing_channel";

//     @Override
//     protected void onCreate(Bundle savedInstanceState) {
//         super.onCreate(savedInstanceState);
//         handlePrintIntent(getIntent());
//     }

//     @Override
//     protected void onNewIntent(Intent intent) {
//         super.onNewIntent(intent);
//         handlePrintIntent(intent);
//     }

//     private void handlePrintIntent(Intent intent) {
//         if (intent != null && intent.getAction() != null) {
//             if (Intent.ACTION_VIEW.equals(intent.getAction()) || 
//                 "android.print.PRINT_DOCUMENT".equals(intent.getAction())) {
                
//                 Uri fileUri = intent.getData();
//                 if (fileUri != null) {
//                     new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                         .invokeMethod("printDocument", fileUri.toString());
//                 }
//             }
//         }
//     }
// }
