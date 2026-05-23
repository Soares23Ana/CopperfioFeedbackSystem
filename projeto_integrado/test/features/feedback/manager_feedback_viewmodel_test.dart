import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/features/feedback/data/models/feedback_model.dart';
import 'package:projeto_integrado/features/feedback/data/repositories/feedback_repository.dart';
import 'package:projeto_integrado/features/feedback/presentation/viewmodels/manager_feedback_viewmodel.dart';

/// Mock da FeedbackRepository para testes
class MockFeedbackRepository implements FeedbackRepository {
  final Map<String, FeedbackModel> _feedbacks = {};

  // Dados de teste pré-carregados
  void _initializeTestData() {
    _feedbacks.clear();

    final feedbacks = [
      FeedbackModel(
        id: '1',
        author: 'João Silva',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
        date: DateTime(2026, 5, 15),
      ),
      FeedbackModel(
        id: '2',
        author: 'Maria Santos',
        rating: 4,
        description: 'Produto de boa qualidade e entrega rápida',
        category: 'Produto',
        date: DateTime(2026, 5, 14),
      ),
      FeedbackModel(
        id: '3',
        author: 'Pedro Costa',
        rating: 3,
        description: 'Atendimento poderia melhorar em alguns pontos',
        category: 'Atendimento',
        date: DateTime(2026, 5, 12),
      ),
      FeedbackModel(
        id: '4',
        author: 'Ana Oliveira',
        rating: 5,
        description: 'Excelente entrega no prazo prometido!',
        category: 'Entrega',
        date: DateTime(2026, 5, 10),
      ),
    ];

    for (final feedback in feedbacks) {
      _feedbacks[feedback.id!] = feedback;
    }
  }

  @override
  Future<List<FeedbackModel>> getAllFeedbacks() async {
    return _feedbacks.values.toList();
  }

  @override
  Future<FeedbackModel?> getFeedbackById(String id) async => _feedbacks[id];

  @override
  Future<List<FeedbackModel>> getFeedbacksByAuthor(String author) async {
    return _feedbacks.values.where((f) => f.author == author).toList();
  }

  @override
  Future<List<FeedbackModel>> getFeedbacksByCategory(String category) async {
    return _feedbacks.values.where((f) => f.category == category).toList();
  }

  @override
  Future<bool> hasUserFeedbackToday(String author) async {
    return false;
  }

  @override
  Future<FeedbackModel> saveFeedback(FeedbackModel feedback) async => feedback;

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
  group('ManagerFeedbackViewModel Tests', () {
    late ManagerFeedbackViewModel viewModel;
    late MockFeedbackRepository mockRepository;

    setUp(() {
      mockRepository = MockFeedbackRepository();
      mockRepository._initializeTestData();
      viewModel = ManagerFeedbackViewModel(repository: mockRepository);
    });

    tearDown(() {
      mockRepository.clear();
      viewModel.dispose();
    });

    // TC09 - Gestor visualiza feedbacks
    test('TC09: Gestor consegue visualizar lista de feedbacks', () async {
      await viewModel.loadFeedbacks();

      expect(viewModel.feedbacks, isNotEmpty);
      expect(viewModel.feedbacks.length, 4);
      expect(viewModel.feedbacks[0].author, 'João Silva');
      expect(viewModel.feedbacks[0].rating, 5);
    });

    test('TC09a: Feedbacks carregados com sucesso', () async {
      expect(viewModel.isLoading, isFalse);

      await viewModel.loadFeedbacks();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.feedbacks, isNotEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('TC09b: Feedbacks listados com dados completos', () async {
      await viewModel.loadFeedbacks();

      final firstFeedback = viewModel.feedbacks[0];
      expect(firstFeedback.id, isNotNull);
      expect(firstFeedback.author, isNotNull);
      expect(firstFeedback.rating, isNotNull);
      expect(firstFeedback.description, isNotNull);
      expect(firstFeedback.category, isNotNull);
      expect(firstFeedback.date, isNotNull);
    });

    // TC10 - Filtro por categoria
    test('TC10a: Filtrar feedbacks por categoria "Atendimento"', () async {
      await viewModel.filterByCategory('Atendimento');

      expect(viewModel.filteredFeedbacks, isNotEmpty);
      expect(viewModel.filteredFeedbacks.length, 2);
      expect(
        viewModel.filteredFeedbacks.every((f) => f.category == 'Atendimento'),
        isTrue,
      );
    });

    test('TC10b: Filtrar feedbacks por categoria "Produto"', () async {
      await viewModel.filterByCategory('Produto');

      expect(viewModel.filteredFeedbacks.length, 1);
      expect(viewModel.filteredFeedbacks[0].author, 'Maria Santos');
    });

    test('TC10c: Filtrar feedbacks por categoria "Entrega"', () async {
      await viewModel.filterByCategory('Entrega');

      expect(viewModel.filteredFeedbacks.length, 1);
      expect(viewModel.filteredFeedbacks[0].author, 'Ana Oliveira');
    });

    test('TC10d: Categoria vazia retorna lista vazia', () async {
      await viewModel.filterByCategory('CategoriaInexistente');

      expect(viewModel.filteredFeedbacks, isEmpty);
    });

    test('TC10e: Limpar filtro retorna todos feedbacks', () async {
      await viewModel.filterByCategory('Atendimento');
      expect(viewModel.filteredFeedbacks.length, 2);

      viewModel.clearFilter();
      expect(viewModel.filteredFeedbacks, isEmpty);
      expect(viewModel.selectedCategory, isNull);
    });

    // TC11 - Ordenação cronológica (mais recente primeiro)
    test('TC11a: Feedbacks ordenados por data decrescente', () async {
      await viewModel.loadFeedbacks();

      // Verificar que está ordenado: mais recente primeiro
      for (int i = 0; i < viewModel.feedbacks.length - 1; i++) {
        expect(
          viewModel.feedbacks[i].date.isAfter(
                viewModel.feedbacks[i + 1].date,
              ) ||
              viewModel.feedbacks[i].date.isAtSameMomentAs(
                viewModel.feedbacks[i + 1].date,
              ),
          isTrue,
        );
      }
    });

    test('TC11b: Primeira entrada é a mais recente', () async {
      await viewModel.loadFeedbacks();

      expect(viewModel.feedbacks[0].date, DateTime(2026, 5, 15));
      expect(viewModel.feedbacks[0].author, 'João Silva');
    });

    test('TC11c: Última entrada é a mais antiga', () async {
      await viewModel.loadFeedbacks();

      expect(
        viewModel.feedbacks[viewModel.feedbacks.length - 1].date,
        DateTime(2026, 5, 10),
      );
      expect(
        viewModel.feedbacks[viewModel.feedbacks.length - 1].author,
        'Ana Oliveira',
      );
    });

    test('TC11d: Filtrados também mantêm ordem cronológica', () async {
      await viewModel.filterByCategory('Atendimento');

      for (int i = 0; i < viewModel.filteredFeedbacks.length - 1; i++) {
        expect(
          viewModel.filteredFeedbacks[i].date.isAfter(
                viewModel.filteredFeedbacks[i + 1].date,
              ) ||
              viewModel.filteredFeedbacks[i].date.isAtSameMomentAs(
                viewModel.filteredFeedbacks[i + 1].date,
              ),
          isTrue,
        );
      }
    });

    // Testes adicionais de funcionalidade
    test('Filtrar por autor', () async {
      await viewModel.filterByAuthor('João Silva');

      expect(viewModel.filteredFeedbacks.length, 1);
      expect(viewModel.filteredFeedbacks[0].author, 'João Silva');
    });

    test('Deletar feedback', () async {
      await viewModel.loadFeedbacks();
      final initialCount = viewModel.feedbacks.length;

      await viewModel.deleteFeedback('1');

      expect(viewModel.feedbacks.length, initialCount - 1);
    });

    test('Obter feedback por ID', () async {
      final feedback = await viewModel.getFeedbackById('1');

      expect(feedback, isNotNull);
      expect(feedback!.author, 'João Silva');
      expect(feedback.rating, 5);
    });

    test('Feedback não encontrado retorna null', () async {
      final feedback = await viewModel.getFeedbackById('999');

      expect(feedback, isNull);
    });
  });
}
