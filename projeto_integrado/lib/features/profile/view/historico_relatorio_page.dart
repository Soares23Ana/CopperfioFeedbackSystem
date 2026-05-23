import 'package:flutter/material.dart';
class HistoricoRelatorioPage extends StatelessWidget {
  final Map<String, dynamic> relatorioData;
  final Map<String, dynamic> metadata;
  final String createdText;

  const HistoricoRelatorioPage({
    super.key,
    required this.relatorioData,
    required this.metadata,
    required this.createdText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topico = metadata['topicoFoco'] as String? ?? 'Relatório de IA';
    final filtroTipo = metadata['filtroTipo'] as String? ?? 'Todos os tipos';
    final totalFeedbacks = metadata['totalFeedbacks']?.toString() ?? '—';
    final periodo = metadata['periodo'] != null
        ? '${metadata['periodo']['inicio'] ?? ''} → ${metadata['periodo']['fim'] ?? ''}'
        : 'Período não informado';
    final metricas = relatorioData['metricas'] as Map<String, dynamic>? ?? {};
    final notaMedia = metricas['notaMedia']?.toString() ?? '—';
    final positivos = metricas['totalPositivos']?.toString() ?? '0';
    final negativos = metricas['totalNegativos']?.toString() ?? '0';
    final neutros = metricas['totalNeutros']?.toString() ?? '0';

    final resumoExecutivo =
        relatorioData['resumoExecutivo'] as String? ?? 'Sem resumo.';
    final focoEstrategico =
        relatorioData['focoEstrategico'] as String? ?? 'Sem análise.';
    final analisePositiva = List<String>.from(
      relatorioData['analisePositiva'] ?? [],
    );
    final analiseNegativa = List<String>.from(
      relatorioData['analiseNegativa'] ?? [],
    );
    final analiseNeutra = List<String>.from(
      relatorioData['analiseNeutra'] ?? [],
    );
    final recomendacoes = List<String>.from(
      relatorioData['recomendacoesAcao'] ?? [],
    );
    final conclusao = relatorioData['conclusao'] as String? ?? 'Sem conclusão.';
    final tabelaItens = relatorioData['tabelaItens'] as String? ?? '';

    final cardColor = theme.colorScheme.surface;
    final surfaceVariant = theme.colorScheme.surfaceVariant;
    final onSurface = theme.colorScheme.onSurface;
    final screenWidth = MediaQuery.of(context).size.width;
    final metricWidth = (screenWidth - 56) / 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório IA'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Relatório IA',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(topico, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.analytics,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildBadge('Feedbacks: $totalFeedbacks', context),
                      _buildBadge('Filtro: $filtroTipo', context),
                      _buildBadge('Período: $periodo', context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Nota Média',
                          notaMedia,
                          theme.colorScheme.primary,
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Positivos',
                          positivos,
                          Colors.green.shade700,
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Negativos',
                          negativos,
                          Colors.red.shade700,
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Neutros',
                          neutros,
                          Colors.orange.shade700,
                          context,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionCard('Resumo Executivo', resumoExecutivo, context),
            _buildSectionCard('Análise Estratégica', focoEstrategico, context),
            if (analisePositiva.isNotEmpty) ...[
              _buildBulletCard('Pontos Positivos', analisePositiva, context),
            ],
            if (analiseNegativa.isNotEmpty) ...[
              _buildBulletCard('Pontos Negativos', analiseNegativa, context),
            ],
            if (analiseNeutra.isNotEmpty) ...[
              _buildBulletCard('Pontos Neutros', analiseNeutra, context),
            ],
            if (recomendacoes.isNotEmpty) ...[
              _buildBulletCard('Recomendações de Ação', recomendacoes, context),
            ],
            _buildSectionCard('Conclusão', conclusao, context),
            if (tabelaItens.isNotEmpty) ...[
              _buildItemsTableCard(tabelaItens, context),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    Color color,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String text, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBulletCard(
    String title,
    List<String> items,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTableCard(String tabelaTexto, BuildContext context) {
    // Parsear a tabela de itens do texto
    final lines = tabelaTexto.split('\n').where((line) => line.contains('-') && line.contains('Item')).toList();
    
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Média de Notas por Item',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...lines.map((line) {
            // Extrair item e valor (ex: "- Item 1 (Qualidade do Produto): 9.50")
            final parts = line.split(':');
            if (parts.length == 2) {
              final itemLabel = parts[0].replaceAll('- ', '').trim();
              final valor = parts[1].trim();
              
              // Parsear valor para exibir como decimal
              final nota = double.tryParse(valor) ?? 0.0;
              
              // Cor baseada na nota
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
                        style: theme.textTheme.bodyMedium?.copyWith(
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
}
