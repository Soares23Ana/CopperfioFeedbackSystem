import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/firestore_service.dart';
import 'package:projeto_integrado/data/repositories/chamados_repository.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';

class NotificacaoItem {
  final String id;
  final String titulo;
  final String subtitulo;
  final String tipo; // 'feedback', 'chamado', 'pedido'
  final DateTime timestamp;
  final IconType icon;
  final String status; // 'Feedback', 'Chamado', 'Pedido'
  final bool isRead;
  final Map<String, dynamic> data; // dados completos

  NotificacaoItem({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.tipo,
    required this.timestamp,
    required this.icon,
    required this.status,
    required this.isRead,
    required this.data,
  });

  factory NotificacaoItem.fromFeedback(
    Map<String, dynamic> data,
    String docId,
  ) {
    final timestamp = (data['data'] as Timestamp?)?.toDate() ?? DateTime.now();
    final isRead = data['isRead'] as bool? ?? false;
    final clienteNome = data['clienteNome'] as String? ?? 'Cliente';

    return NotificacaoItem(
      id: docId,
      titulo: 'Novo feedback de $clienteNome',
      subtitulo:
          'O cliente enviou um novo feedback. Verifique a mensagem e responda se necessário.',
      tipo: 'feedback',
      timestamp: timestamp,
      icon: IconType.feedback,
      status: 'Feedback',
      isRead: isRead,
      data: data,
    );
  }

  factory NotificacaoItem.fromChamado(ChamadoModel chamado) {
    final clienteNome = chamado.usuarioNome.isNotEmpty
        ? chamado.usuarioNome
        : 'Cliente';
    final isRead = chamado.status != 'aberto';
    final title = _buildChamadoTitle(chamado.status, clienteNome);
    final subtitle = _buildChamadoSubtitle(chamado.status);

    return NotificacaoItem(
      id: chamado.id,
      titulo: title,
      subtitulo: subtitle,
      tipo: 'chamado',
      timestamp: chamado.dataAbertura,
      icon: IconType.chamado,
      status: 'Chamado',
      isRead: isRead,
      data: chamado.toMap(),
    );
  }

  factory NotificacaoItem.fromPedido(Map<String, dynamic> data, String docId) {
    final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ??
        (data['data'] as Timestamp?)?.toDate() ??
        DateTime.now();
    final clienteNome = data['nome'] as String? ?? 'Cliente';
    final statusValue = data['status']?.toString() ?? 'Novo';
    final title = _buildPedidoTitle(statusValue, clienteNome);
    final subtitle = _buildPedidoSubtitle(statusValue);

    return NotificacaoItem(
      id: docId,
      titulo: title,
      subtitulo: subtitle,
      tipo: 'pedido',
      timestamp: timestamp,
      icon: IconType.pedido,
      status: 'Pedido',
      isRead: statusValue.toLowerCase() != 'novo',
      data: data,
    );
  }

  static String _buildChamadoTitle(String status, String clienteNome) {
    switch (status.toLowerCase()) {
      case 'em_atendimento':
      case 'em andamento':
      case 'em_andamento':
        return 'Chamado de $clienteNome em atendimento';
      case 'resolvido':
        return 'Chamado de $clienteNome resolvido';
      case 'fechado':
        return 'Chamado de $clienteNome fechado';
      default:
        return 'Novo chamado de $clienteNome';
    }
  }

  static String _buildChamadoSubtitle(String status) {
    switch (status.toLowerCase()) {
      case 'em_atendimento':
      case 'em andamento':
      case 'em_andamento':
        return 'Seu chamado está em andamento com o gestor. Aguarde a atualização.';
      case 'resolvido':
        return 'Seu chamado foi resolvido. Verifique os detalhes e confirme se está tudo certo.';
      case 'fechado':
        return 'O chamado foi fechado. Se precisar de mais ajuda, abra um novo chamado.';
      default:
        return 'O cliente abriu um novo chamado ou atualizou um chamado existente.';
    }
  }

  static String _buildPedidoTitle(String status, String clienteNome) {
    final normalized = status.toLowerCase();
    if (normalized.contains('andamento') || normalized.contains('em_atendimento')) {
      return 'Pedido de $clienteNome em andamento';
    }
    if (normalized.contains('conclu') || normalized.contains('finalizado')) {
      return 'Pedido de $clienteNome concluído';
    }
    if (normalized.contains('cancel')) {
      return 'Pedido de $clienteNome cancelado';
    }
    return 'Novo pedido de $clienteNome';
  }

  static String _buildPedidoSubtitle(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('andamento') || normalized.contains('em_atendimento')) {
      return 'O gestor está trabalhando no seu pedido. Aguarde a conclusão.';
    }
    if (normalized.contains('conclu') || normalized.contains('finalizado')) {
      return 'Seu pedido foi concluído. Confira os detalhes no histórico.';
    }
    if (normalized.contains('cancel')) {
      return 'Seu pedido foi cancelado. Entre em contato para mais informações.';
    }
    return 'O cliente fez um pedido. Confira o pedido e prepare o atendimento.';
  }

  factory NotificacaoItem.fromCatalogUpdate(
    Map<String, dynamic> data,
    String docId,
  ) {
    final timestamp =
        (data['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.now().subtract(const Duration(hours: 1));
    return NotificacaoItem(
      id: docId,
      titulo: data['titulo'] as String? ?? 'Atualização no catálogo',
      subtitulo:
          data['mensagem'] as String? ??
          'O catálogo recebeu atualizações importantes. Veja as novidades.',
      tipo: 'catalogo',
      timestamp: timestamp,
      icon: IconType.catalogo,
      status: 'Catálogo',
      isRead: data['isRead'] as bool? ?? false,
      data: data,
    );
  }

  factory NotificacaoItem.fromAppError(String message, DateTime timestamp) {
    return NotificacaoItem(
      id: 'app_error_${timestamp.millisecondsSinceEpoch}',
      titulo: 'Erro no aplicativo',
      subtitulo: message,
      tipo: 'app_error',
      timestamp: timestamp,
      icon: IconType.appError,
      status: 'Erro',
      isRead: false,
      data: {'message': message},
    );
  }
}

enum IconType { feedback, chamado, pedido, catalogo, appError }

class NotificacoesViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ChamadosRepository _chamadosRepository = ChamadosRepository();
  final AuthService _authService = AuthService();

  List<NotificacaoItem> _notificacoes = [];
  bool _isLoading = false;
  String? _error;
  Stream<List<NotificacaoItem>>? _notificationsStream;

  List<NotificacaoItem> get notificacoes => _notificacoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream unificada de notificações para usuário e gestor
  Stream<List<NotificacaoItem>> obterNotificacoes() {
    return _notificationsStream ??= _createNotificationsStream();
  }

  Stream<List<NotificacaoItem>> _createNotificationsStream() {
    return Stream.fromFuture(_authService.getCurrentUserData())
        .asyncExpand((userData) {
      final userType = userData?['tipo'] as String? ?? 'cliente';
      final forUsuario = userType != 'gestor';
      return _obterNotificacoes(forUsuario: forUsuario);
    }).handleError((error, stackTrace) {
      _error = 'Erro ao carregar notificações: $error';
      _isLoading = false;
      notifyListeners();
    });
  }

  Stream<List<NotificacaoItem>> _obterNotificacoes({
    bool forUsuario = false,
  }) async* {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userData = await _authService.getCurrentUserData();
      final empresaId = userData?['empresaId'] as String? ?? 'copperfio';

      if (forUsuario) {
        final uid = _authService.currentUserId;
        if (uid == null) {
          _isLoading = false;
          notifyListeners();
          yield [];
          return;
        }

        final initialItems = await _fetchCatalogAndAppErrors(empresaId);

        final pedidosStream = _firestoreService.getPedidosDoUsuarioStream(uid).map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return NotificacaoItem.fromPedido(data, doc.id);
          }).toList(),
        );

        final chamadosStream = _chamadosRepository.buscarChamadosDoUsuario(uid).map(
          (chamados) => chamados
              .map((chamado) => NotificacaoItem.fromChamado(chamado))
              .toList(),
        );

        yield* _mergeUsuarioNotifications(
          pedidosStream,
          chamadosStream,
          initialItems,
        );
        return;
      }

      // Obter dados do usuário (gestor)
      final pedidosSnapshot = await _firestoreService
          .buscarPedidosPorEmpresa(empresaId, limite: 50);
      final pedidos = <NotificacaoItem>[];

      for (final doc in pedidosSnapshot) {
        final data = doc.data() as Map<String, dynamic>;
        pedidos.add(NotificacaoItem.fromPedido(data, doc.id));
      }

      final feedbackStream = _firestoreService.getFeedbacks(empresaId).map(
        (snapshot) => snapshot.docs
            .map((doc) => NotificacaoItem.fromFeedback(doc.data(), doc.id))
            .toList(),
      );

      final chamadosStream = _chamadosRepository.buscarChamadosDaEmpresa(
        empresaId,
      ).map(
        (chamados) => chamados
            .map((chamado) => NotificacaoItem.fromChamado(chamado))
            .toList(),
      );

      yield* _mergeGestorNotifications(
        feedbackStream,
        chamadosStream,
        pedidos,
      );
    } catch (e) {
      _error = 'Erro ao carregar notificações: $e';
      _isLoading = false;
      notifyListeners();
      yield [];
    }
  }

  Future<List<NotificacaoItem>> _fetchCatalogAndAppErrors(
    String empresaId,
  ) async {
    final notificacoes = <NotificacaoItem>[];

    try {
      final catalogSnapshot = await _firestoreService.fetchCatalogUpdates(
        empresaId,
      );
      for (final doc in catalogSnapshot.docs) {
        final data = doc.data();
        notificacoes.add(NotificacaoItem.fromCatalogUpdate(data, doc.id));
      }
    } catch (e) {
      print('Erro ao buscar atualizações do catálogo: $e');
    }

    try {
      final appErrorsSnapshot = await _firestoreService.fetchAppErrors(
        empresaId,
      );
      for (final doc in appErrorsSnapshot.docs) {
        final data = doc.data();
        final message =
            data['mensagem'] as String? ??
            'O aplicativo encontrou um erro. Por favor, tente novamente.';
        final timestamp =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        notificacoes.add(NotificacaoItem.fromAppError(message, timestamp));
      }
    } catch (e) {
      print('Erro ao buscar erros de aplicativo: $e');
    }

    return notificacoes;
  }

  Stream<List<NotificacaoItem>> _mergeUsuarioNotifications(
    Stream<List<NotificacaoItem>> pedidosStream,
    Stream<List<NotificacaoItem>> chamadosStream,
    List<NotificacaoItem> initialItems,
  ) {
    final controller = StreamController<List<NotificacaoItem>>();
    var pedidosItems = <NotificacaoItem>[];
    var chamadosItems = <NotificacaoItem>[];

    void publishNotifications() {
      final notificacoes = <NotificacaoItem>[
        ...initialItems,
        ...pedidosItems,
        ...chamadosItems,
      ];
      notificacoes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _notificacoes = notificacoes;
      _isLoading = false;
      _error = null;
      notifyListeners();
      if (!controller.isClosed) {
        controller.add(notificacoes);
      }
    }

    late final StreamSubscription<List<NotificacaoItem>> pedidosSubscription;
    late final StreamSubscription<List<NotificacaoItem>> chamadosSubscription;

    pedidosSubscription = pedidosStream.listen(
      (items) {
        pedidosItems = items;
        publishNotifications();
      },
      onError: (error, stackTrace) {
        _error = 'Erro ao carregar notificações: $error';
        _isLoading = false;
        notifyListeners();
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      },
    );

    chamadosSubscription = chamadosStream.listen(
      (items) {
        chamadosItems = items;
        publishNotifications();
      },
      onError: (error, stackTrace) {
        _error = 'Erro ao carregar notificações: $error';
        _isLoading = false;
        notifyListeners();
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      },
    );

    controller.onCancel = () async {
      await pedidosSubscription.cancel();
      await chamadosSubscription.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Stream<List<NotificacaoItem>> _mergeGestorNotifications(
    Stream<List<NotificacaoItem>> feedbackStream,
    Stream<List<NotificacaoItem>> chamadosStream,
    List<NotificacaoItem> pedidos,
  ) {
    final controller = StreamController<List<NotificacaoItem>>();
    var feedbackItems = <NotificacaoItem>[];
    var chamadosItems = <NotificacaoItem>[];

    void publishNotifications() {
      final notificacoes = <NotificacaoItem>[...feedbackItems, ...chamadosItems, ...pedidos];
      notificacoes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _notificacoes = notificacoes;
      _isLoading = false;
      _error = null;
      notifyListeners();
      if (!controller.isClosed) {
        controller.add(notificacoes);
      }
    }

    late final StreamSubscription<List<NotificacaoItem>> feedbackSubscription;
    late final StreamSubscription<List<NotificacaoItem>> chamadosSubscription;

    feedbackSubscription = feedbackStream.listen(
      (items) {
        feedbackItems = items;
        publishNotifications();
      },
      onError: (error, stackTrace) {
        _error = 'Erro ao carregar notificações: $error';
        _isLoading = false;
        notifyListeners();
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      },
    );

    chamadosSubscription = chamadosStream.listen(
      (items) {
        chamadosItems = items;
        publishNotifications();
      },
      onError: (error, stackTrace) {
        _error = 'Erro ao carregar notificações: $error';
        _isLoading = false;
        notifyListeners();
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      },
    );

    controller.onCancel = () async {
      await feedbackSubscription.cancel();
      await chamadosSubscription.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  // Marcar notificação como lida
  Future<void> marcarComoLida(String notificacaoId, String tipo) async {
    try {
      if (tipo == 'feedback') {
        await _firestoreService.marcarFeedbackComoLido(notificacaoId);
      }
      // Para chamados e pedidos, a lógica de leitura pode ser diferente
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao marcar como lida: $e';
      notifyListeners();
    }
  }

  // Contar notificações não lidas
  int get totalNaoLidas => _notificacoes.where((n) => !n.isRead).length;

  int get totalFeedbacks =>
      _notificacoes.where((n) => n.tipo == 'feedback').length;

  int get totalChamados =>
      _notificacoes.where((n) => n.tipo == 'chamado').length;

  int get totalPedidos => _notificacoes.where((n) => n.tipo == 'pedido').length;
}
