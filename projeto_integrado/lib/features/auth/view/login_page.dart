import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';
import '../../../core/theme_provider.dart';
import '../viewmodel/login_viewmodel.dart';
import '../../home/view/home_page_gestor.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import '../../home/view/home_page_usuario.dart';
import '../../profile/viewmodel/current_user_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final scaffoldColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFF9C1818);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = const Color(0xFF9C1818);
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.grey[600];

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: themeProvider.toggleTheme,
                        tooltip: isDark ? 'Modo claro' : 'Modo escuro',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 8),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.settings_input_hdmi,
                              color: Color(0xFF9C1818),
                              size: 56,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Copperfio',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fios e Cabos de Alumínio',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'BEM-VINDO(A) USUÁRIO!',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 18),
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade100,
                                hintText: 'Digite o seu email',
                                hintStyle: TextStyle(color: hintColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Color(0xFF9C1818),
                                ),
                              ),
                              validator: Validatorless.email('Email inválido'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _senhaController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade100,
                                hintText: 'Digite sua senha',
                                hintStyle: TextStyle(color: hintColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Color(0xFF9C1818),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF9C1818),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: Validatorless.required(
                                'Senha obrigatória',
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C1818),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;

                                  final loginViewModel = context
                                      .read<LoginViewModel>();
                                  final currentUserViewModel = context
                                      .read<CurrentUserViewModel>();

                                  try {
                                    final tipo = await loginViewModel.signIn(
                                      email: _emailController.text.trim(),
                                      senha: _senhaController.text.trim(),
                                    );

                                    // Carrega dados do usuário após login bem-sucedido
                                    if (context.mounted) {
                                      await currentUserViewModel.loadUserData(
                                        force: true,
                                      );
                                    }

                                    if (tipo == 'empresa') {
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const HomePageGestor(),
                                          ),
                                        );
                                      }
                                    } else if (tipo == 'cliente') {
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const HomePageUsuario(),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tipo de usuário inválido.',
                                            ),
                                          ),
                                        );
                                      }
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
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SignupPage(),
                                    ),
                                  ),
                                  child: Text(
                                    'Cadastrar-se',
                                    style: TextStyle(color: titleColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordPage(),
                                    ),
                                  ),
                                  child: Text(
                                    'Esqueceu a senha?',
                                    style: TextStyle(color: titleColor),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
