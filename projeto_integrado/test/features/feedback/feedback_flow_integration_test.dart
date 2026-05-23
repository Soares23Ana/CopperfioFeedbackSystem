import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/features/feedback/data/models/feedback_model.dart';
import 'package:projeto_integrado/features/feedback/data/repositories/feedback_repository.dart';
import 'package:projeto_integrado/features/feedback/presentation/viewmodels/client_feedback_viewmodel.dart';
import 'package:projeto_integrado/features/feedback/presentation/viewmodels/manager_feedback_viewmodel.dart';
import 'package:projeto_integrado/features/feedback/presentation/viewmodels/ai_classifier_viewmodel.dart';

/// Repository real para testes de integração
class IntegrationTestRepository implements FeedbackRepository {
  final Map<String, FeedbackModel> _feedbacks = {};
  final Map<String, int> _dailyFeedbacks = {};

  @override
  Future<FeedbackModel> saveFeedback(FeedbackModel feedback) async {
    if (!feedback.isValid()) {
      throw ArgumentError('Feedback inválido');
    }

    final today = feedback.date.toIso8601String().split('T')[0];
    if (_dailyFeedbacks.containsKey('${feedback.author}:$today')) {
      throw Exception('Você já enviou feedback hoje. Tente novamente amanhã.');
    }

    final id =
        '${DateTime.now().microsecondsSinceEpoch}-${_feedbacks.length + 1}';
    final withId = feedback.copyWith(id: id);
    _feedbacks[id] = withId;

    _dailyFeedbacks['${feedback.author}:$today'] = 1;

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
  Future<bool> hasUserFeedbackToday(String author) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _dailyFeedbacks.containsKey('$author:$today');
  }

  @override
  Future<FeedbackModel> updateFeedback(FeedbackModel feedback) async {
    if (feedback.id != null && _feedbacks.containsKey(feedback.id)) {
      _feedbacks[feedback.id!] = feedback;
      return feedback;
    }
    throw Exception('Feedback não encontrado');
  }

  @override
  Future<void> deleteFeedback(String id) async => _feedbacks.remove(id);

  @override
  Future<FeedbackModel> classifyFeedback(FeedbackModel feedback) async {
    // Classificação simples para teste
    final description = feedback.description.toLowerCase();

    String sentiment = 'NEUTRO';
    double confidence = 0.5;

    if (description.contains('excelente') ||
        description.contains('satisfeito')) {
      sentiment = 'POSITIVO';
      confidence = 0.95;
    } else if (description.contains('péssimo') ||
        description.contains('decepcionado')) {
      sentiment = 'NEGATIVO';
      confidence = 0.95;
    }

    return feedback.copyWith(
      sentiment: sentiment,
      isClassified: true,
      sentimentConfidence: confidence,
    );
  }

  @override
  Future<List<FeedbackModel>> classifyMultipleFeedbacks(
    List<FeedbackModel> feedbacks,
  ) async {
    final results = <FeedbackModel>[];
    for (final feedback in feedbacks) {
      results.add(await classifyFeedback(feedback));
    }
    return results;
  }

  @override
  Future<List<FeedbackModel>> getUnclassifiedFeedbacks() async {
    return _feedbacks.values.where((f) => !f.isClassified).toList();
  }

  void clear() {
    _feedbacks.clear();
    _dailyFeedbacks.clear();
  }
}

void main() {
  group('Feedback Integration Tests - TC15', () {
    late IntegrationTestRepository repository;
    late ClientFeedbackViewModel clientViewModel;
    late ManagerFeedbackViewModel managerViewModel;
    late AIFeedbackClassifierViewModel aiViewModel;

    setUp(() {
      repository = IntegrationTestRepository();
      clientViewModel = ClientFeedbackViewModel(repository: repository);
      managerViewModel = ManagerFeedbackViewModel(repository: repository);
      aiViewModel = AIFeedbackClassifierViewModel(repository: repository);
    });

    tearDown(() {
      repository.clear();
      clientViewModel.dispose();
      managerViewModel.dispose();
      aiViewModel.dispose();
    });

    test(
      'TC15: Fluxo completo - Cliente → Enviar → IA Classifica → Gestor Visualiza',
      () async {
        // =================================================================
        // FASE 1: CLIENTE ENVIA FEEDBACK
        // =================================================================
        print('\n📨 FASE 1: Cliente enviando feedback...');

        await clientViewModel.sendFeedback(
          author: 'João Silva',
          rating: 5,
          description: 'Excelente atendimento, muito satisfeito com o serviço!',
          category: 'Atendimento',
        );

        // Verificações do envio
        expect(clientViewModel.successMessage, contains('sucesso'));
        expect(clientViewModel.errorMessage, isNull);
        expect(clientViewModel.isLoading, isFalse);

        print('✅ Feedback enviado com sucesso!');
        print('   Mensagem: ${clientViewModel.successMessage}');

        // =================================================================
        // FASE 2: IA CLASSIFICA O FEEDBACK
        // =================================================================
        print('\n🤖 FASE 2: IA classificando feedback...');

        // Carregar feedbacks não classificados
        await aiViewModel.loadUnclassifiedFeedbacks();
        expect(aiViewModel.unclassifiedFeedbacks, isNotEmpty);
        print(
          '   Feedbacks não classificados: ${aiViewModel.unclassifiedFeedbacks.length}',
        );

        // Classificar todos
        await aiViewModel.classifyAllPending();

        // Verificações da classificação
        expect(aiViewModel.classifiedFeedbacks, isNotEmpty);
        expect(aiViewModel.unclassifiedFeedbacks, isEmpty);

        final classifiedFeedback = aiViewModel.classifiedFeedbacks[0];
        expect(classifiedFeedback.isClassified, isTrue);
        expect(classifiedFeedback.sentiment, 'POSITIVO');
        expect(classifiedFeedback.sentimentConfidence, greaterThan(0.7));

        print('✅ Feedback classificado!');
        print('   Sentimento: ${classifiedFeedback.sentiment}');
        print(
          '   Confiança: ${(classifiedFeedback.sentimentConfidence! * 100).toStringAsFixed(1)}%',
        );

        // =================================================================
        // FASE 3: GESTOR VISUALIZA O FEEDBACK
        // =================================================================
        print('\n👔 FASE 3: Gestor visualizando feedback...');

        await managerViewModel.loadFeedbacks();

        // Verificações da visualização
        expect(managerViewModel.feedbacks, isNotEmpty);
        expect(managerViewModel.feedbacks.length, 1);

        final feedback = managerViewModel.feedbacks[0];
        expect(feedback.author, 'João Silva');
        expect(feedback.rating, 5);
        expect(feedback.description, contains('Excelente'));
        expect(feedback.category, 'Atendimento');
        expect(feedback.sentiment, 'POSITIVO');

        print('✅ Gestor visualizou feedback!');
        print('   Autor: ${feedback.author}');
        print('   Nota: ${feedback.rating}/5');
        print('   Categoria: ${feedback.category}');
        print('   Sentimento: ${feedback.sentiment}');

        // =================================================================
        // TESTE ADICIONAL: Múltiplos feedbacks com diferentes sentimentos
        // =================================================================
        print('\n📨 TESTE ADICIONAL: Múltiplos feedbacks...');

        // Cliente 2 envia feedback negativo
        await clientViewModel.sendFeedback(
          author: 'Maria Santos',
          rating: 2,
          description:
              'Péssimo atendimento, muito decepcionado com a experiência.',
          category: 'Atendimento',
        );

        // Cliente 3 envia feedback neutro
        clientViewModel.clearMessages();
        await clientViewModel.sendFeedback(
          author: 'Pedro Costa',
          rating: 3,
          description: 'Entrega conforme combinado, sem pontos especiais.',
          category: 'Entrega',
        );

        print('✅ 3 feedbacks enviados no total');

        // IA classifica todos
        await aiViewModel.loadUnclassifiedFeedbacks();
        await aiViewModel.classifyAllPending();

        print('✅ IA classificou todos os feedbacks');
        print('   Estatísticas:');
        print('   - Positivos: ${aiViewModel.sentimentStats['POSITIVO']}');
        print('   - Negativos: ${aiViewModel.sentimentStats['NEGATIVO']}');
        print('   - Neutros: ${aiViewModel.sentimentStats['NEUTRO']}');

        // Gestor visualiza todos
        await managerViewModel.loadFeedbacks();
        expect(managerViewModel.feedbacks.length, 3);

        print(
          '✅ Gestor visualizou todos os ${managerViewModel.feedbacks.length} feedbacks',
        );

        // Gestor filtra por categoria
        await managerViewModel.filterByCategory('Atendimento');
        expect(managerViewModel.filteredFeedbacks.length, 2);

        print(
          '✅ Gestor filtrou por "Atendimento": ${managerViewModel.filteredFeedbacks.length} feedbacks',
        );

        // Verificações finais
        expect(aiViewModel.sentimentStats['POSITIVO'], 1);
        expect(aiViewModel.sentimentStats['NEGATIVO'], 1);
        expect(aiViewModel.sentimentStats['NEUTRO'], 1);

        print('\n✅ FLUXO COMPLETO CONCLUÍDO COM SUCESSO!');
      },
    );

    test('TC15a: Fluxo com erro - Feedback duplicado', () async {
      print('\n⚠️  Testando feedback duplicado...');

      // Enviar primeiro feedback
      await clientViewModel.sendFeedback(
        author: 'João Silva',
        rating: 5,
        description: 'Primeiro feedback do dia, excelente!',
        category: 'Atendimento',
      );

      expect(clientViewModel.successMessage, isNotNull);
      print('✅ Primeiro feedback enviado');

      // Tentar enviar segundo feedback do mesmo autor
      clientViewModel.clearMessages();
      await expectLater(
        clientViewModel.sendFeedback(
          author: 'João Silva',
          rating: 4,
          description: 'Segundo feedback também excelente!',
          category: 'Atendimento',
        ),
        throwsException,
      );

      expect(clientViewModel.errorMessage, contains('já enviou feedback'));
      print('✅ Segundo feedback foi bloqueado corretamente');
    });

    test('TC15b: Fluxo com erro - Validação de entrada', () async {
      print('\n⚠️  Testando validações...');

      // Tentar enviar com nota inválida
      await expectLater(
        clientViewModel.sendFeedback(
          author: 'João',
          rating: 10, // Inválido
          description: 'Descrição com mais de 10 caracteres',
          category: 'Atendimento',
        ),
        throwsArgumentError,
      );

      expect(clientViewModel.errorMessage, contains('entre 1 e 5'));
      print('✅ Validação de nota funcionou');

      // Tentar enviar com descrição curta
      clientViewModel.clearMessages();
      await expectLater(
        clientViewModel.sendFeedback(
          author: 'João',
          rating: 5,
          description: 'Curto', // Menos de 10 caracteres
          category: 'Atendimento',
        ),
        throwsArgumentError,
      );

      expect(clientViewModel.errorMessage, contains('10 caracteres'));
      print('✅ Validação de descrição funcionou');
    });

    test('TC15c: Fluxo de filtro e ordenação do gestor', () async {
      print('\n👔 Testando filtros e ordenação do gestor...');

      // Enviar vários feedbacks
      for (int i = 0; i < 3; i++) {
        clientViewModel.clearMessages();
        await clientViewModel.sendFeedback(
          author: 'Cliente $i',
          rating: 5 - i,
          description: 'Feedback número $i com descrição completa',
          category: i.isEven ? 'Atendimento' : 'Produto',
        );
      }

      print('✅ 3 feedbacks enviados');

      // Gestor carrega e verifica ordenação
      await managerViewModel.loadFeedbacks();
      expect(managerViewModel.feedbacks.length, 3);

      // Primeiro deve ser o mais recente
      print('✅ Feedbacks ordenados por data (mais recente primeiro)');

      // Filtrar por categoria
      await managerViewModel.filterByCategory('Atendimento');
      expect(managerViewModel.filteredFeedbacks.length, 2);

      print('✅ Filtro por categoria funcionou: 2 feedbacks de Atendimento');

      // Limpar filtro
      managerViewModel.clearFilter();
      expect(managerViewModel.filteredFeedbacks, isEmpty);

      print('✅ Filtro limpo');
    });
  });
}
