import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/data/models/product_model.dart';
import 'package:projeto_integrado/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final primaryRed = const Color(0xFF9C1818);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ficha Técnica',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: Container(
                  color: cardColor,
                  child: product.imageUrl.startsWith('assets/')
                      ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                      : Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: Colors.grey.shade400,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SelectableText(
              product.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              product.subtitle,
              style: TextStyle(fontSize: 16, color: textSecondary),
            ),
            const SizedBox(height: 24),
            if (product.description.isNotEmpty) ...[
              Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryRed,
                ),
              ),
              const SizedBox(height: 12),
              ...product.description
                  .split('\n\n')
                  .map(
                    (paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SelectableText(
                        paragraph,
                        style: TextStyle(
                          fontSize: 14,
                          color: textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
            ],
            if (product.specs.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor ?? Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Especificações Técnicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...product.specs.map(
                      (spec) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                color: textPrimary,
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                spec,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textPrimary,
                                  height: 1.4,
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
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openPdf(context),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  'Baixar Ficha Técnica',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? primaryRed.withOpacity(0.15)
                    : primaryRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? primaryRed.withOpacity(0.4)
                      : primaryRed.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informação',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque em "Baixar Ficha Técnica" para salvar o PDF diretamente no diretório de downloads do dispositivo. '
                    'O arquivo estará disponível no app Arquivos/Downloads.',
                    style: TextStyle(fontSize: 13, color: textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Iniciando download da ficha técnica...'),
        duration: Duration(seconds: 2),
      ),
    );

    final pdfUrl = product.effectivePdfUrl;
    if (pdfUrl.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('PDF não disponível para este produto.')),
      );
      return;
    }

    if (pdfUrl.startsWith('assets/')) {
      final file = await _downloadAssetPdf(context, pdfUrl);
      if (file != null && await file.exists()) {
        final opened = await launchUrl(Uri.file(file.path));
        if (!opened) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Arquivo salvo em: ${file.path}'),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('✓ Ficha técnica aberta: ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Erro: Arquivo não foi salvo corretamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    // For remote PDFs, download to device Downloads when possible.
    if (pdfUrl.startsWith('http')) {
      final file = await _downloadRemotePdf(context, pdfUrl);
      if (file != null && await file.exists()) {
        final opened = await launchUrl(Uri.file(file.path));
        if (!opened) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Arquivo salvo em: ${file.path}'),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('✓ Ficha técnica aberta: ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar a ficha técnica.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
  }

  Future<File?> _downloadAssetPdf(
    BuildContext context,
    String assetPath,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final originalName = assetPath.split('/').last;
      final nameWithoutExt = originalName.replaceAll('.pdf', '');
      final fileName =
          '${nameWithoutExt}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Prefer opening native save dialog on Android so user can choose Downloads
      final tempDir = await getApplicationDocumentsDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.create(recursive: true);
      await tempFile.writeAsBytes(bytes, flush: true);
      if (Platform.isAndroid) {
        try {
          final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
          await FlutterFileDialog.saveFile(params: params);
          messenger.showSnackBar(
            SnackBar(
              content: Text('Selecione onde salvar a ficha técnica.'),
              duration: const Duration(seconds: 3),
            ),
          );
          try {
            await NotificationService().showDownloadNotification(
              fileName: fileName,
              filePath: tempFile.path,
            );
          } catch (_) {}
        } catch (_) {}
        return tempFile;
      }

      final downloadDir = await _getDownloadDirectory();
      final file = File('${downloadDir.path}/$fileName');
      try {
        await file.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {}

      if (await file.exists()) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('✓ Ficha técnica salva em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        try {
          await NotificationService().showDownloadNotification(
            fileName: fileName,
            filePath: file.path,
          );
        } catch (_) {
          // Não impede o sucesso do salvamento.
        }

        return file;
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return null;
  }

  Future<File?> _downloadRemotePdf(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar PDF: HTTP ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      final originalName = url.split('/').last;
      final nameWithoutExt = originalName.replaceAll(
        RegExp(r'\.(pdf)', caseSensitive: false),
        '',
      );
      final fileName =
          '${nameWithoutExt}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // On Android, prefer showing the native save dialog (SAF) so the user
      // can choose to save the file directly into public Downloads on their
      // physical device. We write a temporary file and invoke the dialog.
      final tempDir = await getApplicationDocumentsDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.create(recursive: true);
      await tempFile.writeAsBytes(resp.bodyBytes, flush: true);

      if (Platform.isAndroid) {
        try {
          final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
          await FlutterFileDialog.saveFile(params: params);
          messenger.showSnackBar(
            SnackBar(
              content: Text('Selecione onde salvar a ficha técnica.'),
              duration: const Duration(seconds: 3),
            ),
          );
          try {
            await NotificationService().showDownloadNotification(
              fileName: fileName,
              filePath: tempFile.path,
            );
          } catch (_) {}
        } catch (_) {
          // ignore
        }
        return tempFile;
      }

      final downloadDir = await _getDownloadDirectory();
      final file = File('${downloadDir.path}/$fileName');
      try {
        await file.create(recursive: true);
        await file.writeAsBytes(resp.bodyBytes, flush: true);
      } catch (_) {}

      if (await file.exists()) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('✓ Ficha técnica salva em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        try {
          await NotificationService().showDownloadNotification(
            fileName: fileName,
            filePath: file.path,
          );
        } catch (_) {}

        return file;
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return null;
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final androidPublicDir = Directory('/storage/emulated/0/Download');
      if (await androidPublicDir.exists()) {
        return androidPublicDir;
      }

      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final rootPath = externalDir.path.split('/Android').first;
          final downloadDir = Directory('$rootPath/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
      } catch (_) {
        // Ignora falha e tenta outras pastas.
      }

      try {
        final downloadDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (downloadDirs != null && downloadDirs.isNotEmpty) {
          final downloadDir = downloadDirs.first;
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
      } catch (_) {
        // Ignora falha e usa documentos.
      }
    }

    return await getApplicationDocumentsDirectory();
  }
}
