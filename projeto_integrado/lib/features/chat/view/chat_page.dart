import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';
import 'package:projeto_integrado/data/models/message_model.dart';
import 'package:projeto_integrado/features/profile/viewmodel/current_user_viewmodel.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatPage extends StatefulWidget {
  final String? contactId;
  final String? contactName;

  const ChatPage({super.key, this.contactId, this.contactName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(ChatViewModel vm) async {
    if (_messageController.text.trim().isEmpty || widget.contactId == null)
      return;

    try {
      await vm.enviarMensagem(
        recipientId: widget.contactId!,
        recipientName: widget.contactName ?? 'Usuário',
        content: _messageController.text,
      );
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao enviar mensagem: $e')));
      }
    }
  }

  String get contactId => widget.contactId ?? '';

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUserId =
        context.watch<CurrentUserViewModel>().currentUser?.uid ?? '';
    final isDark = themeProvider.isDarkMode;

    if (contactId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: themeProvider.toggleTheme,
            ),
          ],
        ),
        body: Center(
          child: Text(
            'Selecione um contato para começar',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat com Gestor'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: themeProvider.toggleTheme,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chat com Gestor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: vm.obterMensagensEntre(currentUserId, contactId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar mensagens: ${snapshot.error}',
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Nenhuma mensagem ainda. Comece a conversa!'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final currentUserId =
                        context
                            .watch<CurrentUserViewModel>()
                            .currentUser
                            ?.uid ??
                        '';
                    final isCurrentUser = msg.senderId == currentUserId;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blue.shade200
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isCurrentUser)
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: msg.senderName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ': ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              msg.content,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.timestamp.toString().split('.')[0],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  backgroundColor: const Color(0xFF9C1818),
                  onPressed: () => _sendMessage(vm),
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
