import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/reusable_views/movies_shimmer.dart';
import '../../core/utilities/common_utilities.dart';
import '../../services/movie_service.dart';
import 'dashboard_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardBloc _bloc;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _bloc = DashboardBloc(MovieRepository())..add(FetchMovies(1));
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _bloc.state;
      if (!state.hasReachedMax && state.status != ScreenStatus.loading) {
        _bloc.add(FetchNextPage());
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
        appBar: AppBar(title: const Text("Dashboard")),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == ScreenStatus.loading && state.movies.isEmpty) {
              return const MovieShimmer();
            }

            if (state.status == ScreenStatus.failure) {
              return const Center(child: Text("Failed to load movies"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                _bloc.add(FetchMovies(1)); // Reset to page 1
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.movies.length
                    : state.movies.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.movies.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final movie = state.movies[index];
                  return ListTile(
                    title: Text(movie.title),
                    leading: movie.posterPath != null
                        ? Image.network(
                            "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                            width: 50,
                          )
                        : const Icon(Icons.movie),
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
