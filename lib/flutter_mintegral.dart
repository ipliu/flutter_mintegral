
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMintegral {
  static const MethodChannel _channel = MethodChannel('flutter_mintegral');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
