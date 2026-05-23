# projeto_integrado

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuração da IA

A IA do app usa o Google Gemini e precisa de uma chave de API. Para configurar:

- Copie o arquivo ` .env.example` para `.env` na raiz do projeto.
- Defina sua chave como:

```env
GOOGLE_API_KEY=SEU_TOKEN_AQUI
```

- Se preferir, execute o app com a variável de ambiente em tempo de execução:

```bash
flutter run --dart-define=GOOGLE_API_KEY=SEU_TOKEN_AQUI
```

- A IA é usada no chat do assistente e nas análises de feedback do dashboard.

Se a chave não estiver configurada, o app mostrará uma mensagem de erro clara informando como ativar a IA.
