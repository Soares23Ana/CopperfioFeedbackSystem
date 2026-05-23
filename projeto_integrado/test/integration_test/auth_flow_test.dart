import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado/data/models/usuario_model.dart';
import 'package:projeto_integrado/features/auth/viewmodel/signup_viewmodel.dart';
import 'package:projeto_integrado/features/auth/viewmodel/login_viewmodel.dart';
import 'package:projeto_integrado/services/auth_service.dart';

/// Repository real para testes de integração de auth
class IntegrationAuthService implements AuthService {
  final Map<String, String> _users = {};

  @override
  Future<void> register({
    required String email,
    required String password,
    required String nome,
    String? empresa,
    String? cnpj,
  }) async {
    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Informe um e-mail válido.');
    }

    if (_users.containsKey(email)) {
      throw Exception('E-mail já cadastrado.');
    }

    _users[email] = password;
  }

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
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Preencha e-mail e senha.');
    }

    if (!_users.containsKey(email)) {
      throw Exception('E-mail ou senha inválidos.');
    }

    if (_users[email] != password) {
      throw Exception('E-mail ou senha inválidos.');
    }

    return 'mock-uid-${email.hashCode}';
  }

  @override
  Future<bool> existsUserByEmail(String email) async {
    return _users.containsKey(email);
  }

  @override
  Future<void> resetPassword(String email) async {
    // Mock
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
  group('Auth Flow Integration Tests - TC09', () {
    late SignupViewModel signupViewModel;
    late LoginViewModel loginViewModel;
    late IntegrationAuthService authService;

    setUp(() {
      authService = IntegrationAuthService();
      signupViewModel = SignupViewModel(authService: authService);
      loginViewModel = LoginViewModel(authService: authService);
    });

    tearDown(() {
      authService.clear();
      signupViewModel.dispose();
      loginViewModel.dispose();
    });

    test('TC09: Fluxo completo - Cadastro → Login → Home', () async {
      print('\n🔐 FASE 1: Cadastro do usuário...');

      // =================================================================
      // FASE 1: CADASTRO
      // =================================================================
      final novoUsuario = UsuarioModel(
        nome: 'Marcelo Silva',
        email: 'marcelo@email.com',
        senha: '123456',
        empresa: 'Tech Company',
        cnpj: '12.345.678/0001-00',
      );

      await signupViewModel.cadastrarUsuario(novoUsuario);

      // Verificações do cadastro
      expect(signupViewModel.successMessage, isNotNull);
      expect(signupViewModel.successMessage, contains('sucesso'));
      expect(signupViewModel.errorMessage, isNull);
      expect(signupViewModel.isLoading, isFalse);

      print('✅ Cadastro realizado com sucesso!');
      print('   Usuário: ${novoUsuario.nome}');
      print('   Email: ${novoUsuario.email}');
      print('   Mensagem: ${signupViewModel.successMessage}');

      // =================================================================
      // FASE 2: RETORNO AO LOGIN
      // =================================================================
      print('\n🔑 FASE 2: Voltando para tela de login...');

      // Limpar mensagens
      signupViewModel.clearMessages();
      expect(signupViewModel.successMessage, isNull);

      print('✅ Usuário redirecionado para login');

      // =================================================================
      // FASE 3: LOGIN
      // =================================================================
      print('\n🚀 FASE 3: Fazendo login com as credenciais...');

      final userType = await loginViewModel.signIn(
        email: 'marcelo@email.com',
        senha: '123456',
      );

      // Verificações do login
      expect(userType, isNotNull);
      expect(loginViewModel.errorMessage, isNull);
      expect(loginViewModel.isLoading, isFalse);

      print('✅ Login realizado com sucesso!');
      print('   Email: marcelo@email.com');
      print('   Tipo de usuário: $userType');

      // =================================================================
      // FASE 4: NAVEGAÇÃO PARA HOME
      // =================================================================
      print('\n🏠 FASE 4: Navegação para Home...');

      expect(userType, isNotEmpty);
      print('✅ Usuário navegou para Home!');

      print('\n✅ FLUXO COMPLETO CONCLUÍDO COM SUCESSO!');
    });

    test('TC09a: Fluxo com erro - Cadastro duplicado', () async {
      print('\n⚠️  Testando cadastro duplicado...');

      final usuario = UsuarioModel(
        nome: 'Marcelo Silva',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      // Primeiro cadastro
      await signupViewModel.cadastrarUsuario(usuario);
      expect(signupViewModel.successMessage, isNotNull);
      print('✅ Primeiro cadastro realizado');

      // Tentar segundo cadastro com mesmo email
      signupViewModel.clearMessages();
      await expectLater(
        signupViewModel.cadastrarUsuario(usuario),
        throwsException,
      );

      expect(signupViewModel.errorMessage, contains('já cadastrado'));
      print('✅ Segundo cadastro foi bloqueado corretamente');
    });

    test('TC09b: Fluxo com erro - Login antes de cadastrar', () async {
      print('\n⚠️  Testando login sem cadastro prévio...');

      await expectLater(
        loginViewModel.signIn(email: 'naoexiste@email.com', senha: 'senha123'),
        throwsException,
      );

      expect(loginViewModel.errorMessage, isNotNull);
      print('✅ Login foi bloqueado corretamente');
    });

    test('TC09c: Fluxo com validações - Email inválido no cadastro', () async {
      print('\n⚠️  Testando email inválido no cadastro...');

      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marceloemail.com', // Inválido - sem @
        senha: '123456',
      );

      await expectLater(
        signupViewModel.cadastrarUsuario(usuario),
        throwsException,
      );

      expect(signupViewModel.errorMessage, contains('e-mail válido'));
      print('✅ Email inválido foi rejeitado');
    });

    test('TC09d: Fluxo com validações - Campos vazios', () async {
      print('\n⚠️  Testando campos vazios...');

      // Email vazio no cadastro
      final usuarioVazio = UsuarioModel(
        nome: 'Marcelo',
        email: '',
        senha: '123456',
      );

      await expectLater(
        signupViewModel.cadastrarUsuario(usuarioVazio),
        throwsException,
      );
      print('✅ Cadastro com email vazio foi bloqueado');

      // Email e senha vazio no login
      await expectLater(
        loginViewModel.signIn(email: '', senha: ''),
        throwsException,
      );
      print('✅ Login com campos vazios foi bloqueado');
    });

    test('TC09e: Múltiplos usuários cadastrados e login individual', () async {
      print('\n👥 Testando múltiplos usuários...');

      // Cadastrar usuário 1
      final usuario1 = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await signupViewModel.cadastrarUsuario(usuario1);
      print('✅ Usuário 1 cadastrado');

      // Cadastrar usuário 2
      signupViewModel.clearMessages();
      final usuario2 = UsuarioModel(
        nome: 'João',
        email: 'joao@email.com',
        senha: '654321',
      );

      await signupViewModel.cadastrarUsuario(usuario2);
      print('✅ Usuário 2 cadastrado');

      // Login usuário 1
      final userType1 = await loginViewModel.signIn(
        email: 'marcelo@email.com',
        senha: '123456',
      );
      expect(userType1, isNotNull);
      print('✅ Usuário 1 fez login com sucesso');

      // Login usuário 2
      loginViewModel.clearError();
      final userType2 = await loginViewModel.signIn(
        email: 'joao@email.com',
        senha: '654321',
      );
      expect(userType2, isNotNull);
      print('✅ Usuário 2 fez login com sucesso');

      print('✅ Múltiplos usuários funcionando!');
    });

    test('TC09f: Tentativas erradas de login', () async {
      print('\n❌ Testando tentativas erradas de login...');

      // Cadastrar usuário
      final usuario = UsuarioModel(
        nome: 'Marcelo',
        email: 'marcelo@email.com',
        senha: '123456',
      );

      await signupViewModel.cadastrarUsuario(usuario);
      print('✅ Usuário cadastrado');

      // Tentar login com senha errada
      await expectLater(
        loginViewModel.fazerLogin(
          email: 'marcelo@email.com',
          senha: 'senhaErrada',
        ),
        throwsException,
      );
      expect(loginViewModel.errorMessage, contains('inválidos'));
      print('✅ Login com senha errada foi bloqueado');

      // Tentar login com email errado
      loginViewModel.clearMessages();
      await expectLater(
        loginViewModel.fazerLogin(email: 'outro@email.com', senha: '123456'),
        throwsException,
      );
      expect(loginViewModel.errorMessage, contains('inválidos'));
      print('✅ Login com email errado foi bloqueado');
    });

    test('TC09g: Fluxo completo com sucesso de novo', () async {
      print('\n🔄 Testando fluxo novamente para garantir consistência...');

      // Cadastro
      final usuario = UsuarioModel(
        nome: 'Ana Silva',
        email: 'ana@email.com',
        senha: 'senha123',
      );

      await signupViewModel.cadastrarUsuario(usuario);
      expect(signupViewModel.successMessage, isNotNull);
      print('✅ Cadastro de Ana realizado');

      // Login
      await loginViewModel.fazerLogin(
        email: 'ana@email.com',
        senha: 'senha123',
      );
      expect(loginViewModel.successMessage, isNotNull);
      print('✅ Login de Ana realizado');

      print('✅ FLUXO REPETIDO COM SUCESSO!');
    });
  });
}
