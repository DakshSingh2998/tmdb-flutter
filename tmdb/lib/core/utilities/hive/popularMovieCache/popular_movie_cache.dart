import '../../../../screens/dashboard/models/movie_response.dart';
import '../commonManager/common_manager.dart';

class PopularMovieCacheManager {
  static PopularMovieCacheManager? _instance;
  PopularMovieCacheManager._internal();

  final Map<int, MovieResponse> _cachedPages = {};

  static Future<PopularMovieCacheManager> getInstance() async {
    if (_instance != null) return _instance!;

    final service = PopularMovieCacheManager._internal();
    await service.init();
    _instance = service;
    return _instance!;
  }

  Future<void> init() async {
    try {
      await getPage(1);
    } catch (_) {}
  }

  Future<void> savePage(MovieResponse pageData) async {
    final manager = await getPageManager();
    final key = 'page_${pageData.page}';
    await manager.saveWithKey(key, pageData);
    _cachedPages[pageData.page ?? 0] = pageData;
  }

  Future<MovieResponse?> getPage(int page) async {
    if (_cachedPages.containsKey(page)) return _cachedPages[page];

    final manager = await getPageManager();
    final key = 'page_$page';
    final data = await manager.getWithKey(key);
    if (data != null) _cachedPages[page] = data;
    return data;
  }

  Future<void> clearAllPages() async {
    final manager = await getPageManager();
    await manager.clear();
    _cachedPages.clear();
  }

  MovieResponse? get memoryPageOne => _cachedPages[1];

  Future<CommonManager<MovieResponse, MovieResponseAdapter>>
  getPageManager() async {
    final manager = CommonManager<MovieResponse, MovieResponseAdapter>();
    final adapter = MovieResponseAdapter();
    final hiveBox = HiveBoxNames.popularMovieCache;
    await manager.init(
      encrypted: false,
      boxName: hiveBox.boxName,
      adapter: adapter,
      typeId: hiveBox.typeId,
    );
    return manager;
  }
}
