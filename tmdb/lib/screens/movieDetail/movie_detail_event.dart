import 'package:equatable/equatable.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object> get props => [];
}

class MarkAsFavorite extends MovieDetailEvent {
  final int movieId;
  final bool favorite;

  const MarkAsFavorite(this.movieId, this.favorite);

  @override
  List<Object> get props => [movieId, favorite];
}

class ClearToastMessage extends MovieDetailEvent {
  @override
  List<Object> get props => [];
}
