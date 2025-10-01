class MovieSetFavouriteResponse {
  final bool success;
  final int statusCode;
  final String statusMessage;

  MovieSetFavouriteResponse({
    required this.success,
    required this.statusCode,
    required this.statusMessage,
  });

  factory MovieSetFavouriteResponse.fromJson(Map<String, dynamic> json) {
    return MovieSetFavouriteResponse(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      statusMessage: json['status_message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'status_message': statusMessage,
    };
  }
}
