import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/utilities/common_utilities.dart';

@immutable
class MovieDetailState extends Equatable {
  final String toastMessage;
  final ScreenStatus status;

  const MovieDetailState({
    this.toastMessage = '',
    this.status = ScreenStatus.initial,
  });

  MovieDetailState copyWith({String? toastMessage, ScreenStatus? status}) {
    return MovieDetailState(
      toastMessage: toastMessage ?? this.toastMessage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [toastMessage, status];
}
