import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../../core/theme_provider.dart';
import '../../../core/manager_app_bar.dart';
import 'feedbacks_page.dart';
import 'alertas_page.dart' as alertas;
import '../../chamados/view/chamados_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String _selectedPeriod = 'semanal';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<DashboardViewModel>(context, listen: false);
      vm.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final primaryColor = const Color(0xFF8C1D18);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final lightCardColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFFBEAEA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ManagerAppBar(
        themeProvider: themeProvider,
        onBack: () => Navigator.pop(context),
        showProfileIcon: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'GESTOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vm.greeting,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Two small stats
              Row(
                children: [
                  Expanded(
                    child: _buildSmallStatCard(
                      title: 'TOTAL FEEDBACKS',
                      value: vm.feedbacks.toString(),
                      cardColor: cardColor,
                      textColor: textColor,
                      accentColor: primaryColor.withOpacity(0.16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallStatCard(
                      title: 'VAR. SATISFAÇÃO',
                      value: '${vm.satisfacao}%',
                      cardColor: cardColor,
                      textColor: primaryColor,
                      accentColor: primaryColor.withOpacity(0.16),
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildSatisfactionTrendCard(
                vm: vm,
                isDark: isDark,
                primaryColor: primaryColor,
                cardColor: cardColor,
                textColor: textColor,
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Radar Chart Card
              _buildRadarChartCard(
                vm: vm,
                isDark: isDark,
                primaryColor: primaryColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 16),

              // Donut Chart Card
              _buildCardContainer(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISTRIBUIÇÃO DE\nSENTIMENTO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(enabled: false),
                                  sections: vm.distribuicaoSentimento.entries
                                      .map((entry) {
                                        final color = entry.key == 'Negativo'
                                            ? primaryColor
                                            : entry.key == 'Positivo'
                                            ? Colors.green
                                            : Colors.grey[400]!;
                                        return PieChartSectionData(
                                          color: color,
                                          value: entry.value,
                                          radius: 12,
                                          showTitle: false,
                                        );
                                      })
                                      .toList(),
                                  centerSpaceRadius: 35,
                                  sectionsSpace: 2,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    vm.feedbacks.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vm.distribuicaoSentimento.entries.map((
                            entry,
                          ) {
                            final color = entry.key == 'Negativo'
                                ? primaryColor
                                : entry.key == 'Positivo'
                                ? Colors.green
                                : Colors.grey[400]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildLegendItem(
                                '${entry.key} ${entry.value.round()}%',
                                color,
                                isDark,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FeedbacksPage()),
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
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_outline),
              ),
              label: 'FEEDBACKS (${vm.feedbacks})',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.notifications_none),
              ),
              label: 'ALERTAS (${vm.alertas})',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.support_agent),
              ),
              label: 'CHAMADOS (${vm.chamados})',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String value,
    required Color cardColor,
    required Color textColor,
    required Color accentColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 42,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: textColor.withOpacity(0.75),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (icon != null)
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: textColor, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({
    required Widget child,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  void _navigateToFeedbacks({String? filter, String? search, String? title}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FeedbacksPage(initialFilter: filter, initialSearch: search),
      ),
    );
    if (title != null && title.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Filtrando: $title')));
    }
  }

  Widget _buildHorizontalBar(
    String label,
    int value,
    int maxValue,
    Color primaryColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    double percentage = value / maxValue;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 24,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChartCard({
    required DashboardViewModel vm,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
  }) {
    final radarLabels = [
      'DURABILIDADE',
      'EMBALAGEM',
      'PRECISÃO',
      'LOGÍSTICA',
      'ATENDIMENTO',
    ];
    final currentValues = radarLabels
        .map((label) => vm.radarMetrics[label] ?? 0.0)
        .toList();
    final previousValues = radarLabels
        .map((label) => vm.radarPreviousMetrics[label] ?? 0.0)
        .toList();

    return _buildCardContainer(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MÉTRICAS DE QUALIDADE COMPARATIVAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                Icons.bubble_chart,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                dataSets: [
                  RadarDataSet(
                    fillColor: primaryColor.withOpacity(0.18),
                    borderColor: primaryColor,
                    entryRadius: 3,
                    borderWidth: 2,
                    dataEntries: currentValues
                        .map((value) => RadarEntry(value: value))
                        .toList(),
                  ),
                  RadarDataSet(
                    fillColor: Colors.grey.withOpacity(0.16),
                    borderColor: Colors.grey[400]!,
                    entryRadius: 3,
                    borderWidth: 2,
                    dataEntries: previousValues
                        .map((value) => RadarEntry(value: value))
                        .toList(),
                  ),
                ],
                radarBorderData: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
                gridBorderData: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
                tickBorderData: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
                tickCount: 4,
                ticksTextStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                  fontSize: 8,
                ),
                getTitle: (index, angle) =>
                    RadarChartTitle(text: radarLabels[index], angle: angle),
                titleTextStyle: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 11,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Compare as métricas de qualidade para identificar tendências.',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem('Semestre Atual', primaryColor, isDark),
              const SizedBox(width: 16),
              _buildLegendItem('Semestre Anterior', Colors.grey[400]!, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionTrendCard({
    required DashboardViewModel vm,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    required String selectedPeriod,
    required ValueChanged<String> onPeriodChanged,
  }) {
    final rawTrendValues = vm.satisfacaoTrendByPeriod[selectedPeriod] ?? [];
    final rawTrendLabels = vm.satisfacaoLabelsByPeriod[selectedPeriod] ?? [];
    final trendValues = rawTrendValues.isNotEmpty
        ? rawTrendValues
        : List<double>.filled(5, 0.0);
    final trendLabels = rawTrendLabels.isNotEmpty
        ? rawTrendLabels
        : ['01/00', '02/00', '03/00', '04/00', '05/00'];
    final isRising =
        trendValues.length >= 2 && trendValues.last >= trendValues.first;
    final chartColor = isRising ? Colors.green : Colors.red;
    final displayMaxY = max(
      100.0,
      trendValues.isNotEmpty ? trendValues.reduce(max).ceilToDouble() : 100.0,
    );

    return _buildCardContainer(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVOLUÇÃO DA SATISFAÇÃO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedPeriod == 'semanal'
                        ? 'Tendência do CSAT nos últimos 7 dias'
                        : selectedPeriod == 'mensal'
                        ? 'Tendência do CSAT nos últimos 30 dias'
                        : 'Tendência do CSAT nos últimos 12 meses',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.show_chart,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPeriodButton(
                'semanal',
                '7d',
                selectedPeriod,
                onPeriodChanged,
                primaryColor,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildPeriodButton(
                'mensal',
                '30d',
                selectedPeriod,
                onPeriodChanged,
                primaryColor,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildPeriodButton(
                'anual',
                '1a',
                selectedPeriod,
                onPeriodChanged,
                primaryColor,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => cardColor,
                    tooltipRoundedRadius: 12,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.toInt();
                        final label = index >= 0 && index < trendLabels.length
                            ? trendLabels[index]
                            : '';
                        return LineTooltipItem(
                          '$label\n${spot.y.toStringAsFixed(0)}%',
                          TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: displayMaxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trendLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            trendLabels[index],
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 70,
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left: 8, bottom: 6),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (_) => 'Meta 70%',
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: trendValues
                        .asMap()
                        .entries
                        .map(
                          (entry) => FlSpot(entry.key.toDouble(), entry.value),
                        )
                        .toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        chartColor.withOpacity(0.9),
                        chartColor.withOpacity(0.4),
                      ],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: chartColor,
                            strokeWidth: 1.8,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          chartColor.withOpacity(0.24),
                          chartColor.withOpacity(0.04),
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
    );
  }

  Widget _buildLegendItem(String text, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(
    String value,
    String label,
    String currentValue,
    ValueChanged<String> onChanged,
    Color primaryColor,
    bool isDark,
  ) {
    final selected = value == currentValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? primaryColor
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected
                ? primaryColor
                : (isDark ? Colors.grey[300] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildVerticalBarGroup(
    int x,
    double y,
    Color color, {
    bool isHighlighted = false,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 35,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Colors.transparent,
          ),
        ),
      ],
      showingTooltipIndicators: isHighlighted ? [0] : [],
    );
  }
}
