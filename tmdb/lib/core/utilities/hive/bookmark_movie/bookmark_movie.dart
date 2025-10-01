import '../commonManager/common_manager.dart';

class BookmarkedMovieManager {
  static BookmarkedMovieManager? _instance;
  BookmarkedMovieManager._internal();

  final Set<int> _bookmarkedIds = {};

  static Future<BookmarkedMovieManager> getInstance() async {
    if (_instance != null) return _instance!;

    final manager = BookmarkedMovieManager._internal();
    await manager.init();
    _instance = manager;
    return manager;
  }

  /// Load bookmarks from storage
  Future<void> init() async {
    try {
      final manager = await _getStorageManager();
      final storedIds = await manager.getWithKey(
        HiveBoxNames.bookmarkedMovies.boxName,
      );
      if (storedIds != null) {
        _bookmarkedIds.addAll(storedIds.cast<int>());
      }
    } catch (_) {}
  }

  /// Add bookmark
  Future<void> addBookmark(int movieId) async {
    _bookmarkedIds.add(movieId);
    await _saveToStorage();
  }

  /// Remove bookmark
  Future<void> removeBookmark(int movieId) async {
    _bookmarkedIds.remove(movieId);
    await _saveToStorage();
  }

  bool isBookmarked(int movieId) => _bookmarkedIds.contains(movieId);

  List<int> get allBookmarkedIds {
    final ids = _bookmarkedIds.toList();
    ids.sort();
    return ids;
  }

  Future<void> clearAll() async {
    _bookmarkedIds.clear();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final manager = await _getStorageManager();
    await manager.saveWithKey(
      HiveBoxNames.bookmarkedMovies.boxName,
      _bookmarkedIds.toList(),
    );
  }

  /// Use CommonManager for persistent storage
  Future<CommonManager<List<int>, dynamic>> _getStorageManager() async {
    final manager = CommonManager<List<int>, int>();
    final hiveBox = HiveBoxNames.bookmarkedMovies;
    await manager.init(
      encrypted: false,
      boxName: hiveBox.boxName,
      adapter: null,
      typeId: hiveBox.typeId,
    );
    return manager;
  }
}
