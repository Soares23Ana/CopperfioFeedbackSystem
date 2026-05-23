import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String mensagem;
  final String lote;
  final String userId;
  final String userEmpresa;
  final String userName;
  final String userEmail;
  final String userType;
  final String empresaId;
  final DateTime data;
  final String status;
  final bool isRead;
  final int item1;
  final int item2;
  final int item3;
  final int item4;
  final int item5;
  final int item6;
  final int item7;
  final int item8;
  final double notaMedia;
  final int generalRating;
  final String atendimentoMood;
  final List<String> tags;
  final Map<String, dynamic> questionResponses;
  final String photoUrl;

  FeedbackModel({
    required this.id,
    required this.mensagem,
    required this.lote,
    required this.userId,
    required this.userEmpresa,
    required this.userName,
    required this.userEmail,
    required this.userType,
    required this.empresaId,
    required this.data,
    required this.status,
    required this.isRead,
    required this.item1,
    required this.item2,
    required this.item3,
    required this.item4,
    required this.item5,
    required this.item6,
    required this.item7,
    required this.item8,
    required this.notaMedia,
    required this.generalRating,
    required this.atendimentoMood,
    required this.tags,
    required this.questionResponses,
    required this.photoUrl,
  });

  factory FeedbackModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FeedbackModel(
      id: doc.id,
      mensagem: data['mensagem'] ?? '',
      lote: data['lote'] ?? '',
      userId: data['userId'] ?? '',
      userEmpresa: data['userEmpresa'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userType: data['userType'] ?? '',
      empresaId: data['empresaId'] ?? '',
      data: (data['data'] as Timestamp).toDate(),
      status: data['status'] ?? 'novo',
      isRead: data['isRead'] ?? false,
      item1: data['item1'] ?? 0,
      item2: data['item2'] ?? 0,
      item3: data['item3'] ?? 0,
      item4: data['item4'] ?? 0,
      item5: data['item5'] ?? 0,
      item6: data['item6'] ?? 0,
      item7: data['item7'] ?? 0,
      item8: data['item8'] ?? 0,
      notaMedia: (data['notaMedia'] as num?)?.toDouble() ?? 0.0,
      generalRating: data['generalRating'] as int? ?? 0,
      atendimentoMood: data['atendimentoMood'] as String? ?? '',
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      questionResponses:
          (data['questionResponses'] as Map<String, dynamic>?) ?? {},
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }
}
