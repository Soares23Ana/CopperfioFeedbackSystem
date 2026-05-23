import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> uploadFeedbackImage(File imageFile, String userId) async {
    if (!await imageFile.exists()) {
      throw Exception('Arquivo de imagem não encontrado. Tente novamente.');
    }

    final storage = FirebaseStorage.instance;
    final reference = storage
        .ref()
        .child('feedback_images')
        .child('$userId-${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final uploadTask = reference.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      if (snapshot.state != TaskState.success) {
        throw Exception('Falha ao enviar imagem: upload não concluído.');
      }

      // Try to get download URL; sometimes a transient error occurs,
      // retry once before failing to reduce 'No object exists' issues.
      try {
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        // retry once after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          return await storage.ref(snapshot.ref.fullPath).getDownloadURL();
        } catch (e2) {
          throw FirebaseException(
            plugin: 'firebase_storage',
            message: 'Falha ao obter URL da imagem enviada: ${e2.toString()}',
          );
        }
      }
    } on FirebaseException catch (e) {
      throw Exception('Falha ao enviar imagem: ${e.message ?? e.code}');
    }
  }

  // 🔹 Criar feedback
  Future<void> criarFeedback({
    required String mensagem,
    required String userId,
    required String empresaId,
    String? lote,
    int? item1,
    int? item2,
    int? item3,
    int? item4,
    int? item5,
    int? item6,
    int? item7,
    int? item8,
    double? notaMedia,
    String? userEmpresa,
    String? userName,
    String? userEmail,
    String? userType,
    String? atendimentoMood,
    List<String>? tags,
    String? photoUrl,
    int? generalRating,
    Map<String, dynamic>? questionResponses,
  }) async {
    await _db.collection('feedbacks').add({
      'mensagem': mensagem,
      'lote': lote ?? '',
      'item1': item1 ?? 0,
      'item2': item2 ?? 0,
      'item3': item3 ?? 0,
      'item4': item4 ?? 0,
      'item5': item5 ?? 0,
      'item6': item6 ?? 0,
      'item7': item7 ?? 0,
      'item8': item8 ?? 0,
      'notaMedia': notaMedia ?? 0.0,
      'generalRating': generalRating ?? 0,
      'atendimentoMood': atendimentoMood ?? '',
      'tags': tags ?? [],
      'photoUrl': photoUrl ?? '',
      'userId': userId,
      'userEmpresa': userEmpresa ?? '',
      'userName': userName ?? '',
      'userEmail': userEmail ?? '',
      'userType': userType ?? 'cliente',
      'empresaId': empresaId,
      'questionResponses': questionResponses ?? {},
      'data': Timestamp.now(),
      'status': 'novo',
      'isRead': false,
    });
  }

  // 🔹 Criar pedido / solicitação de orçamento
  Future<String> criarPedido({
    String? userId,
    String? empresaId,
    required String nome,
    required String empresa,
    required String endereco,
    required String bairro,
    required String estado,
    required String cidade,
    required String cep,
    required String fone,
    required String email,
    required String observacoes,
    List<String>? items,
    String? total,
    String? status,
    String? summary,
    String? details,
    String? notes,
  }) async {
    final summaryText = summary?.trim().isNotEmpty == true
        ? summary!.trim()
        : (observacoes.trim().isNotEmpty
              ? observacoes
                    .trim()
                    .replaceAll('\n', ' ')
                    .replaceAll(RegExp('\s+'), ' ')
              : 'Pedido de orçamento');

    final docRef = await _db.collection('pedidos').add({
      'userId': userId ?? '',
      'empresaId': empresaId ?? 'copperfio',
      'nome': nome,
      'empresa': empresa,
      'endereco': endereco,
      'bairro': bairro,
      'estado': estado,
      'cidade': cidade,
      'cep': cep,
      'fone': fone,
      'email': email,
      'observacoes': observacoes,
      'items': items ?? [],
      'total': total ?? '',
      'status': status ?? 'novo',
      'summary': summaryText,
      'details': details ?? observacoes,
      'notes': notes ?? 'Solicitação enviada por $nome',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // 🔹 Stream de feedbacks (tempo real)
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedbacks(String empresaId) {
    return _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .snapshots();
  }

  // 🔹 Obter atualizações do catálogo para notificações de cliente
  Future<QuerySnapshot<Map<String, dynamic>>> fetchCatalogUpdates(
    String empresaId,
  ) async {
    return await _db
        .collection('catalog_updates')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  // 🔹 Obter erros de aplicativo para notificações de cliente
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAppErrors(
    String empresaId,
  ) async {
    return await _db
        .collection('app_errors')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  // 🔹 Obter feedbacks da empresa em lote (para cálculos analíticos)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getFeedbackDocuments(String empresaId) async {
    final query = await _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('data', descending: true)
        .get();
    return query.docs;
  }

  // 🔹 Deletar feedback
  Future<void> deletarFeedback(String feedbackId) async {
    await _db.collection('feedbacks').doc(feedbackId).delete();
  }

  // 🔹 Marcar feedback como lido
  Future<void> marcarFeedbackComoLido(String feedbackId) async {
    await _db.collection('feedbacks').doc(feedbackId).update({'isRead': true});
  }

  // 🔹 Contar feedbacks da empresa
  Future<int> getFeedbacksCount(String empresaId) async {
    final snapshot = await _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // 🔹 Contar feedbacks não lidos (alertas)
  Future<int> getUnreadFeedbacksCount(String empresaId) async {
    final snapshot = await _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // 🔹 Contar chamados da empresa
  Future<int> getChamadosCount(String empresaId) async {
    final snapshot = await _db
        .collection('chamados')
        .where('empresaId', isEqualTo: empresaId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // 🔹 Obter CopperPoints do usuário
  Future<int> getUserCopperPoints(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.data()?['copperPoints'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // 🔹 Incrementar CopperPoints do usuário
  Future<void> incrementUserCopperPoints(String userId, int points) async {
    try {
      await _db.collection('users').doc(userId).update({
        'copperPoints': FieldValue.increment(points),
      });
    } catch (e) {
      // Se o documento não existir ou não ter o campo, cria
      await _db.collection('users').doc(userId).set({
        'copperPoints': points,
      }, SetOptions(merge: true));
    }
  }

  // 🔹 Obter dados completos do usuário incluindo CopperPoints
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // MÉTODOS PARA IA COM GEMINI
  // ============================================

  // Obter feedback por ID
  Future<DocumentSnapshot> getFeedbackById(String feedbackId) async {
    return await _db.collection('feedbacks').doc(feedbackId).get();
  }

  // Salvar análise de feedback individual
  Future<void> salvarAnaliseFeedback(
    String feedbackId,
    Map<String, dynamic> analise,
  ) async {
    await _db.collection('feedbacks').doc(feedbackId).update({
      'analiseIA': analise,
      'analisadoEm': FieldValue.serverTimestamp(),
    });
  }

  // Salvar relatório da empresa
  Future<void> salvarRelatorioEmpresa(
    String empresaId,
    Map<String, dynamic> relatorio,
    Map<String, dynamic> metadata,
  ) async {
    await _db.collection('relatorios_ia').add({
      'empresaId': empresaId,
      'relatorio': relatorio,
      'metadata': metadata,
      'criadoEm': FieldValue.serverTimestamp(),
      'tipo': 'relatorio_feedback',
    });
  }

  // Salvar plano de ação da empresa
  Future<void> salvarPlanoDeAcao(
    String empresaId,
    Map<String, dynamic> plano,
    Map<String, dynamic> metadata,
  ) async {
    await _db.collection('planos_de_acao').add({
      'empresaId': empresaId,
      'plano': plano,
      'metadata': metadata,
      'criadoEm': FieldValue.serverTimestamp(),
      'status': 'ativo',
    });
  }

  // Obter análises de feedback da empresa
  Stream<QuerySnapshot> getAnalisesFeedback(String empresaId) {
    return _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .where('analiseIA', isNotEqualTo: null)
        .orderBy('analisadoEm', descending: true)
        .snapshots();
  }

  // Obter relatórios da empresa
  Stream<QuerySnapshot> getRelatoriosEmpresa(String empresaId) {
    return _db
        .collection('relatorios_ia')
        .where('empresaId', isEqualTo: empresaId)
        .snapshots();
  }

  // Excluir relatório da empresa
  Future<void> deleteRelatorio(String relatorioId) async {
    await _db.collection('relatorios_ia').doc(relatorioId).delete();
  }

  // Obter planos de ação da empresa
  Stream<QuerySnapshot> getPlanosDeAcao(String empresaId) {
    return _db
        .collection('planos_de_acao')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('criadoEm', descending: true)
        .snapshots();
  }

  // Obter feedbacks por usuário
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedbacksByUserStream(
    String userId,
  ) {
    return _db
        .collection('feedbacks')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Buscar feedbacks para relatório
  Future<List<Map<String, dynamic>>> buscarFeedbacksParaRelatorio(
    String empresaId,
    DateTimeRange? periodo,
    int limite,
  ) async {
    final snapshot = await _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .get();

    final feedbacks = snapshot.docs.map((doc) => doc.data()).where((data) {
      if (periodo == null) {
        return true;
      }

      final dateValue = data['data'];
      DateTime? dateObj;

      if (dateValue is DateTime) {
        dateObj = dateValue;
      } else if (dateValue is Timestamp) {
        dateObj = dateValue.toDate();
      } else if (dateValue is String) {
        dateObj = DateTime.tryParse(dateValue);
      }

      if (dateObj == null) {
        return false;
      }

      return !dateObj.isBefore(periodo.start) && !dateObj.isAfter(periodo.end);
    }).toList();

    feedbacks.sort((a, b) {
      DateTime parseDate(dynamic value) {
        if (value is DateTime) {
          return value;
        }
        if (value is Timestamp) {
          return value.toDate();
        }
        if (value is String) {
          return DateTime.tryParse(value) ??
              DateTime.fromMillisecondsSinceEpoch(0);
        }
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      return parseDate(b['data']).compareTo(parseDate(a['data']));
    });

    if (feedbacks.length > limite) {
      return feedbacks.sublist(0, limite);
    }

    return feedbacks;
  }

  // Buscar feedbacks críticos
  Future<List<Map<String, dynamic>>> buscarFeedbacksCriticos(
    String empresaId,
    DateTimeRange? periodo,
  ) async {
    Query<Map<String, dynamic>> query = _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .where('notaMedia', isLessThanOrEqualTo: 6)
        .orderBy('notaMedia')
        .orderBy('data', descending: true);

    if (periodo != null) {
      query = query
          .where('data', isGreaterThanOrEqualTo: periodo.start)
          .where('data', isLessThanOrEqualTo: periodo.end);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  double _normalizeFeedbackRating(Map<String, dynamic> data) {
    final notaMedia = (data['notaMedia'] as num?)?.toDouble() ?? 0.0;
    final generalRating = (data['generalRating'] as num?)?.toDouble() ?? 0.0;

    if (notaMedia > 0) {
      return notaMedia.clamp(0.0, 10.0);
    }

    if (generalRating > 0) {
      return (generalRating <= 5 ? generalRating * 2.0 : generalRating).clamp(
        0.0,
        10.0,
      );
    }

    return 0.0;
  }

  double _calculateEfficiencyFromRatings(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    return double.parse((average.clamp(0.0, 10.0) * 10).toStringAsFixed(1));
  }

  // 🔹 Obter eficiência de produção baseada em feedbacks
  Future<Map<String, dynamic>> getProductionEfficiency(String empresaId) async {
    try {
      final now = DateTime.now();
      final lastTurnTime = now.subtract(const Duration(hours: 8));

      // Feedbacks do turno atual
      final currentTurnSnapshot = await _db
          .collection('feedbacks')
          .where('empresaId', isEqualTo: empresaId)
          .where(
            'data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastTurnTime),
          )
          .get();

      // Feedbacks do turno anterior
      final previousTurnTime = lastTurnTime.subtract(const Duration(hours: 8));
      final previousTurnSnapshot = await _db
          .collection('feedbacks')
          .where('empresaId', isEqualTo: empresaId)
          .where(
            'data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(previousTurnTime),
          )
          .where('data', isLessThan: Timestamp.fromDate(lastTurnTime))
          .get();

      // Feedbacks totais da empresa para obter a média geral
      final allSnapshot = await _db
          .collection('feedbacks')
          .where('empresaId', isEqualTo: empresaId)
          .orderBy('data', descending: true)
          .get();

      final allRatings = allSnapshot.docs
          .map((doc) => _normalizeFeedbackRating(doc.data()))
          .where((rating) => rating > 0)
          .toList();

      final overallEfficiency = allRatings.isNotEmpty
          ? _calculateEfficiencyFromRatings(allRatings)
          : 83.5;

      double variation = 0.0;
      if (currentTurnSnapshot.docs.isNotEmpty &&
          previousTurnSnapshot.docs.isNotEmpty) {
        final currentRatings = currentTurnSnapshot.docs
            .map((doc) => _normalizeFeedbackRating(doc.data()))
            .where((rating) => rating > 0)
            .toList();

        final previousRatings = previousTurnSnapshot.docs
            .map((doc) => _normalizeFeedbackRating(doc.data()))
            .where((rating) => rating > 0)
            .toList();

        if (currentRatings.isNotEmpty && previousRatings.isNotEmpty) {
          final currentEfficiency = _calculateEfficiencyFromRatings(
            currentRatings,
          );
          final previousEfficiency = _calculateEfficiencyFromRatings(
            previousRatings,
          );
          variation = double.parse(
            (currentEfficiency - previousEfficiency).toStringAsFixed(1),
          );
        }
      }

      return {
        'efficiency': overallEfficiency,
        'variation': variation,
        'feedbackCount': allSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Erro ao obter eficiência de produção: $e');
      return {'efficiency': 83.5, 'variation': 2.1, 'feedbackCount': 0};
    }
  }

  // 🔹 Stream de eficiência de produção (atualização em tempo real)
  Stream<Map<String, dynamic>> getProductionEfficiencyStream(String empresaId) {
    return _db
        .collection('feedbacks')
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return {'efficiency': 83.5, 'variation': 2.1, 'feedbackCount': 0};
          }

          final allRatings = snapshot.docs
              .map((doc) => _normalizeFeedbackRating(doc.data()))
              .where((rating) => rating > 0)
              .toList();

          final overallEfficiency = allRatings.isNotEmpty
              ? _calculateEfficiencyFromRatings(allRatings)
              : 83.5;

          final now = DateTime.now();
          final lastTurnTime = now.subtract(const Duration(hours: 8));
          final previousTurnTime = lastTurnTime.subtract(
            const Duration(hours: 8),
          );

          final currentRatings = snapshot.docs
              .where((doc) {
                final data = doc.data();
                final dateValue = data['data'];
                if (dateValue is Timestamp) {
                  return dateValue.toDate().isAfter(lastTurnTime);
                }
                return false;
              })
              .map((doc) => _normalizeFeedbackRating(doc.data()))
              .where((rating) => rating > 0)
              .toList();

          final previousRatings = snapshot.docs
              .where((doc) {
                final data = doc.data();
                final dateValue = data['data'];
                if (dateValue is Timestamp) {
                  final date = dateValue.toDate();
                  return date.isAfter(previousTurnTime) &&
                      date.isBefore(lastTurnTime);
                }
                return false;
              })
              .map((doc) => _normalizeFeedbackRating(doc.data()))
              .where((rating) => rating > 0)
              .toList();

          double variation = 0.0;
          if (currentRatings.isNotEmpty && previousRatings.isNotEmpty) {
            final currentEfficiency = _calculateEfficiencyFromRatings(
              currentRatings,
            );
            final previousEfficiency = _calculateEfficiencyFromRatings(
              previousRatings,
            );
            variation = double.parse(
              (currentEfficiency - previousEfficiency).toStringAsFixed(1),
            );
          }

          return {
            'efficiency': overallEfficiency,
            'variation': variation,
            'feedbackCount': snapshot.docs.length,
          };
        });
  }

  // 🔹 Buscar pedidos por empresa
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  buscarPedidosPorEmpresa(String empresaId, {int limite = 50}) async {
    try {
      final snapshot = await _db
          .collection('pedidos')
          .where('empresaId', isEqualTo: empresaId)
          .limit(limite)
          .get();

      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final aDate = a.data()['createdAt'];
        final bDate = b.data()['createdAt'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        return -1;
      });
      return docs;
    } catch (e) {
      debugPrint('Erro ao buscar pedidos da empresa: $e');
      return [];
    }
  }

  // 🔹 Stream de pedidos por empresa (tempo real)
  Stream<QuerySnapshot<Map<String, dynamic>>> getPedidosStream(
    String empresaId,
  ) {
    return _db
        .collection('pedidos')
        .where('empresaId', isEqualTo: empresaId)
        .snapshots();
  }

  // 🔹 Stream de pedidos do usuário (tempo real)
  Stream<QuerySnapshot<Map<String, dynamic>>> getPedidosDoUsuarioStream(
    String userId,
  ) {
    return _db
        .collection('pedidos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
