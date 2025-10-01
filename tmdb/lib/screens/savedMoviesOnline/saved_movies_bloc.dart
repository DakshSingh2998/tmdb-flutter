import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/check_network.dart';
import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/hive/popularMovieCache/popular_movie_cache.dart';
import '../../services/movie_service.dart';
import '../dashboard/models/movie_response.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMoviesBloc extends Bloc<SavedMoviesEvent, SavedMoviesState> {
  final MovieRepository movieRepository;

  SavedMoviesBloc({MovieRepository? movieRepository})
    : movieRepository = movieRepository ?? MovieRepository(),
      super(SavedMoviesState()) {
    on<FetchMovies>(_onFetchMovies);
    on<ClearToastMessage>((event, emit) {
      emit(state.copyWith(toastMessage: ""));
    });
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<SavedMoviesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ScreenStatus.loading));
      // No cache, fetch and save
      final hasConnection = await hasInternetConnection();
      if (!hasConnection) {
        emit(state.copyWith(status: ScreenStatus.failure));
        if (state.toastMessage.isEmpty) {
          emit(
            state.copyWith(
              toastMessage: "Connect to the internet to load more data",
            ),
          );
        }
        return;
      }

      final response = await movieRepository.fetchFavoriteMovies(
        page: event.page,
      );

      emit(
        state.copyWith(
          status: ScreenStatus.success,
          movies: List.of(state.movies)..addAll(response.results),
          currentPage: response.page,
          hasReachedMax: response.page >= response.totalPages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ScreenStatus.failure));
    }
  }

  Future<bool> hasInternetConnection() async {
    final checker = NetworkChecker();
    return await checker.isConnected();
  }
}
