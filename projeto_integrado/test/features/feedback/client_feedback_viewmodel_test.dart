import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/features/feedback/data/models/feedback_model.dart';
import 'package:projeto_integrado/features/feedback/data/repositories/feedback_repository.dart';
import 'package:projeto_integrado/features/feedback/presentation/viewmodels/client_feedback_viewmodel.dart';

/// Mock da FeedbackRepository para testes
class MockFeedbackRepository implements FeedbackRepository {
  final Map<String, FeedbackModel> _feedbacks = {};
  bool shouldThrowDuplicate = false;

  @override
  Future<FeedbackModel> saveFeedback(FeedbackModel feedback) async {
    if (shouldThrowDuplicate) {
      throw Exception('Você já enviou feedback hoje. Tente novamente amanhã.');
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final withId = feedback.copyWith(id: id);
    _feedbacks[id] = withId;
    return withId;
  }

  @override
  Future<bool> hasUserFeedbackToday(String author) async {
    return _feedbacks.values.any((f) => f.author == author);
  }

  @override
  Future<FeedbackModel?> getFeedbackById(String id) async => _feedbacks[id];

  @override
  Future<List<FeedbackModel>> getAllFeedbacks() async =>
      _feedbacks.values.toList();

  @override
  Future<List<FeedbackModel>> getFeedbacksByAuthor(String author) async {
    return _feedbacks.values.where((f) => f.author == author).toList();
  }

  @override
  Future<List<FeedbackModel>> getFeedbacksByCategory(String category) async {
    return _feedbacks.values.where((f) => f.category == category).toList();
  }

  @override
  Future<FeedbackModel> updateFeedback(FeedbackModel feedback) async =>
      feedback;

  @override
  Future<void> deleteFeedback(String id) async => _feedbacks.remove(id);

  @override
  Future<FeedbackModel> classifyFeedback(FeedbackModel feedback) async =>
      feedback;

  @override
  Future<List<FeedbackModel>> classifyMultipleFeedbacks(
    List<FeedbackModel> feedbacks,
  ) async => feedbacks;

  @override
  Future<List<FeedbackModel>> getUnclassifiedFeedbacks() async => [];

  void clear() => _feedbacks.clear();
}

void main() {
  group('ClientFeedbackViewModel Tests', () {
    late ClientFeedbackViewModel viewModel;
    late MockFeedbackRepository mockRepository;

    setUp(() {
      mockRepository = MockFeedbackRepository();
      viewModel = ClientFeedbackViewModel(repository: mockRepository);
    });

    tearDown(() {
      mockRepository.clear();
      viewModel.dispose();
    });

    // TC01 - Enviar feedback válido completo
    test('TC01: Enviar feedback com dados válidos', () async {
      await viewModel.sendFeedback(
        author: 'João Silva',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
      );

      expect(viewModel.successMessage, contains('sucesso'));
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    // TC02 - Enviar com campos vazios
    test('TC02a: Enviar feedback com autor vazio', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: '',
          rating: 5,
          description: 'Descrição com 10 caracteres',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, isNotNull);
    });

    test('TC02b: Enviar feedback com descrição vazia', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 5,
          description: '',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, isNotNull);
    });

    test('TC02c: Enviar feedback com categoria vazia', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 5,
          description: 'Descrição válida com mais de 10',
          category: '',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, isNotNull);
    });

    // TC03 - Nota menor que 1
    test('TC03a: Nota zero', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 0,
          description: 'Descrição com 10 caracteres',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, contains('entre 1 e 5'));
    });

    test('TC03b: Nota negativa', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: -1,
          description: 'Descrição com 10 caracteres',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, contains('entre 1 e 5'));
    });

    // TC04 - Nota maior que 5
    test('TC04a: Nota 6', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 6,
          description: 'Descrição com 10 caracteres',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, contains('entre 1 e 5'));
    });

    test('TC04b: Nota 100', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 100,
          description: 'Descrição com 10 caracteres',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, contains('entre 1 e 5'));
    });

    // TC05 - Descrição muito curta
    test('TC05a: Descrição com 9 caracteres', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 5,
          description: '123456789',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, contains('10 caracteres'));
    });

    test('TC05b: Descrição com 10 caracteres (limite válido)', () async {
      await viewModel.sendFeedback(
        author: 'João',
        rating: 5,
        description: '1234567890',
        category: 'Categoria',
      );

      expect(viewModel.successMessage, isNotNull);
    });

    test('TC05c: Descrição "Ótimo!" - menos de 10', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 5,
          description: 'Ótimo!',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, contains('10 caracteres'));
    });

    // TC06 - Feedback duplicado
    test('TC06: Feedback duplicado no mesmo dia', () async {
      mockRepository.shouldThrowDuplicate = true;

      await expectLater(
        viewModel.sendFeedback(
          author: 'João',
          rating: 5,
          description: 'Segundo feedback do dia',
          category: 'Categoria',
        ),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('já enviou feedback hoje'));
    });

    // TC07 - Mensagem de sucesso
    test('TC07: Mensagem de sucesso é exibida', () async {
      await viewModel.sendFeedback(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
      );

      expect(viewModel.successMessage, isNotNull);
      expect(
        viewModel.successMessage,
        contains('Feedback enviado com sucesso!'),
      );
      expect(viewModel.errorMessage, isNull);
    });

    // TC08 - Mensagem de erro de validação
    test('TC08: Mensagem de erro de validação', () async {
      await expectLater(
        viewModel.sendFeedback(
          author: '',
          rating: 5,
          description: 'Descrição válida com mais de 10',
          category: 'Categoria',
        ),
        throwsArgumentError,
      );

      expect(viewModel.errorMessage, isNotNull);
    });

    // Estados de loading
    test('Estado isLoading durante envio', () async {
      expect(viewModel.isLoading, isFalse);

      final future = viewModel.sendFeedback(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
      );

      // Não podemos testar isLoading durante execução neste contexto
      await future;

      expect(viewModel.isLoading, isFalse);
    });

    test('clearMessages limpa mensagens', () async {
      await viewModel.sendFeedback(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
      );

      expect(viewModel.successMessage, isNotNull);

      viewModel.clearMessages();

      expect(viewModel.successMessage, isNull);
      expect(viewModel.errorMessage, isNull);
    });
  });
}
