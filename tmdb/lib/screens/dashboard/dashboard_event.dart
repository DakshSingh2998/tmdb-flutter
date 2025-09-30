import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovies extends DashboardEvent {
  final int page;
  FetchMovies(this.page);

  @override
  List<Object?> get props => [page];
}

class FetchNextPage extends DashboardEvent {}
