import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';

class HiveBoxHelper<T> {
  final String boxName;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Box<T>? _box;

  HiveBoxHelper({required this.boxName});

  /// Initialize Hive box with optional encryption
  Future<void> init({bool encrypted = false}) async {
    if (_box?.isOpen ?? false) return;

    if (!Hive.isBoxOpen(boxName)) {
      if (encrypted) {
        final key = await _getEncryptionKey();
        _box = await Hive.openBox<T>(
          boxName,
          encryptionCipher: HiveAesCipher(key),
        );
      } else {
        _box = await Hive.openBox<T>(boxName);
      }
    } else {
      _box = Hive.box<T>(boxName);
    }
  }

  /// Set item at a key
  Future<void> set(String key, T value) async {
    await _box?.put(key, value);
  }

  /// Get item by key
  T? get(String key) {
    return _box?.get(key);
  }

  /// Delete item by key
  Future<void> delete(String key) async {
    await _box?.delete(key);
  }

  /// Clear the box
  Future<void> clear() async {
    await _box?.clear();
  }

  /// Get all keys
  List<String> getAllKeys() {
    return _box?.keys.cast<String>().toList() ?? [];
  }

  /// Get all values
  List<T> getAllValues() {
    return _box?.values.toList() ?? [];
  }

  /// Check if box contains a key
  bool containsKey(String key) {
    return _box?.containsKey(key) ?? false;
  }

  /// Generate or retrieve encryption key from secure storage
  Future<List<int>> _getEncryptionKey() async {
    const storageKey = 'hive_secure_key';

    String? encodedKey = await _secureStorage.read(key: storageKey);

    if (encodedKey != null) {
      return base64Url.decode(encodedKey);
    }

    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: storageKey, value: base64UrlEncode(key));
    return key;
  }

  /// Close box
  Future<void> close() async {
    await _box?.close();
  }
}
