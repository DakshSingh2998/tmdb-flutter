import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/check_network.dart';
import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/hive/bookmark_movie/bookmark_movie.dart';
import '../../core/utilities/hive/popularMovieCache/popular_movie_cache.dart';
import '../../core/utilities/sql/movies_db_helper.dart';
import '../../services/movie_service.dart';
import '../dashboard/models/movie_response.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMoviesBloc extends Bloc<SavedMoviesEvent, SavedMoviesState> {
  final dbHelper = MovieDBHelper();
  SavedMoviesBloc() : super(const SavedMoviesState()) {
    on<FetchMovies>(_onFetchMovies);
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<SavedMoviesState> emit,
  ) async {
    try {
      if (state.status == ScreenStatus.loading) {
        return;
      }
      emit(state.copyWith(status: ScreenStatus.loading));

      final bookmarkManager = await BookmarkedMovieManager.getInstance();
      final bookmarkedIds = bookmarkManager.allBookmarkedIds.toSet();

      List<Movie> allMovies = await dbHelper.getMoviesByPage(
        event.page,
        ids: bookmarkedIds,
      );

      emit(
        state.copyWith(
          status: ScreenStatus.success,
          movies: event.page == 1 ? allMovies : [...state.movies, ...allMovies],
          hasReachedMax: allMovies.length < 20,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching saved movies: $e');
      emit(state.copyWith(status: ScreenStatus.failure));
    }
  }
}
