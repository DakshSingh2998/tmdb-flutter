import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/reusable_views/movies_shimmer.dart';
import '../../core/utilities/common_utilities.dart';
import '../../main.dart';
import '../../reusable_views/movie_card.dart';
import '../../reusable_views/retry_view.dart';
import '../movieDetail/movie_detail.dart';
import 'saved_movies_bloc.dart';
import 'saved_movies_event.dart';
import 'saved_movies_state.dart';

class SavedMovies extends StatefulWidget {
  SavedMovies({super.key});

  @override
  State<SavedMovies> createState() => _SavedMovieState();
}

class _SavedMovieState extends State<SavedMovies> with RouteAware {
  late final SavedMoviesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SavedMoviesBloc()..add(FetchMovies());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe to RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _bloc.close();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when coming back to this route from another route
  @override
  void didPopNext() {
    super.didPopNext();
    _bloc.add(FetchMovies()); // Refresh movies when returning to this screen
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text("Bookmarked Movies")),
        body: BlocConsumer<SavedMoviesBloc, SavedMoviesState>(
          listener: (context, state) => {},
          builder: (context, state) {
            if (state.status == ScreenStatus.loading && state.movies.isEmpty) {
              return const MovieShimmer();
            }
            if (state.status == ScreenStatus.failure && state.movies.isEmpty) {
              return Center(
                child: RetryView(
                  message: "Failed to load movies",
                  onRetry: () {
                    _bloc.add(FetchMovies());
                  },
                ),
              );
            }
            return state.status == ScreenStatus.success && state.movies.isEmpty
                ? Center(child: Text("No bookmarked movies"))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 cells in a row
                          childAspectRatio:
                              9 / 15, // adjust card height/width ratio
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: state.movies.length,
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
                  );
          },
        ),
      ),
    );
  }
}
