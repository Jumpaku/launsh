import 'package:flutter/foundation.dart';

class AppLogController extends ChangeNotifier {
  final StringBuffer _buffer = StringBuffer();

  String get log => _buffer.toString();

  void add(String message) {
    _buffer.writeln('[${DateTime.now().toIso8601String()}] $message');
    notifyListeners();
  }

  void clear() {
    _buffer.clear();
    notifyListeners();
  }
}

