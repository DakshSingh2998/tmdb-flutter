import 'package:hive_ce/hive.dart';
import '../hive_box_helper.dart';

enum HiveBoxNames {
  popularMovieCache('popular_movie_cache', 2);

  final String boxName;
  final int typeId;

  const HiveBoxNames(this.boxName, this.typeId);
}

class CommonManager<T1, T2 extends TypeAdapter<T1>> {
  late String _boxName;
  late HiveBoxHelper<T1> _helper;

  /// 🧊 Init Hive box with encryption
  Future<void> init({
    required bool encrypted,
    required String boxName,
    required T2 adapter,
    required int typeId,
  }) async {
    _boxName = boxName;
    _helper = HiveBoxHelper<T1>(boxName: _boxName);

    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }

    await _helper.init(encrypted: encrypted);
  }

  /// 💾 Save object with a custom key (e.g. page_1)
  Future<void> saveWithKey(String key, T1 object) async {
    await _helper.set(key, object);
  }

  /// 🔄 Get object by key
  Future<T1?> getWithKey(String key) async {
    return _helper.get(key);
  }

  /// ❌ Delete object by key
  Future<void> deleteWithKey(String key) async {
    await _helper.delete(key);
  }

  /// 🧹 Clear entire box
  Future<void> clear() async {
    await _helper.clear();
  }

  /// 📦 Get all keys in the box
  Future<List<String>> getAllKeys() async {
    return _helper.getAllKeys();
  }

  /// 📄 Get all values in the box
  Future<List<T1>> getAllValues() async {
    return _helper.getAllValues();
  }
}
