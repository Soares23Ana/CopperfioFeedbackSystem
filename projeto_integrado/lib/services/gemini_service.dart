import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:projeto_integrado/config.dart';

class GeminiService {
  GenerativeModel? _model;

  GeminiService() {
    final apiKey = Config.googleApiKey;
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Você é o Analista de RH da Copperfio. Analise feedbacks de fábrica e escritório. Retorne apenas JSON puro.',
        ),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> analisarFeedback(String texto) async {
    final prompt = '''
Analise este feedback e retorne um JSON com esta exata estrutura:
{
  "sentimento": "positivo|neutro|negativo",
  "categoria": "segurança|clima|processo|qualidade|outro",
  "urgencia": 1-5,
  "resumo": "resumo breve do feedback em 1 linha",
  "sugestao": "sugestão de ação recomendada"
}

Feedback: "$texto"
''';

    final response = await _runPrompt(prompt);
    final resultado = _parseJsonResponse(response);
    _validarResposta(resultado);
    return resultado;
  }

  Future<Map<String, dynamic>> gerarRelatorio(
    List<Map<String, dynamic>> feedbacks, {
    required String topicoFoco,
    required double notaMedia,
    required int totalPositivos,
    required int totalNegativos,
    required int totalNeutros,
    required double mediaItem1,
    required double mediaItem2,
    required double mediaItem3,
    required double mediaItem4,
    required double mediaItem5,
    required double mediaItem6,
    required double mediaItem7,
    required double mediaItem8,
    String tabelaClientes = '',
  }) async {
    final feedbacksTexto = feedbacks
        .map((f) {
          final titulo = f['titulo'] as String? ?? '';
          final mensagem = f['mensagem'] as String? ?? f['descricao'] as String? ?? '';
          final nota = f['notaMedia']?.toString() ?? 'N/A';
          final tags = (f['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          return 'Nota: $nota | Tags: ${tags.join(", ")} | Título: $titulo | Mensagem: $mensagem';
        })
        .join('\n\n');

    // Montar mini-tabela com médias dos itens
    final tabelaItens = '''
$tabelaClientes

MÉDIA DE NOTAS POR ITEM (com base nos feedbacks analisados):
- Item 1 (Qualidade do Produto): ${mediaItem1.toStringAsFixed(2)}
- Item 2 (Adequação da Embalagem): ${mediaItem2.toStringAsFixed(2)}
- Item 3 (Prazo de Entrega): ${mediaItem3.toStringAsFixed(2)}
- Item 4 (Conhecimento Técnico): ${mediaItem4.toStringAsFixed(2)}
- Item 5 (Cordialidade e Empatia): ${mediaItem5.toStringAsFixed(2)}
- Item 6 (Qualidade do Suporte Técnico): ${mediaItem6.toStringAsFixed(2)}
- Item 7 (Satisfação Geral): ${mediaItem7.toStringAsFixed(2)}
- Item 8 (Observações Complementares): ${mediaItem8.toStringAsFixed(2)}
''';

    final prompt = '''
Você é um consultor analista de RH e Qualidade da Copperfio. Analise rigorosamente os seguintes feedbacks de clientes e colaboradores.

DADOS REAIS CALCULADOS:
- Total de Feedbacks Analisados: ${feedbacks.length}
- Nota Média Geral (0 a 10): ${notaMedia.toStringAsFixed(2)}
- Quantidade Positivos: $totalPositivos
- Quantidade Neutros: $totalNeutros
- Quantidade Negativos: $totalNegativos

$tabelaItens

O GESTOR SOLICITOU FOCO ESPECIAL NESTE TÓPICO: "$topicoFoco"

Instruções críticas:
1. NÃO recalcule médias numéricas, use as fornecidas acima.
2. Seja detalhista na extração qualitativa, listando pontos reais que aparecem no texto.
3. Foque sua inteligência estratégica em responder ao tópico solicitado pelo gestor em "focoEstrategico".
4. Retorne APENAS um JSON válido e perfeitamente formatado.
5. No final do JSON, inclua um campo "tabelaItens" com a mini-tabela de médias formatada para exibição.

ESTRUTURA DO JSON:
{
  "resumoExecutivo": "Texto de 3-4 linhas com a visão geral",
  "focoEstrategico": "Texto denso (parágrafo único) analisando os dados sob a ótica do tópico solicitado: $topicoFoco",
  "analisePositiva": ["Ponto positivo específico 1", "Ponto positivo específico 2"],
  "analiseNeutra": ["Ponto neutro ou de atenção 1"],
  "analiseNegativa": ["Problema ou crítica específica 1", "Problema ou crítica específica 2"],
  "recomendacoesAcao": ["Ação prática sugerida 1", "Ação prática sugerida 2"],
  "conclusao": "Mensagem final curta",
  "tabelaItens": "$tabelaItens"
}

Feedbacks para análise:
$feedbacksTexto
''';

    final response = await _runPrompt(prompt);
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> analisarPlanoDeAcao(List<Map<String, dynamic>> feedbacks) async {
    final feedbacksTexto = feedbacks
        .map((f) {
          final titulo = f['titulo'] as String? ?? '';
          final mensagem = f['mensagem'] as String? ?? f['descricao'] as String? ?? '';
          final nota = f['notaMedia']?.toString() ?? 'N/A';
          return 'Nota: $nota - $titulo: $mensagem';
        })
        .join('\n');

    final prompt = '''
Você é um consultor de RH da Copperfio. Analise estes feedbacks críticos e gere um plano de ação estruturado em JSON.
Retorne APENAS JSON válido com esta estrutura:
{
  "status": "crítico|preocupante|atenção",
  "resumoPlano": "resumo curto da sugestão de plano de ação",
  "resumoChamado": "resumo curto do chamado do cliente",
  "impactoEmpresa": "como o problema impacta a empresa",
  "problemaPrincipal": "problema principal identificado",
  "impactoNegocio": "impacto nos negócios",
  "acoesPrioritarias": ["ação1", "ação2", "ação3"],
  "acoesMedioTermo": ["ação1", "ação2"],
  "metricasMonitoramento": ["métrica1", "métrica2"],
  "estimativaImpacto": "impacto esperado"
}

Feedbacks críticos:
$feedbacksTexto
''';

    final response = await _runPrompt(prompt);
    return _parseJsonResponse(response);
  }

  Future<Map<String, dynamic>> gerarSugestaoDeEmail({
    required String titulo,
    required String descricao,
    required String clienteNome,
    required String empresaNome,
    required String prioridade,
    required String dataAbertura,
  }) async {
    final prompt = '''
Você é um analista de atendimento e suporte da Copperfio. Com base no chamado abaixo, gere uma sugestão de email para o cliente que ajude a resolver o problema relatado.
Retorne APENAS JSON válido com esta estrutura:
{
  "assunto": "Assunto do email",
  "mensagem": "Texto completo do email"
}

Chamado:
- Título: $titulo
- Cliente: $clienteNome
- Empresa: $empresaNome
- Prioridade: $prioridade
- Data de abertura: $dataAbertura
- Descrição do problema: $descricao
''';

    final response = await _runPrompt(prompt);
    return _parseJsonResponse(response);
  }

  Future<String> _runPrompt(String prompt) async {
    if (_model == null) {
      throw Exception(Config.missingApiKeyMessage);
    }

    // Retry logic for transient server errors (503 / UNAVAILABLE), with backoff
    const maxAttempts = 4;
    final backoffMs = [300, 800, 1800, 3600];

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _model!.generateContent([Content.text(prompt)]);
        final jsonString = response.text;

        if (jsonString == null || jsonString.isEmpty) {
          throw Exception('Resposta vazia da API Gemini');
        }

        return jsonString.trim();
      } catch (e) {
        final err = e.toString();

        // Detect rate limit / quota errors — do not retry (fail fast)
        if (err.contains('429') || err.toLowerCase().contains('quota') || err.toLowerCase().contains('rate limit')) {
          throw Exception('Limite de cota da API atingido. Tente novamente mais tarde.');
        }

        // Network errors — fail fast with friendly message
        if (err.toLowerCase().contains('network') || err.toLowerCase().contains('connection')) {
          throw Exception('Erro de conexão. Verifique sua internet.');
        }

        // Transient server-side errors — retry with backoff
        final isTransient = err.contains('503') || err.toLowerCase().contains('unavailable') || err.toLowerCase().contains('server error') || err.toLowerCase().contains('high demand');

        if (!isTransient || attempt == maxAttempts) {
          // No more retries or not transient — surface a clear error message
          if (isTransient) {
            throw Exception('Erro ao conectar com Gemini: o serviço está indisponível no momento. Tente novamente mais tarde. Detalhe: $err');
          }
          throw Exception('Erro ao conectar com Gemini: $err');
        }

        // Wait before next attempt
        final delayMs = backoffMs[(attempt - 1).clamp(0, backoffMs.length - 1)];
        await Future.delayed(Duration(milliseconds: delayMs));
        // continue to next attempt
      }
    }

    throw Exception('Erro desconhecido ao conectar com Gemini.');
  }

  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    try {
      final clean = jsonString.trim();
      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start == -1 || end == -1 || start > end) {
        throw FormatException('JSON inválido');
      }

      final jsonPart = clean.substring(start, end + 1);
      final decoded = json.decode(jsonPart);
      return Map<String, dynamic>.from(decoded as Map<String, dynamic>);
    } catch (e) {
      throw FormatException('Erro ao converter JSON do Gemini: ${e.toString()}');
    }
  }

  void _validarResposta(Map<String, dynamic> resposta) {
    final camposObrigatorios = ['sentimento', 'categoria', 'urgencia', 'resumo', 'sugestao'];
    for (final campo in camposObrigatorios) {
      if (!resposta.containsKey(campo) || resposta[campo] == null) {
        throw Exception('Campo obrigatório ausente: $campo');
      }
    }

    final sentimentosValidos = ['positivo', 'neutro', 'negativo'];
    if (!sentimentosValidos.contains(resposta['sentimento'])) {
      resposta['sentimento'] = 'neutro';
    }

    final categoriasValidas = ['segurança', 'clima', 'processo', 'qualidade', 'outro'];
    if (!categoriasValidas.contains(resposta['categoria'])) {
      resposta['categoria'] = 'outro';
    }

    if (resposta['urgencia'] is! int || resposta['urgencia'] < 1 || resposta['urgencia'] > 5) {
      resposta['urgencia'] = 3;
    }
  }
}