import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/check_network.dart';
import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/hive/bookmark_movie/bookmark_movie.dart';
import '../../core/utilities/hive/popularMovieCache/popular_movie_cache.dart';
import '../../services/movie_service.dart';
import '../dashboard/models/movie_response.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMoviesBloc extends Bloc<SavedMoviesEvent, SavedMoviesState> {
  SavedMoviesBloc() : super(const SavedMoviesState()) {
    on<FetchMovies>(_onFetchMovies);
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<SavedMoviesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ScreenStatus.loading));

      final cacheManager = await PopularMovieCacheManager.getInstance();
      final bookmarkManager = await BookmarkedMovieManager.getInstance();

      List<Movie> allMovies = [];
      int page = 1;

      while (true) {
        MovieResponse? cachedPage;
        try {
          cachedPage = await cacheManager.getPage(page);
        } catch (e) {
          debugPrint('Error fetching cached page $page: $e');
          break;
        }

        if (cachedPage == null || cachedPage.results.isEmpty) {
          break; // No more pages
        }

        allMovies.addAll(cachedPage.results);
        page++;
      }

      // Filter movies by bookmarked IDs
      final bookmarkedIds = bookmarkManager.allBookmarkedIds.toSet();
      final bookmarkedMovies = allMovies
          .where((movie) => bookmarkedIds.contains(movie.id))
          .toList();

      emit(
        state.copyWith(status: ScreenStatus.success, movies: bookmarkedMovies),
      );
    } catch (e) {
      debugPrint('Error fetching saved movies: $e');
      emit(state.copyWith(status: ScreenStatus.failure));
    }
  }
}
