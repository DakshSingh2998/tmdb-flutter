import 'package:equatable/equatable.dart';
import '../../core/utilities/common_utilities.dart';
import '../dashboard/models/movie_response.dart';

class SearchMovieState extends Equatable {
  final ScreenStatus status;
  final List<Movie> movies;
  final bool hasReachedMax;
  final int currentPage;
  final String toastMessage;

  const SearchMovieState({
    this.status = ScreenStatus.initial,
    this.movies = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.toastMessage = "",
  });

  SearchMovieState copyWith({
    ScreenStatus? status,
    List<Movie>? movies,
    bool? hasReachedMax,
    int? currentPage,
    String? toastMessage,
  }) {
    return SearchMovieState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      toastMessage: toastMessage ?? this.toastMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movies,
    hasReachedMax,
    currentPage,
    toastMessage,
  ];
}
