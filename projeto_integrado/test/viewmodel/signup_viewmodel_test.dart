import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/data/models/usuario_model.dart';
import 'package:projeto_integrado/features/auth/viewmodel/signup_viewmodel.dart';
import 'package:projeto_integrado/services/auth_service.dart';

/// Mock da AuthService para testes
class MockAuthService implements AuthService {
  final Map<String, String> _registeredEmails = {};
  bool shouldThrowDuplicate = false;
  bool shouldThrowInvalidEmail = false;

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
    if (!_registeredEmails.containsKey(email) ||
        _registeredEmails[email] != password) {
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
  }) async {
    if (shouldThrowInvalidEmail) {
      throw Exception('Informe um e-mail válido.');
    }

    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Informe um e-mail válido.');
    }

    if (_registeredEmails.containsKey(email)) {
      throw Exception('E-mail já cadastrado.');
    }

    if (shouldThrowDuplicate) {
      throw Exception('E-mail já cadastrado.');
    }

    _registeredEmails[email] = password;
  }

  @override
  Future<bool> existsUserByEmail(String email) async {
    return _registeredEmails.containsKey(email);
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<String?> getUserType(String userId) async => 'cliente';

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

  void clear() => _registeredEmails.clear();
}

void main() {
  group('SignUpViewModel Tests - Cadastro (TC01-TC05)', () {
    late SignupViewModel viewModel;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      viewModel = SignupViewModel(authService: mockAuthService);
    });

    tearDown(() {
      mockAuthService.clear();
      viewModel.dispose();
    });

    // TC01 - Validar cadastro válido
    test('TC01: Cadastro com dados válidos', () async {
      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
        empresa: 'Tech Company',
        cnpj: '12.345.678/0001-00',
      );

      await viewModel.cadastrarUsuario(usuario);

      expect(viewModel.successMessage, contains('sucesso'));
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    // TC02 - Validar cadastro com campos vazios
    test('TC02a: Cadastro com nome vazio', () async {
      final usuario = UsuarioModel(
        nome: '',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await expectLater(viewModel.cadastrarUsuario(usuario), throwsException);

      expect(viewModel.errorMessage, isNotNull);
    });

    test('TC02b: Cadastro com email vazio', () async {
      final usuario = UsuarioModel(nome: 'Marcelo', email: '', senha: '123456');

      await expectLater(viewModel.cadastrarUsuario(usuario), throwsException);

      expect(viewModel.errorMessage, isNotNull);
    });

    test('TC02c: Cadastro com senha vazia', () async {
      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '',
      );

      await expectLater(viewModel.cadastrarUsuario(usuario), throwsException);

      expect(viewModel.errorMessage, isNotNull);
    });

    // TC03 - Validar e-mail inválido
    test('TC03a: E-mail sem @', () async {
      mockAuthService.shouldThrowInvalidEmail = true;

      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marceloemail.com',
        senha: '123456',
      );

      await expectLater(viewModel.cadastrarUsuario(usuario), throwsException);

      expect(viewModel.errorMessage, contains('e-mail válido'));
    });

    test('TC03b: E-mail sem ponto', () async {
      mockAuthService.shouldThrowInvalidEmail = true;

      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email',
        senha: '123456',
      );

      await expectLater(viewModel.cadastrarUsuario(usuario), throwsException);

      expect(viewModel.errorMessage, contains('e-mail válido'));
    });

    // TC04 - Validar cadastro duplicado
    test('TC04: Cadastro duplicado', () async {
      mockAuthService.shouldThrowDuplicate = true;

      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await expectLater(viewModel.cadastrarUsuario(usuario), throwsException);

      expect(viewModel.errorMessage, contains('já cadastrado'));
    });

    // TC05 - Validar retorno ao login
    test('TC05: Após cadastro, mensagem de sucesso é exibida', () async {
      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await viewModel.cadastrarUsuario(usuario);

      expect(viewModel.successMessage, isNotNull);
      expect(
        viewModel.successMessage,
        contains('Cadastro concluído com sucesso'),
      );
    });

    // Testes adicionais
    test('Estado isLoading durante cadastro', () async {
      expect(viewModel.isLoading, isFalse);

      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      final future = viewModel.cadastrarUsuario(usuario);
      await future;

      expect(viewModel.isLoading, isFalse);
    });

    test('clearMessages limpa as mensagens', () async {
      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await viewModel.cadastrarUsuario(usuario);
      expect(viewModel.successMessage, isNotNull);

      viewModel.clearMessages();
      expect(viewModel.successMessage, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    test('Verificar se email já existe', () async {
      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      // Primeiro cadastro
      await viewModel.cadastrarUsuario(usuario);

      // Verificar se existe
      final existe = await viewModel.existeEmail('marcelo@email.com');
      expect(existe, isTrue);

      // Verificar se não existe
      final naoExiste = await viewModel.existeEmail('outro@email.com');
      expect(naoExiste, isFalse);
    });
  });
}
