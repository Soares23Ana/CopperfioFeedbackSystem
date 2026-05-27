import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';

class FeedbackDetailPage extends StatelessWidget {
  final Map<String, dynamic> feedbackData;

  const FeedbackDetailPage({super.key, required this.feedbackData});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.grey[300] : Colors.grey[700];

    final mensagem = feedbackData['mensagem'] as String? ?? '';
    final lote = feedbackData['lote'] as String? ?? '';
    final userEmpresa =
        feedbackData['userEmpresa'] as String? ??
        feedbackData['empresaId'] as String? ??
        '';
    final userName =
        feedbackData['userName'] as String? ??
        feedbackData['userEmail'] as String? ??
        'Cliente';
    final userEmail = feedbackData['userEmail'] as String? ?? '';
    final status = feedbackData['status'] as String? ?? 'novo';
    final userType = feedbackData['userType'] as String? ?? 'cliente';
    final atendimentoMood = feedbackData['atendimentoMood'] as String? ?? '';
    final generalRating = feedbackData['generalRating'] as int? ?? 0;
    final tags = (feedbackData['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final photoUrl = feedbackData['photoUrl'] as String? ?? '';
    final notaMedia = feedbackData['notaMedia'] as num? ?? 0.0;
    final item1 = feedbackData['item1'] as int? ?? 0;
    final item2 = feedbackData['item2'] as int? ?? 0;
    final item3 = feedbackData['item3'] as int? ?? 0;
    final item4 = feedbackData['item4'] as int? ?? 0;
    final item5 = feedbackData['item5'] as int? ?? 0;
    final item6 = feedbackData['item6'] as int? ?? 0;
    final item7 = feedbackData['item7'] as int? ?? 0;
    final item8 = feedbackData['item8'] as int? ?? 0;
    final analiseIA = feedbackData['analiseIA'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            feedbackData['analiseIA'] as Map<String, dynamic>,
          )
        : null;
    final Timestamp? createdAt = feedbackData['data'] as Timestamp?;
    final dateLabel = createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(
            createdAt.millisecondsSinceEpoch,
          ).toLocal().toString()
        : 'Data não disponível';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Detalhes do Feedback',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    lote.isNotEmpty ? 'Lote: $lote' : 'Feedback do cliente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (userEmpresa.isNotEmpty) ...[
                            _detailRow('Empresa', userEmpresa, isDark),
                            const SizedBox(height: 8),
                          ],
                          _detailRow('Cliente', userName, isDark),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _detailRow('Email', userEmail, isDark),
                          ],
                          const SizedBox(height: 8),
                          _detailRow('Tipo de usuário', userType, isDark),
                          const SizedBox(height: 8),
                          _detailRow('Status', status.toUpperCase(), isDark),
                          const SizedBox(height: 8),
                          _detailRow('Enviado em', dateLabel, isDark),
                          const SizedBox(height: 16),
                          Text(
                            'Resumo da avaliação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            'Avaliação geral',
                            generalRating > 0 ? '$generalRating estrelas' : '-',
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            'Atendimento',
                            atendimentoMood.isNotEmpty ? atendimentoMood : '-',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Notas por Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (item1 > 0) ...[
                            _ratingRow('Satisfação Geral', item1, isDark),
                            const SizedBox(height: 6),
                          ],
                          if (item2 > 0) ...[
                            _ratingRow('Qualidade do Produto', item2, isDark),
                            const SizedBox(height: 6),
                          ],
                          if (item3 > 0) ...[
                            _ratingRow('Embalagem Adequada', item3, isDark),
                            const SizedBox(height: 6),
                          ],
                          if (item4 > 0) ...[
                            _ratingRow('Prazo de Entrega', item4, isDark),
                            const SizedBox(height: 6),
                          ],
                          if (item5 > 0) ...[
                            _ratingRow('Conhecimento Técnico', item5, isDark),
                            const SizedBox(height: 6),
                          ],
                          if (item6 > 0) ...[
                            _ratingRow('Cordialidade e Empatia', item6, isDark),
                            const SizedBox(height: 6),
                          ],
                          if (item7 > 0) ...[
                            _ratingRow(
                              'Qualidade do Suporte Técnico',
                              item7,
                              isDark,
                            ),
                            const SizedBox(height: 6),
                          ],
                          if (item8 > 0) ...[
                            _ratingRow('Satisfação com Suporte', item8, isDark),
                            const SizedBox(height: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF8C1D18),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Média Geral',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  notaMedia > 0
                                      ? notaMedia.toStringAsFixed(2)
                                      : '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color(0xFF8C1D18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _detailRow('Tags', tags.join(', '), isDark),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Mensagem detalhada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mensagem,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: secondaryText,
                            ),
                          ),
                          if (photoUrl.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Foto enviada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 180,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: Text(
                                        'Não foi possível carregar a imagem',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (analiseIA != null) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Análise IA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _analysisRow(
                              'Sentimento',
                              analiseIA['sentimento']?.toString() ?? '-',
                              isDark,
                            ),
                            const SizedBox(height: 8),
                            _analysisRow(
                              'Categoria',
                              analiseIA['categoria']?.toString() ?? '-',
                              isDark,
                            ),
                            const SizedBox(height: 8),
                            _analysisRow(
                              'Urgência',
                              analiseIA['urgencia']?.toString() ?? '-',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Resumo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              analiseIA['resumo']?.toString() ?? '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryText,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sugestão',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              analiseIA['sugestao']?.toString() ?? '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[300] : Colors.black87;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  Widget _ratingRow(String label, int rating, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[300] : Colors.black87;

    // Determinar cor com base na nota
    Color ratingColor;
    if (rating >= 9) {
      ratingColor = Colors.green;
    } else if (rating >= 7) {
      ratingColor = Colors.amber;
    } else if (rating >= 5) {
      ratingColor = Colors.orange;
    } else {
      ratingColor = Colors.red;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14, color: labelColor)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ratingColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ratingColor),
          ),
          child: Text(
            rating.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ratingColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _analysisRow(String label, String value, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[300] : Colors.black87;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }
}
