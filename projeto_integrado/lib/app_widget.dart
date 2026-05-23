import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/features/splash/view/splash_intro_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'P1 - Desenvolvimento Mobile',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const SplashIntroPage(),
        );
      },
    );
  }
}
