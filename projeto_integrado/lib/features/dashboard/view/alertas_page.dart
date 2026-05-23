import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';
import '../viewmodel/alertas_viewmodel.dart';
import '../../../core/theme_provider.dart';
import '../../../core/manager_app_bar.dart';
import 'dashboard_page.dart';
import 'feedbacks_page.dart' as feedbacks;
import '../../chamados/view/chamados_page.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  int _currentIndex = 2; // Alertas is index 2

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AlertasViewModel>(context);
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
        extraActions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Alertas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Feedbacks e chamados que precisam de atenção imediata.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedbacks preocupantes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: vm.feedbacksStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar alertas de feedback: ${snapshot.error}',
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final feedbackDocs = snapshot.data?.docs ?? [];
                      final alertas = feedbackDocs.where((doc) {
                        final data = doc.data();
                        return vm.isFeedbackAlert(data);
                      }).toList();

                      if (alertas.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Nenhum feedback crítico encontrado.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alertas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final feedback = alertas[index].data();
                          final titulo =
                              (feedback['titulo'] as String? ??
                                      'Feedback negativo')
                                  .trim();
                          final mensagem =
                              (feedback['mensagem'] as String? ?? '').trim();
                          final empresa =
                              (feedback['userEmpresa'] as String? ??
                              feedback['empresaId'] as String? ??
                              'Desconhecido');
                          final rating =
                              (feedback['generalRating'] as int?) ?? 0;
                          final notaMedia =
                              (feedback['notaMedia'] as num?)?.toDouble() ??
                              0.0;
                          final date = feedback['data'];
                          final dateText = date is DateTime
                              ? DateFormat('dd/MM/yyyy HH:mm').format(date)
                              : date is Timestamp
                              ? DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(date.toDate())
                              : '';

                          return _buildAlertCard(
                            title: titulo.isEmpty ? 'Feedback crítico' : titulo,
                            subtitle: empresa,
                            description: mensagem.isEmpty
                                ? 'Relato sinalizado como preocupante.'
                                : mensagem,
                            badge:
                                'NPS $rating • ${notaMedia.toStringAsFixed(1)}',
                            dateText: dateText,
                            icon: Icons.feedback,
                            cardColor: cardColor,
                            textColor: textColor,
                            primaryColor: primaryColor,
                            isDark: isDark,
                            onDelete: () {
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
                                        vm.deletarFeedback(alertas[index].id);
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
                            onSuggestion: () => _mostrarSugestaoIa(
                              context,
                              vm,
                              feedback,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chamados urgentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<ChamadoModel>>(
                    stream: vm.chamadosStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar alertas de chamados: ${snapshot.error}',
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final chamados = snapshot.data ?? [];
                      final alertas = chamados
                          .where(vm.isChamadoAlert)
                          .toList();

                      if (alertas.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Nenhum chamado urgente encontrado.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alertas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chamado = alertas[index];
                          final statusText = chamado.status
                              .replaceAll('_', ' ')
                              .toUpperCase();
                          final prioridade = chamado.prioridade.toUpperCase();
                          final dateText = DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(chamado.dataAbertura);

                          return _buildAlertCard(
                            title: chamado.titulo,
                            subtitle: chamado.usuarioNome,
                            description: chamado.descricao,
                            badge: '$statusText • $prioridade',
                            dateText: dateText,
                            icon: Icons.support_agent,
                            cardColor: cardColor,
                            textColor: textColor,
                            primaryColor: primaryColor,
                            isDark: isDark,
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Excluir Chamado'),
                                  content: const Text(
                                    'Deseja realmente excluir este chamado?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        vm.deletarChamado(chamado.id);
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
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const feedbacks.FeedbacksPage(),
                ),
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
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_outline),
              ),
              label: 'Feedbacks',
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
                    Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
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

  void _mostrarSugestaoIa(
    BuildContext context,
    AlertasViewModel vm,
    Map<String, dynamic> feedback,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sugestão da IA'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: vm.gerarAnaliseFeedback(feedback),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Gerando sugestão de ação...'),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              );
            }

            final resultado = snapshot.data;
            final sugestao = resultado?['sugestao'] as String? ?? 'Sem sugestão disponível.';
            final resumo = resultado?['resumo'] as String? ?? '';
            final categoria = resultado?['categoria'] as String? ?? '';
            final urgencia = resultado?['urgencia']?.toString() ?? '';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resumo.isNotEmpty)
                    Text('Resumo:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  if (resumo.isNotEmpty) const SizedBox(height: 6),
                  if (resumo.isNotEmpty) Text(resumo),
                  if (categoria.isNotEmpty) const SizedBox(height: 10),
                  if (categoria.isNotEmpty) Text('Categoria: $categoria'),
                  if (urgencia.isNotEmpty) const SizedBox(height: 6),
                  if (urgencia.isNotEmpty) Text('Urgência: $urgencia'),
                  const SizedBox(height: 12),
                  Text('Sugestão:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),
                  Text(sugestao),
                ],
              ),
            );
          },
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

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required String description,
    required String badge,
    required String dateText,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
    required bool isDark,
    VoidCallback? onDelete,
    VoidCallback? onSuggestion,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              ((isDark ? 0.2 : 0.05) * 255).round(),
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: isDark ? Colors.red[300] : Colors.redAccent,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onSuggestion != null)
                  TextButton.icon(
                    onPressed: onSuggestion,
                    icon: Icon(
                      Icons.lightbulb_outline,
                      color: primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      'Sugestão IA',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateText,
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
