import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_integrado/config.dart';
import 'package:projeto_integrado/data/models/product_model.dart';
import 'package:projeto_integrado/data/repositories/product_repository.dart';

class ChatbotService {
  GenerativeModel? _model;
  final ProductRepository _productRepository = ProductRepository();
  final Map<String, String> _pdfTextCache = {};
  List<ProductModel>? _cachedProducts;
  final List<String> _userMessageHistory = [];

  ChatbotService() {
    final apiKey = Config.googleApiKey;
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Você é o assistente virtual Copper da Copperfio, um especialista técnico e consultivo em cabos e fios de alumínio. Seja prestativo, profissional, ágil e sempre foque em ajudar o cliente a encontrar a melhor solução para obra ou projeto elétrico. Além disso, auxilie ativamente em dúvidas, pedidos e orçamentos dentro do aplicativo. Priorize informações do catálogo do app e das fichas técnicas em PDF disponíveis localmente. Quando necessário e disponível, consulte o site oficial da empresa (https://copperfio.com) para complementar respostas. Não invente dados — se a informação não estiver disponível ou não puder ser verificada, diga que não está disponível e oriente o usuário a usar as telas e botões correspondentes no app. Nunca gere ou envie imagens, URLs de imagens ou blocos de imagem no chat.',
        ),
        generationConfig: GenerationConfig(
          responseMimeType: 'text/plain',
          maxOutputTokens: 512,
          temperature: 0.25,
        ),
      );
    }
  }

  Future<String> ask(
    String userMessage, {
    bool isFirstInteraction = false,
  }) async {
    // Runtime enforcement: intercept requests to speak with a human or to be forwarded.
    if (_isForwardingRequest(userMessage)) {
      return 'Entendo que você deseja falar com um atendente. Para falar com um humano, por favor acesse Perfil > Meus Chamados e preencha os dados do chamado, ou utilize o botão de "Solicitar contato" no perfil do pedido. Posso orientar você passo a passo para abrir o chamado.';
    }

    _appendUserMessageHistory(userMessage);
    final relevantProducts = await _findRelevantProducts(userMessage);
    final productContext = await _buildProductContext(relevantProducts);
    final siteSnippet = await _fetchSiteSnippet(userMessage);
    final prompt = _buildPrompt(
      userMessage,
      productContext,
      isFirstInteraction,
      siteSnippet,
    );

    try {
      if (_model == null) {
        return Config.missingApiKeyMessage;
      }
      final response = await _model!.generateContent([Content.text(prompt)]);
      final answer = _normalizeResponse(response.text?.trim() ?? '');
      // split into message parts of max 3 paragraphs
      final parts = _splitIntoParts(answer, 3);
      if (parts.length <= 1) {
        if (answer.isEmpty) {
          throw Exception('Resposta vazia do Gemini.');
        }
        return answer;
      }
      const marker = '<CONTINUA_NA_PROXIMA_MENSAGEM>';
      final combined = parts.join('\n\n$marker\n\n');
      return combined;
    } catch (e) {
      if (e.toString().contains('429') ||
          e.toString().toLowerCase().contains('quota') ||
          e.toString().toLowerCase().contains('rate limit')) {
        return 'No momento o assistente está sem acesso à IA devido ao limite de cota. Por favor, tente novamente mais tarde.';
      }
      return '${Config.missingApiKeyMessage} Erro: ${e.toString()}';
    }
  }

  Stream<String> askStream(
    String userMessage, {
    bool isFirstInteraction = false,
  }) async* {
    // Runtime enforcement: intercept forwarding requests and yield a safe reply.
    if (_isForwardingRequest(userMessage)) {
      yield 'Entendo que você deseja falar com um atendente. Para falar com um humano, por favor acesse Perfil > Meus Chamados e preencha os dados do chamado, ou utilize o botão de "Solicitar contato" no perfil do pedido. Posso orientar você passo a passo para abrir o chamado.';
      return;
    }

    _appendUserMessageHistory(userMessage);
    final relevantProducts = await _findRelevantProducts(userMessage);
    final productContext = await _buildProductContext(relevantProducts);
    final siteSnippet = await _fetchSiteSnippet(userMessage);
    final prompt = _buildPrompt(
      userMessage,
      productContext,
      isFirstInteraction,
      siteSnippet,
    );

    try {
      if (_model == null) {
        yield Config.missingApiKeyMessage;
        return;
      }
      // Use non-streaming generation to be able to split into separate messages
      final response = await _model!.generateContent([Content.text(prompt)]);
      final fullText = _normalizeResponse(response.text?.trim() ?? '');
      if (fullText.isEmpty) {
        return;
      }
      final parts = _splitIntoParts(fullText, 3);
      const marker = '<CONTINUA_NA_PROXIMA_MENSAGEM>';
      // join parts with marker so UI can split into multiple messages
      final out = parts.join('\n\n$marker\n\n');
      yield out;
    } catch (e) {
      if (e.toString().contains('429') ||
          e.toString().toLowerCase().contains('quota') ||
          e.toString().toLowerCase().contains('rate limit')) {
        throw Exception(
          'No momento o assistente está sem acesso à IA devido ao limite de cota. Por favor, tente novamente mais tarde.',
        );
      }
      throw Exception(
        'Desculpe, não consegui gerar uma resposta agora. Tente novamente ou fale com um gestor.',
      );
    }
  }

  String _normalizeResponse(String text) {
    return text
        .replaceAll(RegExp(r'\bcabose\b', caseSensitive: false), 'cabos e')
        .replaceAll(
          RegExp(r'\bcabos\s*e\s*fios\b', caseSensitive: false),
          'cabos e fios',
        );
  }

  void clearConversationHistory() {
    _userMessageHistory.clear();
  }

  void _appendUserMessageHistory(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    _userMessageHistory.add(trimmed);
    if (_userMessageHistory.length > 10) {
      _userMessageHistory.removeAt(0);
    }
  }

  String _buildConversationHistory() {
    if (_userMessageHistory.isEmpty) {
      return 'Nenhum histórico de conversa disponível ainda.';
    }
    final lines = _userMessageHistory.map((msg) => '- $msg').join('\n');
    return 'Histórico de mensagens do usuário nesta sessão:\n$lines';
  }

  List<String> _splitIntoParts(String text, int paragraphsPerPart) {
    if (text.trim().isEmpty) return [];
    // split by blank lines first
    final rawParas = text
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (rawParas.isEmpty) {
      // fallback split by single newline
      final lines = text
          .split(RegExp(r'\n'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (lines.isEmpty) return [];
      return _groupParagraphs(lines, paragraphsPerPart);
    }
    return _groupParagraphs(rawParas, paragraphsPerPart);
  }

  List<String> _groupParagraphs(List<String> paras, int perGroup) {
    final parts = <String>[];
    for (var i = 0; i < paras.length; i += perGroup) {
      final group = paras.sublist(
        i,
        (i + perGroup) > paras.length ? paras.length : i + perGroup,
      );
      parts.add(group.join('\n\n'));
    }
    return parts;
  }

  bool _isForwardingRequest(String text) {
    final t = text.toLowerCase();
    final patterns = [
      'falar com',
      'falar ao gestor',
      'falar com um humano',
      'atendente',
      'encaminhar',
      'transferir',
      'ligar para',
      'contato com',
      'quero falar',
      'suporte humano',
      'falar com o gestor',
      'atendimento humano',
    ];
    for (final p in patterns) {
      if (t.contains(p)) return true;
    }
    return false;
  }

  /// Debug helper: returns the full prompt that will be sent to the model for inspection.
  Future<String> debugPromptFor(
    String userMessage, {
    bool isFirstInteraction = false,
  }) async {
    final relevantProducts = await _findRelevantProducts(userMessage);
    final productContext = await _buildProductContext(relevantProducts);
    final siteSnippet = await _fetchSiteSnippet(userMessage);
    final prompt = _buildPrompt(
      userMessage,
      productContext,
      isFirstInteraction,
      siteSnippet,
    );
    return prompt;
  }

  Future<List<ProductModel>> _findRelevantProducts(String userMessage) async {
    final allProducts = _cachedProducts ??= await _productRepository
        .fetchProducts();
    final queryWords = userMessage
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9à-ú]+'))
        .where((word) => word.length >= 3)
        .toSet();

    if (queryWords.isEmpty) {
      return allProducts.take(2).toList();
    }

    final scoredProducts = allProducts
        .map((product) {
          final searchable =
              '${product.title} ${product.subtitle} ${product.description} ${product.specs.join(' ')}'
                  .toLowerCase();
          final score = queryWords.fold<int>(0, (score, word) {
            return searchable.contains(word) ? score + 1 : score;
          });
          return MapEntry(product, score);
        })
        .where((entry) => entry.value > 0)
        .toList();

    if (scoredProducts.isEmpty) {
      return allProducts.take(2).toList();
    }

    scoredProducts.sort((a, b) => b.value.compareTo(a.value));
    return scoredProducts.take(3).map((entry) => entry.key).toList();
  }

  Future<String> _buildProductContext(List<ProductModel> products) async {
    if (products.isEmpty) {
      return 'Não há produtos específicos identificados como relevantes para esta pergunta.';
    }

    final productSections = <String>[];
    for (final product in products) {
      final pdfSnippet = await _extractPdfSnippet(product.pdfUrl);
      final productSection =
          '''
Produto: ${product.title}
Subtítulo: ${product.subtitle}
Descrição: ${product.description}
Especificações principais: ${product.specs.join('; ')}
Ficha técnica PDF: ${product.pdfUrl.isNotEmpty ? product.pdfUrl : 'não disponível'}
Trechos da ficha técnica: ${pdfSnippet.isNotEmpty ? pdfSnippet : 'Não foi possível extrair texto da ficha técnica.'}
''';
      productSections.add(productSection.trim());
    }

    // Gera sugestões de cross-sell com base nos produtos relevantes e no catálogo em cache
    final crossSell = _buildCrossSellSuggestions(products);

    final joined = productSections.join('\n\n');
    return '$joined\n\nSugestões complementares (prioritizadas):\n$crossSell';
  }

  String _searchableText(ProductModel p) {
    return '${p.title} ${p.subtitle} ${p.description} ${p.specs.join(' ')}'
        .toLowerCase();
  }

  String _buildCrossSellSuggestions(List<ProductModel> products) {
    final allProducts = _cachedProducts ?? [];
    if (allProducts.isEmpty) return 'Sem dados de catálogo para sugerir.';

    final suggestions = <String>[];
    final suggestedTitles = <String>{};

    for (final product in products) {
      final sourceText = _searchableText(product);

      final scores = <ProductModel, int>{};
      for (final candidate in allProducts) {
        if (candidate.title == product.title) continue;
        final candidateText = _searchableText(candidate);
        final sourceWords = sourceText.split(RegExp(r'[^a-z0-9à-ú]+')).toSet();
        final candWords = candidateText.split(RegExp(r'[^a-z0-9à-ú]+')).toSet();
        final shared = sourceWords
            .intersection(candWords)
            .where((w) => w.length >= 3)
            .toList();
        final score = shared.length;
        if (score > 0) scores[candidate] = score;
      }

      final ranked = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      int added = 0;
      for (final entry in ranked) {
        final cand = entry.key;
        if (suggestedTitles.contains(cand.title)) continue;
        final sharedWords = _searchableText(cand)
            .split(RegExp(r'[^a-z0-9à-ú]+'))
            .toSet()
            .intersection(
              _searchableText(product).split(RegExp(r'[^a-z0-9à-ú]+')).toSet(),
            )
            .where((w) => w.length >= 3)
            .toList();
        final reason = sharedWords.isNotEmpty
            ? 'Compartilha: ${sharedWords.take(3).join(', ')}'
            : 'Produto complementar sugerido';
        suggestions.add('- ${cand.title} — $reason');
        suggestedTitles.add(cand.title);
        added++;
        if (added >= 2) break; // no máximo 2 por produto relevante
      }
    }

    // If still empty, fallback to top catalog items
    if (suggestions.isEmpty) {
      for (final cand in allProducts.take(3)) {
        suggestions.add('- ${cand.title} — Sugestão popular');
      }
    }

    // limit total suggestions
    final unique = suggestions.take(6).toList();
    return unique.join('\n');
  }

  String _institutionalContext() {
    return '''
Localização estratégica: Fábrica própria e centro de distribuição em São João da Boa Vista - SP. Atendimento e logística ágil para todo o território nacional.

Público-alvo principal: Empreiteiras de energia, construtoras, indústrias de médio/grande porte, instaladores eletricistas, engenheiros eletricistas e compradores de materiais elétricos de infraestrutura.

Pilares da marca: Alta condutibilidade, conformidade rigorosa com normas técnicas (ABNT), excelente custo-benefício (alumínio pode chegar a ser até 70% mais barato e mais leve que o cobre em aplicações de potência) e sustentabilidade (material 100% reciclável).

Catálogo técnico e regras de aplicação (resumo para decisões de cross-sell):

A) Cabos de Alumínio Nus (CA e CAA):
 - Uso: Linhas aéreas de transmissão e distribuição (alta e média tensão).
 - Regra de sugestão: Se o cliente estiver comprando cabo nu para redes aéreas, sugira Cabos Multiplexados para descida/entrada de serviço na edificação.

B) Cabos de Alumínio Multiplexados (Duplex/Triplex/Quadruplex, isolação XLPE):
 - Uso: Redes aéreas de distribuição secundária (baixa tensão, até 1kV), entradas de padrão residencial/comercial.
 - Regra de sugestão: Ao vender multiplexados, pergunte se o cliente já calculou o número de fases (bifásico/trifásico) para confirmar o modelo correto.

C) Cabos de Alumínio Isolados (Unipolares/Multipolares, XLPE/PVC, 0,6/1kV):
 - Uso: Instalações industriais, comerciais, subestações, circuitos enterrados em eletrodutos.
 - Regra de sugestão: Recomende fitas de sinalização para enterramento e conectores bimetálicos adequados.

Vocabulário técnico e conversões:
 - Bitola / Seção transversal: medido em mm². Exemplos comuns: 10, 16, 25, 35, 50, 70, 95, 120, 240mm².
 - AWG / MCM: se o usuário usar medidas americanas (AWG ou MCM), tente mapear para mm² usando a tabela de equivalência das fichas técnicas; se a tabela não estiver disponível localmente, peça confirmação antes de converter.
 - Normas: Citar que os produtos seguem ABNT (por exemplo, NBR 7285, NBR 8182, NBR 7271) quando aplicável.

Guia de conectividade e alertas críticos:
 - Nunca conectar alumínio diretamente em borne de cobre sem conector bimetálico e pasta antioxidante; isso evita corrosão galvânica.
 - Recomende sempre terminais/conectores bimetálicos e pasta antioxidante (ex.: Intox) para conexões em disjuntores ou barramentos de cobre.

Logística, embalagens e unidades:
 - Formas de envio: rolos (50m/100m) para metragens menores; bobinas de madeira para grandes metragens.
 - Peso e manuseio: destaque que o alumínio é mais leve que o cobre, facilitando puxamento e reduzindo custo de mão de obra.

Como usar o site e as fichas técnicas:
 - Priorize sempre as fichas técnicas internas e o catálogo do aplicativo para dados numéricos e tabelas.
 - Se o usuário pedir informação que possa estar no site (https://copperfio.com), indique que você consultará o site quando houver integração; se a integração não estiver disponível, explique que pode verificar nas fichas técnicas do produto e oferecer-se para checar a ficha técnica local.
 - Ao citar valores técnicos (bitolas, correntes, tabelas), só utilize números que estejam nas fichas técnicas ou no catálogo; caso contrário, peça confirmação.
''';
  }

  Future<String> _extractPdfSnippet(String assetPath) async {
    if (assetPath.isEmpty) {
      return '';
    }

    if (_pdfTextCache.containsKey(assetPath)) {
      return _pdfTextCache[assetPath]!;
    }

    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final decoded = latin1.decode(bytes, allowInvalid: true);
      final cleaned = decoded.replaceAll(
        RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'),
        ' ',
      );
      final matches = RegExp(r'\(([^)]{20,})\)')
          .allMatches(cleaned)
          .map((m) {
            return m.group(1)!.replaceAll('\\', '');
          })
          .where((text) => text.trim().isNotEmpty)
          .toList();

      String snippet;
      if (matches.isNotEmpty) {
        snippet = matches.take(30).join('. ');
      } else {
        final chunks = cleaned
            .split(RegExp(r'\s{2,}'))
            .where((chunk) => chunk.trim().length >= 30)
            .toList();
        snippet = chunks.take(12).join('. ');
      }

      snippet = snippet.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (snippet.length > 800) {
        snippet = '${snippet.substring(0, 800)}...';
      }

      _pdfTextCache[assetPath] = snippet;
      return snippet;
    } catch (_) {
      return '';
    }
  }

  String _buildPrompt(
    String userMessage,
    String productContext,
    bool isFirstInteraction,
    String siteContext,
  ) {
    final institutional = _institutionalContext();

    return '''
# PERSONA E PAPEL
Você é o "Copper", o assistente virtual inteligente e especialista técnico da Copperfio. Sua personalidade é prestativa, altamente profissional, ágil e consultiva. Você não é apenas um tirador de dúvidas; você é um especialista que ajuda o cliente a encontrar a melhor solução para a obra ou projeto elétrico. Além disso, auxilie diretamente em dúvidas, pedidos e orçamentos dentro do aplicativo.

# ESCOPO DE ATUAÇÃO
Você deve orientar o usuário sobre orçamento, pedido, chamado, produtos, cabos e alumínio.

# REGRAS DE CONVERSAÇÃO E FLUXOS COMPORTAMENTAIS
1. QUALIFICAÇÃO PROATIVA DE ORÇAMENTOS:
   - Assim que o usuário demonstrar interesse em preços, orçamentos ou valores, solicite proativamente tipo de cabo e metragem.
   - Ao iniciar a conversa de orçamento, lembre o usuário de verificar se possui produtos favoritados no aplicativo (ícone de coração) para incluí-los no pedido.
   - Só encaminhe os dados para a equipe de vendas após obter essas informações essenciais.

2. SUGESTÃO CONSULTIVA E CROSS-SELLING:
   - Sempre que um usuário perguntar sobre um produto específico, além de responder a dúvida técnica com precisão, avalie a necessidade e sugira produtos correlacionados.
   - Se o cliente perguntar por Cabo Nu (por exemplo, para linhas aéreas), pergunte se ele também precisará de cabos Multiplexados para as conexões de descida ou ramais de ligação.
   - Se o cliente perguntar por Cabos Isolados (XLPE), recomende tamanhos ou bitolas complementares padrão para redes de baixa tensão.
   - Caso o produto solicitado não seja ideal para o cenário do cliente, sugira uma alternativa viável em alumínio, comparando Nu vs. Multiplex para explicar a melhor adequação.

3. RESOLUÇÃO TÉCNICA E TRIAGEM DE CHAMADOS:
   - Antes de orientar o cliente a abrir um chamado técnico em Perfil > Meus Chamados, tente sanar a dúvida consultando diretamente as fichas técnicas disponíveis no catálogo.
   - Se o problema for físico (material danificado, defeito, atraso), auxilie o usuário com o passo a passo para a abertura do chamado.

4. TRANSBORDO HUMANO:
  - Se o usuário solicitar falar com um humano ou com o gestor: NÃO encaminhe automaticamente nem afirme que você fará o contato. Explique os passos que o usuário deve seguir no aplicativo para solicitar atendimento (por exemplo, Perfil > Meus Chamados ou o botão "Solicitar contato" no pedido). Ofereça-se para orientar o usuário passo a passo na abertura do chamado e, se solicitado, registre os dados essenciais fornecidos pelo usuário sem prometer encaminhamento automático.

5. INSTRUÇÕES DE NAVEGAÇÃO DO APLICATIVO:
   - Fazer Pedido: "Acesse o catálogo, selecione o produto desejado e toque no botão de fazer pedido."
   - Enviar Feedback: "Vá em Perfil > FeedBacks, selecione a categoria correspondente (Produto, Atendimento, Aplicativo), escreva sua mensagem e envie."
   - Ver Medidas/Especificações: "Abra a página do produto desejado e toque na aba Ficha Técnica."
   - Salvar/Favoritar Produto: "Toque no ícone de coração localizado no produto."
   - Baixar Ficha Técnica (PDF): "Abra o produto, clique no botão de download e aguarde o arquivo."
   - Atualizar Perfil/Endereço: "Vá na seção Perfil, toque no botão de editar, altere seus dados e salve."
   - Imagens: O assistente nunca deve enviar imagens, URLs de imagens ou blocos de imagem no chat. Não gere imagens nem inclua qualquer tipo de visualização gráfica nas respostas.
   - Respostas mais curtas: responda em no máximo 3 frases quando possível. Use frases objetivas, evite repetições e texto prolixo. Priorize clareza e economia de tokens para reduzir o uso de cota.

# BASE DE CONHECIMENTO TÉCNICO
Você possui conhecimento profundo sobre condutores elétricos de alumínio voltados para obras, indústrias e projetos de redes de distribuição de energia. Sempre utilize as informações contidas na variável abaixo para detalhar especificações exatas.

# RESTRIÇÕES
- Nunca invente bitolas, metragens, capacidades de corrente ou dados técnicos que não estejam explicitamente detalhados no contexto de produto.
- Nunca execute alterações cadastrais ou de endereço diretamente pelo chat. Sempre instrua o usuário a usar o botão "Editar" na tela de Perfil.
- Não adote um tom puramente robótico; seja empático e use termos do universo de engenharia elétrica de forma simplificada e comercial.

# CONTEXTO INSTITUCIONAL E DIFERENCIAIS:
$institutional

# CONTEXTO ATUAL DO PRODUTO:
$productContext

 # INFORMAÇÃO SOBRE SAUDAÇÕES
Somente inclua uma saudação inicial (por exemplo, "Olá" ou "Bom dia") se `isFirstInteraction` for `true`. Caso contrário, não comece a resposta com saudações ou apresentações repetidas.

# REGRAS DE NÃO-ENCAMINHAMENTO
Você NÃO deve encaminhar, transferir ou prometer agendar contato com o usuário para outro canal. Se o usuário pedir atendimento humano, explique claramente os passos que ele pode seguir no aplicativo (por exemplo, onde abrir um chamado ou como solicitar contato), mas não afirme que você irá encaminhar ou agendar.

# VARIÁVEL DE CONTEXTO
isFirstInteraction: $isFirstInteraction

# HISTÓRICO DA CONVERSA
${_buildConversationHistory()}

# MENSAGEM DO USUÁRIO:
"$userMessage"

Resposta:''';
  }

  Future<String> _fetchSiteSnippet(String query) async {
    try {
      final url = Uri.parse('https://www.copperfio.com.br/');
      final resp = await http.get(url).timeout(const Duration(seconds: 6));
      if (resp.statusCode != 200) return '';
      var html = resp.body;
      // remove scripts and styles
      html = html.replaceAll(
        RegExp(r'<script[^>]*>.*?<\/script>', dotAll: true),
        ' ',
      );
      html = html.replaceAll(
        RegExp(r'<style[^>]*>.*?<\/style>', dotAll: true),
        ' ',
      );
      // strip tags
      final text = html
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final qwords = query
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9à-ú]+'))
          .where((w) => w.length >= 3)
          .toSet();

      if (qwords.isEmpty) {
        return text.length > 800 ? '${text.substring(0, 800)}...' : text;
      }

      final sentences = text.split(RegExp(r'(?<=[\.!?])\s+'));
      final matches = <String>[];
      for (final s in sentences) {
        final sl = s.toLowerCase();
        if (qwords.any((w) => sl.contains(w))) {
          matches.add(s.trim());
          if (matches.length >= 8) break;
        }
      }

      if (matches.isNotEmpty) {
        final joined = matches.join(' ');
        return joined.length > 1000
            ? '${joined.substring(0, 1000)}...'
            : joined;
      }

      return text.length > 800 ? '${text.substring(0, 800)}...' : text;
    } catch (_) {
      return '';
    }
  }
}
