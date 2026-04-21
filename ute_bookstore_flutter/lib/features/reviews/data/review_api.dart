import '../../../core/api_client.dart';
import 'review_models.dart';

class ReviewApi {
  ReviewApi(this._client);

  final ApiClient _client;

  Future<List<Review>> fetchReviews(String bookId) async {
    final response = await _client.dio.get('/reviews/book/$bookId');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const <Review>[];
  }

  Future<ReviewSummary> fetchSummary(String bookId) async {
    final response = await _client.dio.get('/reviews/book/$bookId/summary');
    return ReviewSummary.fromJson(response.data as Map<String, dynamic>);
  }
}

