import 'package:equatable/equatable.dart';

abstract class SavedMoviesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovies extends SavedMoviesEvent {
  FetchMovies();

  @override
  List<Object?> get props => [];
}
