import 'package:equatable/equatable.dart';

abstract class SearchMovieEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovies extends SearchMovieEvent {
  final int page;
  FetchMovies(this.page);
}

class ClearToastMessage extends SearchMovieEvent {
  @override
  List<Object?> get props => [];
}
