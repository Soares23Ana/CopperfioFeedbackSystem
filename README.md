# Sistema de Qualidade - Copperfio

Este repositório contém a documentação e o código do aplicativo corporativo desenvolvido para a empresa Copperfio, especializada na venda de cabos elétricos para empresas.

## Sobre o projeto

O sistema tem como objetivo centralizar atendimento, reclamações, catálogo de produtos e análise de feedbacks, oferecendo uma área exclusiva para clientes e um painel gerencial com dashboards estratégicos.

### Objetivo do Projeto

Desenvolver um aplicativo Android corporativo que permita:

- melhorar o relacionamento com clientes;
- organizar reclamações e chamados;
- disponibilizar fichas técnicas e catálogo de produtos;
- coletar avaliações e feedbacks;
- fornecer dados estratégicos para a tomada de decisão da gestão.

## Equipe 5

- Alice dos Santos Maganhoto
- Amanda Rodrigues Pristupa Martins
- Ana Júlia Gouveia Mazzi
- Ana Luiza Soares
- Mirian Suelen Passos
- Hanry de Sousa

## Documentação do Projeto

Para facilitar a navegação, acesse os documentos detalhados abaixo:

| Documento | Descrição | Link |
| --- | --- | --- |
| Requisitos Funcionais | Funcionalidades que o sistema deve ter. | [Acessar RF](./docs/rf.md) |
| Requisitos Não Funcionais | Critérios de performance, segurança e usabilidade. | [Acessar RNF](./docs/rnf.md) |
| Regras de Negócio | Regras que devem ser seguidas pelo sistema. | [Acessar RN](docs/rf.md) |
| Casos de Uso | Fluxos de utilização do sistema. | [Acessar UC](docs/uc.md) |
| Backlog e User Stories | Épicos, histórias de usuário e próximos passos. | [Acessar Backlog](./docs/backlog.md) |
| Arquitetura | Estrutura técnica e visão do sistema. | [Acessar Arquitetura](./docs/architecture2.md) |

## Funcionalidades principais

- Autenticação via e-mail e senha usando Firebase Auth.
- Cadastro de novos usuários com nome, empresa e CNPJ.
- Recuperação de senha por e-mail.
- Catálogo de produtos e fichas técnicas em PDF.
- Criação e acompanhamento de chamados de suporte.
- Envio de feedbacks e avaliações.
- Dashboard gerencial para o gestor.
- Chat de atendimento com histórico de conversas.
- Alternância entre tema claro e escuro.

## Tecnologias utilizadas

- Flutter
- Firebase Auth
- Cloud Firestore
- Provider
- Flutter Local Notifications
- fl_chart
- shared_preferences

## Estrutura do projeto

- `lib/features/` — funcionalidades e telas por módulo.
- `lib/data/` — modelos e repositórios de dados.
- `lib/services/` — integração com Firebase e notificações.
- `lib/core/` — provedores de estado e tema.
- `assets/fichasTecnicas/` — PDFs de fichas técnicas de produtos.

## Como executar

1. Instale as dependências:

Primeiro, adicione o pacote do Cloud Functions executando o comando abaixo no seu terminal:

```bash
flutter pub add cloud_functions:^6.2.0
```

Em seguida, certifique-se de que todas as outras dependências do projeto estejam baixadas e atualizadas:

```bash
flutter pub get
```
2. Execute o app:

```bash
flutter run
```


