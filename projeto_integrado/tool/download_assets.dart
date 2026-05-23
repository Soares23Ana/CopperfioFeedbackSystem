// Script to download site images into assets/images/
// Run with: dart run tool/download_assets.dart

import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final urls = <String>[
    'https://www.copperfio.com.br/img/home/img_04.png',
    'https://www.copperfio.com.br/img/empresa/copperfio.jpg',
    'https://www.copperfio.com.br/img/home/img_02.png',
    'https://www.copperfio.com.br/img/home/img_03.png',
    'https://i.imgur.com/q4kgwSC.jpg',
    'https://i.imgur.com/6OJihLQ.jpg',
    'https://i.imgur.com/Yx8aKAH.jpg',
    'https://i.imgur.com/hOvo6H3.jpg',
    'https://i.imgur.com/4CV4yP7.jpg',
    'https://i.imgur.com/nTYMP1r.jpg',
    'https://i.imgur.com/VK0Z1ai.jpg',
    'https://i.imgur.com/QZq5vUq.jpg',
    'https://i.imgur.com/JJE5pLu.jpg',
    'https://i.imgur.com/hMQbvXv.jpg',
    'https://i.imgur.com/hMQbvXv.jpg',
  ];

  final dir = Directory('assets/images');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  for (final url in urls) {
    final uri = Uri.parse(url);
    final filename = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : uri.host;
    final file = File('${dir.path}/$filename');

    if (file.existsSync()) {
      stdout.writeln('Skipping existing: $filename');
      continue;
    }

    try {
      stdout.writeln('Downloading $url');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        await file.writeAsBytes(resp.bodyBytes);
        stdout.writeln('Saved: ${file.path}');
      } else {
        stdout.writeln('Failed (${resp.statusCode}) for $url');
      }
    } catch (e) {
      stdout.writeln('Error downloading $url -> $e');
    }
  }

  stdout.writeln(
    'All done. Remember to run `flutter pub get` if you add assets.',
  );
}
