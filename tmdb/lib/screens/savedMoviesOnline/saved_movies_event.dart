import 'package:equatable/equatable.dart';

abstract class SavedMoviesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovies extends SavedMoviesEvent {
  final int page;

  FetchMovies({required this.page});

  @override
  List<Object?> get props => [page];
}

class ClearToastMessage extends SavedMoviesEvent {
  @override
  List<Object?> get props => [];
}
