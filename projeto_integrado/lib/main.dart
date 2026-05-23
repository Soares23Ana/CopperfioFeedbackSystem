import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_providers.dart';
import 'app_widget.dart';
import 'package:projeto_integrado/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente PRIMEIRO
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✓ Arquivo .env carregado via filesystem');
  } catch (e) {
    debugPrint('⚠ Tentando carregar .env dos assets...');
    try {
      final envContent = await rootBundle.loadString('.env');
      // Se conseguiu ler, cria um mapa e seta manualmente
      final lines = envContent.split('\n');
      for (final line in lines) {
        if (line.contains('GOOGLE_API_KEY') && !line.startsWith('#')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            dotenv.env[key] = value;
            debugPrint('✓ GOOGLE_API_KEY carregada manualmente dos assets');
          }
        }
      }
    } catch (e2) {
      debugPrint('⚠ Erro: $e2 - IA pode não estar disponível');
    }
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }

  runApp(
    MultiProvider(providers: AppProviders.providers, child: const AppWidget()),
  );
}
