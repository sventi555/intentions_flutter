import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'http://10.0.2.2:3001'
          : 'http://localhost:3001';
    } else {
      return 'https://api.intentions.sventi.com';
    }
  }
}
