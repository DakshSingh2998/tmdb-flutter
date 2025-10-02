import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../screens/dashboard/models/movie_response.dart';

class MovieDBHelper {
  static final MovieDBHelper _instance = MovieDBHelper._internal();
  factory MovieDBHelper() => _instance;
  MovieDBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'movies.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE movies(
      id INTEGER PRIMARY KEY,
      title TEXT,
      posterPath TEXT,
      adult INTEGER,
      backdropPath TEXT,
      genreIds TEXT,
      originalLanguage TEXT,
      originalTitle TEXT,
      overview TEXT,
      popularity REAL,
      releaseDate TEXT,
      video INTEGER,
      voteAverage REAL,
      voteCount INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE now_playing_movies(
      id INTEGER PRIMARY KEY,
      title TEXT,
      posterPath TEXT,
      adult INTEGER,
      backdropPath TEXT,
      genreIds TEXT,
      originalLanguage TEXT,
      originalTitle TEXT,
      overview TEXT,
      popularity REAL,
      releaseDate TEXT,
      video INTEGER,
      voteAverage REAL,
      voteCount INTEGER
    )
  ''');
  }

  Future<void> insertOrUpdateNowPlayingMovie(Movie movie) async {
    final db = await database;
    await db.insert('now_playing_movies', {
      'id': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'adult': movie.adult == true ? 1 : 0,
      'backdropPath': movie.backdropPath,
      'genreIds': movie.genreIds?.join(','),
      'originalLanguage': movie.originalLanguage,
      'originalTitle': movie.originalTitle,
      'overview': movie.overview,
      'popularity': movie.popularity,
      'releaseDate': movie.releaseDate,
      'video': movie.video ? 1 : 0,
      'voteAverage': movie.voteAverage,
      'voteCount': movie.voteCount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateMovie(Movie movie) async {
    final db = await database;
    await db.insert('movies', {
      'id': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'adult': movie.adult == true ? 1 : 0,
      'backdropPath': movie.backdropPath,
      'genreIds': movie.genreIds?.join(','),
      'originalLanguage': movie.originalLanguage,
      'originalTitle': movie.originalTitle,
      'overview': movie.overview,
      'popularity': movie.popularity,
      'releaseDate': movie.releaseDate,
      'video': movie.video ? 1 : 0,
      'voteAverage': movie.voteAverage,
      'voteCount': movie.voteCount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Movie>> getNowPlayingMoviesByPage(
    int page, {
    int pageSize = 20,
    String? query,
  }) async {
    final db = await database;
    final offset = (page - 1) * pageSize;

    String? where;
    List<dynamic>? whereArgs;

    if (query != null && query.isNotEmpty) {
      where = 'title LIKE ?';
      whereArgs = ['%$query%'];
    }

    final maps = await db.query(
      'now_playing_movies',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'popularity DESC',
      limit: pageSize,
      offset: offset,
    );

    return maps.map((map) => _mapToMovie(map)).toList();
  }

  Future<List<Movie>> getMoviesByPage(
    int page, {
    int pageSize = 20,
    String? query,
    Set<int>? ids,
  }) async {
    final db = await database;
    final offset = (page - 1) * pageSize;

    String? where;
    List<dynamic>? whereArgs;

    final conditions = <String>[];
    final args = <dynamic>[];

    if (query != null && query.isNotEmpty) {
      conditions.add('title LIKE ?');
      args.add('%$query%');
    }

    if (ids != null) {
      if (ids.isEmpty) {
        return [];
      }
      final placeholders = List.filled(ids.length, '?').join(',');
      conditions.add('id IN ($placeholders)');
      args.addAll(ids);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
      whereArgs = args;
    }

    final maps = await db.query(
      'movies',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'popularity DESC',
      limit: pageSize,
      offset: offset,
    );

    return maps.map((map) => _mapToMovie(map)).toList();
  }

  Movie _mapToMovie(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      adult: map['adult'] == 1,
      backdropPath: map['backdropPath'],
      genreIds: map['genreIds'] != null && map['genreIds'].isNotEmpty
          ? (map['genreIds'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : [],
      originalLanguage: map['originalLanguage'],
      originalTitle: map['originalTitle'],
      overview: map['overview'],
      popularity: map['popularity']?.toDouble(),
      releaseDate: map['releaseDate'],
      video: map['video'] == 1,
      voteAverage: map['voteAverage']?.toDouble(),
      voteCount: map['voteCount'],
    );
  }
}
