import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../screens/dashboard/models/movie_response.dart';
import '../../screens/movieDetail/models/movie_set_favourite.dart';
part 'rest_client.g.dart';

const baseUrl = "https://api.themoviedb.org/3/";
const String staticToken =
    'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmU5YmY3OTBhOTY3MmQ2M2RlNzBhMWYwODUzYzRkMiIsIm5iZiI6MTc1OTIyMjkzNS42NjYsInN1YiI6IjY4ZGI5Yzk3YjQ1OWMyMTQyODJkZjJkNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.F9aGFm-09dMP0szgIXDK4h1ZR5lc_7MFGfwFuBBLOrg';

@RestApi(baseUrl: baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET('/movie/popular')
  Future<MovieResponse> getPopularMovies(@Query('page') int page);

  @POST('account/{account_id}/favorite')
  Future<MovieSetFavouriteResponse> markAsFavorite(
    @Path('account_id') String accountId,
    @Body() Map<String, dynamic> body,
  );

  @GET('account/{account_id}/favorite/movies')
  Future<MovieResponse> getFavoriteMovies(
    @Path('account_id') String accountId,
    @Query('page') int page,
  );

  @GET('movie/{movie_id}')
  Future<Movie> getMovieDetails(@Path('movie_id') int movieId);

  @GET('search/movie?query={query}&page={page}')
  Future<MovieResponse> searchMovies(
    @Path('query') String query,
    @Path('page') int page,
  );

  @GET('movie/now_playing')
  Future<MovieResponse> getNowPlaying(@Query('page') int page);
}

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Authorization': staticToken,
          'Content-Type': 'application/json',
        },
        connectTimeout: Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(AppLoggerInterceptor());
  }
}

class AppLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('➡️ REQUEST: ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    print('Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('Message: ${err.message}');
    super.onError(err, handler);
  }
}
