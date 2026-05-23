import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/features/auth/view/login_page.dart';
import 'package:projeto_integrado/features/home/view/home_page_gestor.dart';
import 'package:projeto_integrado/features/home/view/home_page_usuario.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';

class SplashIntroPage extends StatefulWidget {
  const SplashIntroPage({super.key});

  @override
  State<SplashIntroPage> createState() => _SplashIntroPageState();
}

class _SplashIntroPageState extends State<SplashIntroPage> {
  bool _navigated = false;

  Future<void> _goToInitialRoute() async {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;

    final viewModel = context.read<CurrentUserViewModel>();
    await viewModel.loadUserData();

    final currentUser = viewModel.currentUser;
    if (currentUser == null) {
      _goToLoginPage();
      return;
    }

    if (!mounted) return;
    final tipo = viewModel.userType;

    if (tipo == 'empresa') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageGestor()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageUsuario()),
      );
    }
  }

  void _goToLoginPage() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2500), _goToInitialRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9C1818),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.settings_input_hdmi, color: Colors.white, size: 92),
            SizedBox(height: 24),
            Text(
              'Copperfio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fios e Cabos de Alumínio',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
