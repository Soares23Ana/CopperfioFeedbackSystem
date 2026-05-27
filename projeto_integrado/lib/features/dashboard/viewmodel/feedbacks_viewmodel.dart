import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/firestore_service.dart';
import 'package:projeto_integrado/services/gemini_service.dart';
import 'package:projeto_integrado/services/history_service.dart';

class FeedbacksViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final AuthService _authService = AuthService();
  final GeminiService _geminiService = GeminiService();

  Stream<QuerySnapshot<Map<String, dynamic>>> feedbacksStream() async* {
    final userData = await _authService.getCurrentUserData();
    final empresaId = userData?['empresaId'] as String? ?? 'copperfio';
    yield* _service.getFeedbacks(empresaId);
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> aplicarFiltroEBusca(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> feedbacks,
    String filtro,
    String busca,
    DateTimeRange? selectedDateRange,
  ) {
    final normalizedFilter = filtro.toUpperCase();
    final query = busca.trim().toLowerCase();

    final filtered = feedbacks.where((doc) {
      final data = doc.data();
      final matchesType = _matchesFilterType(
        data,
        normalizedFilter,
        selectedDateRange,
      );
      final matchesSearch = query.isEmpty || _matchesSearch(data, query);
      return matchesType && matchesSearch;
    }).toList();

    if (query.isNotEmpty) {
      filtered.sort((a, b) {
        final scoreB = _relevanceScore(b.data(), query);
        final scoreA = _relevanceScore(a.data(), query);
        return scoreB.compareTo(scoreA);
      });
    }

    return filtered;
  }

  bool _matchesFilterType(
    Map<String, dynamic> data,
    String filter,
    DateTimeRange? selectedDateRange,
  ) {
    if (filter == 'TODOS') return true;
    if (filter == 'POSITIVOS') {
      return _isPositivo(data);
    }
    if (filter == 'NEGATIVOS') {
      return _isNegativo(data);
    }
    if (filter == 'NEUTRO') {
      return _isNeutro(data);
    }
    if (filter == 'CRÍTICOS' || filter == 'CRITICOS') {
      return _isCritico(data);
    }
    if (filter == 'ELOGIOS') {
      return _isElogio(data);
    }
    if (filter == 'SUGESTÕES' || filter == 'SUGESTOES') {
      return _isSugestao(data);
    }
    if (filter == 'DATA') {
      return _matchesDateRange(data, selectedDateRange);
    }
    return true;
  }

  bool _matchesDateRange(
    Map<String, dynamic> data,
    DateTimeRange? selectedDateRange,
  ) {
    if (selectedDateRange == null) return true;

    DateTime? dateObj;
    final dataValue = data['data'];
    if (dataValue is Timestamp) {
      dateObj = dataValue.toDate();
    } else if (dataValue is DateTime) {
      dateObj = dataValue;
    } else if (dataValue is String) {
      dateObj = DateTime.tryParse(dataValue);
    }

    if (dateObj == null) return false;
    final dateOnly = DateTime(dateObj.year, dateObj.month, dateObj.day);
    final startOnly = DateTime(
      selectedDateRange.start.year,
      selectedDateRange.start.month,
      selectedDateRange.start.day,
    );
    final endOnly = DateTime(
      selectedDateRange.end.year,
      selectedDateRange.end.month,
      selectedDateRange.end.day,
    );

    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  bool _matchesSearch(Map<String, dynamic> data, String query) {
    final terms = query.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    final searchableText = <String>[
      data['titulo'] as String? ?? '',
      data['mensagem'] as String? ?? '',
      data['descricao'] as String? ?? '',
      data['userEmpresa'] as String? ?? data['empresaId'] as String? ?? '',
      data['atendimentoMood'] as String? ?? '',
      (data['tags'] as List<dynamic>?)?.cast<String>().join(' ') ?? '',
      '${data['generalRating'] ?? ''}',
      '${data['notaMedia'] ?? ''}',
    ].join(' ').toLowerCase();

    return terms.every((term) => searchableText.contains(term));
  }

  int _relevanceScore(Map<String, dynamic> data, String query) {
    final terms = query.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    final title = (data['titulo'] as String? ?? '').toLowerCase();
    final description =
        ((data['mensagem'] as String? ?? '') +
                ' ' +
                (data['descricao'] as String? ?? ''))
            .toLowerCase();
    final company =
        (data['userEmpresa'] as String? ?? data['empresaId'] as String? ?? '')
            .toLowerCase();
    final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final mood = (data['atendimentoMood'] as String? ?? '').toLowerCase();
    final ratingText =
        '${data['generalRating'] ?? ''} ${data['notaMedia'] ?? ''}';

    var score = 0;
    for (final term in terms) {
      if (title.contains(term)) score += 50;
      if (description.contains(term)) score += 30;
      if (company.contains(term)) score += 20;
      if (tags.any((tag) => tag.toLowerCase().contains(term))) score += 25;
      if (mood.contains(term)) score += 15;
      if (ratingText.contains(term)) score += 15;
      if (term == 'crítico' || term == 'critico' || term == 'urgente')
        score += 25;
      if (term == 'elogio' ||
          term == 'ótimo' ||
          term == 'otimo' ||
          term == 'excelente')
        score += 20;
      if (term == 'sugestão' || term == 'sugestao' || term == 'melhoria')
        score += 20;
      if (term == 'problema' || term == 'reclamação' || term == 'reclamacao')
        score += 15;
    }

    if (_isCritico(data)) score += 10;
    if (_isElogio(data)) score += 6;
    if (_isSugestao(data)) score += 8;
    return score;
  }

  bool _isCritico(Map<String, dynamic> data) {
    final title = (data['titulo'] as String? ?? '').toLowerCase();
    final text =
        ((data['mensagem'] as String? ?? '') +
                ' ' +
                (data['descricao'] as String? ?? '') +
                ' ' +
                (data['atendimentoMood'] as String? ?? ''))
            .toLowerCase();
    final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final notaMedia = (data['notaMedia'] as num?)?.toDouble() ?? 0.0;
    final generalRating = data['generalRating'] as int? ?? 0;

    return title.contains('crítico') ||
        title.contains('critico') ||
        title.contains('urgente') ||
        text.contains('crítico') ||
        text.contains('critico') ||
        text.contains('urgente') ||
        text.contains('problema') ||
        text.contains('atraso') ||
        tags.any((tag) {
          final lower = tag.toLowerCase();
          return lower.contains('crítico') ||
              lower.contains('critico') ||
              lower.contains('reclamação') ||
              lower.contains('reclamacao') ||
              lower.contains('urgente');
        }) ||
        notaMedia <= 4.5 ||
        generalRating <= 3;
  }

  bool _isElogio(Map<String, dynamic> data) {
    final title = (data['titulo'] as String? ?? '').toLowerCase();
    final text =
        ((data['mensagem'] as String? ?? '') +
                ' ' +
                (data['descricao'] as String? ?? ''))
            .toLowerCase();

    return title.contains('elogio') ||
        title.contains('ótimo') ||
        title.contains('otimo') ||
        title.contains('excelente') ||
        text.contains('elogio') ||
        text.contains('ótimo') ||
        text.contains('otimo') ||
        text.contains('excelente');
  }

  bool _isNeutro(Map<String, dynamic> data) {
    final notaMedia = (data['notaMedia'] as num?)?.toDouble() ?? 0.0;
    return notaMedia >= 4.0 && notaMedia < 7.0;
  }

  bool _isPositivo(Map<String, dynamic> data) {
    return _isElogio(data);
  }

  bool _isNegativo(Map<String, dynamic> data) {
    return _isCritico(data);
  }

  bool _isSugestao(Map<String, dynamic> data) {
    final title = (data['titulo'] as String? ?? '').toLowerCase();
    final text =
        ((data['mensagem'] as String? ?? '') +
                ' ' +
                (data['descricao'] as String? ?? ''))
            .toLowerCase();

    return title.contains('sugestão') ||
        title.contains('sugestao') ||
        title.contains('melhoria') ||
        text.contains('sugestão') ||
        text.contains('sugestao') ||
        text.contains('melhoria');
  }

  Future<void> enviarFeedback({
    required String mensagem,
    required String lote,
    required List<int> itemScores,
    required int generalRating,
    required String atendimentoMood,
    required List<String> tags,
    File? photoFile,
    Map<String, dynamic>? questionResponses,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }

    final userData = await _authService.getCurrentUserData();
    final userName = userData?['nome'] as String?;
    final userEmail = userData?['email'] as String?;
    final userType = userData?['tipo'] as String?;
    final userEmpresa =
        userData?['empresa'] as String? ?? userData?['empresaId'] as String?;

    final userEmpresaId = userData?['empresaId'] as String? ?? 'copperfio';

    final averageScore = itemScores.isEmpty
        ? 0.0
        : itemScores.reduce((a, b) => a + b) / itemScores.length;

    final paddedItemScores = List<int>.filled(8, 0);
    for (var i = 0; i < itemScores.length && i < 8; i++) {
      paddedItemScores[i] = itemScores[i];
    }

    String? photoUrl;
    if (photoFile != null) {
      try {
        photoUrl = await _service.uploadFeedbackImage(photoFile, userId);
      } catch (e) {
        // Image upload failed — log and continue without image (photo optional)
        debugPrint('uploadFeedbackImage failed: $e');
        photoUrl = null;
      }
    }

    await _service.criarFeedback(
      mensagem: mensagem,
      lote: lote,
      item1: paddedItemScores[0],
      item2: paddedItemScores[1],
      item3: paddedItemScores[2],
      item4: paddedItemScores[3],
      item5: paddedItemScores[4],
      item6: paddedItemScores[5],
      item7: paddedItemScores[6],
      item8: paddedItemScores[7],
      notaMedia: averageScore,
      generalRating: generalRating,
      atendimentoMood: atendimentoMood,
      tags: tags,
      photoUrl: photoUrl,
      userId: userId,
      userEmpresa: userEmpresa,
      userName: userName,
      userEmail: userEmail,
      userType: userType,
      empresaId: userEmpresaId,
      questionResponses: questionResponses,
    );

    // Incrementar CopperPoints após enviar feedback
    await _service.incrementUserCopperPoints(userId, 50);

    await const HistoryService().addAction(
      type: 'feedback',
      title: 'Feedback enviado',
      description: 'O usuário enviou um feedback sobre o lote $lote.',
      metadata: {
        'generalRating': generalRating,
        'atendimentoMood': atendimentoMood,
        'notaMedia': averageScore,
      },
    );
  }

  // Deletar feedback
  Future<void> deletarFeedback(String feedbackId) async {
    try {
      await _service.deletarFeedback(feedbackId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar feedback: $e');
    }
  }

  // Marcar feedback como lido
  Future<void> marcarComoLido(String feedbackId) async {
    try {
      await _service.marcarFeedbackComoLido(feedbackId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao marcar como lido: $e');
    }
  }

  // ============================================
  // MÉTODOS DE IA COM GEMINI
  // ============================================

  // Analisar feedback individual
  Future<Map<String, dynamic>> analisarFeedback(String feedbackId) async {
    try {
      await _authService.getCurrentUserData();

      final feedbackDoc = await _service.getFeedbackById(feedbackId);
      if (!feedbackDoc.exists) {
        throw Exception('Feedback não encontrado');
      }

      final feedbackData = feedbackDoc.data() as Map<String, dynamic>;
      final existingAnalise = feedbackData['analiseIA'];
      if (existingAnalise is Map<String, dynamic>) {
        return Map<String, dynamic>.from(existingAnalise);
      }

      final textoFeedback = _extrairTextoFeedback(feedbackData);

      final analise = await _geminiService.analisarFeedback(textoFeedback);

      // Salvar análise no Firestore
      await _service.salvarAnaliseFeedback(feedbackId, analise);

      return analise;
    } catch (e) {
      throw Exception('Erro ao analisar feedback: $e');
    }
  }

  // Gerar relatório de feedbacks
  Future<Map<String, dynamic>> gerarRelatorioFeedbacks({
    String? filtroTipo,
    DateTimeRange? periodo,
    int? limiteFeedbacks,
    required String topicoFoco,
  }) async {
    try {
      final userData = await _authService.getCurrentUserData();
      final empresaId = userData?['empresaId'] as String? ?? 'copperfio';

      // Buscar feedbacks com filtros
      final feedbacks = await _buscarFeedbacksParaRelatorio(
        empresaId,
        filtroTipo,
        periodo,
        limiteFeedbacks ?? 50,
      );

      if (feedbacks.isEmpty) {
        return {
          'resumoExecutivo':
              'Nenhum feedback encontrado no período selecionado.',
          'focoEstrategico': 'Não há dados para analisar o foco solicitado.',
          'metricas': {
            'notaMedia': 0.0,
            'totalPositivos': 0,
            'totalNegativos': 0,
            'totalNeutros': 0,
          },
          'analisePositiva': [],
          'analiseNegativa': [],
          'analiseNeutra': [],
          'recomendacoesAcao': [],
          'conclusao': 'Dados insuficientes.',
        };
      }

      int totalPositivos = 0;
      int totalNegativos = 0;
      int totalNeutros = 0;
      double somaNotas = 0.0;
      int countNotas = 0;

      // Somas para cada item (1-8)
      final somaItem = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      final countItem = [0, 0, 0, 0, 0, 0, 0, 0];

      for (var f in feedbacks) {
        if (_isElogio(f)) {
          totalPositivos++;
        } else if (_isCritico(f)) {
          totalNegativos++;
        } else {
          totalNeutros++;
        }

        final notaMedia = f['notaMedia'];
        if (notaMedia != null) {
          somaNotas += (notaMedia as num).toDouble();
          countNotas++;
        }

        // Coletar notas de cada item
        final items = [
          'item1',
          'item2',
          'item3',
          'item4',
          'item5',
          'item6',
          'item7',
          'item8',
        ];
        for (var i = 0; i < items.length; i++) {
          final itemValue = f[items[i]];
          if (itemValue != null) {
            somaItem[i] += (itemValue as num).toDouble();
            countItem[i]++;
          }
        }
      }

      final notaMediaGeral = countNotas > 0 ? (somaNotas / countNotas) : 0.0;

      // Calcular médias de cada item
      final mediaItem = List<double>.generate(
        8,
        (i) => countItem[i] > 0 ? somaItem[i] / countItem[i] : 0.0,
      );

      // Buscar CNPJs dos usuários e gerar tabela de clientes
      final tabelaClientes = await _gerarTabelaClientesComCnpj(feedbacks);

      final relatorio = await _gerarRelatorioComGemini(
        feedbacks,
        topicoFoco: topicoFoco,
        notaMedia: notaMediaGeral,
        totalPositivos: totalPositivos,
        totalNegativos: totalNegativos,
        totalNeutros: totalNeutros,
        mediaItem1: mediaItem[0],
        mediaItem2: mediaItem[1],
        mediaItem3: mediaItem[2],
        mediaItem4: mediaItem[3],
        mediaItem5: mediaItem[4],
        mediaItem6: mediaItem[5],
        mediaItem7: mediaItem[6],
        mediaItem8: mediaItem[7],
        tabelaClientes: tabelaClientes,
      );

      // Inclui as métricas reais no JSON de retorno para garantir precisão
      relatorio['metricas'] = {
        'notaMedia': double.parse(notaMediaGeral.toStringAsFixed(2)),
        'totalPositivos': totalPositivos,
        'totalNegativos': totalNegativos,
        'totalNeutros': totalNeutros,
      };

      // Anexa os feedbacks originais (apenas campos necessários) ao relatório
      relatorio['feedbacks'] = feedbacks.map((f) {
        return {
          'userId': f['userId'] ?? '',
          'userEmpresa': f['userEmpresa'] ?? f['userName'] ?? '',
          'item1': f['item1'] ?? 0,
          'item2': f['item2'] ?? 0,
          'item3': f['item3'] ?? 0,
          'item4': f['item4'] ?? 0,
          'item5': f['item5'] ?? 0,
          'item6': f['item6'] ?? 0,
          'item7': f['item7'] ?? 0,
          'item8': f['item8'] ?? 0,
          'notaMedia': f['notaMedia'] ?? 0.0,
          'mensagem': f['mensagem'] ?? '',
        };
      }).toList();

      // Salvar relatório no Firestore
      await _service.salvarRelatorioEmpresa(empresaId, relatorio, {
        'filtroTipo': filtroTipo,
        'topicoFoco': topicoFoco,
        'periodo': periodo != null
            ? {
                'inicio': periodo.start.toIso8601String(),
                'fim': periodo.end.toIso8601String(),
              }
            : null,
        'totalFeedbacks': feedbacks.length,
      });

      return relatorio;
    } catch (e) {
      throw Exception('Erro ao gerar relatório: $e');
    }
  }

  // Analisar plano de ação para empresa
  Future<Map<String, dynamic>> analisarPlanoDeAcao({
    DateTimeRange? periodo,
  }) async {
    try {
      final userData = await _authService.getCurrentUserData();
      final empresaId = userData?['empresaId'] as String? ?? 'copperfio';

      // Buscar apenas feedbacks negativos/crìticos
      final feedbacksCriticos = await _buscarFeedbacksCriticos(
        empresaId,
        periodo,
      );

      if (feedbacksCriticos.isEmpty) {
        return {
          'status': 'positivo',
          'problemaPrincipal': 'Nenhum problema crítico identificado',
          'impactoNegocio': 'Baixo risco',
          'acoesPrioritarias': [],
          'acoesMedioTermo': [],
          'metricasMonitoramento': [],
          'estimativaImpacto': 'Situação estável',
        };
      }

      final plano = await _gerarPlanoDeAcaoComGemini(feedbacksCriticos);

      // Salvar plano no Firestore
      await _service.salvarPlanoDeAcao(empresaId, plano, {
        'periodo': periodo != null
            ? {
                'inicio': periodo.start.toIso8601String(),
                'fim': periodo.end.toIso8601String(),
              }
            : null,
        'feedbacksAnalisados': feedbacksCriticos.length,
      });

      return plano;
    } catch (e) {
      throw Exception('Erro ao analisar plano de ação: $e');
    }
  }

  // ============================================
  // MÉTODOS AUXILIARES PARA IA
  // ============================================

  String _extrairTextoFeedback(Map<String, dynamic> feedbackData) {
    final titulo = feedbackData['titulo'] as String? ?? '';
    final mensagem = feedbackData['mensagem'] as String? ?? '';
    final descricao = feedbackData['descricao'] as String? ?? '';
    final atendimentoMood = feedbackData['atendimentoMood'] as String? ?? '';
    final tags = (feedbackData['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final notaMedia = feedbackData['notaMedia'] as num? ?? 0;

    return '''
Título: $titulo
Mensagem: $mensagem
Descrição: $descricao
Nota: $notaMedia/10
Humor do atendimento: $atendimentoMood
Tags: ${tags.join(', ')}
'''
        .trim();
  }

  Future<List<Map<String, dynamic>>> _buscarFeedbacksParaRelatorio(
    String empresaId,
    String? filtroTipo,
    DateTimeRange? periodo,
    int limite,
  ) async {
    final feedbacks = await _service.buscarFeedbacksParaRelatorio(
      empresaId,
      periodo,
      limite,
    );

    if (filtroTipo == null) {
      return feedbacks;
    }

    final filtro = filtroTipo.toUpperCase();
    return feedbacks.where((data) {
      if (filtro == 'CRÍTICOS' || filtro == 'CRITICOS') {
        return _isCritico(data);
      }
      if (filtro == 'ELOGIOS') {
        return _isElogio(data);
      }
      if (filtro == 'SUGESTÕES' || filtro == 'SUGESTOES') {
        return _isSugestao(data);
      }
      return true;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _buscarFeedbacksCriticos(
    String empresaId,
    DateTimeRange? periodo,
  ) async {
    return await _service.buscarFeedbacksCriticos(empresaId, periodo);
  }

  // Gerar tabela de clientes com CNPJ
  Future<String> _gerarTabelaClientesComCnpj(
    List<Map<String, dynamic>> feedbacks,
  ) async {
    final Map<String, Map<String, dynamic>> clientesUnicos = {};

    // Mapear clientes únicos com seus dados
    for (var feedback in feedbacks) {
      final userId = feedback['userId'] as String? ?? '';
      final userEmpresa = feedback['userEmpresa'] as String? ?? '';

      if (userId.isNotEmpty && userEmpresa.isNotEmpty) {
        if (!clientesUnicos.containsKey(userId)) {
          clientesUnicos[userId] = {'userEmpresa': userEmpresa, 'cnpj': ''};
        }
      }
    }

    // Buscar CNPJs para cada usuário único
    for (var userId in clientesUnicos.keys) {
      try {
        final userDoc = await _service.getUserData(userId);
        if (userDoc != null) {
          final cnpj = userDoc['cnpj'] as String? ?? '';
          clientesUnicos[userId]!['cnpj'] = cnpj;
        }
      } catch (e) {
        print('⚠️ Erro ao buscar CNPJ do usuário $userId: $e');
      }
    }

    // Montar a tabela formatada
    final buffer = StringBuffer();
    buffer.writeln('TABELA DE CLIENTES E CNPJ:');
    buffer.writeln('─' * 80);
    buffer.writeln('Cliente'.padRight(40) + 'CNPJ');
    buffer.writeln('─' * 80);

    for (var cliente in clientesUnicos.values) {
      final empresa = (cliente['userEmpresa'] as String? ?? '').padRight(40);
      final cnpj = cliente['cnpj'] as String? ?? '';
      buffer.writeln('$empresa$cnpj');
    }

    buffer.writeln('─' * 80);
    return buffer.toString();
  }

  Future<Map<String, dynamic>> _gerarRelatorioComGemini(
    List<Map<String, dynamic>> feedbacks, {
    required String topicoFoco,
    required double notaMedia,
    required int totalPositivos,
    required int totalNegativos,
    required int totalNeutros,
    required double mediaItem1,
    required double mediaItem2,
    required double mediaItem3,
    required double mediaItem4,
    required double mediaItem5,
    required double mediaItem6,
    required double mediaItem7,
    required double mediaItem8,
    String tabelaClientes = '',
  }) async {
    return await _geminiService.gerarRelatorio(
      feedbacks,
      topicoFoco: topicoFoco,
      notaMedia: notaMedia,
      totalPositivos: totalPositivos,
      totalNegativos: totalNegativos,
      totalNeutros: totalNeutros,
      mediaItem1: mediaItem1,
      mediaItem2: mediaItem2,
      mediaItem3: mediaItem3,
      mediaItem4: mediaItem4,
      mediaItem5: mediaItem5,
      mediaItem6: mediaItem6,
      mediaItem7: mediaItem7,
      mediaItem8: mediaItem8,
      tabelaClientes: tabelaClientes,
    );
  }

  Future<Map<String, dynamic>> _gerarPlanoDeAcaoComGemini(
    List<Map<String, dynamic>> feedbacks,
  ) async {
    return await _geminiService.analisarPlanoDeAcao(feedbacks);
  }
}
