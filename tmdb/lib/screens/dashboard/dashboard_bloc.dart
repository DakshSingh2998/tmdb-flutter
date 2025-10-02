import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/network/check_network.dart';
import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/sql/movies_db_helper.dart';
import '../../services/movie_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'models/movie_response.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MovieRepository movieRepository;
  final dbHelper = MovieDBHelper();

  DashboardBloc(this.movieRepository) : super(const DashboardState()) {
    on<FetchMovies>(
      _onFetchMovies,
      transformer: (events, mapper) {
        final paginated = concurrent<FetchMovies>().call(events, mapper);

        return MergeStream([paginated]);
      },
    );
    on<ClearToastMessage>((event, emit) {
      emit(state.copyWith(toastMessage: ""));
    });
  }
  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      if (state.status == ScreenStatus.loading) return;

      emit(state.copyWith(status: ScreenStatus.loading));

      final cachedMovies = await dbHelper.getMoviesByPage(
        event.page,
        pageSize: 20,
      );

      if (cachedMovies.isNotEmpty) {
        emit(
          state.copyWith(
            status: ScreenStatus.success,
            movies: event.page == 1
                ? cachedMovies
                : [...state.movies, ...cachedMovies],
            currentPage: event.page,
            hasReachedMax: cachedMovies.length < 20,
          ),
        );
      }

      if (!await hasInternetConnection()) {
        if (cachedMovies.isEmpty) {
          emit(
            state.copyWith(
              toastMessage: "pleaseConnectToInternet".loc,
              status: ScreenStatus.success,
            ),
          );
        }
        return;
      }

      final response = await movieRepository.fetchMovies(page: event.page);
      final apiMovies = response.results;

      if (apiMovies.isEmpty) return;

      bool hasNewData = false;
      final existingIds =
          (cachedMovies.isNotEmpty ? cachedMovies : state.movies)
              .map((m) => m.id)
              .toSet();

      for (final movie in apiMovies) {
        await dbHelper.insertOrUpdateMovie(movie);
        if (!existingIds.contains(movie.id)) hasNewData = true;
      }

      if (hasNewData || cachedMovies.isEmpty) {
        final updatedMovies = event.page == 1
            ? apiMovies
            : [...state.movies, ...apiMovies];

        emit(
          state.copyWith(
            status: ScreenStatus.success,
            movies: updatedMovies,
            currentPage: event.page,
            hasReachedMax: apiMovies.length < 20,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ScreenStatus.failure,
          toastMessage: "failedToLoadMovies".loc,
        ),
      );
      debugPrint(e.toString());
    }
  }

  Future<bool> hasInternetConnection() async {
    final checker = NetworkChecker();
    return await checker.isConnected();
  }
}
