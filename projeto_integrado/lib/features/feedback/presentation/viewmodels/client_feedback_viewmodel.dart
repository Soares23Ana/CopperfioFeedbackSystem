import '../../data/models/feedback_model.dart';
import '../../data/repositories/feedback_repository.dart';

class ClientFeedbackViewModel {
  final FeedbackRepository repository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  ClientFeedbackViewModel({required this.repository});

  Future<void> sendFeedback({
    required String author,
    required int rating,
    required String description,
    required String category,
  }) async {
    if (author.trim().isEmpty) {
      errorMessage = 'Autor não pode estar vazio';
      throw ArgumentError(errorMessage);
    }
    if (category.trim().isEmpty) {
      errorMessage = 'Categoria não pode estar vazia';
      throw ArgumentError(errorMessage);
    }
    if (description.trim().isEmpty) {
      errorMessage = 'Descrição não pode estar vazia';
      throw ArgumentError(errorMessage);
    }
    if (description.trim().length < 10) {
      errorMessage = 'Descrição deve ter pelo menos 10 caracteres';
      throw ArgumentError(errorMessage);
    }
    if (rating < 1 || rating > 5) {
      errorMessage = 'A nota deve ser entre 1 e 5';
      throw ArgumentError(errorMessage);
    }

    final feedback = FeedbackModel(
      author: author,
      rating: rating,
      description: description,
      category: category,
      date: DateTime.now(),
    );

    isLoading = true;
    errorMessage = null;
    successMessage = null;

    try {
      await repository.saveFeedback(feedback);
      successMessage = 'Feedback enviado com sucesso!';
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
      successMessage = null;
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  void clearMessages() {
    successMessage = null;
    errorMessage = null;
  }

  void dispose() {}
}
