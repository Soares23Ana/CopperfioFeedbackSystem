import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';
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
  String? _usuarioEmail;
  String? _emailSuggestionSubject;
  String? _emailSuggestionBody;
  String? _emailSuggestionError;
  bool _showEmailSuggestion = false;
  bool _isGeneratingEmailSuggestion = false;
  late final Future<Map<String, dynamic>> _planoDeAcaoFuture;

  @override
  void initState() {
    super.initState();
    _planoDeAcaoFuture = _gerarPlanoDeAcao();
    _loadUsuarioEmailIfNeeded();
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

  Future<Map<String, dynamic>> _gerarPlanoDeAcao() async {
    final gemini = GeminiService();
    try {
      return await gemini.analisarPlanoDeAcao([
        {
          'titulo': widget.chamado.titulo,
          'descricao': widget.chamado.descricao,
          'mensagem': widget.chamado.descricao,
          'notaMedia': 0,
        },
      ]);
    } catch (e) {
      // Return a friendly fallback so the UI can show a helpful message
      return {
        'status': 'indisponível',
        'problemaPrincipal': '',
        'impactoNegocio': '',
        'acoesPrioritarias': [],
        'acoesMedioTermo': [],
        'metricasMonitoramento': [],
        'estimativaImpacto': '',
        'errorMessage': 'Não foi possível gerar sugestão de plano de ação no momento. Tente novamente mais tarde.'
      };
    }
  }

  Future<void> _generateEmailSuggestion() async {
    setState(() {
      _isGeneratingEmailSuggestion = true;
      _emailSuggestionError = null;
    });

    final gemini = GeminiService();
    final clienteName = widget.chamado.usuarioNome.isNotEmpty
        ? widget.chamado.usuarioNome
        : 'Cliente';
    try {
      final result = await gemini.gerarSugestaoDeEmail(
        titulo: widget.chamado.titulo,
        descricao: widget.chamado.descricao,
        clienteNome: clienteName,
        empresaNome: widget.chamado.empresaNome,
        prioridade: widget.chamado.prioridade,
        dataAbertura: _formatDate(widget.chamado.dataAbertura),
      );

      setState(() {
        _emailSuggestionSubject = result['assunto']?.toString().trim();
        _emailSuggestionBody = result['mensagem']?.toString().trim();
      });
    } catch (e) {
      setState(() {
        _emailSuggestionError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingEmailSuggestion = false;
        });
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    final date = dateTime.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchEmail(String email, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
      },
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      highlight: (_usuarioEmail ?? widget.chamado.usuarioEmail)
                          .isNotEmpty,
                      highlightColor: primaryColor,
                    ),
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
                    const SizedBox(height: 24),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _planoDeAcaoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Row(
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Gerando sugestão de plano de ação...',
                                ),
                              ),
                            ],
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            'Não foi possível gerar uma sugestão de plano de ação: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          );
                        }

                        final plano = snapshot.data ?? {};
                        final emailAddress = (_usuarioEmail ?? widget.chamado.usuarioEmail).isNotEmpty
                            ? (_usuarioEmail ?? widget.chamado.usuarioEmail)
                            : '';

                        final widgetList = <Widget>[
                          if (plano.containsKey('errorMessage')) ...[
                            Text(
                              plano['errorMessage'].toString(),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _buildActionPlanSection(plano),
                          const SizedBox(height: 24),
                          _buildEmailSuggestionButton(emailAddress),
                        ];

                        if (_showEmailSuggestion) {
                          widgetList.add(const SizedBox(height: 24));
                          if (_isGeneratingEmailSuggestion) {
                            widgetList.add(Row(
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(width: 16),
                                Expanded(child: Text('Gerando sugestão de email...')),
                              ],
                            ));
                          } else if (_emailSuggestionError != null) {
                            widgetList.add(Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _emailSuggestionError!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildEmailSuggestionSection(emailAddress),
                              ],
                            ));
                          } else if (_emailSuggestionSubject != null && _emailSuggestionBody != null) {
                            widgetList.add(_buildEmailSuggestionSection(emailAddress));
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widgetList,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPlanSection(Map<String, dynamic> plano) {
    final status = plano['status']?.toString() ?? '';
    final resumoPlano = plano['resumoPlano']?.toString() ?? '';
    final resumoChamado = plano['resumoChamado']?.toString() ?? '';
    final impactoEmpresa = plano['impactoEmpresa']?.toString() ?? '';
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
        const Text(
          'Sugestão de Plano de Ação',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (resumoChamado.isNotEmpty) ...[
          Text(
            'Explicação do chamado',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            resumoChamado,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
        ],
        if (impactoEmpresa.isNotEmpty) ...[
          Text(
            'Impacto na empresa',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            impactoEmpresa,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
        ],
        if (resumoPlano.isNotEmpty) ...[
          Text(
            'Resumo do plano',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            resumoPlano,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
        ],
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
          const SizedBox(height: 12),
          const Text(
            'Ações prioritárias',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...acoesPrioritarias.map((acao) => _buildBulletItem(acao)),
        ],
        if (acoesMedioTermo.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Ações médio prazo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...acoesMedioTermo.map((acao) => _buildBulletItem(acao)),
        ],
        if (metricasMonitoramento.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Métricas de monitoramento',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ...metricasMonitoramento.map((acao) => _buildBulletItem(acao)),
        ],
        if (estimativaImpacto.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.show_chart,
            'Estimativa de impacto',
            estimativaImpacto,
          ),
        ],
      ],
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

  Widget _buildEmailSuggestionButton(String emailAddress) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _showEmailSuggestion = true;
            _emailSuggestionError = null;
          });
          if (_emailSuggestionSubject == null && _emailSuggestionBody == null) {
            _generateEmailSuggestion();
          }
        },
        icon: const Icon(Icons.email_outlined),
        label: const Text('Gerar sugestão de email para o cliente'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C1D18),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEmailSuggestionSection(String emailAddress) {
    final subject = _emailSuggestionSubject ?? 'Resposta ao chamado';
    final body = _emailSuggestionBody ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8C1D18).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF8C1D18).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.recommend,
                size: 20,
                color: Color(0xFF8C1D18),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sugestão de Email para o Cliente',
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assunto sugerido:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Corpo do email sugerido:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$subject\n\n$body'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sugestão de email copiada para a área de transferência!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Sugestão'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: emailAddress.isNotEmpty
                  ? () => _launchEmail(emailAddress, subject)
                  : null,
              icon: const Icon(Icons.send),
              label: const Text('Responder Cliente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C1D18),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
