import 'package:equatable/equatable.dart';

abstract class NowPlayingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovies extends NowPlayingEvent {
  final int page;
  FetchMovies(this.page);

  @override
  List<Object?> get props => [page];
}

class ClearToastMessage extends NowPlayingEvent {
  @override
  List<Object?> get props => [];
}
