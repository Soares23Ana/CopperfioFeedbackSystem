import '../../data/models/feedback_model.dart';
import '../../data/repositories/feedback_repository.dart';

class AIFeedbackClassifierViewModel {
  final FeedbackRepository repository;

  List<FeedbackModel> unclassifiedFeedbacks = [];
  List<FeedbackModel> classifiedFeedbacks = [];
  Map<String, int> sentimentStats = {};

  AIFeedbackClassifierViewModel({required this.repository});

  Future<void> loadUnclassifiedFeedbacks() async {
    unclassifiedFeedbacks = await repository.getUnclassifiedFeedbacks();
    unclassifiedFeedbacks.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> classifyFeedback(FeedbackModel feedback) async {
    final classified = await repository.classifyFeedback(feedback);
    final updated = await repository.updateFeedback(classified);

    _replaceClassifiedFeedback(updated);
    _removeFromUnclassified(updated);
    _updateSentimentStats();
  }

  Future<void> classifyAllPending() async {
    final pending = List<FeedbackModel>.from(unclassifiedFeedbacks);
    if (pending.isEmpty) {
      return;
    }

    final classifiedList = await repository.classifyMultipleFeedbacks(pending);
    for (final classified in classifiedList) {
      final updated = await repository.updateFeedback(classified);
      _replaceClassifiedFeedback(updated);
      _removeFromUnclassified(updated);
    }

    _updateSentimentStats();
  }

  void _replaceClassifiedFeedback(FeedbackModel feedback) {
    final index = classifiedFeedbacks.indexWhere((f) => f.id == feedback.id);
    if (index >= 0) {
      classifiedFeedbacks[index] = feedback;
    } else {
      classifiedFeedbacks.add(feedback);
    }
  }

  void _removeFromUnclassified(FeedbackModel feedback) {
    unclassifiedFeedbacks.removeWhere((f) => f.id == feedback.id);
  }

  void _updateSentimentStats() {
    sentimentStats = {};
    for (final feedback in classifiedFeedbacks) {
      final sentiment = feedback.sentiment;
      sentimentStats[sentiment] = (sentimentStats[sentiment] ?? 0) + 1;
    }
  }

  void dispose() {}
}
