import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/hive/popularMovieCache/popular_movie_cache.dart';
import '../../services/movie_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'models/movie_response.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MovieRepository movieRepository;

  DashboardBloc(this.movieRepository) : super(const DashboardState()) {
    on<FetchMovies>(_onFetchMovies);
    on<FetchNextPage>(_onFetchNextPage);
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ScreenStatus.loading));

      final cacheManager = await PopularMovieCacheManager.getInstance();
      final cached = await cacheManager.getPage(event.page);

      MovieResponse response;

      if (cached != null) {
        // Fetch fresh data from API
        final fresh = await movieRepository.fetchMovies(page: event.page);

        // If totalPages changed, reset cache and refetch
        if (fresh.totalPages != cached.totalPages) {
          await cacheManager.clearAllPages();
          await cacheManager.savePage(fresh);
          response = fresh;
        } else {
          response = cached;
        }
      } else {
        // No cache, fetch and save
        response = await movieRepository.fetchMovies(page: event.page);
        try {
          await cacheManager.savePage(response);
        } catch (e) {
          print(e);
        }
      }

      emit(
        state.copyWith(
          status: ScreenStatus.success,
          movies: response.results,
          currentPage: response.page,
          hasReachedMax: response.page >= response.totalPages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ScreenStatus.failure));
    }
  }

  Future<void> _onFetchNextPage(
    FetchNextPage event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.hasReachedMax || state.status == ScreenStatus.loading) return;

    try {
      final nextPage = state.currentPage + 1;
      final response = await movieRepository.fetchMovies(page: nextPage);

      emit(
        state.copyWith(
          status: ScreenStatus.success,
          movies: List.of(state.movies)..addAll(response.results),
          currentPage: response.page,
          hasReachedMax: response.page >= response.totalPages,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ScreenStatus.failure));
    }
  }
}
