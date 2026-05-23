import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/features/auth/viewmodel/login_viewmodel.dart';
import 'package:projeto_integrado/services/auth_service.dart';

/// Mock da AuthService para testes de login
class MockLoginAuthService implements AuthService {
  final Map<String, String> _users = {'marcelo@email.com': '123456'};

  bool shouldThrowError = false;
  bool shouldThrowInvalidCredentials = false;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrowError) {
      throw Exception('Erro ao conectar');
    }

    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Preencha e-mail e senha.');
    }

    if (!_users.containsKey(email)) {
      throw Exception('E-mail ou senha inválidos.');
    }

    if (_users[email] != password) {
      throw Exception('E-mail ou senha inválidos.');
    }

    if (shouldThrowInvalidCredentials) {
      throw Exception('E-mail ou senha inválidos.');
    }

    return 'mock-uid-${email.hashCode}';
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String nome,
    String? empresa,
    String? cnpj,
  }) async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<bool> existsUserByEmail(String email) async {
    return _users.containsKey(email);
  }

  @override
  Future<String?> getUserType(String userId) async {
    return 'cliente';
  }

  @override
  String? get currentUserId => null;

  @override
  User? getCurrentUser() => null;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(
    String userId,
  ) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUserData() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateCurrentUserData(Map<String, dynamic> updates) async {}

  @override
  Future<String?> promoteUserToGestor(String email) async => null;

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async => null;

  @override
  Future<Map<String, dynamic>?> getFirstEmpresaUser() async => null;

  void clear() => _users.clear();
}

void main() {
  group('LoginViewModel Tests - Login (TC06-TC08)', () {
    late LoginViewModel viewModel;
    late MockLoginAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockLoginAuthService();
      viewModel = LoginViewModel(authService: mockAuthService);
    });

    tearDown(() {
      mockAuthService.clear();
      viewModel.dispose();
    });

    // TC06 - Validar login válido
    test('TC06: Login com dados válidos', () async {
      await viewModel.fazerLogin(email: 'marcelo@email.com', senha: '123456');

      expect(viewModel.successMessage, contains('sucesso'));
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    // TC07 - Validar login com campos vazios
    test('TC07a: Login com email vazio', () async {
      await expectLater(
        viewModel.fazerLogin(email: '', senha: '123456'),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('Preencha e-mail e senha'));
    });

    test('TC07b: Login com senha vazia', () async {
      await expectLater(
        viewModel.fazerLogin(email: 'marcelo@email.com', senha: ''),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('Preencha e-mail e senha'));
    });

    test('TC07c: Login com ambos vazios', () async {
      await expectLater(
        viewModel.fazerLogin(email: '', senha: ''),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('Preencha e-mail e senha'));
    });

    // TC08 - Validar login inválido
    test('TC08a: Login com email incorreto', () async {
      mockAuthService.shouldThrowInvalidCredentials = true;

      await expectLater(
        viewModel.fazerLogin(email: 'wrong@email.com', senha: '123456'),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('E-mail ou senha inválidos'));
    });

    test('TC08b: Login com senha incorreta', () async {
      mockAuthService.shouldThrowInvalidCredentials = true;

      await expectLater(
        viewModel.fazerLogin(email: 'marcelo@email.com', senha: 'senhaErrada'),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('E-mail ou senha inválidos'));
    });

    test('TC08c: Login com ambos incorretos', () async {
      mockAuthService.shouldThrowInvalidCredentials = true;

      await expectLater(
        viewModel.fazerLogin(email: 'wrong@email.com', senha: 'senhaErrada'),
        throwsException,
      );

      expect(viewModel.errorMessage, contains('E-mail ou senha inválidos'));
    });

    // Testes adicionais
    test('Estado isLoading durante login', () async {
      expect(viewModel.isLoading, isFalse);

      final future = viewModel.fazerLogin(
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await future;

      expect(viewModel.isLoading, isFalse);
    });

    test('clearMessages limpa as mensagens', () async {
      await viewModel.fazerLogin(email: 'marcelo@email.com', senha: '123456');

      expect(viewModel.successMessage, isNotNull);

      viewModel.clearMessages();

      expect(viewModel.successMessage, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    test('Múltiplas tentativas de login', () async {
      // Primeira tentativa - sucesso
      await viewModel.fazerLogin(email: 'marcelo@email.com', senha: '123456');
      expect(viewModel.successMessage, isNotNull);

      // Limpar mensagens
      viewModel.clearMessages();

      // Segunda tentativa - erro
      mockAuthService.shouldThrowInvalidCredentials = true;
      await expectLater(
        viewModel.fazerLogin(
          email: 'marcelo@email.com',
          senha: 'wrongPassword',
        ),
        throwsException,
      );

      expect(viewModel.errorMessage, isNotNull);
    });

    test('Mensagem de sucesso contém informações', () async {
      await viewModel.fazerLogin(email: 'marcelo@email.com', senha: '123456');

      expect(viewModel.successMessage, isNotNull);
      expect(viewModel.successMessage, contains('Login'));
    });

    test('Mensagem de erro é específica', () async {
      mockAuthService.shouldThrowInvalidCredentials = true;

      await expectLater(
        viewModel.fazerLogin(email: 'marcelo@email.com', senha: 'errada'),
        throwsException,
      );

      final errorMsg = viewModel.errorMessage;
      expect(errorMsg, isNotNull);
      expect(errorMsg, contains('inválidos'));
    });
  });
}
