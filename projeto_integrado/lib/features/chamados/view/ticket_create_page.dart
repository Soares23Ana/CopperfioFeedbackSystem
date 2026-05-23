import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/features/chamados/viewmodel/chamados_viewmodel.dart';
import '../../../core/theme_provider.dart';

class TicketCreatePage extends StatefulWidget {
  const TicketCreatePage({super.key});

  @override
  State<TicketCreatePage> createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends State<TicketCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedPriority = 'media';
  String? _selectedCategory;
  final List<String> _priorities = ['baixa', 'media', 'alta'];
  final List<String> _categories = [
    'Técnico',
    'Administrativo',
    'Financeiro',
    'Outros',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendTicket() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final viewModel = Provider.of<ChamadosViewModel>(
          context,
          listen: false,
        );
        await viewModel.criarChamado(
          titulo: _titleController.text,
          descricao: _descriptionController.text,
          prioridade: _selectedPriority ?? 'media',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chamado criado com sucesso!')),
          );
          Navigator.maybePop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao criar chamado: $e')));
        }
      }
    }
  }

  void _cancel() {
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = const Color(0xFF8C1D18);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF3F1F6);
    final cardColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final fieldColor = isDark
        ? const Color(0xFF2B2B2B)
        : const Color(0xFFF7F7F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, isDark, themeProvider),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFormCard(
                  context,
                  isDark,
                  primaryColor,
                  cardColor,
                  fieldColor,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sendTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C1818),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Enviar Chamado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF1F1F1F)
                              : Colors.white,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFF9C1818),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: isDark
                              ? Colors.white
                              : const Color(0xFF9C1818),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF9C1818),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF9C1818),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Novo Chamado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                  ),
                  onPressed: themeProvider.toggleTheme,
                ),
              ],
            ),
          ),
          Container(
            height: 110,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF9C1818)),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 160,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        bottomLeft: Radius.circular(80),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Central de Chamados',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Descreva seu problema ou solicitação',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color cardColor,
    Color fieldColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Título do Chamado', isDark),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _titleController,
                hintText: 'Digite um título breve',
                suffixIcon: Icons.title,
                isDark: isDark,
                fieldColor: fieldColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('Categoria', isDark),
              const SizedBox(height: 8),
              _buildDropdownField(isDark, fieldColor),
              const SizedBox(height: 20),
              _buildFieldLabel('Prioridade', isDark),
              const SizedBox(height: 8),
              _buildPriorityField(isDark),
              const SizedBox(height: 20),
              _buildFieldLabel('Descrição', isDark),
              const SizedBox(height: 8),
              _buildDescriptionField(isDark, fieldColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData suffixIcon,
    required bool isDark,
    required Color fieldColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
        filled: true,
        fillColor: fieldColor,
        suffixIcon: Icon(
          suffixIcon,
          color: isDark ? Colors.white70 : const Color(0xFF9C1818),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(bool isDark, Color fieldColor) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: InputDecoration(
          hintText: 'Selecione a categoria',
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
          border: InputBorder.none,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? Colors.white70 : const Color(0xFF9C1818),
        ),
        dropdownColor: fieldColor,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        items: _categories
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecione a categoria';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPriorityField(bool isDark) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPriority,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      items: _priorities.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(
            priority.replaceFirst(priority[0], priority[0].toUpperCase()),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPriority = value;
        });
      },
      dropdownColor: isDark ? const Color(0xFF2B2B2B) : Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF2B2B2B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black26,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black26,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark, Color fieldColor) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Descreva o ocorrido';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Descreva em detalhes o ocorrido',
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      ),
    );
  }
}
