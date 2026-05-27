import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _feedbacksSubscription;

  String greeting = 'Olá, Gestor.';
  int feedbacks = 0;
  int satisfacao = 25;
  int alertas = 0;
  int chamados = 0;

  Map<String, int> problemasPorLote = {};
  Map<String, double> distribuicaoSentimento = {
    'Positivo': 0,
    'Neutro': 0,
    'Negativo': 0,
  };
  Map<String, double> radarMetrics = {
    'DURABILIDADE': 0,
    'EMBALAGEM': 0,
    'PRECISÃO': 0,
    'LOGÍSTICA': 0,
    'ATENDIMENTO': 0,
  };
  Map<String, double> radarPreviousMetrics = {
    'DURABILIDADE': 0,
    'EMBALAGEM': 0,
    'PRECISÃO': 0,
    'LOGÍSTICA': 0,
    'ATENDIMENTO': 0,
  };
  List<double> evolucaoSatisfacao = [0, 0, 0, 0, 0];
  List<double> satisfacaoTrendValues = [0, 0, 0, 0, 0];
  List<String> satisfacaoTrendLabels = ['1', '2', '3', '4', '5'];
  
  Map<String, List<double>> satisfacaoTrendByPeriod = {
    'semanal': [],
    'mensal': [],
    'anual': [],
  };
  Map<String, List<String>> satisfacaoLabelsByPeriod = {
    'semanal': [],
    'mensal': [],
    'anual': [],
  };

  Future<void> loadData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      final empresaId = userData?['empresaId'] as String? ?? 'copperfio';
      final userName = userData?['nome'] as String?;

      greeting = 'Olá, ${userName?.split(' ').first ?? 'Gestor'}.';

      final feedbackStream = _firestoreService.getFeedbacks(empresaId);
      _feedbacksSubscription?.cancel();
      _feedbacksSubscription = feedbackStream.listen(
        (snapshot) {
          final docs = snapshot.docs;
          feedbacks = docs.length;
          alertas = docs.where((doc) => (doc.data()['isRead'] as bool?) == false).length;
          _buildAnalytics(docs);
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Erro no stream de feedbacks do dashboard: $error');
        },
      );

      chamados = await _firestoreService.getChamadosCount(empresaId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados do dashboard: $e');
    }
  }

  void _buildAnalytics(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> feedbackDocs,
  ) {
    final loteCounts = <String, int>{};
    final sentimentoCounts = <String, int>{
      'Positivo': 0,
      'Neutro': 0,
      'Negativo': 0,
    };
    final satisfacaoValores = <double>[];
    final metricEntries = <Map<String, dynamic>>[];

    final satisfacaoTrendByDay = <DateTime, List<double>>{};

    for (final doc in feedbackDocs) {
      final data = doc.data();
      final lote = (data['lote'] as String?)?.toUpperCase().trim() ?? '';
      if (lote.isNotEmpty) {
        loteCounts[lote] = (loteCounts[lote] ?? 0) + 1;
      }

      final notaMedia = (data['notaMedia'] as num?)?.toDouble() ?? 0.0;
      final analiseIA = (data['analiseIA'] as Map<String, dynamic>?) ??
          (data['iaAnalysis'] as Map<String, dynamic>?);
      final sentimento = analiseIA != null
          ? (analiseIA['sentimento'] as String?)?.toLowerCase()
          : null;

      if (sentimento == 'positivo' || sentimento == 'positiva') {
        sentimentoCounts['Positivo'] = sentimentoCounts['Positivo']! + 1;
      } else if (sentimento == 'negativo') {
        sentimentoCounts['Negativo'] = sentimentoCounts['Negativo']! + 1;
      } else if (sentimento == 'neutro') {
        sentimentoCounts['Neutro'] = sentimentoCounts['Neutro']! + 1;
      } else {
        if (notaMedia >= 7.0) {
          sentimentoCounts['Positivo'] = sentimentoCounts['Positivo']! + 1;
        } else if (notaMedia >= 4.0) {
          sentimentoCounts['Neutro'] = sentimentoCounts['Neutro']! + 1;
        } else {
          sentimentoCounts['Negativo'] = sentimentoCounts['Negativo']! + 1;
        }
      }

      final satisfacao = (notaMedia.clamp(0.0, 10.0) * 10).roundToDouble();
      satisfacaoValores.add(satisfacao);

      final timestamp = (data['data'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);
      satisfacaoTrendByDay.putIfAbsent(dateOnly, () => []).add(satisfacao);

      final productQuality = (data['item2'] as num?)?.toDouble() ?? 0.0;
      final packagingScore = (data['item3'] as num?)?.toDouble() ?? 0.0;
      final deliveryPunctuality = (data['item4'] as num?)?.toDouble() ?? 0.0;
      final technicalKnowledge = (data['item5'] as num?)?.toDouble() ?? 0.0;
      final cordialityEmpathy = (data['item6'] as num?)?.toDouble() ?? 0.0;
      final supportQuality = (data['item7'] as num?)?.toDouble() ?? 0.0;
      final supportSatisfaction = (data['item8'] as num?)?.toDouble() ?? 0.0;
      final atendimentoAverage = (cordialityEmpathy + supportQuality + supportSatisfaction) / 3.0;

      metricEntries.add({
        'DATE': timestamp.millisecondsSinceEpoch.toDouble(),
        'DURABILIDADE': productQuality,
        'EMBALAGEM': packagingScore,
        'PRECISÃO': technicalKnowledge,
        'LOGÍSTICA': deliveryPunctuality,
        'ATENDIMENTO': atendimentoAverage,
      });
    }

    final sortedTrendDates = satisfacaoTrendByDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    final trendDates = sortedTrendDates.length <= 7
        ? sortedTrendDates
        : sortedTrendDates.sublist(sortedTrendDates.length - 7);
    satisfacaoTrendValues = trendDates
        .map((date) {
          final values = satisfacaoTrendByDay[date]!;
          return values.reduce((a, b) => a + b) / values.length;
        })
        .toList();
    satisfacaoTrendLabels = trendDates
        .map((date) => '${date.day}/${date.month.toString().padLeft(2, '0')}')
        .toList();

    if (satisfacaoTrendValues.isEmpty) {
      satisfacaoTrendValues = [0, 0, 0, 0, 0];
      satisfacaoTrendLabels = ['01/00', '02/00', '03/00', '04/00', '05/00'];
    }

    _computeSatisfactionTrendByPeriod(satisfacaoTrendByDay);

    final sortedLoteEntries = loteCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    problemasPorLote = Map.fromEntries(sortedLoteEntries.take(4));

    if (problemasPorLote.isEmpty) {
      problemasPorLote = {
        'CASE1': 0,
        'CASE2': 0,
        'CASE3': 0,
        'CASE4': 0,
      };
    }

    final totalSentimentos = sentimentoCounts.values.fold<int>(0, (sum, val) => sum + val);
    distribuicaoSentimento = sentimentoCounts.map((key, count) {
      return MapEntry(key, totalSentimentos == 0 ? 0.0 : (count / totalSentimentos) * 100);
    });

    metricEntries.sort((a, b) => a['DATE']!.compareTo(b['DATE']!));
    final splitIndex = (metricEntries.length / 2).floor();
    final currentMetrics = metricEntries.sublist(splitIndex);
    final previousMetrics = metricEntries.sublist(0, splitIndex);

    radarMetrics = _computeRadarMetrics(currentMetrics);
    radarPreviousMetrics = previousMetrics.isNotEmpty
        ? _computeRadarMetrics(previousMetrics)
        : radarMetrics;

    if (satisfacaoValores.isNotEmpty) {
      final average = satisfacaoValores.reduce((a, b) => a + b) / satisfacaoValores.length;
      satisfacao = average.round().clamp(0, 100);
    }

    evolucaoSatisfacao = List<double>.generate(
      5,
      (index) => index < satisfacaoValores.length ? satisfacaoValores[index] : 0,
    );

    if (evolucaoSatisfacao.every((value) => value == 0)) {
      evolucaoSatisfacao = [55, 65, 60, 70, 50];
    }
  }

  Map<String, double> _computeRadarMetrics(
    List<Map<String, dynamic>> entries,
  ) {
    if (entries.isEmpty) {
      return {
        'DURABILIDADE': 0,
        'EMBALAGEM': 0,
        'PRECISÃO': 0,
        'LOGÍSTICA': 0,
        'ATENDIMENTO': 0,
      };
    }

    final totals = <String, double>{
      'DURABILIDADE': 0,
      'EMBALAGEM': 0,
      'PRECISÃO': 0,
      'LOGÍSTICA': 0,
      'ATENDIMENTO': 0,
    };

    for (final entry in entries) {
      totals['DURABILIDADE'] = totals['DURABILIDADE']! + (entry['DURABILIDADE'] ?? 0);
      totals['EMBALAGEM'] = totals['EMBALAGEM']! + (entry['EMBALAGEM'] ?? 0);
      totals['PRECISÃO'] = totals['PRECISÃO']! + (entry['PRECISÃO'] ?? 0);
      totals['LOGÍSTICA'] = totals['LOGÍSTICA']! + (entry['LOGÍSTICA'] ?? 0);
      totals['ATENDIMENTO'] = totals['ATENDIMENTO']! + (entry['ATENDIMENTO'] ?? 0);
    }

    return totals.map((key, total) {
      return MapEntry(key, (total / entries.length).clamp(0.0, 10.0));
    });
  }

  void _computeSatisfactionTrendByPeriod(Map<DateTime, List<double>> trendByDay) {
    if (trendByDay.isEmpty) {
      satisfacaoTrendByPeriod['semanal'] = List.filled(7, 0.0);
      satisfacaoLabelsByPeriod['semanal'] = List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 7 - index));
        return '${date.day}/${date.month.toString().padLeft(2, '0')}';
      });
      satisfacaoTrendByPeriod['mensal'] = List.filled(6, 0.0);
      satisfacaoLabelsByPeriod['mensal'] = List.generate(6, (index) {
        final date = DateTime.now().subtract(Duration(days: 30 - index * 5));
        return '${date.day}/${date.month.toString().padLeft(2, '0')}';
      });
      satisfacaoTrendByPeriod['anual'] = List.filled(12, 0.0);
      satisfacaoLabelsByPeriod['anual'] = [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ];
      return;
    }

    final sortedDates = trendByDay.keys.toList()..sort();
    final now = DateTime.now();

    // Semanal (últimos 7 dias)
    final weekValues = <double>[];
    final weekLabels = <String>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final values = trendByDay[dateOnly] ?? [];
      final average = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0.0;
      weekValues.add(average);
      weekLabels.add('${dateOnly.day}/${dateOnly.month.toString().padLeft(2, '0')}');
    }
    satisfacaoTrendByPeriod['semanal'] = weekValues;
    satisfacaoLabelsByPeriod['semanal'] = weekLabels;

    // Mensal (últimos 30 dias) - agrupado em 5 blocos de 6 dias para manter um conjunto compacto
    final monthValues = <double>[];
    final monthLabels = <String>[];
    for (int block = 0; block < 6; block++) {
      final blockStart = now.subtract(Duration(days: 29 - block * 5));
      final blockEnd = blockStart.add(Duration(days: 4));
      final blockEntries = trendByDay.entries.where((entry) {
        final date = entry.key;
        return !date.isBefore(blockStart) && !date.isAfter(blockEnd);
      }).expand((entry) => entry.value).toList();
      final average = blockEntries.isNotEmpty ? blockEntries.reduce((a, b) => a + b) / blockEntries.length : 0.0;
      monthValues.add(average);
      monthLabels.add('${blockStart.day}/${blockStart.month.toString().padLeft(2, '0')}');
    }
    satisfacaoTrendByPeriod['mensal'] = monthValues;
    satisfacaoLabelsByPeriod['mensal'] = monthLabels;

    // Anual (últimos 12 meses) - agrupado por mês
    final yearValues = <double>[];
    final yearLabels = <String>[];
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    for (int monthOffset = 11; monthOffset >= 0; monthOffset--) {
      final date = DateTime(now.year, now.month - monthOffset, 1);
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 1).subtract(const Duration(days: 1));
      final monthEntries = trendByDay.entries.where((entry) {
        final entryDate = entry.key;
        return !entryDate.isBefore(startOfMonth) && !entryDate.isAfter(endOfMonth);
      }).expand((entry) => entry.value).toList();
      final average = monthEntries.isNotEmpty ? monthEntries.reduce((a, b) => a + b) / monthEntries.length : 0.0;
      yearValues.add(average);
      yearLabels.add(months[date.month - 1]);
    }
    satisfacaoTrendByPeriod['anual'] = yearValues;
    satisfacaoLabelsByPeriod['anual'] = yearLabels;
  }

  @override
  void dispose() {
    _feedbacksSubscription?.cancel();
    super.dispose();
  }
}
