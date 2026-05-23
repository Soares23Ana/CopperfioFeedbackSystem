import 'package:flutter/material.dart';
import 'package:projeto_integrado/services/gemini_service.dart';

class FeedbackAnalysisWidget extends StatefulWidget {
  const FeedbackAnalysisWidget({super.key});

  @override
  State<FeedbackAnalysisWidget> createState() => _FeedbackAnalysisWidgetState();
}

class _FeedbackAnalysisWidgetState extends State<FeedbackAnalysisWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  Map<String, dynamic>? _analise;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _enviarFeedback() async {
    final texto = _feedbackController.text.trim();
    if (texto.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, digite um feedback';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analise = null;
    });

    try {
      final resultado = await _geminiService.analisarFeedback(texto);
      setState(() {
        _analise = resultado;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Digite seu feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _enviarFeedback,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Enviar Feedback'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_analise != null) ...[
              const Text(
                'Análise do Feedback:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildAnaliseCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnaliseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sentimento: ${_analise!['sentimento']}'),
            Text('Categoria: ${_analise!['categoria']}'),
            Text('Urgência: ${_analise!['urgencia']}/5'),
            const SizedBox(height: 8),
            Text('Resumo: ${_analise!['resumo']}'),
            const SizedBox(height: 8),
            Text('Sugestão: ${_analise!['sugestao']}'),
          ],
        ),
      ),
    );
  }
}