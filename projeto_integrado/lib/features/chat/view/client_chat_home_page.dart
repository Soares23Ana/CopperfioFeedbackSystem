import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/services/chatbot_service.dart';
import 'package:projeto_integrado/services/history_service.dart';

class ClientChatHomePage extends StatefulWidget {
  const ClientChatHomePage({super.key});

  @override
  State<ClientChatHomePage> createState() => _ClientChatHomePageState();
}

class _ClientChatHomePageState extends State<ClientChatHomePage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  final List<Map<String, String>> _messages = [];
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _chatbotService.clearConversationHistory();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendUserMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    // Determine if this is the first interaction in the chat
    final isFirstInteraction = _messages.isEmpty;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messages.add({'sender': 'bot', 'text': ''});
      _chatController.clear();
      _isBotTyping = true;
    });

    await const HistoryService().addAction(
      type: 'chat',
      title: 'Pergunta enviada ao assistente',
      description: 'O usuário enviou a pergunta: "$text"',
    );

    _askBot(text, _messages.length - 1, isFirstInteraction);
  }
  Future<void> _askBot(String text, int botMessageIndex, bool isFirstInteraction) async {
    try {
      const marker = '<CONTINUA_NA_PROXIMA_MENSAGEM>';
      await for (final token in _chatbotService.askStream(text, isFirstInteraction: isFirstInteraction)) {
        if (!mounted) return;
        setState(() {
          var currentText = _messages[botMessageIndex]['text'] ?? '';
          currentText = '$currentText$token';

          // If marker appears, split into a new bot message bubble
          while (currentText.contains(marker)) {
            final split = currentText.split(marker);
            final before = split.first.trim();
            final after = split.sublist(1).join(marker).trim();

            // set current message to text before marker
            _messages[botMessageIndex]['text'] = before;

            // create new bot message bubble for the continuation
            _messages.add({'sender': 'bot', 'text': ''});
            botMessageIndex = _messages.length - 1;

            // continue loop with the remainder (may contain more markers)
            currentText = after;
            continue;
          }

          // append any remaining text to the current bot message
          if (currentText.isNotEmpty) {
            final existing = _messages[botMessageIndex]['text'] ?? '';
            _messages[botMessageIndex]['text'] = existing.isEmpty ? currentText : '$existing\n\n$currentText';
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[botMessageIndex]['text'] = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isBotTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessageBubble(Map<String, String> message, bool isDark) {
    final isUser = message['sender'] == 'user';
    final bubbleColor = isUser
        ? (isDark ? Colors.black : Colors.white)
        : const Color(0xFF9C1818);
    final textColor = isUser
        ? (isDark ? Colors.white : Colors.black87)
        : Colors.white;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: isUser ? 16 : 14),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.06 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message['text'] ?? '',
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chat com o assistente'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index], isDark);
                        },
                      ),
                    ),
                    if (_isBotTyping)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Assistente está digitando...',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.75),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'Digite sua pergunta...',
                                filled: true,
                                fillColor:
                                    Theme.of(context).inputDecorationTheme.fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendUserMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendUserMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este chat é com o assistente virtual Copper. Pergunte sobre orçamento, pedido ou chamado.',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
