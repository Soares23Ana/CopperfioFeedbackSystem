# Implementation Checklist & Action Items

## Current Project Health: 55% Complete ⚠️

```
Features:
  Authentication       ████████████████████ 100% ✅
  Feedback System      ████████████████████ 100% ✅
  Navigation           ███████████████████  95%  ✅
  Chat System          ██░░░░░░░░░░░░░░░░░  10%  ❌
  Chamados/Tickets     ██░░░░░░░░░░░░░░░░░  10%  ❌
  Dashboard Analytics  ███░░░░░░░░░░░░░░░░  15%  ⚠️
  Alerts System        ████░░░░░░░░░░░░░░░  20%  ⚠️
  
Total: 56/100 points
```

---

## Critical Issues to Fix (Priority Order)

### 🔴 HIGH PRIORITY (Blocking Core Functionality)

#### Issue #1: Chat System Returns Empty Messages
**File**: `chat_repository.dart`  
**Problem**: Both methods are stubs
```dart
// Current (broken):
Future<List<dynamic>> fetchMessages() async {
  return [];  // ❌ Always empty!
}

Future<void> sendMessage(String texto, String usuarioId) async {
  // ❌ Does nothing!
}
```

**Impact**: 
- Users can't send/receive messages
- Chat feature is completely non-functional
- No data persistence

**Fix Required**:
- [ ] Create Message model
- [ ] Add messages Firebase collection
- [ ] Implement fetchMessages() with Firebase query
- [ ] Implement sendMessage() with Firebase write
- [ ] Add real-time Stream support
- [ ] Test send/receive flow

**Estimated Effort**: 4-6 hours

---

#### Issue #2: Chamados Form Doesn't Save
**File**: `ticket_create_page.dart` (line 70-80)  
**Problem**: Submit button only shows SnackBar
```dart
void _sendTicket() {
  if (_formKey.currentState?.validate() ?? false) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chamado enviado com sucesso!')),
    );
    // ❌ No actual save to database!
  }
}
```

**Impact**:
- Tickets aren't saved anywhere
- Managers can't see user tickets
- No ticket history
- No support ticket workflow

**Fix Required**:
- [ ] Create Chamado model with all fields
- [ ] Add chamados Firebase collection
- [ ] Add criarChamado() method to FirestoreService
- [ ] Wire _sendTicket() to actually save
- [ ] Add upload for evidence/attachments
- [ ] Create manager ticket view
- [ ] Test full ticket creation flow

**Estimated Effort**: 6-8 hours

---

#### Issue #3: ChatRepository is Used Nowhere Properly
**File**: `chat_viewmodel.dart`  
**Problem**: ViewModel tries to use stub methods
```dart
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  
  Future<void> carregarMensagens() async {
    _mensagens = await _repository.fetchMessages();  // Returns []
  }
}
```

**Impact**: Same as Issue #1 - messages list is always empty

**Fix**: Implement ChatRepository properly (addresses Issue #1)

---

### 🟠 MEDIUM PRIORITY (Partial Functionality)

#### Issue #4: Dashboard Shows Hardcoded Data
**File**: `dashboard_viewmodel.dart`  
**Problem**: All metrics are static
```dart
class DashboardViewModel extends ChangeNotifier {
  int feedbacks = 118;              // ❌ Hardcoded!
  int satisfacao = 25;              // ❌ Hardcoded!
  int alertas = 2;                  // ❌ Hardcoded!
  
  Map<String, int> problemasPorLote = {
    "CASE1": 10, "CASE2": 20, ...  // ❌ Hardcoded!
  };
}
```

**Impact**:
- Dashboard numbers never change
- Managers can't see real business metrics
- Charts don't reflect actual feedback data
- Real-time monitoring not possible

**Fix Required**:
- [ ] Add methods to calculate metrics from feedbacks collection
- [ ] Count feedbacks grouped by lote (problemasPorLote)
- [ ] Calculate satisfaction percentage from feedback sentiment
- [ ] Count real alerts from alerts collection
- [ ] Add Stream support for real-time updates
- [ ] Update DashboardPage to use new data

**Estimated Effort**: 3-4 hours

---

#### Issue #5: Alerts System is Hardcoded
**File**: `alertas_viewmodel.dart`  
**Problem**: Static alert list
```dart
final List<Alerta> alertas = [
  Alerta(titulo: "Falha na comunicação com o servidor...", ...),
  Alerta(titulo: "Conexão instável detectada", ...),
];
```

**Impact**:
- Alerts never update
- No real system monitoring
- Managers get stale information

**Fix Required**:
- [ ] Create alerts Firebase collection
- [ ] Add methods to create/read alerts
- [ ] Stream alerts in real-time
- [ ] Link alerts to actual system events
- [ ] Test alert triggering

**Estimated Effort**: 3-4 hours

---

#### Issue #6: Contact Page is Mislabeled
**File**: `contact_page.dart`  
**Problem**: Called "contact" but it's actually a contact FORM for Copperfio company  
**Impact**: User expects chat, gets a form

**Fix Required**:
- [ ] Rename to "contact_form_page.dart" or move to different feature
- [ ] OR replace with actual chat interface
- [ ] Update menu navigation accordingly

**Estimated Effort**: 1-2 hours

---

### 🟡 LOW PRIORITY (Nice to Have)

#### Issue #7: Audio Recording Not Implemented
**File**: `feedback_page.dart`  
**Problem**: Microphone icon exists but doesn't record
```dart
void _toggleRecording() {
  setState(() {
    _isAudioRecording = !_isAudioRecording;  // ❌ Just toggles flag
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_isAudioRecording ? 'Gravando áudio...' : 'Áudio pausado')),
  );
}
```

**Impact**: Users can't send voice feedback

**Fix Required**:
- [ ] Add audio_waveforms package
- [ ] Implement recording to Firebase Storage
- [ ] Add playback capability
- [ ] Link to feedback submission

**Estimated Effort**: 4-5 hours

---

#### Issue #8: Search/Filter are UI Only
**Problem**: Search fields on all pages don't actually filter

**Impact**: Can't find feedbacks, tickets, or messages

**Fix Required**:
- [ ] Implement search in FeedbacksPage
- [ ] Implement search in ChamadosPage
- [ ] Implement search in ChatPage
- [ ] Add client-side or Firebase filtering

**Estimated Effort**: 3-4 hours

---

#### Issue #9: No File Upload for Evidence
**Problem**: Chamados form has evidence area but can't upload

**Impact**: Users can't attach screenshots or files to tickets

**Fix Required**:
- [ ] Add firebase_storage package
- [ ] Implement file picker
- [ ] Upload to Firebase Storage
- [ ] Store reference in chamado document
- [ ] Display in manager view

**Estimated Effort**: 4-5 hours

---

## Files That Need to Be Created

### 1. Message Model
**Location**: `lib/data/models/message_model.dart`
```dart
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String messageType;  // "text", "audio", "file"
  final String? attachmentUrl;
  
  Message({...});
  
  factory Message.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

---

### 2. Chamado Model (Proper)
**Location**: `lib/data/models/chamado_model.dart`
```dart
class ChamadoModel {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria;
  final String lote;
  final String userId;
  final String userName;
  final String userEmail;
  final String empresaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;  // "novo", "em_andamento", "resolvido"
  final String prioridade;
  final List<String> attachments;
  final String? respostaGestor;
  
  ChamadoModel({...});
  
  factory ChamadoModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

---

### 3. Alert Model
**Location**: `lib/data/models/alert_model.dart`
```dart
class AlertModel {
  final String id;
  final String empresaId;
  final String titulo;
  final String descricao;
  final String tipo;
  final String severidade;
  final DateTime createdAt;
  final bool resolvido;
  final DateTime? resolvidoEm;
  
  AlertModel({...});
  
  factory AlertModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

---

## Files That Need Major Updates

### 1. chat_repository.dart
**Current**: 2 stub methods  
**Needed**: Full Firebase integration
```dart
class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Future<List<Message>> fetchMessages(String chatId) async {
    // Query messages collection
  }
  
  Future<void> sendMessage(Message message) async {
    // Save to Firebase
  }
  
  Stream<List<Message>> messageStream(String chatId) {
    // Real-time stream
  }
  
  Future<void> markAsRead(String messageId) async {
    // Update isRead flag
  }
}
```

---

### 2. firestore_service.dart
**Current**: Only feedback methods  
**Needed**: Add chat and chamados methods
```dart
class FirestoreService {
  // Existing (keep):
  Future<void> criarFeedback(...) async { ... }
  Stream<QuerySnapshot> getFeedbacks(String empresaId) { ... }
  
  // New - Chat:
  Future<void> enviarMensagem(Message message) async { ... }
  Stream<QuerySnapshot> getMessages(String chatId) { ... }
  Future<void> marcarComoLido(String messageId) async { ... }
  
  // New - Chamados:
  Future<String> criarChamado(ChamadoModel chamado) async { ... }
  Future<void> atualizarChamado(String id, Map data) async { ... }
  Stream<QuerySnapshot> getChamados(String empresaId) { ... }
  Future<DocumentSnapshot> getChamadoDetalhes(String id) async { ... }
  
  // New - Alerts:
  Future<void> criarAlerta(AlertModel alert) async { ... }
  Stream<QuerySnapshot> getAlertas(String empresaId) { ... }
  Future<void> resolverAlerta(String id) async { ... }
}
```

---

### 3. chamados_viewmodel.dart
**Current**: Only mock data  
**Needed**: Firebase integration with real CRUD
```dart
class ChamadosViewModel extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final AuthService _authService = AuthService();
  
  List<ChamadoModel> _chamados = [];
  bool _isLoading = false;
  String? _error;
  
  List<ChamadoModel> get chamados => _chamados;
  
  Future<void> carregarChamados() async {
    // Fetch from Firebase
  }
  
  Future<void> criarChamado(String titulo, ...) async {
    // Create and save
  }
  
  Stream<List<ChamadoModel>> getChamadosStream() {
    // Real-time updates
  }
}
```

---

### 4. chat_viewmodel.dart
**Current**: Stub implementation  
**Needed**: Real Firebase streaming
```dart
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  
  String? _currentChatId;
  List<Message> _mensagens = [];
  bool _estaCarregando = false;
  
  Stream<List<Message>> get mensagensStream {
    if (_currentChatId == null) return const Stream.empty();
    return _repository.messageStream(_currentChatId!);
  }
  
  Future<void> enviarMensagem(String texto) async {
    // Actual implementation
  }
  
  Future<void> iniciarChat(String userId) async {
    // Start chat with user
  }
}
```

---

## Implementation Timeline

### Week 1: Foundation
- [ ] Day 1-2: Create models (Message, Chamado, Alert)
- [ ] Day 3: Update FirestoreService with new methods
- [ ] Day 4: Fix chat_repository.dart
- [ ] Day 5: Wire ChatViewModel to real data

### Week 2: Features
- [ ] Day 1-2: Implement chamados collection and CRUD
- [ ] Day 3: Wire ticket creation form to Firebase
- [ ] Day 4: Create manager chamados view
- [ ] Day 5: Test full workflow

### Week 3: Polish
- [ ] Day 1-2: Connect dashboard to real data
- [ ] Day 3: Implement alerts properly
- [ ] Day 4: Add file upload support
- [ ] Day 5: Testing and bug fixes

---

## Testing Checklist

### Chat System
- [ ] Can send a message
- [ ] Messages appear in real-time for both users
- [ ] Message timestamp is correct
- [ ] Read status works
- [ ] Conversations persist after app close

### Chamados System
- [ ] Can create a ticket
- [ ] Ticket appears in manager view
- [ ] Can attach files
- [ ] Status can be updated
- [ ] Notifications sent on status change

### Dashboard
- [ ] Feedback count is accurate
- [ ] Charts update in real-time
- [ ] Metrics reflect actual data
- [ ] Satisfaction score calculated correctly

### General
- [ ] No crashes on any page
- [ ] All forms validate correctly
- [ ] Navigation works correctly
- [ ] Real-time updates work without lag

---

## Code Quality Checklist

- [ ] All ViewModels use proper Provider pattern
- [ ] All Firebase operations have error handling
- [ ] Timestamps use server-side Timestamp.now()
- [ ] Collection names consistent (lowercase, no spaces)
- [ ] Document IDs properly generated or auto
- [ ] Security rules set up correctly
- [ ] No hardcoded API keys or credentials
- [ ] Comments added to complex logic
- [ ] Consistent error messages for users

---

## Firebase Security Rules (Needed)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Users can write feedbacks, managers can read all
    match /feedbacks/{document=**} {
      allow create: if request.auth.uid != null;
      allow read: if request.auth.token.role == 'empresa' ||
                     request.auth.uid == resource.data.userId;
    }
    
    // Messages
    match /messages/{document=**} {
      allow read, write: if request.auth.uid != null;
    }
    
    // Chamados
    match /chamados/{document=**} {
      allow create: if request.auth.uid != null;
      allow read: if request.auth.token.role == 'empresa' ||
                     request.auth.uid == resource.data.userId;
      allow update: if request.auth.token.role == 'empresa';
    }
    
    // Alerts
    match /alerts/{document=**} {
      allow read: if request.auth.token.role == 'empresa';
      allow write: if false; // System only
    }
  }
}
```

---

## Success Criteria

### Minimum Viable Product (MVP)
- ✅ Authentication working
- ✅ Feedback system working
- ❌ Chat system (currently)
- ❌ Chamados system (currently)
- ⚠️ Dashboard with real data

### Full Release
- ✅ All of MVP
- ✅ Real-time notifications
- ✅ File uploads
- ✅ Audio recording
- ✅ Advanced search
- ✅ Complete analytics

---

## Current Project Status Summary

**Working Flawlessly**:
- Authentication (login, signup, password reset)
- Feedback submission and viewing
- Navigation and routing

**Need Completion**:
- Chat messaging system (no Firebase)
- Support tickets system (no Firebase)
- Dashboard analytics (using mock data)

**Next Steps**:
1. Fix chat (4-6 hours)
2. Fix chamados (6-8 hours)
3. Connect dashboard to real data (3-4 hours)
4. Add file uploads (4-5 hours)
5. Testing and deployment (ongoing)

**Estimated Total Remaining**: 20-27 hours
