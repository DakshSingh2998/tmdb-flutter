import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_response.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class MovieResponse extends HiveObject {
  final int page;

  @JsonKey(name: "results")
  final List<Movie> results;

  @JsonKey(name: "total_pages")
  final int totalPages;

  @JsonKey(name: "total_results")
  final int totalResults;

  MovieResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 2)
class Movie extends HiveObject {
  final int id;

  final String title;

  @JsonKey(name: "poster_path")
  final String? posterPath;

  final bool? adult;

  @JsonKey(name: "backdrop_path")
  final String? backdropPath;

  @JsonKey(name: "genre_ids")
  final List<int>? genreIds;

  @JsonKey(name: "original_language")
  final String? originalLanguage;

  @JsonKey(name: "original_title")
  final String? originalTitle;

  final String? overview;

  final double? popularity;

  @JsonKey(name: "release_date")
  final String? releaseDate;

  final bool video;

  @JsonKey(name: "vote_average")
  final double? voteAverage;

  @JsonKey(name: "vote_count")
  final int? voteCount;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.releaseDate,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
