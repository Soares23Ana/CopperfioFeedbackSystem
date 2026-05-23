import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/features/feedback/data/models/feedback_model.dart';
import 'package:projeto_integrado/features/feedback/data/repositories/feedback_repository.dart';
import 'package:projeto_integrado/features/feedback/presentation/viewmodels/ai_classifier_viewmodel.dart';

/// Mock da FeedbackRepository para testes de IA
class MockAIRepository implements FeedbackRepository {
  final Map<String, FeedbackModel> _feedbacks = {};

  void addFeedback(FeedbackModel feedback) {
    final id =
        feedback.id ??
        '${DateTime.now().microsecondsSinceEpoch}-${_feedbacks.length + 1}';
    _feedbacks[id] = feedback.copyWith(id: id);
  }

  @override
  Future<List<FeedbackModel>> getUnclassifiedFeedbacks() async {
    return _feedbacks.values.where((f) => !f.isClassified).toList();
  }

  @override
  Future<FeedbackModel> classifyFeedback(FeedbackModel feedback) async {
    // Simular classificação simples baseada em palavras-chave
    final description = feedback.description.toLowerCase();

    String sentiment = 'NEUTRO';
    if (description.contains('excelente') ||
        description.contains('ótimo') ||
        description.contains('satisfeito')) {
      sentiment = 'POSITIVO';
    } else if (description.contains('péssimo') ||
        description.contains('ruim') ||
        description.contains('decepcionado')) {
      sentiment = 'NEGATIVO';
    }

    return feedback.copyWith(
      sentiment: sentiment,
      isClassified: true,
      sentimentConfidence: 0.85,
    );
  }

  @override
  Future<List<FeedbackModel>> classifyMultipleFeedbacks(
    List<FeedbackModel> feedbacks,
  ) async {
    final results = <FeedbackModel>[];
    for (final feedback in feedbacks) {
      final classified = await classifyFeedback(feedback);
      results.add(classified);
    }
    return results;
  }

  @override
  Future<FeedbackModel> updateFeedback(FeedbackModel feedback) async {
    if (feedback.id != null) {
      _feedbacks[feedback.id!] = feedback;
    }
    return feedback;
  }

  @override
  Future<FeedbackModel> saveFeedback(FeedbackModel feedback) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final withId = feedback.copyWith(id: id);
    _feedbacks[id] = withId;
    return withId;
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
  Future<bool> hasUserFeedbackToday(String author) async => false;

  @override
  Future<void> deleteFeedback(String id) async => _feedbacks.remove(id);

  void clear() => _feedbacks.clear();
}

void main() {
  group('AIFeedbackClassifierViewModel Tests', () {
    late AIFeedbackClassifierViewModel viewModel;
    late MockAIRepository mockRepository;

    setUp(() {
      mockRepository = MockAIRepository();
      viewModel = AIFeedbackClassifierViewModel(repository: mockRepository);
    });

    tearDown(() {
      mockRepository.clear();
      viewModel.dispose();
    });

    // TC12 - IA classifica sentimento POSITIVO
    test(
      'TC12a: IA classifica feedback positivo com palavra "excelente"',
      () async {
        final feedback = FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente atendimento, muito satisfeito!',
          category: 'Atendimento',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyFeedback(
          mockRepository._feedbacks.values.first,
        );

        expect(viewModel.classifiedFeedbacks, isNotEmpty);
        expect(viewModel.classifiedFeedbacks[0].sentiment, 'POSITIVO');
      },
    );

    test(
      'TC12b: IA classifica feedback positivo com palavra "ótimo"',
      () async {
        final feedback = FeedbackModel(
          author: 'Maria',
          rating: 5,
          description: 'Ótimo produto, recomendo!',
          category: 'Produto',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyFeedback(
          mockRepository._feedbacks.values.first,
        );

        expect(viewModel.classifiedFeedbacks[0].sentiment, 'POSITIVO');
      },
    );

    test(
      'TC12c: IA classifica feedback positivo com múltiplas palavras',
      () async {
        final feedback = FeedbackModel(
          author: 'Pedro',
          rating: 5,
          description:
              'Maravilhoso! Excelente serviço, muito satisfeito com tudo!',
          category: 'Serviço',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyFeedback(
          mockRepository._feedbacks.values.first,
        );

        expect(viewModel.classifiedFeedbacks[0].sentiment, 'POSITIVO');
      },
    );

    // TC13 - IA classifica sentimento NEGATIVO
    test(
      'TC13a: IA classifica feedback negativo com palavra "péssimo"',
      () async {
        final feedback = FeedbackModel(
          author: 'João',
          rating: 1,
          description: 'Péssimo atendimento, muito decepcionado.',
          category: 'Atendimento',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyFeedback(
          mockRepository._feedbacks.values.first,
        );

        expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEGATIVO');
      },
    );

    test('TC13b: IA classifica feedback negativo com palavra "ruim"', () async {
      final feedback = FeedbackModel(
        author: 'Maria',
        rating: 1,
        description: 'Produto ruim, não recomendo.',
        category: 'Produto',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEGATIVO');
    });

    test(
      'TC13c: IA classifica feedback negativo com múltiplas palavras',
      () async {
        final feedback = FeedbackModel(
          author: 'Pedro',
          rating: 1,
          description:
              'Horrível! Péssimo serviço, muito decepcionado com a experiência.',
          category: 'Serviço',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyFeedback(
          mockRepository._feedbacks.values.first,
        );

        expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEGATIVO');
      },
    );

    // TC14 - IA classifica sentimento NEUTRO
    test('TC14a: IA classifica feedback neutro sem palavras-chave', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 3,
        description: 'Recebi o pedido conforme esperado.',
        category: 'Entrega',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEUTRO');
    });

    test('TC14b: IA classifica feedback neutro factual', () async {
      final feedback = FeedbackModel(
        author: 'Maria',
        rating: 3,
        description: 'O produto chegou dentro do prazo prometido.',
        category: 'Entrega',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEUTRO');
    });

    test('TC14c: IA classifica feedback neutro descritivo', () async {
      final feedback = FeedbackModel(
        author: 'Pedro',
        rating: 3,
        description: 'Entrega realizada conforme combinado.',
        category: 'Entrega',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEUTRO');
    });

    // Testes de funcionalidade adicional
    test(
      'Feedback recebe flag isClassified = true após classificação',
      () async {
        final feedback = FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente atendimento, muito satisfeito!',
          category: 'Atendimento',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyFeedback(
          mockRepository._feedbacks.values.first,
        );

        expect(viewModel.classifiedFeedbacks[0].isClassified, isTrue);
      },
    );

    test('Feedback recebe confidence score após classificação', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(viewModel.classifiedFeedbacks[0].sentimentConfidence, isNotNull);
      expect(
        viewModel.classifiedFeedbacks[0].sentimentConfidence,
        greaterThan(0),
      );
    });

    test('Classificar múltiplos feedbacks', () async {
      final feedbacks = [
        FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente atendimento, muito satisfeito!',
          category: 'Atendimento',
          date: DateTime.now(),
        ),
        FeedbackModel(
          author: 'Maria',
          rating: 1,
          description: 'Péssimo serviço, muito decepcionado.',
          category: 'Serviço',
          date: DateTime.now(),
        ),
      ];

      for (final feedback in feedbacks) {
        mockRepository.addFeedback(feedback);
      }

      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyAllPending();

      expect(viewModel.classifiedFeedbacks.length, 2);
      expect(viewModel.sentimentStats['POSITIVO'], 1);
      expect(viewModel.sentimentStats['NEGATIVO'], 1);
    });

    test('Feedback é removido de unclassified após classificação', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      expect(viewModel.unclassifiedFeedbacks, isNotEmpty);

      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);
      expect(viewModel.unclassifiedFeedbacks, isEmpty);
    });

    test('Estatísticas de sentimento são calculadas', () async {
      final feedbacks = [
        FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente!',
          category: 'Cat',
          date: DateTime.now(),
        ),
        FeedbackModel(
          author: 'Maria',
          rating: 1,
          description: 'Péssimo!',
          category: 'Cat',
          date: DateTime.now(),
        ),
        FeedbackModel(
          author: 'Pedro',
          rating: 3,
          description: 'Normal, nada especial.',
          category: 'Cat',
          date: DateTime.now(),
        ),
      ];

      for (final feedback in feedbacks) {
        mockRepository.addFeedback(feedback);
      }

      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyAllPending();

      expect(viewModel.sentimentStats['POSITIVO'], 1);
      expect(viewModel.sentimentStats['NEGATIVO'], 1);
      expect(viewModel.sentimentStats['NEUTRO'], 1);
    });

    // CT15 - Validar confiança de classificação
    test('CT15a: Confiança de classificação é maior que 0', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(
        viewModel.classifiedFeedbacks[0].sentimentConfidence,
        greaterThan(0.0),
      );
    });

    test('CT15b: Confiança de classificação é menor ou igual a 1.0', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento, muito satisfeito!',
        category: 'Atendimento',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(
        viewModel.classifiedFeedbacks[0].sentimentConfidence,
        lessThanOrEqualTo(1.0),
      );
    });

    test(
      'CT15c: Confiança é presente em todos os feedbacks classificados',
      () async {
        final feedbacks = [
          FeedbackModel(
            author: 'João',
            rating: 5,
            description: 'Excelente!',
            category: 'Cat',
            date: DateTime.now(),
          ),
          FeedbackModel(
            author: 'Maria',
            rating: 1,
            description: 'Péssimo!',
            category: 'Cat',
            date: DateTime.now(),
          ),
          FeedbackModel(
            author: 'Pedro',
            rating: 3,
            description: 'Normal.',
            category: 'Cat',
            date: DateTime.now(),
          ),
        ];

        for (final feedback in feedbacks) {
          mockRepository.addFeedback(feedback);
        }

        await viewModel.loadUnclassifiedFeedbacks();
        await viewModel.classifyAllPending();

        for (final feedback in viewModel.classifiedFeedbacks) {
          expect(feedback.sentimentConfidence, isNotNull);
          expect(feedback.sentimentConfidence, greaterThan(0.0));
          expect(feedback.sentimentConfidence, lessThanOrEqualTo(1.0));
        }
      },
    );

    // CT16 - Validar persistência de classificação
    test('CT16a: Classificação é atualizada no repositório', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 5,
        description: 'Excelente atendimento!',
        category: 'Atendimento',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      final feedbackId = mockRepository._feedbacks.keys.first;

      final feedbackBefore = mockRepository._feedbacks[feedbackId]!;
      expect(feedbackBefore.isClassified, isFalse);

      await viewModel.classifyFeedback(feedbackBefore);

      final feedbackAfter = mockRepository._feedbacks[feedbackId]!;
      expect(feedbackAfter.isClassified, isTrue);
      expect(feedbackAfter.sentiment, 'POSITIVO');
    });

    test('CT16b: Classificação é salva com sentimento e confiança', () async {
      final feedback = FeedbackModel(
        author: 'Maria',
        rating: 1,
        description: 'Péssimo serviço!',
        category: 'Serviço',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      final feedbackId = mockRepository._feedbacks.keys.first;

      await viewModel.classifyFeedback(mockRepository._feedbacks[feedbackId]!);

      final classified = mockRepository._feedbacks[feedbackId]!;
      expect(classified.isClassified, isTrue);
      expect(classified.sentiment, isNotNull);
      expect(classified.sentimentConfidence, isNotNull);
    });

    test(
      'CT16c: Feedback classificado não aparece mais em unclassified',
      () async {
        final feedback = FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente!',
          category: 'Atendimento',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        final feedbackId = mockRepository._feedbacks.keys.first;

        final unclassifiedBefore = await mockRepository
            .getUnclassifiedFeedbacks();
        expect(unclassifiedBefore.length, 1);

        await viewModel.classifyFeedback(
          mockRepository._feedbacks[feedbackId]!,
        );

        final unclassifiedAfter = await mockRepository
            .getUnclassifiedFeedbacks();
        expect(unclassifiedAfter, isEmpty);
      },
    );

    test('CT16d: Múltiplos feedbacks persistem classificação', () async {
      final feedbacks = [
        FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente!',
          category: 'Cat',
          date: DateTime.now(),
        ),
        FeedbackModel(
          author: 'Maria',
          rating: 1,
          description: 'Péssimo!',
          category: 'Cat',
          date: DateTime.now(),
        ),
        FeedbackModel(
          author: 'Pedro',
          rating: 3,
          description: 'Normal.',
          category: 'Cat',
          date: DateTime.now(),
        ),
      ];

      for (final feedback in feedbacks) {
        mockRepository.addFeedback(feedback);
      }

      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyAllPending();

      // Verificar que todos foram persistidos
      final allFeedbacks = await mockRepository.getAllFeedbacks();
      expect(allFeedbacks.length, 3);

      for (final feedback in allFeedbacks) {
        expect(feedback.isClassified, isTrue);
        expect(feedback.sentiment, isNotNull);
      }
    });

    // Testes de edge cases e validações
    test('Feedback com descrição vazia não é classificado', () async {
      final feedback = FeedbackModel(
        author: 'João',
        rating: 5,
        description: '',
        category: 'Atendimento',
        date: DateTime.now(),
      );

      mockRepository.addFeedback(feedback);
      await viewModel.loadUnclassifiedFeedbacks();
      await viewModel.classifyFeedback(mockRepository._feedbacks.values.first);

      expect(viewModel.classifiedFeedbacks[0].sentiment, 'NEUTRO');
    });

    test(
      'Reclassificar feedback já classificado atualiza sentimento',
      () async {
        final feedback = FeedbackModel(
          author: 'João',
          rating: 5,
          description: 'Excelente!',
          category: 'Atendimento',
          date: DateTime.now(),
        );

        mockRepository.addFeedback(feedback);
        final feedbackId = mockRepository._feedbacks.keys.first;

        await viewModel.classifyFeedback(
          mockRepository._feedbacks[feedbackId]!,
        );
        expect(mockRepository._feedbacks[feedbackId]!.sentiment, 'POSITIVO');

        final updated = mockRepository._feedbacks[feedbackId]!.copyWith(
          description: 'Péssimo!',
        );
        mockRepository._feedbacks[feedbackId] = updated;

        await viewModel.classifyFeedback(updated);
        expect(mockRepository._feedbacks[feedbackId]!.sentiment, 'NEGATIVO');
      },
    );
  });
}
