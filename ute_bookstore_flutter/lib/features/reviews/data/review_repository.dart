import 'review_api.dart';
import 'review_models.dart';

class ReviewRepository {
  ReviewRepository(this._api);

  final ReviewApi _api;

  Future<List<Review>> fetchReviews(String bookId) => _api.fetchReviews(bookId);

  Future<ReviewSummary> fetchSummary(String bookId) => _api.fetchSummary(bookId);
}

