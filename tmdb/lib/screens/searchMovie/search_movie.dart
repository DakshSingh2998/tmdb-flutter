import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utilities/common_utilities.dart';
import '../../reusable_views/d_textfield.dart';
import '../../reusable_views/movie_card.dart';
import '../../reusable_views/movies_shimmer.dart';
import '../../reusable_views/retry_view.dart';
import '../../services/movie_service.dart';
import '../movieDetail/movie_detail.dart';
import 'search_movie_bloc.dart';
import 'search_movie_event.dart';
import 'search_movie_state.dart';

class SearchMovieView extends StatefulWidget {
  const SearchMovieView({super.key});

  @override
  State<SearchMovieView> createState() => SearchMovieViewState();
}

class SearchMovieViewState extends State<SearchMovieView> {
  late final SearchMovieBloc _bloc;
  late final ScrollController _scrollController;
  DateTime? _lastToastShown;

  @override
  void initState() {
    super.initState();
    _bloc = SearchMovieBloc(MovieRepository());
    _scrollController = ScrollController()..addListener(_onScroll);

    _bloc.controller.addListener(() {
      _bloc.add(FetchMovies(1));
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _bloc.state;
      if (!state.hasReachedMax &&
          state.status != ScreenStatus.loading &&
          _bloc.controller.text.isNotEmpty) {
        _bloc.add(FetchMovies(state.currentPage + 1));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.controller.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text("Search Movies")),
        body: BlocConsumer<SearchMovieBloc, SearchMovieState>(
          listenWhen: (previous, current) =>
              previous.toastMessage != current.toastMessage,
          listener: (context, state) {
            if (state.toastMessage.isNotEmpty) {
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DTextField(
                    config: DTextFieldConfig(
                      hintText: "Search",
                      controller: _bloc.controller,
                    ),
                  ),
                ),

                // if (state.status == ScreenStatus.loading &&
                //     state.movies.isEmpty)
                //   Expanded(
                //     child: GridView.builder(
                //       padding: const EdgeInsets.all(8),
                //       gridDelegate:
                //           const SliverGridDelegateWithFixedCrossAxisCount(
                //             crossAxisCount: 2,
                //             childAspectRatio: 9 / 15,
                //             crossAxisSpacing: 8,
                //             mainAxisSpacing: 8,
                //           ),
                //       itemCount: 1,
                //       itemBuilder: (context, index) {
                //         return MovieShimmer();
                //       },
                //     ),
                //   ),
                if (state.status == ScreenStatus.failure &&
                    state.movies.isEmpty)
                  Center(
                    child: RetryView(
                      message: "Failed to load movies",
                      onRetry: () {
                        _bloc.add(FetchMovies(1));
                      },
                    ),
                  ),
                if (state.status == ScreenStatus.initial &&
                    state.movies.isEmpty)
                  Center(
                    child: Text(
                      "Begin typing to search movies",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _bloc.add(FetchMovies(1));
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 9 / 15,
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
                          return MovieShimmer();
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
