import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/check_network.dart';
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
    on<ClearToastMessage>((event, emit) {
      emit(state.copyWith(toastMessage: ""));
    });
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ScreenStatus.loading));
      MovieResponse response;
      MovieResponse? cached;
      PopularMovieCacheManager? cacheManager;
      try {
        cacheManager = await PopularMovieCacheManager.getInstance();
        cached = await cacheManager.getPage(event.page);
      } catch (e) {
        debugPrint(e.toString());
      }

      if (cached != null) {
        // refresh data if needed
        response = cached;
      } else {
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

        response = await movieRepository.fetchMovies(page: event.page);
        try {
          await cacheManager?.savePage(response);
        } catch (e) {
          emit(state.copyWith(status: ScreenStatus.failure));
          debugPrint(e.toString());
        }
      }

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
