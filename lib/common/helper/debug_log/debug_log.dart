import 'dart:developer';
import 'package:flutter/foundation.dart'; // dla kDebugMode

void debugLog(String message, {String name = 'App'}) {
  log(message, name: name);
  if (kDebugMode) {
    print('[$name] $message');
  }
}