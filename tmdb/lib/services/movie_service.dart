import '../core/network/rest_client.dart';
import '../screens/dashboard/models/movie_response.dart';

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
}
