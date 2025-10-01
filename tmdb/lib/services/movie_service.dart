import '../core/network/rest_client.dart';
import '../screens/dashboard/models/movie_response.dart';
import '../screens/movieDetail/models/movie_set_favourite.dart';

class MovieRepository {
  Future<MovieResponse> fetchMovies({int page = 1}) async {
    try {
      final dio = DioClient().dio;
      final client = RestClient(dio);
      final response = await client.getPopularMovies(page);
      return response;
    } catch (e) {
      throw Exception("Failed to load movies: $e");
    }
  }

  Future<MovieSetFavouriteResponse> markMovieAsFavorite({
    String accountId = "22348556",
    required int movieId,
    required bool favorite,
  }) async {
    try {
      final dio = DioClient().dio;
      final client = RestClient(dio);
      final body = {
        'media_type': 'movie',
        'media_id': movieId,
        'favorite': favorite,
      };
      return await client.markAsFavorite(accountId, body);
    } catch (e) {
      throw Exception("Failed to mark movie as favorite: $e");
    }
  }

  Future<MovieResponse> fetchFavoriteMovies({
    String accountId = "22348556",
    int page = 1,
  }) async {
    try {
      final dio = DioClient().dio;
      final client = RestClient(dio);
      final response = await client.getFavoriteMovies(accountId, page);
      return response;
    } catch (e) {
      throw Exception("Failed to load favorite movies: $e");
    }
  }

  Future<Movie> fetchMovieDetails({required int movieId}) async {
    try {
      final dio = DioClient().dio;
      final client = RestClient(dio);
      final response = await client.getMovieDetails(movieId);
      return response;
    } catch (e) {
      throw Exception("Failed to load movie details: $e");
    }
  }
}
