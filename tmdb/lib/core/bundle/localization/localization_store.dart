import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationStore {
  static final LocalizationStore _instance = LocalizationStore._internal();

  factory LocalizationStore() => _instance;

  LocalizationStore._internal();

  Map<String, String>? _localizedMap;

  Future<void> load() async {
    final String jsonString = await rootBundle.loadString(
      'assets/lang/en_us.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedMap = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  String translate(String key) {
    if (_localizedMap == null) {
      return key; // Fallback to the key if loading fails
    }
    return _localizedMap![key] ?? key;
  }
}
