import 'package:flutter/services.dart';

class AutoPrint {
  static const MethodChannel _channel = MethodChannel('auto_print');

  static Future<bool> printPDF(String filePath, String printerUrl) async {
    try {
      final bool result = await _channel.invokeMethod('printPDF', {
        'filePath': filePath,
        'printerUrl': printerUrl,
      });
      return result;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
