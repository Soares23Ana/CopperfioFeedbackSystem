# Key Files Reference & Implementation Map

## Complete File Tree with Status

```
projeto_integrado/
│
├── lib/
│   ├── main.dart ✅
│   │   └── Initializes Firebase, Provider setup with 5 ViewModels
│   │   └── Entry point: SplashIntroPage
│   │
│   ├── firebase_options.dart ✅
│   │   └── Firebase configuration for all platforms
│   │
│   ├── services/ (Core Service Layer)
│   │   ├── auth_service.dart ✅ FULLY WORKING
│   │   │   ├── signIn(email, password) → UserCredential
│   │   │   ├── register(email, password, nome, empresa) → void
│   │   │   ├── resetPassword(email) → void
│   │   │   ├── getUserType(userId) → String?
│   │   │   ├── getCurrentUserData() → Map<String, dynamic>?
│   │   │   ├── promoteUserToGestor(email) → String (uid)
│   │   │   ├── getUserByEmail(email) → Map<String, dynamic>?
│   │   │   └── currentUserId → String?
│   │   │
│   │   └── firestore_service.dart ⚠️ PARTIAL (only Feedback)
│   │       ├── criarFeedback(...) ✅ WORKING
│   │       └── getFeedbacks(empresaId) → Stream ✅ WORKING
│   │       └── MISSING: chat, chamados methods
│   │
│   ├── data/
│   │   ├── models/
│   │   │   └── usuario_model.dart ✅
│   │   │       └── Fields: nome, email, senha, endereco, 
│   │   │              dataNascimento, genero, empresa, role
│   │   │
│   │   ├── repositories/
│   │   │   └── chat_repository.dart ❌ STUB
│   │   │       ├── fetchMessages() → empty List
│   │   │       └── sendMessage(texto, usuarioId) → stub
│   │   │
│   │   └── usuario_mock_store.dart
│   │       └── Mock data for testing
│   │
│   └── features/ (MVVM Pattern)
│       │
│       ├── splash/ ✅ WORKING
│       │   └── view/
│       │       └── splash_intro_page.dart
│       │           └── 4 second splash → LoginPage
│       │
│       ├── auth/ ✅ FULLY WORKING
│       │   ├── view/
│       │   │   ├── login_page.dart
│       │   │   │   └── Firebase auth + role detection
│       │   │   ├── signup_page.dart
│       │   │   ├── forgot_password_page.dart
│       │   │   └── password_recovery_code_page.dart
│       │   │       (password_success_page.dart)
│       │   └── viewmodel/
│       │       ├── login_viewmodel.dart ✅
│       │       │   └── signIn() → tipo (cliente|empresa)
│       │       └── signup_viewmodel.dart ✅
│       │           └── cadastrarUsuario() → void
│       │
│       ├── home/ ✅ NAVIGATION WORKING
│       │   ├── view/
│       │   │   ├── home_page_usuario.dart ✅
│       │   │   │   └── Drawer menu for regular users
│       │   │   │   ├─ PERFIL → PerfilPage
│       │   │   │   ├─ ENVIAR FEEDBACK → FeedbackPage
│       │   │   │   ├─ CENTRAL DE CHAMADOS → TicketCreatePage
│       │   │   │   ├─ CATÁLOGO → CatalogPage
│       │   │   │   ├─ ASSISTÊNCIA → ChatPage (via ContactPage)
│       │   │   │   └─ SAIR → LoginPage
│       │   │   │
│       │   │   ├── home_page_gestor.dart ✅
│       │   │   │   └── Button menu for managers
│       │   │   │   ├─ Dashboard
│       │   │   │   ├─ Feedbacks
│       │   │   │   ├─ Alertas
│       │   │   │   ├─ Chamados
│       │   │   │   ├─ Chat
│       │   │   │   └─ Adicionar Gestor
│       │   │   │
│       │   ├── home_page.dart (unused?)
│       │   ├── catalog_page.dart (basic UI)
│       │   └── add_user_page.dart (manager promotion form)
│       │   └── viewmodel/
│       │       └── add_user_viewmodel.dart ✅
│       │           └── promoteUserToGestor(email) → bool
│       │
│       ├── profile/ ✅ BASIC UI
│       │   └── view/
│       │       └── perfil_page.dart
│       │           └── Shows user avatar, badges, stats
│       │
│       ├── chat/ ⚠️ PARTIAL (UI only, no Firebase)
│       │   ├── view/
│       │   │   ├── chat_page.dart
│       │   │   │   └── Displays vm.mensagens from ViewModel
│       │   │   │   └── Has message input field
│       │   │   │   └── Shows all UI elements correctly laid out
│       │   │   │
│       │   │   └── contact_page.dart
│       │   │       └── This is a CONTACT FORM, not chat
│       │   │       └── Fields: nome, empresa, endereco, etc
│       │   │       └── Confusing naming - should rename
│       │   │
│       │   └── viewmodel/
│       │       └── chat_viewmodel.dart ❌ STUB
│       │           ├── _mensagens: List<dynamic> (empty)
│       │           ├── carregarMensagens() → calls repo.fetchMessages()
│       │           └── enviarMensagem(texto) → calls repo.sendMessage()
│       │           └── PROBLEM: Repository returns [] always
│       │
│       ├── chamados/ ⚠️ PARTIAL (Mock data UI only)
│       │   ├── view/
│       │   │   ├── chamados_page.dart
│       │   │   │   └── ListView showing vm.chamados (mock)
│       │   │   │   └── Search functionality (UI only)
│       │   │   │
│       │   │   ├── ticket_create_page.dart
│       │   │   │   ├── Form fields:
│       │   │   │   │   ├─ Lote (TextFormField)
│       │   │   │   │   ├─ Description (TextFormField)
│       │   │   │   │   ├─ Category dropdown (Qualidade, Logística, Segurança, Manutenção)
│       │   │   │   │   └─ Evidence upload area
│       │   │   │   └── Buttons: "Enviar Chamado", "Cancelar"
│       │   │   │   └── PROBLEM: _sendTicket() only shows SnackBar
│       │   │   │
│       │   │   └── support_page.dart
│       │   │
│       │   └── viewmodel/
│       │       └── chamados_viewmodel.dart ❌ MOCK DATA
│       │           └── List<Chamado> chamados = [
│       │               Chamado(titulo: "MC - Qualidade...", codigo: "ICP-004", ...),
│       │               // ... 6 hardcoded tickets only
│       │           ]
│       │
│       ├── dashboard/ ✅ PARTIAL (UI + Mock Data)
│       │   ├── view/
│       │   │   ├── dashboard_page.dart ✅
│       │   │   │   ├── Shows: feedback count, satisfaction score, alerts
│       │   │   │   ├── Charts: Problems by batch (BarChart), Sentiment distribution
│       │   │   │   ├── Tab navigation to: Feedbacks, Alertas, Chamados
│       │   │   │   └── Uses data from DashboardViewModel (mock)
│       │   │   │
│       │   │   ├── feedbacks_page.dart ✅ WORKING
│       │   │   │   ├── StreamBuilder listening to vm.feedbacksStream()
│       │   │   │   ├── Search bar (UI only)
│       │   │   │   ├── ListView of feedback cards
│       │   │   │   ├── Click → FeedbackDetailPage
│       │   │   │   └── Real-time updates from Firebase ✅
│       │   │   │
│       │   │   ├── feedback_page.dart ✅ USER FORM
│       │   │   │   ├── Form fields:
│       │   │   │   │   ├─ Lote (TextFormField)
│       │   │   │   │   ├─ Feedback message (TextField)
│       │   │   │   │   ├─ Audio recording toggle (UI only)
│       │   │   │   │   └─ Send button
│       │   │   │   ├── On submit: vm.enviarFeedback() ✅
│       │   │   │   └── Success screen: FeedbackSuccessPage
│       │   │   │
│       │   │   ├── feedback_detail_page.dart ✅
│       │   │   │   ├── Shows all feedback metadata:
│       │   │   │   │   ├─ Empresa, Cliente, Email, Type
│       │   │   │   │   ├─ Status, Timestamp, Message
│       │   │   │   │   └─ All extracted from feedbackData Map
│       │   │   │   └── Read-only view
│       │   │   │
│       │   ├── feedback_success_page.dart ✅
│       │   │   └── Success message + navigation buttons
│       │   │
│       │   ├── alertas_page.dart ⚠️ MOCK DATA
│       │   │   ├── Shows hardcoded alerts:
│       │   │   │   ├─ "Falha na comunicação com servidor"
│       │   │   │   └─ "Conexão instável detectada"
│       │   │   ├── Shows hardcoded contacts: "Elektro Silva Ltda", "Construtronics"
│       │   │   └── Not connected to any real data source
│       │   │
│       │   └── viewmodel/
│       │       ├── dashboard_viewmodel.dart ❌ MOCK DATA
│       │       │   └── Static fields: feedbacks, satisfacao, alertas
│       │       │       problemasPorLote, distribuicaoSentimento, etc
│       │       │
│       │       ├── feedbacks_viewmodel.dart ✅ WORKING
│       │       │   ├── feedbacksStream() → real Firebase stream
│       │       │   └── enviarFeedback(mensagem, lote) ✅
│       │       │
│       │       └── alertas_viewmodel.dart ❌ MOCK DATA
│       │           └── List<Alerta> alertas = [hardcoded]
│       │           └── List<String> contatosImediatos = [hardcoded]
│       │
│       └── [OTHER UNUSED/PARTIAL FEATURES]
```

---

## Firebase Collections: Current vs. Needed

### Currently Implemented ✅

**Collection: `users`**
```
Document ID: Firebase Auth UID
{
  email: string              // "usuario@email.com"
  nome: string               // "João Silva"
  empresa: string            // "Copperfio"
  tipo: string               // "cliente" or "empresa"
  empresaId: string          // "copperfio" (hardcoded)
  createdAt: Timestamp       // Server timestamp
  promotedAt: Timestamp      // (optional) When promoted to gestor
}
```

**Collection: `feedbacks`**
```
Document ID: Auto-generated
{
  mensagem: string           // "Feedback text from user"
  lote: string              // "BATCH123" (optional - batch reference)
  userId: string            // Reference to users.uid
  userEmpresa: string       // "Copperfio"
  userName: string          // "João Silva"
  userEmail: string         // "joao@email.com"
  userType: string          // "cliente" (always from feedbacks)
  empresaId: string         // "copperfio"
  data: Timestamp           // When submitted
  status: string            // "novo" (hardcoded)
  isRead: boolean           // false (default)
}
```

---

### NOT Implemented ❌ (Need to Create)

**Collection: `messages` or `chats`** (For Chat System)
```
Document ID: Auto-generated
{
  chatId: string                    // "chat_001" or grouped by users
  senderId: string                  // Firebase UID
  senderName: string                // "João"
  receiverId: string                // (optional for group chat)
  message: string                   // "Hello"
  timestamp: Timestamp              // Message time
  isRead: boolean                   // false
  messageType: string               // "text", "audio", "file"
  attachmentUrl: string             // (optional) Firebase Storage ref
}

// OR for group/admin chat:
{
  chatId: string                    // Unique chat ID
  participants: [string]            // Array of UIDs
  message: string
  senderId: string
  timestamp: Timestamp
  // ... etc
}
```

**Collection: `chamados` or `tickets`** (For Support Tickets)
```
Document ID: Auto-generated (code: ICP-001, ICP-002, etc)
{
  id: string                    // Auto-generated or "ICP-004"
  titulo: string                // "MC - Qualidade: Calos de Mão"
  descricao: string             // Full description
  categoria: string             // "Qualidade", "Logística", "Segurança", "Manutenção"
  lote: string                  // Batch reference
  userId: string                // Who created the ticket
  userName: string              // "João Silva"
  userEmail: string             // "joao@email.com"
  empresaId: string             // "copperfio"
  createdAt: Timestamp
  updatedAt: Timestamp
  status: string                // "novo", "em_andamento", "resolvido", "fechado"
  prioridade: string            // "baixa", "media", "alta"
  attachments: [string]         // Firebase Storage references
  respostaGestor: string        // Manager's response (optional)
  respostaData: Timestamp       // When manager responded
}
```

**Collection: `alerts`** (For Real Alert System)
```
Document ID: Auto-generated
{
  empresaId: string             // "copperfio"
  titulo: string                // Alert title
  descricao: string             // Alert description
  tipo: string                  // "sistema", "network", "dados", etc
  severidade: string            // "baixa", "media", "alta", "critica"
  createdAt: Timestamp
  resolvido: boolean            // false (default)
  resolvidoEm: Timestamp        // (optional)
}
```

---

## State Management: Provider Setup

### In main.dart:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => DashboardViewModel()),
    ChangeNotifierProvider(create: (_) => FeedbacksViewModel()),
    ChangeNotifierProvider(create: (_) => AlertasViewModel()),
    ChangeNotifierProvider(create: (_) => ChamadosViewModel()),
    ChangeNotifierProvider(create: (_) => ChatViewModel()),
  ],
  child: const MyApp(),
)
```

### How to Access in Widgets:
```dart
// Read-only (no rebuild on change)
final vm = Provider.of<FeedbacksViewModel>(context, listen: false);

// With rebuild on change
final vm = Provider.of<FeedbacksViewModel>(context);

// Using Consumer pattern
Consumer<FeedbacksViewModel>(
  builder: (context, vm, child) {
    return Text('Feedbacks: ${vm...}');
  },
)
```

---

## Navigation Flow Diagrams

### Authentication & Role-Based Navigation:
```
┌─────────────────┐
│ SplashIntroPage │ (4 sec)
└────────┬────────┘
         ↓
┌─────────────────┐
│   LoginPage     │
└────────┬────────┘
         ↓
    [Check tipo]
         ├──────────────────────┬──────────────────────┐
         ↓                      ↓
    "cliente"             "empresa" (gestor)
         ↓                      ↓
┌────────────────────┐  ┌──────────────────────┐
│ HomePageUsuario    │  │ HomePageGestor       │
│ (Drawer Menu)      │  │ (Button Navigation)  │
└────────┬───────────┘  └──────────┬───────────┘
         │                         │
    5 menu items          6 navigation buttons
```

### User (Cliente) Menu Destinations:
```
HomePageUsuario Drawer
├─ PERFIL
│  └─ PerfilPage
│
├─ ENVIAR FEEDBACK
│  └─ FeedbackPage
│     └─ [Fill form & submit]
│        └─ FeedbackSuccessPage
│
├─ CENTRAL DE CHAMADOS
│  └─ TicketCreatePage
│     └─ [Fill form]
│
├─ CATÁLOGO
│  └─ CatalogPage
│
├─ ASSISTÊNCIA
│  └─ ContactPage (should be ChatPage)
│
└─ SAIR
   └─ LoginPage
```

### Manager (Gestor) Button Navigation:
```
HomePageGestor
├─ Dashboard Button
│  └─ DashboardPage
│     ├─ Tab: Dashboard (default)
│     ├─ Tab: Feedbacks → FeedbacksPage
│     │   └─ [Click feedback]
│     │      └─ FeedbackDetailPage
│     ├─ Tab: Alertas → AlertasPage
│     └─ Tab: Chamados → ChamadosPage
│
├─ Feedbacks Button
│  └─ FeedbacksPage (direct)
│
├─ Alertas Button
│  └─ AlertasPage (direct)
│
├─ Chamados Button
│  └─ ChamadosPage (direct)
│
├─ Chat Button
│  └─ ChatPage (direct)
│
├─ Adicionar Gestor Button
│  └─ AddUserPage
│
└─ Logout (AppBar icon)
   └─ LoginPage
```

---

## ViewModel Pattern Used

### Example: FeedbacksViewModel (✅ WORKING)
```dart
class FeedbacksViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final AuthService _authService = AuthService();

  // State
  Stream<QuerySnapshot<Map<String, dynamic>>> feedbacksStream() async* {
    // Implementation details...
  }

  Future<void> enviarFeedback({...}) async {
    // Implementation details...
    notifyListeners();  // Trigger UI rebuild
  }
}

// Usage in View:
final vm = Provider.of<FeedbacksViewModel>(context);
StreamBuilder<QuerySnapshot>(
  stream: vm.feedbacksStream(),
  builder: (context, snapshot) {
    // Build UI with snapshot data
  }
)
```

### Example: ChamadosViewModel (❌ MOCK DATA)
```dart
class ChamadosViewModel extends ChangeNotifier {
  // Should have:
  List<Chamado> _chamados = [];  // From Firebase
  Future<void> carregarChamados() // Fetch from Firebase
  Future<void> criarChamado(Chamado) // Save to Firebase
  
  // Currently has:
  final List<Chamado> chamados = [
    // 6 hardcoded Chamado objects only
  ];
}
```

---

## What Each Service Does

### AuthService (lib/services/auth_service.dart)
**Purpose**: All Firebase Authentication operations

**Key Methods**:
- `signIn(email, password)` → UserCredential - Login user
- `register(email, password, nome, empresa)` → UserCredential - Create new user (always tipo="cliente")
- `getUserType(userId)` → String? - Get user's role
- `getCurrentUserData()` → Map? - Get full user document
- `promoteUserToGestor(email)` → String (uid) - Upgrade cliente to empresa
- `resetPassword(email)` → void - Send password reset email
- `existsUserByEmail(email)` → bool - Check if user exists

---

### FirestoreService (lib/services/firestore_service.dart)
**Purpose**: Firebase Firestore database operations

**Currently Implemented**:
- `criarFeedback(...)` - Save feedback to Firebase
- `getFeedbacks(empresaId)` - Stream all company feedbacks

**Should Have But Missing**:
- Methods for chat messages (send, retrieve, stream)
- Methods for chamados/tickets (create, read, update, delete, stream)
- Methods for alerts (create, read, stream)
- Batch operations for performance
- Transaction support for multi-document updates

---

## Key Dart Classes & Models

### Feedback Structure (No explicit model, uses Map)
```dart
// From FeedbackDetailPage:
feedbackData['mensagem']      // string
feedbackData['lote']          // string
feedbackData['userEmpresa']   // string
feedbackData['userName']      // string
feedbackData['userEmail']     // string
feedbackData['status']        // string ("novo")
feedbackData['userType']      // string ("cliente")
feedbackData['data']          // Timestamp
```

### Chamado Model (Used in ViewModel)
```dart
class Chamado {
  final String titulo;
  final String descricao;
  final String codigo;
  final Color cor;
  
  Chamado({...});
}
```

### Alerta Model (Used in AlertasViewModel)
```dart
class Alerta {
  final String titulo;
  final String descricao;
  
  Alerta({...});
}
```

### UsuarioModel (Defined but underutilized)
```dart
class UsuarioModel {
  final String nome;
  final String email;
  final String? senha;
  final String? endereco;
  final String? dataNascimento;
  final String? genero;
  final String? empresa;
  final String role;  // "cliente" or "empresa"
}
```

---

## Form Validation

Using `validatorless: ^1.2.5` package:

```dart
TextFormField(
  validator: Validatorless.email('Email inválido'),
)

TextFormField(
  validator: Validatorless.required('Campo obrigatório'),
)

TextFormField(
  validator: Validatorless.multiple([
    Validatorless.required('Required'),
    Validatorless.email('Invalid email'),
  ]),
)
```

---

## Styling & Colors Used

**Primary Brand Color**: `Color(0xFF9C1818)` - Burgundy/Maroon (Copperfio)  
**Secondary Color**: `Color(0xFFDD4E41)` - Red-Orange  
**Accent Color**: `Color(0xFFB02820)` - Darker Burgundy  
**Background**: `Color(0xFFF3F1F6)` - Light Gray/Lavender  

These are used consistently across all screens for theming.

---

## Asset References

The app tries to load:
- `assets/images/copperfio_logo.png` - Company logo (may not exist, has errorBuilder fallback)

Uses Material Icons as fallback when images fail.

---

## Debugging Tips

To check what's happening:

1. **Check Firebase Rules** - Make sure Firestore security rules allow read/write
2. **Check empresaId** - Always hardcoded as "copperfio" for filtering
3. **Check User Type** - On login, tipo field determines which home page shows
4. **Check Timestamps** - Firestore uses `Timestamp.now()` for server-side timestamps
5. **Monitor Providers** - Use `Provider.of(context, listen: false)` for debugging

---

## Next Phase Implementation Order

1. **Fix Chat System** (Currently broken)
   - Create Message model
   - Add messages collection
   - Implement ChatRepository
   - Add real Firebase operations

2. **Fix Chamados System** (Currently mocked)
   - Create Chamado model with all fields
   - Add chamados collection
   - Implement CRUD in FirestoreService
   - Wire up form submission

3. **Fix Dashboard Analytics** (Currently mocked)
   - Calculate metrics from real feedbacks
   - Make alerts data-driven
   - Add real-time updates

4. **Add Missing Features**
   - File uploads (Firebase Storage)
   - Push notifications (Firebase Messaging)
   - Audio recording capability
   - Search/filter across collections
