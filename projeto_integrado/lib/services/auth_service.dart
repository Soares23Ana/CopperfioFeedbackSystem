import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/cnpj_input_formatter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    return await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password.trim(),
    );
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final credential = await signIn(email: email, password: password);
    final uid = credential.user?.uid;
    if (uid == null) {
      return null;
    }
    final tipo = await getUserType(uid);
    return tipo ?? 'cliente';
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<void> register({
    required String email,
    required String password,
    required String nome,
    required String empresa,
    required String cnpj,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedCnpj = CnpjInputFormatter.digitsOnly(cnpj.trim());

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password.trim(),
    );

    final tipo = 'cliente';
    final userId = userCredential.user?.uid;

    if (userId != null) {
      await userCredential.user?.updateDisplayName(nome.trim());
      await _db.collection('users').doc(userId).set({
        'email': normalizedEmail,
        'email_lower': normalizedEmail,
        'nome': nome.trim(),
        'empresa': empresa.trim(),
        'cnpj': normalizedCnpj,
        'tipo': tipo,
        'empresaId': 'copperfio',
        'copperPoints': 0,
        'level': 'Bronze',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.setLanguageCode('pt-br');
    await _auth.sendPasswordResetEmail(email: _normalizeEmail(email));
  }

  String? get currentUserId => _auth.currentUser?.uid;

  User? getCurrentUser() => _auth.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(
    String userId,
  ) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc : null;
  }

  Future<String?> getUserType(String userId) async {
    final doc = await getUserDocument(userId);
    return doc?.data()?['tipo'] as String?;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final doc = await getUserDocument(uid);
    return doc?.data();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateCurrentUserData(Map<String, dynamic> updates) async {
    final uid = currentUserId;
    if (uid == null) return;

    final normalizedUpdates = Map<String, dynamic>.from(updates);
    if (normalizedUpdates.containsKey('cnpj') &&
        normalizedUpdates['cnpj'] is String) {
      normalizedUpdates['cnpj'] =
          CnpjInputFormatter.digitsOnly(normalizedUpdates['cnpj'] as String);
    }

    await _db
        .collection('users')
        .doc(uid)
        .set(normalizedUpdates, SetOptions(merge: true));
  }

  Future<bool> existsUserByEmail(String email) async {
    try {
      final trimmedEmail = email.trim();
      final normalizedEmail = _normalizeEmail(trimmedEmail);

      print('[EXISTE_EMAIL] Procurando por: $trimmedEmail');
      print('[EXISTE_EMAIL] Email normalizado: $normalizedEmail');

      try {
        final lowercaseEmailSnapshot = await _db
            .collection('users')
            .where('email_lower', isEqualTo: normalizedEmail)
            .limit(1)
            .get();
        if (lowercaseEmailSnapshot.docs.isNotEmpty) {
          print('[EXISTE_EMAIL] ✓ Encontrado em email_lower');
          return true;
        }
      } catch (e) {
        print('Erro ao buscar email_lower: $e');
      }

      try {
        final lowercaseEmailSnapshot = await _db
            .collection('users')
            .where('email_lower', isEqualTo: normalizedEmail)
            .limit(1)
            .get();
        if (lowercaseEmailSnapshot.docs.isNotEmpty) {
          print('[EXISTE_EMAIL] ✓ Encontrado em email_lower');
          return true;
        }
      } catch (e) {
        print('Erro ao buscar email_lower: $e');
      }

      try {
        final exactEmailSnapshot = await _db
            .collection('users')
            .where('email', isEqualTo: trimmedEmail)
            .limit(1)
            .get();
        if (exactEmailSnapshot.docs.isNotEmpty) {
          print('[EXISTE_EMAIL] ✓ Encontrado em email (trimmed)');
          return true;
        }
      } catch (e) {
        print('Erro ao buscar email exato: $e');
      }

      try {
        final allUsersSnapshot = await _db.collection('users').get();
        print('[EXISTE_EMAIL] Total de usuários no Firestore: ${allUsersSnapshot.docs.length}');
        for (var doc in allUsersSnapshot.docs) {
          final userEmail = doc.data()['email']?.toString() ?? '';
          print('[EXISTE_EMAIL] Comparando: "$normalizedEmail" com "$userEmail"');
          if (userEmail.toLowerCase() == normalizedEmail) {
            print('[EXISTE_EMAIL] ✓ Encontrado em busca geral');
            return true;
          }
        }
      } catch (e) {
        print('Erro ao buscar todos os usuários: $e');
      }

      print('[EXISTE_EMAIL] ✗ Email NÃO encontrado: $normalizedEmail');
      return false;
    } catch (e) {
      print('Erro geral em existsUserByEmail: $e');
      return false;
    }
  }

  Future<String?> promoteUserToGestor(String email) async {
    final email_ = email.trim().toLowerCase();

    try {
      var querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email_)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await _db
            .collection('users')
            .where('email_lower', isEqualTo: email_)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty) {
        final allUsersSnapshot = await _db.collection('users').get();
        for (var doc in allUsersSnapshot.docs) {
          final userEmail = doc.data()['email']?.toString() ?? '';
          if (userEmail.toLowerCase() == email_) {
            querySnapshot = await _db
                .collection('users')
                .where('email', isEqualTo: userEmail)
                .limit(1)
                .get();
            break;
          }
        }
      }

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuário com este e-mail não encontrado.');
      }

      final userDoc = querySnapshot.docs.first;
      final uid = userDoc.id;
      final currentTipo = userDoc.data()['tipo'] as String?;

      if (currentTipo == 'empresa') {
        throw Exception('Este usuário já é gestor de vendas.');
      }

      await _db.collection('users').doc(uid).update({
        'tipo': 'empresa',
        'promotedAt': FieldValue.serverTimestamp(),
      });

      return uid;
    } catch (e) {
      throw Exception('Erro ao promover usuário para gestor: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      var querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }

      querySnapshot = await _db
          .collection('users')
          .where('email_lower', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }

      final allUsersSnapshot = await _db.collection('users').get();
      for (var doc in allUsersSnapshot.docs) {
        final userEmail = doc.data()['email']?.toString() ?? '';
        if (userEmail.toLowerCase() == normalizedEmail) {
          return doc.data();
        }
      }

      return null;
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFirstEmpresaUser() async {
    final querySnapshot = await _db
        .collection('users')
        .where('tipo', isEqualTo: 'empresa')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    return {...doc.data(), 'id': doc.id};
  }
}
