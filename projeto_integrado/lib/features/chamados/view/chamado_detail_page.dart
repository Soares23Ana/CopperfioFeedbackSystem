import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';
import 'package:projeto_integrado/data/repositories/chamados_repository.dart';
import 'package:projeto_integrado/services/auth_service.dart';
import 'package:projeto_integrado/services/gemini_service.dart';

class ChamadoDetailPage extends StatefulWidget {
  final ChamadoModel chamado;

  const ChamadoDetailPage({super.key, required this.chamado});

  @override
  State<ChamadoDetailPage> createState() => _ChamadoDetailPageState();
}

class _ChamadoDetailPageState extends State<ChamadoDetailPage> {
  final AuthService _authService = AuthService();
  final ChamadosRepository _repository = ChamadosRepository();
  String? _usuarioEmail;
  String? _savedEmailTemplate;
  Future<String>? _emailTemplateFuture;
  final ScrollController _scrollController = ScrollController();
  late final Future<Map<String, dynamic>> _planoDeAcaoFuture;

  @override
  void initState() {
    super.initState();
    _planoDeAcaoFuture = _carregarOuGerarPlanoDeAcao();
    _loadUsuarioEmailIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsuarioEmailIfNeeded() async {
    if (widget.chamado.usuarioEmail.isNotEmpty) {
      _usuarioEmail = widget.chamado.usuarioEmail;
      return;
    }

    try {
      final doc = await _authService.getUserDocument(widget.chamado.usuarioId);
      final email = doc?.data()?['email'] as String?;
      if (mounted) {
        setState(() {
          _usuarioEmail = email;
        });
      }
    } catch (_) {
      // Se falhar, mantemos o e-mail como não informado.
    }
  }

  Future<Map<String, dynamic>> _carregarOuGerarPlanoDeAcao() async {
    try {
      final chamadoData = await _repository.buscarChamadoDados(
        widget.chamado.id,
      );
      if (chamadoData != null) {
        final existingAnalise = chamadoData['analiseIA'];
        if (existingAnalise is Map<String, dynamic>) {
          _savedEmailTemplate = existingAnalise['emailTemplate'] as String?;
          return Map<String, dynamic>.from(existingAnalise);
        }
      }

      final gemini = GeminiService();
      final plano = await gemini.analisarPlanoDeAcao([
        {
          'titulo': widget.chamado.titulo,
          'descricao': widget.chamado.descricao,
          'mensagem': widget.chamado.descricao,
          'notaMedia': 0,
        },
      ]);

      await _repository.salvarAnaliseChamado(widget.chamado.id, plano);
      return plano;
    } catch (e) {
      return {
        'status': 'indisponível',
        'problemaPrincipal': '',
        'impactoNegocio': '',
        'acoesPrioritarias': [],
        'acoesMedioTermo': [],
        'metricasMonitoramento': [],
        'estimativaImpacto': '',
        'errorMessage':
            'Não foi possível gerar sugestão de plano de ação no momento. Tente novamente mais tarde.',
      };
    }
  }

  String _formatDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aberto':
        return Colors.blue;
      case 'em_atendimento':
        return Colors.orange;
      case 'resolvido':
        return Colors.green;
      case 'fechado':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.chamado.status);
    final primaryColor = const Color(0xFF8C1D18);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Chamado')),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CARD 1: INFORMAÇÕES DO CHAMADO
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.chamado.titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.chamado.status
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.chamado.prioridade.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.business,
                        'Empresa',
                        widget.chamado.empresaNome,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.person_outline,
                        'Solicitante',
                        widget.chamado.usuarioNome,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.email,
                        'E-mail do solicitante',
                        (_usuarioEmail ?? widget.chamado.usuarioEmail)
                                .isNotEmpty
                            ? (_usuarioEmail ?? widget.chamado.usuarioEmail)
                            : 'Não informado',
                        highlight:
                            (_usuarioEmail ?? widget.chamado.usuarioEmail)
                                .isNotEmpty,
                        highlightColor: primaryColor,
                      ),

                      // (moved _showFullScreenTemplate method to class scope)
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Aberto em',
                        _formatDate(widget.chamado.dataAbertura),
                      ),
                      if (widget.chamado.dataFechamento != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.check_circle,
                          'Fechado em',
                          _formatDate(widget.chamado.dataFechamento!),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.chamado.descricao,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mensagens: ${widget.chamado.mensagens.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // CARD 2: SUGESTÃO DE PLANO DE AÇÃO (EXPANDÍVEL)
              FutureBuilder<Map<String, dynamic>>(
                future: _planoDeAcaoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Gerando sugestão de plano de ação...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Não foi possível gerar uma sugestão de plano de ação: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  final plano = snapshot.data ?? {};
                  if (plano.containsKey('errorMessage')) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          plano['errorMessage'].toString(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildActionPlanSection(
                            plano,
                            () => _requestEmailTemplate(plano),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_emailTemplateFuture != null) ...[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: FutureBuilder<String>(
                              future: _emailTemplateFuture,
                              builder: (context, emailSnapshot) {
                                if (emailSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (emailSnapshot.hasError) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Não foi possível gerar o modelo de e-mail: ${emailSnapshot.error}',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildEmailTemplateSection(
                                        _buildFallbackEmailTemplate(plano),
                                      ),
                                    ],
                                  );
                                }
                                return _buildEmailTemplateSection(
                                  emailSnapshot.data ??
                                      _buildFallbackEmailTemplate(plano),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPlanSection(
    Map<String, dynamic> plano,
    VoidCallback onGenerateEmail,
  ) {
    final status = plano['status']?.toString() ?? '';
    final problemaPrincipal = plano['problemaPrincipal']?.toString() ?? '';
    final impactoNegocio = plano['impactoNegocio']?.toString() ?? '';
    final acoesPrioritarias = List<String>.from(
      plano['acoesPrioritarias'] ?? [],
    );
    final acoesMedioTermo = List<String>.from(plano['acoesMedioTermo'] ?? []);
    final metricasMonitoramento = List<String>.from(
      plano['metricasMonitoramento'] ?? [],
    );
    final estimativaImpacto = plano['estimativaImpacto']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8C1D18).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF8C1D18).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 22,
                color: Color(0xFF8C1D18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sugestão de Plano de Ação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C1D18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (status.isNotEmpty)
          _buildInfoRow(Icons.timeline, 'Status da análise', status),
        if (problemaPrincipal.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.construction,
            'Problema principal',
            problemaPrincipal,
          ),
        ],
        if (impactoNegocio.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(Icons.insights, 'Impacto no negócio', impactoNegocio),
        ],
        if (acoesPrioritarias.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Ações prioritárias',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: acoesPrioritarias
                  .map((acao) => _buildBulletItem(acao))
                  .toList(),
            ),
          ),
        ],
        if (acoesMedioTermo.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Ações médio prazo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: acoesMedioTermo
                  .map((acao) => _buildBulletItem(acao))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onGenerateEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C1818),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Modelo de e-mail',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        if (metricasMonitoramento.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Métricas de monitoramento',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: metricasMonitoramento
                  .map((acao) => _buildBulletItem(acao))
                  .toList(),
            ),
          ),
        ],
        if (estimativaImpacto.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.show_chart,
            'Estimativa de impacto',
            estimativaImpacto,
          ),
        ],
      ],
    );
  }

  void _showFullScreenTemplate(String emailTemplate) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Visualizar Template'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: emailTemplate));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Email copiado para a área de transferência!',
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  emailTemplate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
    Color? highlightColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: highlight
                      ? highlightColor ?? const Color(0xFF8C1D18)
                      : Colors.black87,
                  decoration: highlight
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestEmailTemplate(Map<String, dynamic> plano) async {
    if (_savedEmailTemplate != null) {
      setState(() {
        _emailTemplateFuture = Future.value(_savedEmailTemplate);
      });
    } else {
      setState(() {
        _emailTemplateFuture = _gerarEmailTemplate(plano);
      });
    }
    _emailTemplateFuture?.whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<String> _gerarEmailTemplate(Map<String, dynamic> plano) async {
    final gemini = GeminiService();
    final chamadoData = {
      'id': widget.chamado.id,
      'titulo': widget.chamado.titulo,
      'descricao': widget.chamado.descricao,
      'mensagem': widget.chamado.descricao,
      'usuarioNome': widget.chamado.usuarioNome,
      'usuarioEmail': _usuarioEmail ?? widget.chamado.usuarioEmail,
      'empresaNome': widget.chamado.empresaNome,
      'prioridade': widget.chamado.prioridade,
      'status': widget.chamado.status,
    };

    final emailTemplate = await gemini.gerarEmailResposta(chamadoData, plano);
    if (emailTemplate.isNotEmpty) {
      _savedEmailTemplate = emailTemplate;
      try {
        await _repository.salvarTemplateEmailChamado(
          widget.chamado.id,
          emailTemplate,
        );
      } catch (_) {
        // Não bloqueia a exibição caso falhe ao salvar.
      }
    }
    return emailTemplate;
  }

  String _buildFallbackEmailTemplate(Map<String, dynamic> plano) {
    final clienteName = widget.chamado.usuarioNome.isNotEmpty
        ? widget.chamado.usuarioNome
        : 'Cliente';
    final emailAddress =
        (_usuarioEmail ?? widget.chamado.usuarioEmail).isNotEmpty
        ? (_usuarioEmail ?? widget.chamado.usuarioEmail)
        : 'email@exemplo.com';
    final dataAberturaFormatada = _formatDate(widget.chamado.dataAbertura);
    final problemaPrincipal =
        plano['problemaPrincipal']?.toString() ?? 'Problema reportado';
    final impactoNegocio = plano['impactoNegocio']?.toString() ?? '';
    final acoesPrioritarias = List<String>.from(
      plano['acoesPrioritarias'] ?? [],
    );

    final acoesTexto = acoesPrioritarias.isNotEmpty
        ? acoesPrioritarias
              .asMap()
              .entries
              .map((entry) {
                return '**AÇÃO ${entry.key + 1}: ${entry.value.split('-').first.trim()}**\n- Timeline: [Defina aqui]\n- Responsável: [Defina aqui]\n- Objetivo: [Defina aqui]';
              })
              .join('\n\n')
        : '''**AÇÃO 1: Análise Preliminar**
- Timeline: 24-48 horas
- Responsável: Equipe Técnica

**AÇÃO 2: Investigação da Causa Raiz**
- Timeline: 3-5 dias úteis
- Responsável: Engenharia

**AÇÃO 3: Implementação de Medidas Corretivas**
- Timeline: 5-10 dias úteis
- Responsável: Setor Responsável

**AÇÃO 4: Teste de Validação**
- Timeline: 10-15 dias úteis
- Responsável: QA

**AÇÃO 5: Comunicação de Resultado**
- Timeline: Até 15 dias
- Responsável: Gestor de Qualidade''';

    return '''Assunto: Re: ${widget.chamado.titulo} - Chamado #${widget.chamado.id} - Recebimento Confirmado

Prezado(a) $clienteName,

Agradecemos por entrar em contato conosco e reportar o problema em seu chamado.

Confirmamos o recebimento do seu chamado em $dataAberturaFormatada com prioridade ${widget.chamado.prioridade.toUpperCase()}, e já iniciamos uma análise sobre o ocorrido.

---

### INFORMAÇÕES DO CHAMADO
- ID: #${widget.chamado.id}
- Status: ${widget.chamado.status.replaceAll('_', ' ').toUpperCase()}
- Empresa: ${widget.chamado.empresaNome}
- Solicitante: $clienteName
- Email: $emailAddress
- Data de Abertura: $dataAberturaFormatada

### DESCRIÇÃO DO PROBLEMA
${widget.chamado.descricao}

### ANÁLISE PRELIMINAR
**Problema Principal:**
$problemaPrincipal

${impactoNegocio.isNotEmpty ? '**Impacto no Negócio:**\n$impactoNegocio' : ''}

---

### PLANO DE AÇÃO

$acoesTexto

---

### PRÓXIMAS ETAPAS

1. Nossa equipe entrará em contato para coletar mais detalhes se necessário
2. Você receberá atualizações a cada 3-5 dias úteis
3. Um relatório completo será enviado após conclusão da investigação

Estamos comprometidos em resolver este problema o mais rápido possível. Caso tenha urgência ou dúvidas adicionais, não hesite em nos contatar.

Agradecemos pela paciência e confiança em nossos serviços.

Atenciosamente,
[NOME DA EMPRESA]
Equipe de Suporte''';
  }

  Widget _buildEmailTemplateSection(String emailTemplate) {
    final emailAddress =
        (_usuarioEmail ?? widget.chamado.usuarioEmail).isNotEmpty
        ? (_usuarioEmail ?? widget.chamado.usuarioEmail)
        : 'email@exemplo.com';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8C1D18).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF8C1D18).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 22,
                color: Color(0xFF8C1D18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Template de Email para Cliente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C1D18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                emailTemplate,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: emailTemplate));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Email copiado para a área de transferência!',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.content_copy),
                label: const Text('Copiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () => _showFullScreenTemplate(emailTemplate),
                icon: const Icon(Icons.open_in_full),
                label: const Text('Expandir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed:
                    emailAddress.isNotEmpty &&
                        emailAddress != 'email@exemplo.com'
                    ? () => _launchEmail(emailAddress)
                    : null,
                icon: const Icon(Icons.send),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C1D18),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
