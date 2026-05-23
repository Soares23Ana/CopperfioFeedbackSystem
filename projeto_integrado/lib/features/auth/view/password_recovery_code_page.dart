import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';
import '../viewmodel/signup_viewmodel.dart';
import 'password_reset_page.dart';

class PasswordRecoveryCodePage extends StatefulWidget {
  final String email;

  const PasswordRecoveryCodePage({super.key, required this.email});

  @override
  State<PasswordRecoveryCodePage> createState() =>
      _PasswordRecoveryCodePageState();
}

class _PasswordRecoveryCodePageState extends State<PasswordRecoveryCodePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();

  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _resendCode() async {
    if (_remainingSeconds > 0) return;

    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<SignupViewModel>();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Digite o email antes de reenviar o código.')),
      );
      return;
    }

    try {
      await viewModel.redefinirSenha(email);
      _startCountdown();
      _codeController.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Novo código enviado para o e-mail.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao reenviar código: ${error.toString()}')),
      );
    }
  }

  String get _timerLabel {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recuperação de Senha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.settings_input_hdmi,
                                    size: 64,
                                    color: Color(0xFF9C1818),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Center(
                                  child: Text(
                                    'Copperfio',
                                    style: TextStyle(
                                      color: Color(0xFF9C1818),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Fios e Cabos de Alumínio',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'Recuperação de Senha',
                                  style: TextStyle(
                                    color: Color(0xFF9C1818),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Email cadastrado:',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Digite o seu email cadastrado',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: Validatorless.email(
                                    'Email inválido',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Digite o código:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Expira em $_timerLabel',
                                      style: TextStyle(
                                        color: _remainingSeconds > 10
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _codeController,
                                  decoration: InputDecoration(
                                    hintText: 'Digite o código de verificação',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: Validatorless.required(
                                    'Código obrigatório',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _remainingSeconds == 0
                                        ? _resendCode
                                        : null,
                                    child: Text(
                                      _remainingSeconds == 0
                                          ? 'Reenviar código'
                                          : 'Reenviar em $_timerLabel',
                                      style: TextStyle(
                                        color: _remainingSeconds == 0
                                            ? const Color(0xFFDD4E41)
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Se o código estiver correto, você poderá seguir para a página de redefinição de senha.',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 77, 73, 73),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B0000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!_formKey.currentState!.validate()) return;

                                      final messenger = ScaffoldMessenger.of(context);
                                      final navigator = Navigator.of(context);
                                      final viewModel = context.read<SignupViewModel>();
                                      final email = _emailController.text.trim();
                                      final code = _codeController.text.trim();

                                      final exists = await viewModel.existeEmail(email);
                                      if (!mounted) return;

                                      if (!exists) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'E-mail não encontrado. Cadastre-se primeiro.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (_) => PasswordResetPage(
                                            email: email,
                                            code: code,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Continuar',
                                      style: TextStyle(
                                        color: Colors.white,
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
