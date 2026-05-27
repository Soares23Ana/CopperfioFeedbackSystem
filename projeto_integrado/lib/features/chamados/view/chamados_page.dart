import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projeto_integrado/data/models/chamado_model.dart';
import 'package:projeto_integrado/features/chamados/view/chamado_detail_page.dart';
import '../viewmodel/chamados_viewmodel.dart';
import '../../../core/theme_provider.dart';
import '../../../core/manager_app_bar.dart';
import '../../dashboard/view/dashboard_page.dart';
import '../../dashboard/view/feedbacks_page.dart';
import '../../dashboard/view/alertas_page.dart' as alertas;

class ChamadosPage extends StatefulWidget {
  const ChamadosPage({super.key});

  @override
  State<ChamadosPage> createState() => _ChamadosPageState();
}

class _ChamadosPageState extends State<ChamadosPage> {
  int _currentIndex = 3; // Chamados is index 3

  void _openChamadoDetail(BuildContext context, ChamadoModel chamado) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChamadoDetailPage(chamado: chamado)),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChamadosViewModel>(context);
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF5EBEB),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: primaryColor.withAlpha((0.1 * 255).round()),
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar chamados...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<ChamadoModel>>(
              stream: vm.obterChamadosDaEmpresa(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar chamados: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chamados = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Chamados',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
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
                                  ? primaryColor.withAlpha((0.2 * 255).round())
                                  : const Color(0xFFF2D7D5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '${chamados.length} REGISTRO${chamados.length != 1 ? 'S' : ''}',
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
                    const SizedBox(height: 24),
                    if (chamados.isEmpty)
                      Center(
                        child: Text(
                          'Nenhum chamado encontrado.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: chamados.length,
                          itemBuilder: (context, index) {
                            final chamado = chamados[index];
                            final statusText = chamado.status
                                .replaceAll('_', ' ')
                                .toUpperCase();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(4),
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
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    chamado.titulo,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? primaryColor
                                                              .withAlpha(
                                                                (0.15 * 255)
                                                                    .round(),
                                                              )
                                                        : const Color(
                                                            0xFFF2D7D5,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    statusText,
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (chamado.hasAnaliseIa && chamado.hasEmailTemplate)
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 2),
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF29A745),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                const SizedBox(width: 8),
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text(
                                                            'Excluir Chamado',
                                                          ),
                                                          content: const Text(
                                                            'Deseja realmente excluir este chamado?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                'Cancelar',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                vm.deletarChamado(
                                                                  chamado.id,
                                                                );
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: const Text(
                                                                'Excluir',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
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
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              chamado.descricao,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[700],
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _buildInfoRow(
                                              Icons.business,
                                              'Empresa: ${chamado.empresaNome}',
                                              isDark,
                                              primaryColor,
                                            ),
                                            const SizedBox(height: 8),
                                            _buildInfoRow(
                                              Icons.person_outline,
                                              'Usuário: ${chamado.usuarioNome}',
                                              isDark,
                                              primaryColor,
                                            ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _openChamadoDetail(
                                                      context,
                                                      chamado,
                                                    ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'VER DETALHES',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward,
                                                      size: 16,
                                                    ),
                                                  ],
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
                MaterialPageRoute(builder: (_) => const FeedbacksPage()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const alertas.AlertasPage()),
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
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.notifications_none),
              ),
              label: 'Alertas',
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
                    Icons.support_agent,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              label: 'Chamados',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    bool isDark,
    Color primaryColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[800],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
