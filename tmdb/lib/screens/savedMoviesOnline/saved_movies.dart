import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/reusable_views/movies_shimmer.dart';
import '../../core/utilities/common_utilities.dart';
import '../../reusable_views/movie_card.dart';
import '../../reusable_views/retry_view.dart';
import '../../services/movie_service.dart';
import '../movieDetail/movie_detail.dart';
import 'saved_movies_bloc.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMoviesView extends StatefulWidget {
  const SavedMoviesView({super.key});

  @override
  State<SavedMoviesView> createState() => _SavedMoviesViewState();
}

class _SavedMoviesViewState extends State<SavedMoviesView> {
  late final SavedMoviesBloc _bloc;
  late final ScrollController _scrollController;
  DateTime? _lastToastShown;

  @override
  void initState() {
    super.initState();
    _bloc = SavedMoviesBloc()..add(FetchMovies(page: 1));
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _bloc.state;
      if (!state.hasReachedMax && state.status != ScreenStatus.loading) {
        _bloc.add(FetchMovies(page: state.currentPage + 1));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text("Saved Movies")),
        body: BlocConsumer<SavedMoviesBloc, SavedMoviesState>(
          listenWhen: (previous, current) =>
              previous.toastMessage != current.toastMessage,
          listener: (context, state) {
            if (state.toastMessage.isEmpty == false) {
              final now = DateTime.now();
              if (_lastToastShown == null ||
                  now.difference(_lastToastShown!) >
                      const Duration(seconds: 3)) {
                _lastToastShown = now;
                final toastMessage = state.toastMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(toastMessage),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
            _bloc.add(ClearToastMessage());
          },
          builder: (context, state) {
            if (state.status == ScreenStatus.loading && state.movies.isEmpty) {
              return const MovieShimmer();
            }
            if (state.status == ScreenStatus.failure && state.movies.isEmpty) {
              return Center(
                child: RetryView(
                  message: "Failed to load movies",
                  onRetry: () {
                    _bloc.add(FetchMovies(page: state.currentPage + 1));
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _bloc.add(FetchMovies(page: 1)); // Reset to page 1
              },
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cells in a row
                  childAspectRatio: 9 / 15, // adjust card height/width ratio
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.hasReachedMax
                    ? state.movies.length
                    : (state.status == ScreenStatus.loading
                          ? state.movies.length + 1
                          : state.movies.length),
                itemBuilder: (context, index) {
                  if (index >= state.movies.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final movie = state.movies[index];
                  return MovieCard(
                    title: movie.title,
                    overview: movie.overview,
                    posterPath: movie.posterPath,
                    isGrid: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailView(movie: movie),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
