class UsuarioModel {
  final String nome;
  final String email;
  final String? senha;
  final String? endereco;
  final String? dataNascimento;
  final String? genero;
  final String? empresa;
  final String? cnpj;
  final String role; // 'cliente' ou 'gestor'

  UsuarioModel({
    required this.nome,
    required this.email,
    this.senha,
    this.endereco,
    this.dataNascimento,
    this.genero,
    this.empresa,
    this.cnpj,
    this.role = 'cliente',
  });

  // Converte um MAPA (vindo do Firebase) para a sua Classe UsuarioModel
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      endereco: map['endereco'],
      dataNascimento: map['dataNascimento'],
      genero: map['genero'],
      empresa: map['empresa'],
      cnpj: map['cnpj'],
      role: map['role'] ?? 'cliente',
    );
  }

  // Converte a Classe para um MAPA (para salvar no Firebase)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'endereco': endereco,
      'dataNascimento': dataNascimento,
      'genero': genero,
      'empresa': empresa,
      'cnpj': cnpj,
      'role': role,
    };
  }
}
