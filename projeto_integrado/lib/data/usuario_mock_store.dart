import 'models/usuario_model.dart';

class UsuarioMockStore {
  static final UsuarioMockStore _instance = UsuarioMockStore._internal();
  factory UsuarioMockStore() => _instance;

  final List<UsuarioModel> usuarios = [];

  UsuarioMockStore._internal();

  void adicionar(UsuarioModel user) => usuarios.add(user);

  bool existe(String email, String senha) {
    return usuarios.any((u) => u.email == email && u.senha == senha);
  }

  UsuarioModel? autenticar(String email, String senha) {
    for (final usuario in usuarios) {
      if (usuario.email == email && usuario.senha == senha) {
        return usuario;
      }
    }
    return null;
  }

  bool existeEmail(String email) {
    return usuarios.any((u) => u.email == email);
  }

  void atualizarSenha(String email, String novaSenha) {
    for (var i = 0; i < usuarios.length; i++) {
      if (usuarios[i].email == email) {
        usuarios[i] = UsuarioModel(
          nome: usuarios[i].nome,
          email: usuarios[i].email,
          senha: novaSenha,
          endereco: usuarios[i].endereco,
          dataNascimento: usuarios[i].dataNascimento,
          genero: usuarios[i].genero,
          empresa: usuarios[i].empresa,
          cnpj: usuarios[i].cnpj,
          role: usuarios[i].role,
        );
        break;
      }
    }
  }
}
