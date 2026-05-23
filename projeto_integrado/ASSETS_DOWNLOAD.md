Uso

Este projeto inclui um script que baixa as imagens usadas no carrossel e no catálogo diretamente do site da Copperfio para `assets/images/`.

Passos:

1. Certifique-se de que o pacote `http` esteja disponível (já está listado em `pubspec.yaml`).

2. Executar:

```bash
flutter pub get
dart run tool/download_assets.dart
```

3. Depois que os arquivos estiverem em `assets/images/`, execute:

```bash
flutter clean
flutter pub get
flutter run
```

Observações:
- O script ignora arquivos já existentes em `assets/images/`.
- Se preferir baixar manualmente, coloque os arquivos listados abaixo em `assets/images/`:
  - img_04.png
  - copperfio.jpg
  - img_02.png
  - img_03.png
  - 01g.jpg ... 11g.jpg
