import 'package:bloc/bloc.dart';

import '../../core/utilities/common_utilities.dart';
import '../../services/movie_service.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

// Bloc
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieRepository movieRepository;

  // Use optional positional or named parameter with default
  MovieDetailBloc({MovieRepository? movieRepository})
    : movieRepository = movieRepository ?? MovieRepository(),
      super(MovieDetailState()) {
    on<MovieDetailEvent>((event, emit) async {
      if (event is MarkAsFavorite) {
        try {
          emit(state.copyWith(status: ScreenStatus.loading));
          final response = await this.movieRepository.markMovieAsFavorite(
            movieId: event.movieId,
            favorite: event.favorite,
          );
          if (response.success) {
            emit(
              state.copyWith(
                status: ScreenStatus.success,
                toastMessage: event.favorite
                    ? "Marked as favorite"
                    : "Removed from favorites",
              ),
            );
          } else {
            emit(
              state.copyWith(
                toastMessage: "Failed to update favorite status",
                status: ScreenStatus.failure,
              ),
            );
          }
        } catch (e) {
          emit(
            state.copyWith(
              toastMessage: "Error: ${e.toString()}",
              status: ScreenStatus.failure,
            ),
          );
        }
      } else if (event is ClearToastMessage) {
        emit(state.copyWith(toastMessage: "", status: ScreenStatus.initial));
      }
    });
  }
}
