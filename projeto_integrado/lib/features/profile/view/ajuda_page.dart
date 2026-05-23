import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrado/core/theme_provider.dart';

class AjudaPage extends StatefulWidget {
  const AjudaPage({super.key});

  @override
  State<AjudaPage> createState() => _AjudaPageState();
}

class _AjudaPageState extends State<AjudaPage> {
  final List<_AjudaTopic> _topics = [
    _AjudaTopic(
      title: 'Como fazer um pedido',
      description:
          'Para fazer um pedido, navegue pelo catálogo, escolha o produto desejado e siga o botão de fazer pedido na parte inferior da página.',
      icon: Icons.shopping_cart,
      steps: [
        'Acesse o catálogo de produtos na tela inicial',
        'Selecione o produto desejado e visualize os detalhes',
        'Pressione o botão "Fazer Pedido" na parte inferior',
        'Confirme o pedido e aguarde a confirmação do gestor',
      ],
    ),
    _AjudaTopic(
      title: 'Como enviar um feedback',
      description:
          'Compartilhe suas sugestões e comentários com nossos gestores para nos ajudar a melhorar o aplicativo.',
      icon: Icons.comment,
      steps: [
        'Vá para "Perfil" no menu inferior',
        'Toque no botão "FeedBacks"',
        'Clique em "Enviar Feedback"',
        'Escreva sua mensagem e envie',
        'O gestor receberá sua mensagem automaticamente',
      ],
    ),
    _AjudaTopic(
      title: 'Como ver as medidas dos fios',
      description:
          'Consulte as especificações técnicas completas de cada produto através da ficha técnica.',
      icon: Icons.straighten,
      steps: [
        'Acesse a página do produto desejado',
        'Deslize para baixo na página',
        'Toque no ícone de "Ficha Técnica"',
        'Visualize todas as medidas e especificações',
        'Você pode fazer download do PDF se necessário',
      ],
    ),
    _AjudaTopic(
      title: 'Como salvar um produto',
      description:
          'Salve seus produtos favoritos para acessá-los rapidamente depois.',
      icon: Icons.favorite,
      steps: [
        'Encontre o produto desejado no catálogo',
        'Toque no ícone de coração (♥) no produto',
        'O produto será salvo nos seus itens favoritos',
        'Acesse "Perfil" → "Itens Salvos" para visualizar',
      ],
    ),
    _AjudaTopic(
      title: 'Como baixar a ficha técnica',
      description:
          'Baixe os documentos PDF com as informações completas dos produtos.',
      icon: Icons.picture_as_pdf,
      steps: [
        'Abra a página do produto',
        'Clique no botão de download (↓)',
        'Aguarde o download ser concluído',
        'O arquivo será salvo na pasta de Downloads do seu celular',
        'Abra o arquivo pelo gerenciador de arquivos quando precisar',
      ],
    ),
    _AjudaTopic(
      title: 'Como acompanhar meus pedidos',
      description:
          'Verifique o status de todos os seus pedidos em tempo real.',
      icon: Icons.track_changes,
      steps: [
        'Vá para "Perfil" → "Meus Chamados"',
        'Visualize a lista de todos os seus pedidos',
        'Toque em um pedido para ver detalhes',
        'Acompanhe o status da sua solicitação em tempo real',
      ],
    ),
    _AjudaTopic(
      title: 'Como usar o chatbot',
      description:
          'Tire suas dúvidas rapidamente com o assistente virtual CopperFio.',
      icon: Icons.smart_toy,
      steps: [
        'Acesse o chatbot no menu inferior',
        'Digite sua pergunta ou dúvida',
        'O chatbot responderá automaticamente',
        'Para falar com um gestor, selecione a opção "Falar com Gestor"',
      ],
    ),
    _AjudaTopic(
      title: 'Como atualizar meu perfil',
      description:
          'Mantenha suas informações de contato e dados sempre atualizados.',
      icon: Icons.person_outline,
      steps: [
        'Vá para "Perfil"',
        'Toque no botão de editar (lápis)',
        'Atualize os dados desejados',
        'Salve as alterações',
      ],
    ),
    _AjudaTopic(
      title: 'Não recebi minha notificação',
      description:
          'Se perdeu alguma notificação importante, aqui está como recuperá-la.',
      icon: Icons.notifications_none,
      steps: [
        'Verifique se as notificações estão ativadas nas configurações do seu celular',
        'Vá para "Perfil" → "Notificações" para ver o histórico',
        'Ative as permissões de notificação para o aplicativo',
        'Tente fazer logout e login novamente para sincronizar',
      ],
    ),
    _AjudaTopic(
      title: 'Não consigo fazer login',
      description:
          'Problemas ao acessar sua conta? Siga estas dicas para resolver.',
      icon: Icons.lock_outline,
      steps: [
        'Verifique se a internet está funcionando normalmente',
        'Confira se digitou o email e senha corretamente',
        'Tente usar "Recuperar Senha" se esqueceu sua senha',
        'Limpe o cache do aplicativo nas configurações do celular',
        'Desinstale e reinstale o aplicativo se necessário',
      ],
    ),
  ];

  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final headerColor = isDark ? Theme.of(context).colorScheme.primary : const Color(0xFF9C1818);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ajuda'),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner informativo
            Container(
              color: headerColor.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo ao Centro de Ajuda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Encontre respostas para suas dúvidas e aprenda a usar o aplicativo ao máximo.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Lista de tópicos
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                final isExpanded = _expandedIndices.contains(index);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    onExpansionChanged: (expanded) {
                      setState(() {
                        if (expanded) {
                          _expandedIndices.add(index);
                        } else {
                          _expandedIndices.remove(index);
                        }
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor: headerColor.withOpacity(0.12),
                      child: Icon(topic.icon, color: headerColor),
                    ),
                    title: Text(
                      topic.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        topic.description,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: headerColor,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Passo a Passo:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: headerColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              topic.steps.length,
                              (stepIndex) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: headerColor,
                                        shape: BoxShape.circle,
                              ),
                                      child: Center(
                                        child: Text(
                                          '${stepIndex + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        topic.steps[stepIndex],
                                        style: const TextStyle(fontSize: 13, height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AjudaTopic {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  const _AjudaTopic({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}
                
