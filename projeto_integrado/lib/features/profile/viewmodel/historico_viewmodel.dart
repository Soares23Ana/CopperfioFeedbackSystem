import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../services/firestore_service.dart';

class HistoricoViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<QuerySnapshot> getRelatorios(String companyId) {
    return _firestoreService.getRelatoriosEmpresa(companyId);
  }

  Future<void> deleteRelatorio(String relatorioId) async {
    await _firestoreService.deleteRelatorio(relatorioId);
  }
}
