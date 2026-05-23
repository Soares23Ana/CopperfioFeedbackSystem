import '../../data/models/feedback_model.dart';
import '../../data/repositories/feedback_repository.dart';

class ManagerFeedbackViewModel {
  final FeedbackRepository repository;

  List<FeedbackModel> feedbacks = [];
  List<FeedbackModel> filteredFeedbacks = [];
  String? selectedCategory;
  bool isLoading = false;
  String? errorMessage;

  ManagerFeedbackViewModel({required this.repository});

  Future<void> loadFeedbacks() async {
    isLoading = true;
    errorMessage = null;
    try {
      feedbacks = await repository.getAllFeedbacks();
      feedbacks.sort((a, b) => b.date.compareTo(a.date));
    } catch (error) {
      errorMessage = error.toString();
      feedbacks = [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> filterByCategory(String category) async {
    selectedCategory = category;
    if (category.trim().isEmpty) {
      filteredFeedbacks = [];
      return;
    }
    filteredFeedbacks = await repository.getFeedbacksByCategory(category);
    filteredFeedbacks.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> filterByAuthor(String author) async {
    selectedCategory = null;
    filteredFeedbacks = await repository.getFeedbacksByAuthor(author);
    filteredFeedbacks.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<FeedbackModel?> getFeedbackById(String id) async {
    return await repository.getFeedbackById(id);
  }

  void clearFilter() {
    selectedCategory = null;
    filteredFeedbacks = [];
  }

  Future<void> deleteFeedback(String id) async {
    await repository.deleteFeedback(id);
    await loadFeedbacks();
  }

  void dispose() {}
}
