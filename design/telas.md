# Mapeamento de Telas do Aplicativo

Este documento contém o levantamento e a especificação de todas as telas do sistema, divididas entre a jornada do usuário final (Cliente) e o painel administrativo (Gestor).

---

##  Fluxo do Cliente

### Splash
* **Título da tela:** Splash
* **Objetivo:** Tela inicial exibida ao abrir o app, usada para carregamento inicial e verificação de sessão.
* **Componentes Principais:** * Logo da aplicação
  * Indicador de carregamento (spinner)
  * Possível animação breve


### Onboarding
* **Título da tela:** Onboarding
* **Objetivo:** Apresentar recursos e benefícios do app para novos usuários.
* **Componentes Principais:** * Carrossel de slides
  * Título e descrição por slide
  * Botões pular/avançar
  * Indicador de progresso


### Cadastro (Sign Up)
* **Título da tela:** Cadastro
* **Objetivo:** Permitir que novos usuários criem uma conta no app.
* **Componentes Principais:** * Campos: Nome, E-mail, Senha, Confirmar senha
  * Botão: Criar Conta
  * Link para Login
  * Checkbox de verificação de termos


### Recuperar Senha
* **Título da tela:** Recuperar Senha
* **Objetivo:** Permitir recuperação de acesso por e-mail ou SMS.
* **Componentes Principais:** * Campo de e-mail/telefone
  * Botão: Enviar instruções
  * Feedback visual de sucesso/erro


### Home Cliente
* **Título da tela:** Home
* **Objetivo:** Exibir visão geral de feedbacks e acesso rápido às principais funções.
* **Componentes Principais:** * Lista de feedbacks (cards)
  * Botão flutuante de adicionar (+)
  * Barra de busca
  * Filtros/ordenamento
  * Navegação inferior (Bottom Navigation) ou Drawer lateral


### Lista de Feedbacks / Feed
* **Título da tela:** Feed de Feedbacks
* **Objetivo:** Listar todos os feedbacks disponíveis com status resumido.
* **Componentes Principais:** * Itens de lista com título, resumo e status
  * Avaliação por estrelas
  * Botão para ver detalhes


### Criar Feedback
* **Título da tela:** Criar Feedback
* **Objetivo:** Permitir que o usuário registre um novo feedback sobre um produto/serviço.
* **Componentes Principais:** * Campo de texto para descrição
  * Componente de avaliação por estrelas
  * Campo para anexar imagem
  * Seletor de categoria
  * Botão: Enviar


### Editar Feedback
* **Título da tela:** Editar Feedback
* **Objetivo:** Permitir alteração de um feedback existente (se permitido pelo fluxo).
* **Componentes Principais:** * Campos preenchidos com os dados atuais
  * Botões: Salvar / Descartar alterações
  * Opção de remover anexos atuais


### Detalhes do Feedback
* **Título da tela:** Detalhes do Feedback
* **Objetivo:** Mostrar informações completas de um feedback selecionado e permitir ações (comentários, status).
* **Componentes Principais:** * Título / Autor / Descrição completa
  * Imagens anexadas
  * Histórico de status e comentários
  * Botões de ação (Comentar, Encerrar, Reportar)


### Comentários
* **Título da tela:** Comentários do Feedback
* **Objetivo:** Exibir e permitir publicar comentários relacionados a um feedback.
* **Componentes Principais:** * Lista de comentários existentes
  * Campo de entrada de texto para novo comentário
  * Botão: Enviar
  * Contador de comentários


### Chat / Suporte
* **Título da tela:** Chat de Suporte
* **Objetivo:** Conversa em tempo real com suporte ou equipe responsável pelos feedbacks.
* **Componentes Principais:** * Linha do tempo / Lista de mensagens
  * Campo de entrada de texto e botão enviar
  * Opção de anexar arquivos
  * Indicador de "digitando..."


### Notificações
* **Título da tela:** Notificações
* **Objetivo:** Listar notificações relacionadas a feedbacks, comentários e status.
* **Componentes Principais:** * Itens de notificação com título, resumo e data
  * Opção de marcar como lida
  * Ações rápidas no card


### Perfil
* **Título da tela:** Perfil
* **Objetivo:** Permitir que o usuário veja e edite suas informações e preferências.
* **Componentes Principais:** * Avatar do usuário
  * Dados básicos (Nome, E-mail)
  * Botão: Editar perfil
  * Configurações rápidas de notificação
  * Botão: Sair (Logout)


### Configurações
* **Título da tela:** Configurações
* **Objetivo:** Gerenciar preferências do app, privacidade e integrações.
* **Componentes Principais:** * Toggles (chaves) de liga/desliga para notificações
  * Opção de idioma do sistema
  * Gerenciamento e exclusão de conta
  * Links para Termos e Políticas


### Favoritos
* **Título da tela:** Favoritos
* **Objetivo:** Mostrar feedbacks marcados como favoritos pelo usuário.
* **Componentes Principais:** * Lista de itens salvos pelo usuário
  * Opção rápida de remover dos favoritos
  * Acesso direto ao detalhe do item


### Histórico
* **Título da tela:** Histórico
* **Objetivo:** Exibir ações passadas do usuário (feedbacks enviados, alterações, status).
* **Componentes Principais:** * Linha do tempo (timeline) ou lista de eventos
  * Filtros de busca por período
  * Link direto para os itens relacionados


### Busca / Pesquisa
* **Título da tela:** Busca
* **Objetivo:** Permitir busca por feedbacks, produtos ou termos específicos.
* **Componentes Principais:** * Campo de busca de texto
  * Lista de termos sugeridos / pesquisas recentes
  * Resultados com filtros dinâmicos
  * Destaque dos termos buscados nos resultados


### Anexar Imagem / Câmera
* **Título da tela:** Anexar Imagem
* **Objetivo:** Interface para capturar ou selecionar imagens a anexar a um feedback.
* **Componentes Principais:** * Tela de preview da imagem
  * Botão: Tirar foto (câmera)
  * Botão: Acessar galeria
  * Ferramentas de recortar/remover imagem


### Dashboard / Relatórios (Visão Geral)
* **Título da tela:** Dashboard
* **Objetivo:** Exibir métricas e relatórios sobre feedbacks e uso do app.
* **Componentes Principais:** * Gráficos analíticos
  * Filtros de busca por período
  * Cartões (cards) de resumo consolidado
  * Opção de exportação de dados


### Moderação / Painel Admin (Visão Geral)
* **Título da tela:** Moderação
* **Objetivo:** Gerenciar e moderar feedbacks, usuários e relatórios.
* **Componentes Principais:** * Lista de itens pendentes de aprovação
  * Botões de ação rápida (Aprovar / Rejeitar)
  * Ações em lote (massa)
  * Barra de busca avançada


### Termos e Privacidade
* **Título da tela:** Termos e Política de Privacidade
* **Objetivo:** Exibir documentos legais e termos de uso do app.
* **Componentes Principais:** * Corpo de texto com rolagem (scroll)
  * Botões: Aceitar / Voltar
  * Links diretos para contato/suporte legal


### Ajuda / FAQ
* **Título da tela:** Ajuda
* **Objetivo:** Oferecer respostas e guias sobre uso do app.
* **Componentes Principais:** * Lista expansível de perguntas frequentes (Accordion)
  * Campo de busca interna na FAQ
  * Links rápidos para acionar o suporte


### Sobre
* **Título da tela:** Sobre
* **Objetivo:** Informações sobre o app, versão e contato.
* **Componentes Principais:** * Número da versão atual do app
  * Descrição institucional
  * Links para site oficial e redes sociais


### Erro / Página Não Encontrada
* **Título da tela:** Erro
* **Objetivo:** Informar falhas, erros de carregamento ou rotas não encontradas.
* **Componentes Principais:** * Mensagem de erro explicativa (ex: Sem conexão, 404)
  * Botão: Tentar novamente
  * Link de redirecionamento para o suporte


---

##  Painel do Gestor (Backoffice)

### Login (Gestor)
* **Objetivo:** Autenticar gestores/administradores com permissões elevadas para acessar o painel administrativo.
* **Componentes Principais:**
  * Campo de e-mail/usuário
  * Campo de senha
  * Botão: Entrar
  * Autenticação multifator (MFA) - Opcional
  * Link para recuperação de senha


### Dashboard do Gestor
* **Objetivo:** Visão geral operacional com métricas e indicadores-chave para tomada de decisão.
* **Componentes Principais:**
  * Cartões de resumo (Totais de feedbacks, pendentes, em andamento, concluídos)
  * Gráficos de tendências (linhas, barras)
  * Filtros por período e equipe de atendimento
  * Atalhos para ações rápidas (Criar relatório, exportar)


### Painel de Moderação
* **Objetivo:** Analisar, aprovar, rejeitar ou sinalizar feedbacks antes da publicação.
* **Componentes Principais:**
  * Lista de itens pendentes com resumo descritivo
  * Botões de ação (Aprovar, rejeitar, editar, marcar como spam)
  * Campo de texto para observações internas de moderação
  * Filtros avançados por prioridade/categoria


### Gestão de Usuários
* **Objetivo:** Visualizar e gerenciar contas de usuários e gestores.
* **Componentes Principais:**
  * Lista de usuários cadastrados com busca e filtros integrados
  * Página de detalhe individual do usuário (Perfil e histórico de ações)
  * Ações administrativas (Bloquear/desbloquear, resetar senha, alterar papéis)
  * Botão: Criar usuário


### Roles & Permissões
* **Objetivo:** Definir papéis (roles) e permissões para os diferentes perfis de acesso ao painel.
* **Componentes Principais:**
  * Lista de roles existentes no sistema
  * Painel editor de permissões (Checkboxes organizados por recurso)
  * Área para atribuição de roles aos usuários
  * Logs detalhados de alterações de permissão


### Fila de Chamados / Queue
* **Objetivo:** Gerenciar a fila de feedbacks ou chamados a serem tratados pela equipe.
* **Componentes Principais:**
  * Lista ordenada de chamados por prioridade ou data de entrada
  * Colunas visuais com status, responsável atual e tempo decorrido em fila
  * Ações em lote (Atribuir responsável, alterar status em massa)
  * Busca avançada com filtros específicos (Categoria, quebra de SLA)


### Atribuição e Distribuição
* **Objetivo:** Atribuir feedbacks a agentes/equipes específicos e definir o SLA da demanda.
* **Componentes Principais:**
  * Caixa de seleção múltipla para itens da lista
  * Painel lateral ou modal de atribuição (Escolha de agente/equipe responsável)
  * Configuração de regras automáticas (Mecanismo round-robin, distribuição por prioridade)
  * Tela de confirmação de atribuição com envio de notificações


### Gestão de Equipes
* **Objetivo:** Criar e gerenciar equipes de trabalho, atribuição de membros e rotas de atendimento.
* **Componentes Principais:**
  * Lista de equipes cadastradas
  * Painel de gerenciamento para adicionar/remover membros
  * Configuração de horários de atendimento e escalas de plantão
  * Painel com métricas de desempenho individuais por equipe


### Detalhe do Feedback (Gestor)
* **Objetivo:** Visualizar todas as informações e ações administrativas consolidadas sobre um feedback específico.
* **Componentes Principais:**
  * Detalhes técnicos completos (Dados do autor, data, sistema operacional/dispositivo)
  * Histórico de status completo e trilha de auditoria (Audit log)
  * Separação de comentários internos (privados) e públicos
  * Botões administrativos (Reabrir, encerrar, transferir para outra equipe)


### Históricos e Auditoria
* **Objetivo:** Rastrear detalhadamente alterações ocorridas, ações de moderadores e eventos globais do sistema.
* **Componentes Principais:**
  * Linha do tempo (Timeline) completa de eventos com filtros de pesquisa
  * Botão para exportação manual de logs de segurança
  * Filtros de pesquisa cruzada por Usuário / Ação / Data
  * Visualização comparativa do tipo "antes e depois" para mudanças de dados


### Relatórios e Métricas
* **Objetivo:** Gerar relatórios operacionais e analíticos estruturados para tomada de decisões estratégicas.
* **Componentes Principais:**
  * Painel de seleção de métricas e período customizado
  * Área de visualização em gráficos interativos e tabelas de dados
  * Opções de exportação em múltiplos formatos (CSV, Excel, PDF)
  * Funcionalidade para salvar e agendar relatórios automáticos por e-mail


### Dashboard de KPIs (Performance)
* **Objetivo:** Monitorar KPIs críticos de atendimento (Tempo médio de resposta, taxa de resolução, satisfação do usuário).
* **Componentes Principais:**
  * Painel com indicadores em grande destaque visual
  * Gráficos para comparação de performance entre períodos anteriores
  * Sistema de alertas visuais configuráveis para métricas fora da meta de SLA


### Exportação e Integração de Dados
* **Objetivo:** Exportar dados brutos do sistema e configurar a integração com ecossistemas externos (BI, CRM).
* **Componentes Principais:**
  * Painel com opções avançadas de filtros e formatos para exportação
  * Tela de configuração de conexões (Webhooks, geração de chaves de API)
  * Histórico de exportações executadas na plataforma


### Painel de Incidentes / Escalação
* **Objetivo:** Gerenciar crises, incidentes críticos reportados e controlar os fluxos internos de escalação.
* **Componentes Principais:**
  * Lista de incidentes ativos ordenados por nível de criticidade
  * Definição visual do fluxo de escalação e responsáveis por nível
  * Linha do tempo com histórico de ações tomadas e tempo de SLA associado
    

### Gestão de Categorias e Taxonomia
* **Objetivo:** Criar, editar e estruturar categorias, tags globais e campos personalizados para os feedbacks.
* **Componentes Principais:**
  * Árvore ou lista de categorias cadastradas
  * Editor dinâmico de campos personalizados (Drag-and-drop ou formulário)
  * Criação de regras de validação lógica e visibilidade dos campos


### Aprovação em Massa
* **Objetivo:** Executar ações em lote de forma otimizada para agilizar a gestão do volume de dados.
* **Componentes Principais:**
  * Seleção múltipla de itens baseada em filtros de busca avançados
  * Tela de preview demonstrando o impacto das ações em lote
  * Confirmação de segurança e geração de log para as alterações em massa


### Notificações do Sistema (Admin)
* **Objetivo:** Visualizar alertas internos e configurar as regras de notificações disparadas pelo sistema.
* **Componentes Principais:**
  * Central de notificações e alertas administrativos ativos
  * Painel de configuração de canais de saída (E-mail, Push Notification, Webhook)
  * Editor visual de templates de mensagem (com tags dinâmicas)


### Configurações Administrativas
* **Objetivo:** Gerenciar parâmetros globais do sistema, identidade visual da plataforma e regras básicas de negócio.
* **Componentes Principais:**
  * Configurações gerais de marca (Nome do sistema, upload de logo, idioma padrão)
  * Painel de definição de parâmetros de SLA padrão e regras operacionais
  * Central para gerenciamento de chaves gerais do sistema e integrações nativas


### Segurança e Conformidade
* **Objetivo:** Painel de controle dedicado à segurança da informação, políticas de retenção de dados e conformidade com leis de proteção de dados.
* **Componentes Principais:**
  * Painel de configuração do tempo de retenção de dados no banco
  * Ferramentas internas para atendimento a requisições de anonimização ou exclusão definitiva (Ex: LGPD)
  * Definição de políticas restritivas de acesso e logs consolidados de conformidade


### Ajuda / Documentação do Gestor
* **Objetivo:** Centralizar manuais de uso, guias práticos e procedimentos operacionais voltados aos administradores.
* **Componentes Principais:**
  * Base de conhecimento interna com artigos de ajuda pesquisáveis (How-tos)
  * Catálogo com Processos Operacionais Padrão (POPs) da empresa
  * Informações e canais de contato direto com a equipe de suporte técnico do sistema
