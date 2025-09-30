import 'package:equatable/equatable.dart';
import '../../core/utilities/common_utilities.dart';
import 'models/movie_response.dart';

class DashboardState extends Equatable {
  final ScreenStatus status;
  final List<Movie> movies;
  final bool hasReachedMax;
  final int currentPage;

  const DashboardState({
    this.status = ScreenStatus.initial,
    this.movies = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  DashboardState copyWith({
    ScreenStatus? status,
    List<Movie>? movies,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, movies, hasReachedMax, currentPage];
}
