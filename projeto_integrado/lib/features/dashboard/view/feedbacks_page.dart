import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodel/feedbacks_viewmodel.dart';
import '../../../core/theme_provider.dart';
import '../../../core/manager_app_bar.dart';
import 'feedback_detail_page.dart';
import 'alertas_page.dart' as alertas;
import '../../chamados/view/chamados_page.dart';
import 'dashboard_page.dart';
import '../../../services/excel_service.dart';

class FeedbacksPage extends StatefulWidget {
  const FeedbacksPage({
    super.key,
    this.initialFilter,
    this.initialSearch,
    this.initialDateRange,
  });

  final String? initialFilter;
  final String? initialSearch;
  final DateTimeRange? initialDateRange;

  @override
  State<FeedbacksPage> createState() => _FeedbacksPageState();
}

class _FeedbacksPageState extends State<FeedbacksPage> {
  int _currentIndex = 1; // Feedbacks is index 1
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'TODOS';
  DateTimeRange? _selectedDateRange;
  final List<String> _filterOptions = [
    'TODOS',
    'POSITIVOS',
    'NEGATIVOS',
    'NEUTRO',
    'DATA',
  ];
  bool _isGeneratingReport = false;
  String? _processingFeedbackId;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter?.toUpperCase() ?? 'TODOS';
    _searchQuery = widget.initialSearch ?? '';
    _selectedDateRange = widget.initialDateRange;
    if (_searchQuery.isNotEmpty) {
      _searchController.text = _searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _mostrarDialogAnalise(Map<String, dynamic> analise) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Análise IA'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sentimento: ${analise['sentimento'] ?? 'N/A'}'),
              Text('Categoria: ${analise['categoria'] ?? 'N/A'}'),
              Text('Urgência: ${analise['urgencia'] ?? 'N/A'}'),
              const SizedBox(height: 12),
              Text('Resumo:'),
              Text(
                analise['resumo'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Sugestão:'),
              Text(
                analise['sugestao'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _analisarFeedback(String feedbackId) async {
    setState(() {
      _processingFeedbackId = feedbackId;
    });

    final vm = Provider.of<FeedbacksViewModel>(context, listen: false);

    try {
      final analise = await vm.analisarFeedback(feedbackId);
      await _mostrarDialogAnalise(analise);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao analisar feedback: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _processingFeedbackId = null;
        });
      }
    }
  }

  Future<void> _abrirConfiguracaoRelatorio() async {
    String topicoSelecionado = _selectedFilter == 'DATA' ? 'TODOS' : _selectedFilter;
    DateTimeRange? periodoSelecionado =
        _selectedDateRange; // usa o filtro atual da tela como padrão
    String filtroSelecionado =
        _selectedFilter; // 'TODOS', 'POSITIVOS', 'NEGATIVOS', 'NEUTRO'

    final List<String> topicosFoco = [
      'TODOS',
      'POSITIVOS',
      'NEGATIVOS',
      'NEUTRO',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDark ? Colors.white : Colors.black87;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurar Relatório IA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A inteligência artificial analisará os feedbacks e gerará um relatório estratégico. Escolha o foco principal da análise:',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tipo de Relatório',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: topicoSelecionado,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        items: topicosFoco.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setModalState(() {
                              topicoSelecionado = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Período Analisado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await _pickDateRange(context);
                      if (picked != null) {
                        setModalState(() {
                          periodoSelecionado = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              periodoSelecionado != null
                                  ? '${DateFormat('dd/MM/yyyy').format(periodoSelecionado!.start)} até ${DateFormat('dd/MM/yyyy').format(periodoSelecionado!.end)}'
                                  : 'Todos os feedbacks',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          if (periodoSelecionado != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setModalState(() {
                                  periodoSelecionado = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C1D18),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Gerar Relatório',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // Atualiza o filtro global para que _executarGeracaoRelatorio use-o
                        setState(() {
                          _selectedFilter = filtroSelecionado;
                          _selectedDateRange = periodoSelecionado;
                        });

                        Navigator.pop(ctx);
                        _executarGeracaoRelatorio(
                          topicoSelecionado,
                          periodoSelecionado,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _executarGeracaoRelatorio(
    String topicoFoco,
    DateTimeRange? periodo,
  ) async {
    setState(() {
      _isGeneratingReport = true;
    });

    final vm = Provider.of<FeedbacksViewModel>(context, listen: false);

    try {
      final relatorio = await vm.gerarRelatorioFeedbacks(
        filtroTipo: _selectedFilter == 'TODOS' ? null : _selectedFilter,
        periodo: periodo,
        topicoFoco: topicoFoco,
      );

      if (!mounted) return;
      _mostrarRelatorioIA(relatorio, topicoFoco);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar relatório: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }

  void _mostrarRelatorioIA(Map<String, dynamic> relatorio, String topicoFoco) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final primaryColor = const Color(0xFF8C1D18);

        final metricas = relatorio['metricas'] ?? {};
        final notaMedia = metricas['notaMedia']?.toString() ?? 'N/A';
        final totalPositivos = metricas['totalPositivos']?.toString() ?? '0';
        final totalNegativos = metricas['totalNegativos']?.toString() ?? '0';
        final totalNeutros = metricas['totalNeutros']?.toString() ?? '0';

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_chart, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Relatório Estratégico IA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Foco: $topicoFoco',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção: Métricas
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panorama de Métricas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetricCard(
                                  'Nota Média',
                                  notaMedia,
                                  Icons.star,
                                  Colors.amber,
                                ),
                                _buildMetricCard(
                                  'Positivos',
                                  totalPositivos,
                                  Icons.thumb_up,
                                  Colors.green,
                                ),
                                _buildMetricCard(
                                  'Negativos',
                                  totalNegativos,
                                  Icons.warning,
                                  Colors.red,
                                ),
                                _buildMetricCard(
                                  'Neutros',
                                  totalNeutros,
                                  Icons.remove_circle_outline,
                                  Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Resumo e Foco
                      _buildSectionTitle(
                        'Resumo Executivo',
                        Icons.article,
                        textColor,
                      ),
                      Text(
                        relatorio['resumoExecutivo'] ?? 'Sem resumo.',
                        style: TextStyle(color: textColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        'Análise Estratégica ($topicoFoco)',
                        Icons.lightbulb,
                        textColor,
                      ),
                      Text(
                        relatorio['focoEstrategico'] ?? 'Sem análise.',
                        style: TextStyle(color: textColor, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Listas Positivas e Negativas
                      if ((relatorio['analisePositiva'] as List?)?.isNotEmpty ==
                          true) ...[
                        _buildSectionTitle(
                          'Pontos Positivos Destacados',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        ...((relatorio['analisePositiva'] as List).map(
                          (e) => _buildBulletPoint(e.toString(), textColor),
                        )),
                        const SizedBox(height: 20),
                      ],

                      if ((relatorio['analiseNegativa'] as List?)?.isNotEmpty ==
                          true) ...[
                        _buildSectionTitle(
                          'Problemas e Pontos Críticos',
                          Icons.error,
                          Colors.red,
                        ),
                        ...((relatorio['analiseNegativa'] as List).map(
                          (e) => _buildBulletPoint(e.toString(), textColor),
                        )),
                        const SizedBox(height: 20),
                      ],

                      if ((relatorio['analiseNeutra'] as List?)?.isNotEmpty ==
                          true) ...[
                        _buildSectionTitle(
                          'Observações e Pontos Neutros',
                          Icons.info,
                          Colors.blue,
                        ),
                        ...((relatorio['analiseNeutra'] as List).map(
                          (e) => _buildBulletPoint(e.toString(), textColor),
                        )),
                        const SizedBox(height: 20),
                      ],

                      if ((relatorio['recomendacoesAcao'] as List?)
                              ?.isNotEmpty ==
                          true) ...[
                        _buildSectionTitle(
                          'Recomendações de Ação',
                          Icons.build,
                          Colors.orange,
                        ),
                        ...((relatorio['recomendacoesAcao'] as List).map(
                          (e) => _buildBulletPoint(e.toString(), textColor),
                        )),
                        const SizedBox(height: 24),
                      ],

                      // Tabela de Médias por Item
                      if (relatorio['tabelaItens'] != null && (relatorio['tabelaItens'] as String).isNotEmpty) ...[
                        _buildSectionTitle(
                          'Média de Notas por Item',
                          Icons.assessment,
                          primaryColor,
                        ),
                        _buildItemsTable(relatorio['tabelaItens'] as String, isDark, textColor, primaryColor),
                        const SizedBox(height: 24),
                      ],

                      _buildSectionTitle('Conclusão', Icons.flag, textColor),
                      Text(
                        relatorio['conclusao'] ?? 'Sem conclusão.',
                        style: TextStyle(color: textColor, height: 1.5),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Fechar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF8C1D18),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(String tabelaTexto, bool isDark, Color textColor, Color primaryColor) {
    // Parsear a tabela de itens do texto
    final lines = tabelaTexto.split('\n').where((line) => line.contains('-') && line.contains('Item')).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lines.map((line) {
            // Extrair item e valor (ex: "- Item 1 (Qualidade do Produto): 9.50")
            final parts = line.split(':');
            if (parts.length == 2) {
              final itemLabel = parts[0].replaceAll('- ', '').trim();
              final valor = parts[1].trim();
              
              // Parsear valor para exibir como decimal
              final nota = double.tryParse(valor) ?? 0.0;
              
              // Cor baseada na nota (verde > 8, amarelo 6-8, vermelho < 6)
              Color notaColor;
              if (nota >= 8.5) {
                notaColor = Colors.green;
              } else if (nota >= 7.0) {
                notaColor = Colors.amber;
              } else if (nota >= 5.0) {
                notaColor = Colors.orange;
              } else {
                notaColor = Colors.red;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemLabel,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: notaColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: notaColor, width: 1.5),
                      ),
                      child: Text(
                        valor,
                        style: TextStyle(
                          color: notaColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FeedbacksViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final primaryColor = const Color(0xFF8C1D18);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ManagerAppBar(
        themeProvider: themeProvider,
        onBack: () => Navigator.pop(context),
        showProfileIcon: false,
      ),
      body: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF5EBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryColor.withAlpha((0.3 * 255).round()),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText:
                              'Buscar feedbacks por empresa, título, conteúdo, nota ou tipo...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1C)
                            : const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : const Color(0xFFDEE2E7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.18)
                                : Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF292929)
                                  : const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.filter_alt_outlined,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                isExpanded: true,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                dropdownColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                items: _filterOptions.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(
                                      _filterDropdownLabel(option),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (option) async {
                                  if (option == null) return;
                                  if (option == 'DATA') {
                                    final pickedRange = await _pickDateRange(context);
                                    if (pickedRange != null) {
                                      setState(() {
                                        _selectedDateRange = pickedRange;
                                        _selectedFilter = 'DATA';
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _selectedFilter = option;
                                      if (option != 'DATA') {
                                        _selectedDateRange = null;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Filtrando por data: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} até ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Ações rápidas: Relatório IA e Exportar Excel (baseado nos registros filtrados)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _abrirConfiguracaoRelatorio(),
                    icon: const Icon(Icons.insert_chart, size: 18),
                    label: const Text('Gerar Relatório IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C1D18),
                      minimumSize: const Size(160, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Gerando planilha, por favor aguarde...'),
                        duration: Duration(seconds: 2),
                      ));
                      try {
                        final docs = (await vm.feedbacksStream().first).docs.map((d) => d.data()).toList();
                        // Apply same local filter as the UI
                        final docsFiltered = vm.aplicarFiltroEBusca((await vm.feedbacksStream().first).docs, _selectedFilter, _searchQuery, _selectedDateRange).map((d) => d.data()).toList();
                        await ExcelService.gerarExcel(feedbacks: docsFiltered.cast<Map<String, dynamic>>());
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao exportar Excel: $e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Exportar Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      minimumSize: const Size(160, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: vm.feedbacksStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar feedbacks: ${snapshot.error}',
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final feedbacks =
                      snapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final filteredFeedbacks = vm.aplicarFiltroEBusca(
                    feedbacks,
                    _selectedFilter,
                    _searchQuery,
                    _selectedDateRange,
                  );
                  final count = filteredFeedbacks.length;
                  final totalCount = feedbacks.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Feedbacks',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? primaryColor.withAlpha(
                                        (0.2 * 255).round(),
                                      )
                                    : const Color(0xFFF2D7D5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                _searchQuery.isNotEmpty ||
                                        _selectedFilter != 'TODOS'
                                    ? '$count de $totalCount resultado${count != 1 ? 's' : ''}'
                                    : '$count REGISTRO${count != 1 ? 'S' : ''}',
                                style: TextStyle(
                                  color: isDark ? Colors.white : primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),


                      if (filteredFeedbacks.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'Nenhum feedback corresponde a "$_searchQuery"'
                                  : 'Nenhum feedback encontrado',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredFeedbacks.length,
                            itemBuilder: (context, index) {
                              final feedback = filteredFeedbacks[index];
                              final data = feedback.data();

                              final userEmpresa =
                                  data['userEmpresa'] as String? ??
                                  data['empresaId'] as String? ??
                                  'Desconhecido';
                              final feedbackText =
                                  data['mensagem'] as String? ??
                                  data['descricao'] as String? ??
                                  data['texto'] as String? ??
                                  data['titulo'] as String? ??
                                  'Sem descrição fornecida.';
                              final atendimentoMood =
                                  data['atendimentoMood'] as String? ?? '';
                              final tags =
                                  (data['tags'] as List<dynamic>?)
                                      ?.cast<String>() ??
                                  [];

                              DateTime? dateObj;
                              if (data['data'] is Timestamp) {
                                dateObj = (data['data'] as Timestamp).toDate();
                              } else if (data['data'] is String) {
                                dateObj = DateTime.tryParse(data['data']);
                              }

                              final formattedDate = dateObj != null
                                  ? DateFormat(
                                      'dd MMM yyyy • HH:mm',
                                    ).format(dateObj)
                                  : '';

                              // Determine Type visually based on text/title heuristic
                              final titleLower =
                                  (data['titulo'] as String? ?? '')
                                      .toLowerCase();
                              final textLower = feedbackText.toLowerCase();
                              Color accentColor = const Color(
                                0xFF5DADE2,
                              ); // Default Blue
                              String type = 'OPERACIONAL';

                              if (titleLower.contains('crítico') ||
                                  titleLower.contains('urgente') ||
                                  titleLower.contains('revisão') ||
                                  textLower.contains('revisão') ||
                                  textLower.contains('problema') ||
                                  textLower.contains('atraso')) {
                                accentColor = primaryColor;
                                type = 'CRÍTICO';
                              } else if (titleLower.contains('elogio') ||
                                  textLower.contains('excelente') ||
                                  textLower.contains('ótimo') ||
                                  textLower.contains('bom')) {
                                accentColor = Colors.grey[400]!;
                                type = 'ELOGIO';
                              } else if (titleLower.contains('sugestão') ||
                                  textLower.contains('sugestão') ||
                                  textLower.contains('melhoria')) {
                                accentColor = const Color(0xFF1ABC9C); // Teal
                                type = 'SUGESTÃO';
                              }

                              return _buildFeedbackCard(
                                context: context,
                                companyName: userEmpresa.toUpperCase(),
                                dateString: formattedDate,
                                feedbackText: feedbackText,
                                atendimentoMood: atendimentoMood,
                                tags: tags,
                                accentColor: accentColor,
                                cardColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : const Color(0xFFFCF6F6),
                                textColor: textColor,
                                isDark: isDark,
                                primaryColor: primaryColor,
                                data: data,
                                id: feedback.id,
                                vm: vm,
                                type: type,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex.clamp(0, 3),
          selectedItemColor: primaryColor,
          unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
          backgroundColor: cardColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const alertas.AlertasPage()),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChamadosPage()),
              );
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.dashboard),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chat_bubble,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              label: 'Feedbacks',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.notifications_none),
              ),
              label: 'Alertas',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.support_agent),
              ),
              label: 'Chamados',
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTimeRange?> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    return await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8C1D18),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  String _filterDropdownLabel(String option) {
    if (option == 'DATA' && _selectedDateRange != null) {
      return 'DATA ${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}';
    }
    if (option == 'POSITIVOS') {
      return 'POSITIVOS';
    }
    if (option == 'NEGATIVOS') {
      return 'NEGATIVOS';
    }
    return option;
  }

  Widget _buildFeedbackCard({
    required BuildContext context,
    required String companyName,
    required String dateString,
    required String feedbackText,
    required String atendimentoMood,
    required List<String> tags,
    required Color accentColor,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    required Color primaryColor,
    required Map<String, dynamic> data,
    required String id,
    required FeedbacksViewModel vm,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FeedbackDetailPage(feedbackData: data),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Excluir Feedback'),
                        content: const Text(
                          'Deseja realmente excluir este feedback?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              vm.deletarFeedback(id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: textColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateString,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Excluir Feedback'),
                                      content: const Text(
                                        'Deseja realmente excluir este feedback?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            vm.deletarFeedback(id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Excluir',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Center(
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: isDark
                                          ? Colors.red[300]
                                          : Colors.redAccent,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '"$feedbackText"',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.black87,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        if (atendimentoMood.isNotEmpty) ...[
                          _buildTag(
                            atendimentoMood.toUpperCase(),
                            isDark
                                ? const Color(0xFF304FFE)
                                : const Color(0xFFE8F0FE),
                            isDark ? Colors.white : const Color(0xFF304FFE),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (tags.isNotEmpty) ...[
                          _buildTag(
                            tags.first.toUpperCase(),
                            isDark
                                ? const Color(0xFF424242)
                                : const Color(0xFFEAF2F8),
                            isDark ? Colors.white : const Color(0xFF2C3E50),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTag(
                              type,
                              isDark
                                  ? primaryColor.withAlpha((0.2 * 255).round())
                                  : const Color(0xFFF2D7D5),
                              isDark ? Colors.white : primaryColor,
                            ),
                            const SizedBox(width: 8),
                            _buildTag(
                              'TÉCNICO',
                              isDark
                                  ? Colors.grey[800]!
                                  : const Color(0xFFEAECEE),
                              isDark ? Colors.grey[300]! : Colors.grey[700]!,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _processingFeedbackId == id
                                  ? null
                                  : () => _analisarFeedback(id),
                              icon: _processingFeedbackId == id
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.analytics_outlined),
                              label: const Text('Análise IA'),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
