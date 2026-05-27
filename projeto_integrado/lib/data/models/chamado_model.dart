class ChamadoModel {
  final String id;
  final String usuarioId;
  final String usuarioNome;
  final String usuarioEmail;
  final String empresaId;
  final String empresaNome;
  final String titulo;
  final String descricao;
  final String status; // 'aberto', 'em_atendimento', 'resolvido', 'fechado'
  final String prioridade; // 'baixa', 'media', 'alta'
  final DateTime dataAbertura;
  final DateTime? dataFechamento;
  final List<String> mensagens; // IDs das mensagens de conversa
  final bool hasAnaliseIa;
  final bool hasEmailTemplate;

  ChamadoModel({
    required this.id,
    required this.usuarioId,
    required this.usuarioNome,
    required this.usuarioEmail,
    required this.empresaId,
    required this.empresaNome,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.prioridade,
    required this.dataAbertura,
    this.dataFechamento,
    this.mensagens = const [],
    this.hasAnaliseIa = false,
    this.hasEmailTemplate = false,
  });

  // Converter para JSON para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'usuarioNome': usuarioNome,
      'usuarioEmail': usuarioEmail,
      'empresaId': empresaId,
      'empresaNome': empresaNome,
      'titulo': titulo,
      'descricao': descricao,
      'status': status,
      'prioridade': prioridade,
      'dataAbertura': dataAbertura.millisecondsSinceEpoch,
      'dataFechamento': dataFechamento?.millisecondsSinceEpoch,
      'mensagens': mensagens,
    };
  }

  // Criar a partir de JSON do Firebase
  factory ChamadoModel.fromMap(Map<String, dynamic> map) {
    return ChamadoModel(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      usuarioNome: map['usuarioNome'] ?? '',
      usuarioEmail: map['usuarioEmail'] ?? '',
      empresaId: map['empresaId'] ?? '',
      empresaNome: map['empresaNome'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      status: map['status'] ?? 'aberto',
      prioridade: map['prioridade'] ?? 'media',
      dataAbertura: DateTime.fromMillisecondsSinceEpoch(
        map['dataAbertura'] as int? ?? 0,
      ),
      dataFechamento: map['dataFechamento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dataFechamento'] as int)
          : null,
      mensagens: List<String>.from(map['mensagens'] ?? []),
      hasAnaliseIa: map['analiseIA'] != null && map['analiseIA'] is Map<String, dynamic>,
      hasEmailTemplate: map['analiseIA'] != null && map['analiseIA'] is Map<String, dynamic> &&
          ((map['analiseIA'] as Map<String, dynamic>)['emailTemplate'] as String?)?.isNotEmpty == true,
    );
  }

  // Criar cópia com mudanças
  ChamadoModel copyWith({
    String? id,
    String? usuarioId,
    String? usuarioNome,
    String? usuarioEmail,
    String? empresaId,
    String? empresaNome,
    String? titulo,
    String? descricao,
    String? status,
    String? prioridade,
    DateTime? dataAbertura,
    DateTime? dataFechamento,
    List<String>? mensagens,
  }) {
    return ChamadoModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      usuarioEmail: usuarioEmail ?? this.usuarioEmail,
      empresaId: empresaId ?? this.empresaId,
      empresaNome: empresaNome ?? this.empresaNome,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      prioridade: prioridade ?? this.prioridade,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      mensagens: mensagens ?? this.mensagens,
    );
  }

  @override
  String toString() {
    return 'ChamadoModel(id: $id, usuario: $usuarioNome, empresa: $empresaNome, status: $status)';
  }
}
