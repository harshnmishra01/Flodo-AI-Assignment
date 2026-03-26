import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to access the host's localhost
  static String  baseUrl = "http://127.0.0.1:8000";

  static const String tasksEndpoint = '/api/tasks/';
}