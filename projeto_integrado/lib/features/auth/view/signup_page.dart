import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';
import '../../../core/cnpj_input_formatter.dart';
import '../../../data/models/usuario_model.dart';
import '../viewmodel/signup_viewmodel.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nomeController;
  late final TextEditingController _empresaController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _celularEmailController;
  late final TextEditingController _senhaController;
  late final TextEditingController _confirmSenhaController;
  bool _obscureSenha = true;
  bool _obscureConfirmSenha = true;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nomeController = TextEditingController();
    _empresaController = TextEditingController();
    _cnpjController = TextEditingController();
    _celularEmailController = TextEditingController();
    _senhaController = TextEditingController();
    _confirmSenhaController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _empresaController.dispose();
    _cnpjController.dispose();
    _celularEmailController.dispose();
    _senhaController.dispose();
    _confirmSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9C1818),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.settings_input_hdmi,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Center(
                                  child: Text(
                                    'Copperfio',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'Fios e Cabos de Alumínio',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Nome Completo
                                TextFormField(
                                  controller: _nomeController,
                                  decoration: InputDecoration(
                                    hintText: 'Nome completo',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  validator: Validatorless.required(
                                    'Nome completo obrigatório',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // E-mail
                                TextFormField(
                                  controller: _celularEmailController,
                                  decoration: InputDecoration(
                                    hintText: 'Digite seu e-mail',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.email,
                                      color: Color(0xFF9C1818),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  validator: Validatorless.multiple([
                                    Validatorless.required(
                                      'E-mail obrigatório',
                                    ),
                                    Validatorless.email('E-mail inválido'),
                                  ]),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),
                                // Senha
                                TextFormField(
                                  controller: _senhaController,
                                  decoration: InputDecoration(
                                    hintText: 'Senha',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureSenha
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(0xFF9C1818),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureSenha = !_obscureSenha;
                                        });
                                      },
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  obscureText: _obscureSenha,
                                  validator: Validatorless.multiple([
                                    Validatorless.required('Senha obrigatória'),
                                    (value) {
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          value.length < 8) {
                                        return 'Mínimo 8 caracteres';
                                      }
                                      return null;
                                    },
                                  ]),
                                ),
                                const SizedBox(height: 12),
                                // Confirmação de senha
                                TextFormField(
                                  controller: _confirmSenhaController,
                                  decoration: InputDecoration(
                                    hintText: 'Confirme a senha',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmSenha
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(0xFF9C1818),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmSenha =
                                              !_obscureConfirmSenha;
                                        });
                                      },
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  obscureText: _obscureConfirmSenha,
                                  validator: Validatorless.multiple([
                                    Validatorless.required(
                                      'Confirmação obrigatória',
                                    ),
                                    Validatorless.compare(
                                      _senhaController,
                                      'As senhas não coincidem',
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: 12),
                                // Nome da empresa
                                TextFormField(
                                  controller: _empresaController,
                                  decoration: InputDecoration(
                                    hintText: 'Nome da empresa',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  validator: Validatorless.required(
                                    'Nome da empresa obrigatório',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // CNPJ
                                TextFormField(
                                  controller: _cnpjController,
                                  decoration: InputDecoration(
                                    hintText: 'CNPJ',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'CNPJ obrigatório';
                                    }
                                    final digits = value.replaceAll(RegExp(r'\D'), '');
                                    if (digits.length != 14) {
                                      return 'CNPJ deve conter 14 números';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(14),
                                    CnpjInputFormatter(),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Botão Cadastre-se
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!_formKey.currentState!.validate())
                                        return;

                                      final usuario = UsuarioModel(
                                        nome: _nomeController.text,
                                        email: _celularEmailController.text
                                            .trim(),
                                        senha: _senhaController.text,
                                        endereco: '',
                                        dataNascimento: '',
                                        genero: '',
                                        empresa: _empresaController.text,
                                        cnpj: CnpjInputFormatter.digitsOnly(
                                          _cnpjController.text,
                                        ),
                                        role: 'usuario',
                                      );

                                      try {
                                        final viewModel = context
                                            .read<SignupViewModel>();
                                        await viewModel.cadastrarUsuario(
                                          usuario,
                                        );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Cadastro realizado com sucesso!',
                                              ),
                                            ),
                                          );

                                          Navigator.pop(context);
                                        }
                                      } catch (error) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(error.toString()),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Cadastrar',
                                      style: TextStyle(
                                        color: const Color(0xFF9C1818),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
