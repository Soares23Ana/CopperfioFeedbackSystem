import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/cep_input_formatter.dart';
import 'package:projeto_integrado/core/phone_input_formatter.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';
import 'package:projeto_integrado/services/firestore_service.dart';
import 'package:projeto_integrado/services/auth_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _empresaController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _estadoController = TextEditingController(text: 'SP');
  final _cidadeController = TextEditingController(text: 'São Paulo');
  final _cepController = TextEditingController();
  final _foneController = TextEditingController();
  final _emailController = TextEditingController();
  final _observacoesController = TextEditingController();
  final Map<String, String> _initialUserData = {};
  bool _triedSubmit = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  Future<void> _loadUserData() async {
    final userViewModel = context.read<CurrentUserViewModel>();
    await userViewModel.loadUserData();
    final data = userViewModel.userData;
    if (data == null) return;

    setState(() {
      _nomeController.text = data['nome'] as String? ?? '';
      _empresaController.text = data['empresa'] as String? ?? '';
      _enderecoController.text = data['endereco'] as String? ?? '';
      _bairroController.text = data['bairro'] as String? ?? '';
      _estadoController.text = data['estado'] as String? ?? 'SP';
      _cidadeController.text = data['cidade'] as String? ?? 'São Paulo';
      _cepController.text = CepInputFormatter.format(
        data['cep'] as String? ?? '',
      );
      _foneController.text = PhoneInputFormatter.format(
        data['telefone'] as String? ?? '',
      );
      _emailController.text = data['email'] as String? ?? '';
      _initialUserData
        ..clear()
        ..addAll({
          'nome': _nomeController.text,
          'empresa': _empresaController.text,
          'endereco': _enderecoController.text,
          'bairro': _bairroController.text,
          'estado': _estadoController.text,
          'cidade': _cidadeController.text,
          'cep': _cepController.text,
          'fone': _foneController.text,
          'email': _emailController.text,
        });
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _empresaController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    _cepController.dispose();
    _foneController.dispose();
    _emailController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    setState(() {
      _triedSubmit = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = _auth.currentUserId;

    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: preciso de login para salvar seu pedido.'),
        ),
      );
      return;
    }

    try {
      await _firestore.criarPedido(
        userId: uid,
        userEmail: _auth.getCurrentUser()?.email?.trim().toLowerCase(),
        empresaId: 'copperfio',
        nome: _nomeController.text.trim(),
        empresa: _empresaController.text.trim(),
        endereco: _enderecoController.text.trim(),
        bairro: _bairroController.text.trim(),
        estado: _estadoController.text.trim(),
        cidade: _cidadeController.text.trim(),
        cep: _cepController.text.trim(),
        fone: PhoneInputFormatter.digitsOnly(_foneController.text),
        email: _emailController.text.trim(),
        observacoes: _observacoesController.text.trim(),
        items: [],
        total: '',
        summary: _observacoesController.text.trim().isNotEmpty
            ? _observacoesController.text.trim()
            : 'Pedido de orçamento via formulário',
        details: _observacoesController.text.trim(),
        notes: 'Pedido enviado pelo cliente ${_nomeController.text.trim()}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação enviada e salva com sucesso!'),
        ),
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar solicitação: ${e.toString()}')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _nomeController.text = _initialUserData['nome'] ?? '';
      _empresaController.text = _initialUserData['empresa'] ?? '';
      _enderecoController.text = _initialUserData['endereco'] ?? '';
      _bairroController.text = _initialUserData['bairro'] ?? '';
      _estadoController.text = _initialUserData['estado'] ?? 'SP';
      _cidadeController.text = _initialUserData['cidade'] ?? 'São Paulo';
      _cepController.text = _initialUserData['cep'] ?? '';
      _foneController.text = _initialUserData['fone'] ?? '';
      _emailController.text = _initialUserData['email'] ?? '';
      _observacoesController.clear();
      _triedSubmit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
        // COR DA SETA: Definida via iconTheme
        iconTheme: const IconThemeData(color: Colors.white),
        // COR DO TEXTO: Definida via titleTextStyle
        title: const Text(
          'Contato',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.contact_mail, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Copperfio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Fios e Cabos de Alumínio',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: _formKey,
                autovalidateMode: _triedSubmit
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Para solicitar orçamentos ou pedidos preencha nosso formulário informando-nos o tipo de cabo e a metragem.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Nome',
                      _nomeController,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Digite seu nome'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Empresa', _empresaController),
                    const SizedBox(height: 12),
                    _buildTextField('Endereço', _enderecoController),
                    const SizedBox(height: 12),
                    _buildTextField('Bairro', _bairroController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField('Estado', _estadoController),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField('Cidade', _cidadeController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'CEP',
                            _cepController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                              CepInputFormatter(),
                            ],
                            validator: (value) {
                              final cep = value?.trim() ?? '';
                              if (cep.isEmpty) {
                                return 'Digite seu CEP';
                              }
                              if (CepInputFormatter.digitsOnly(cep).length !=
                                  8) {
                                return 'CEP inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            'Fone',
                            _foneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                              PhoneInputFormatter(),
                            ],
                            validator: (value) {
                              final phone = PhoneInputFormatter.digitsOnly(
                                value?.trim() ?? '',
                              );
                              if (phone.isEmpty) {
                                return 'Digite seu telefone';
                              }
                              if (phone.length < 10) {
                                return 'Telefone inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'E-mail',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite seu e-mail';
                        }
                        if (!RegExp(
                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Observações (tipo de cabo + metragem)',
                      _observacoesController,
                      minLines: 4,
                      maxLines: 8,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _enviarFormulario,
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Enviar solicitação',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpar formulário'),
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
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obrigatório';
            }
            return null;
          },
      minLines: minLines,
      maxLines: maxLines,
      onChanged: (_) {
        if (_triedSubmit) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: _triedSubmit && controller.text.trim().isEmpty ? '*' : null,
        suffixStyle: const TextStyle(color: Colors.red),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
