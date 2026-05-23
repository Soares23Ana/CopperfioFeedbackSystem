import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;
  final String code;

  const PasswordResetPage({super.key, required this.email, required this.code});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  final _senhaController = TextEditingController();
  final _confirmSenhaController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _codeController = TextEditingController(text: widget.code);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
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
              const Text(
                'Nova senha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  'Defina sua nova senha',
                                  style: TextStyle(
                                    color: Color(0xFF9C1818),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _codeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Código de verificação',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                TextFormField(
                                  controller: _senhaController,
                                  decoration: InputDecoration(
                                    hintText: 'Nova senha',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: Validatorless.multiple([
                                    Validatorless.required('Senha obrigatória'),
                                    Validatorless.min(8, 'Mínimo 8 caracteres'),
                                  ]),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmSenhaController,
                                  decoration: InputDecoration(
                                    hintText: 'Confirme a senha',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscureConfirmPassword,
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
                                const SizedBox(height: 18),
                                const Text(
                                  '''Dicas de senha:
- Ao menos 8 caracteres.
- Misture letras maiúsculas, minúsculas, números e símbolos.''',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 94, 89, 89),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 22),
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
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Recuperação por código não está mais disponível. Use a opção de envio de e-mail na página anterior.',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Redefinir senha',
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
