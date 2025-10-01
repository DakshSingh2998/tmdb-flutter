import 'package:equatable/equatable.dart';
import '../../core/utilities/common_utilities.dart';
import '../dashboard/models/movie_response.dart';

class SavedMoviesState extends Equatable {
  final ScreenStatus status;
  final List<Movie> movies;

  const SavedMoviesState({
    this.status = ScreenStatus.initial,
    this.movies = const [],
  });

  SavedMoviesState copyWith({ScreenStatus? status, List<Movie>? movies}) {
    return SavedMoviesState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
    );
  }

  @override
  List<Object?> get props => [status, movies];
}
