import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String? _cachedApiKey;

  static String get googleApiKey {
    if (_cachedApiKey != null) return _cachedApiKey!;

    const buildKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');
    if (buildKey.isNotEmpty) {
      _cachedApiKey = buildKey;
      debugPrint('✓ IA configurada via --dart-define');
      return buildKey;
    }

    final envKey = dotenv.env['GOOGLE_API_KEY']?.trim() ?? '';
    if (envKey.isNotEmpty) {
      _cachedApiKey = envKey;
      debugPrint('✓ IA configurada via .env');
      return envKey;
    }

    debugPrint('✗ Nenhuma chave GOOGLE_API_KEY encontrada');
    _cachedApiKey = '';
    return '';
  }

  static bool get hasGoogleApiKey => googleApiKey.isNotEmpty;

  static String get missingApiKeyMessage {
    return 'O assistente de IA não está configurado. Defina GOOGLE_API_KEY no .env ou use --dart-define=GOOGLE_API_KEY=SEU_TOKEN.';
  }
}
