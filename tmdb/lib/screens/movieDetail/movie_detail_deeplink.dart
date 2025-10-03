import 'package:flutter/material.dart';

import '../../core/utilities/common_utilities.dart';
import '../../services/movie_service.dart';
import '../dashboard/models/movie_response.dart';
import 'movie_detail.dart';

class MovieDetailDeeplink extends StatefulWidget {
  final int movieId;

  const MovieDetailDeeplink({super.key, required this.movieId});

  @override
  State<MovieDetailDeeplink> createState() => MovieDetailDeeplinkState();
}

class MovieDetailDeeplinkState extends State<MovieDetailDeeplink> {
  Movie? movie;
  ScreenStatus status = ScreenStatus.loading;
  MovieRepository movieRepository = MovieRepository();

  @override
  void initState() {
    super.initState();
    _callApi();
  }

  Future<void> _callApi() async {
    try {
      if (!mounted) return;
      final movie = await movieRepository.fetchMovieDetails(
        movieId: widget.movieId,
      );
      if (!mounted) return;
      setState(() {
        this.movie = movie;
        status = ScreenStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = ScreenStatus.failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (status == ScreenStatus.loading)
        ?  Scaffold(appBar: AppBar(title: Text(widget.movieId.toString()),), body: Center(child: CircularProgressIndicator()))
        : (movie != null)
        ? MovieDetailView(movie: movie!, showSaveButton: false)
        : Scaffold(appBar: AppBar(title: Text(widget.movieId.toString()),),body: Center(child: Text("failedToLoadMovies".loc)));
  }
}
