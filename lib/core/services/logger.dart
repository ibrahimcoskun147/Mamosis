// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';

/// Application wide logger service
/// This abstraction allows changing logging implementations easily
/// and disabling logs in production.
class Logger {
  static const String _tag = '[App]';

  /// Log debug messages
  static void d(String message, [String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} DEBUG: $message');
    }
  }

  /// Log error messages
  static void e(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} ERROR: $message');
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
    // In production, sending to Crashlytics would go here
  }

  /// Log info messages
  static void i(String message, [String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} INFO: $message');
    }
  }
}
