import '../models/feedback_model.dart';

abstract class FeedbackRepository {
  Future<List<FeedbackModel>> getUnclassifiedFeedbacks();
  Future<FeedbackModel> classifyFeedback(FeedbackModel feedback);
  Future<List<FeedbackModel>> classifyMultipleFeedbacks(
    List<FeedbackModel> feedbacks,
  );
  Future<FeedbackModel> updateFeedback(FeedbackModel feedback);
  Future<FeedbackModel> saveFeedback(FeedbackModel feedback);
  Future<FeedbackModel?> getFeedbackById(String id);
  Future<List<FeedbackModel>> getAllFeedbacks();
  Future<List<FeedbackModel>> getFeedbacksByAuthor(String author);
  Future<List<FeedbackModel>> getFeedbacksByCategory(String category);
  Future<bool> hasUserFeedbackToday(String author);
  Future<void> deleteFeedback(String id);
}
