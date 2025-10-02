import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../core/utilities/common_utilities.dart';
import '../../core/utilities/hive/bookmark_movie/bookmark_movie.dart';
import '../../services/movie_service.dart';
import '../dashboard/models/movie_response.dart';
import 'movie_detail_bloc.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart'; // Import your Bloc or Cubit

class MovieDetailView extends StatefulWidget {
  final Movie movie;
  final bool showSaveButton;

  const MovieDetailView({
    super.key,
    required this.movie,
    this.showSaveButton = true,
  });

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  bool isBookmarked = false;
  late BookmarkedMovieManager _bookmarkManager;
  late final MovieDetailBloc _bloc;

  @override
  void initState() {
    _bloc = MovieDetailBloc();
    super.initState();

    _initBookmark();
  }

  Future<void> _initBookmark() async {
    _bookmarkManager = await BookmarkedMovieManager.getInstance();
    setState(() {
      isBookmarked = _bookmarkManager.isBookmarked(widget.movie.id);
    });
  }

  Future<void> _toggleBookmark() async {
    if (isBookmarked) {
      await _bookmarkManager.removeBookmark(widget.movie.id);
    } else {
      await _bookmarkManager.addBookmark(widget.movie.id);
    }
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<MovieDetailBloc, MovieDetailState>(
        listener: (context, state) {
          if (state.toastMessage.isNotEmpty) {
            if (state.status == ScreenStatus.success) {
              _toggleBookmark();
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.toastMessage)));
            _bloc.add(ClearToastMessage());
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(movie.title),

              actions: widget.showSaveButton
                  ? ((state.status == ScreenStatus.loading)
                        ? [
                            Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            ),
                          ]
                        : [
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                // await _toggleBookmark();
                                context.read<MovieDetailBloc>().add(
                                  MarkAsFavorite(movie.id, !isBookmarked),
                                );
                              },
                            ),
                          ])
                  : null,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://image.tmdb.org/t/p/w300${movie.posterPath}",
                      width: 200,
                      height: 300,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Shimmer(
                            duration: Duration(milliseconds: 1500),
                            child: Container(
                              width: 200,
                              height: 300,
                              color: Colors.grey.shade300,
                            ),
                          ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Original title and language
                  Text(
                    "${movie.originalTitle} (${movie.originalLanguage?.toUpperCase()})",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),

                  // Release date and rating
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          "Release: ${movie.releaseDate}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${movie.voteAverage} (${movie.voteCount})",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Popularity
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Popularity: ${movie.popularity?.toStringAsFixed(1)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Genres (just IDs here, you can map IDs to names)
                  if (movie.genreIds?.isNotEmpty == true)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (movie.genreIds ?? [])
                          .map(
                            (id) => Chip(
                              label: Text("Genre $id"),
                              backgroundColor: Colors.green.shade50,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 16),

                  // Overview
                  const Text(
                    "Overview",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview ?? "",
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
