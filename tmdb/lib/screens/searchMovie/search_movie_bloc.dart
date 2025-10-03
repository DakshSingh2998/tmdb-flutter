import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../core/network/check_network.dart';
import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/sql/movies_db_helper.dart';
import '../../services/movie_service.dart';
import 'search_movie_event.dart';
import 'search_movie_state.dart';

class SearchMovieBloc extends Bloc<SearchMovieEvent, SearchMovieState> {
  final MovieRepository movieRepository;
  final TextEditingController controller = TextEditingController();
  final dbHelper = MovieDBHelper();
  late final StreamSubscription _connectivitySubscription;
  final NetworkChecker _networkChecker = NetworkChecker();

  SearchMovieBloc(this.movieRepository) : super(const SearchMovieState()) {
    on<FetchMovies>(
      _onFetchMovies,
      transformer: (events, mapper) {
        final page1Events = events.where((e) => e.page == 1).share();
        final otherEvents = events.where((e) => e.page != 1).share();

        final debounced = restartable<FetchMovies>().call(
          page1Events.debounceTime(const Duration(milliseconds: 2000)),
          mapper,
        );

        final paginated = concurrent<FetchMovies>().call(otherEvents, mapper);

        return MergeStream([debounced, paginated]);
      },
    );
    // Start listening to connectivity changes
    _connectivitySubscription = _networkChecker.onConnectivityChanged.listen((
      status,
    ) {
      if (status && controller.text.isNotEmpty) {
        add(FetchMovies(1));
      }
    });

    on<ClearToastMessage>((event, emit) {
      emit(state.copyWith(toastMessage: ""));
    });
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<SearchMovieState> emit,
  ) async {
    if (event.page == 1) {
      emit(
        state.copyWith(
          status: ScreenStatus.loading,
          movies: [],
          currentPage: 0,
          hasReachedMax: false,
        ),
      );
    }
    if (controller.text.trim().isEmpty) {
      emit(
        state.copyWith(
          status: ScreenStatus.initial,
          movies: [],
          currentPage: 0,
          hasReachedMax: false,
        ),
      );
      return;
    }
    try {
      emit(state.copyWith(status: ScreenStatus.loading));
      final hasInternet = await hasInternetConnection();
      if (hasInternet) {
        final response = await movieRepository.searchMovies(
          query: controller.text.trim(),
          page: event.page,
        );
        final movies = event.page == 1
            ? response.results
            : (List.of(state.movies)..addAll(response.results));

        emit(
          state.copyWith(
            status: ScreenStatus.success,
            movies: movies,
            currentPage: event.page,
            hasReachedMax: (response.page ?? 0) >= (response.totalPages ?? 0),
          ),
        );
      } else {
        final cachedMovies = await dbHelper.getMoviesByPage(
          event.page,
          query: controller.text.trim(),
        );
        final movies = event.page == 1
            ? cachedMovies
            : (List.of(state.movies)..addAll(cachedMovies));

        emit(
          state.copyWith(
            status: ScreenStatus.success,
            movies: movies,
            currentPage: event.page,
            hasReachedMax: cachedMovies.isEmpty,
            toastMessage: "performingLocalSearch".loc,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: ScreenStatus.failure));
    }
  }

  Future<bool> hasInternetConnection() async {
    return await _networkChecker.isConnected();
  }
}
