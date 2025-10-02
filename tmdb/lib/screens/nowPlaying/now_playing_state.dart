import 'package:equatable/equatable.dart';
import '../../core/utilities/common_utilities.dart';
import '../dashboard/models/movie_response.dart';

class NowPlayingState extends Equatable {
  final ScreenStatus status;
  final List<Movie> movies;
  final bool hasReachedMax;
  final int currentPage;
  final String toastMessage;

  const NowPlayingState({
    this.status = ScreenStatus.initial,
    this.movies = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.toastMessage = "",
  });

  NowPlayingState copyWith({
    ScreenStatus? status,
    List<Movie>? movies,
    bool? hasReachedMax,
    int? currentPage,
    String? toastMessage,
  }) {
    return NowPlayingState(
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
