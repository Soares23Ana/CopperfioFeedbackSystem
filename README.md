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


## Como gerar e instalar o APK (Android)

Atualmente, a geração do instalador está disponível apenas para dispositivos **Android**. Siga os passos abaixo para gerar o arquivo e instalá-lo no celular:

### 1. Gerar o arquivo APK
No terminal da raiz do projeto, execute o comando abaixo para gerar a versão final (release) do aplicativo:
```bash
flutter build apk --release
````

### 2. Localizar o arquivo
Após a finalização do processo, o arquivo APK gerado estará na seguinte pasta dentro do projeto:

build/app/outputs/flutter-apk/app-release.apk

(Nota: dependendo da versão do Flutter, o caminho também pode ser estruturado como build/app/outputs/apk/release/app-release.apk).

### 3. Instalação no dispositivo
* Envio: Pegue o arquivo app-release.apk e envie para o celular onde deseja instalar (você pode enviar pelo WhatsApp, e-mail ou cabo USB).

* Download: No celular, baixe o arquivo recebido.

* Permissão: Ao abrir o arquivo, o Android utilizará o Instalador de Pacotes do sistema.

* Verificação de Segurança: Como o app não está na Google Play Store, o Android (via Google Play Protect) pode exibir um aviso de "App Desconhecido". Pode permitir e avançar com a instalação normalmente.

* Pronto! O aplicativo estará instalado e pronto para o uso.


