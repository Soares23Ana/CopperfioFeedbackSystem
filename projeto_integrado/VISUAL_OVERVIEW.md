# Visual Project Overview

## 📊 Feature Status Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│                    PROJECT INTEGRADO - STATUS               │
│                   Copperfio Portal (Flutter)                │
└─────────────────────────────────────────────────────────────┘

AUTHENTICATION & CORE
├─ Firebase Auth Integration      ████████████████████ 100% ✅
├─ User Role Detection            ████████████████████ 100% ✅
├─ User Promotion to Gestor       ████████████████████ 100% ✅
└─ Navigation/Routing             ███████████████████░  95%  ✅

IMPLEMENTED FEATURES
├─ Feedback System                ████████████████████ 100% ✅
│  ├─ Submit feedback             ████████████████████ 100% ✅
│  ├─ Real-time streaming         ████████████████████ 100% ✅
│  ├─ Manager view                ████████████████████ 100% ✅
│  └─ Detail page                 ████████████████████ 100% ✅
│
└─ UI/UX Screens                  ███████████████████░  95%  ✅
   ├─ Login/Signup               ████████████████████ 100% ✅
   ├─ Home (User)                ████████████████████ 100% ✅
   ├─ Home (Manager)             ████████████████████ 100% ✅
   ├─ Dashboard                  ████████████████████ 100% ✅
   └─ Alerts                     ████████████████████ 100% ✅

PARTIAL FEATURES
├─ Dashboard Analytics           ███░░░░░░░░░░░░░░░░░  15%  ⚠️
│  └─ (Using mock data, not real feedback metrics)
│
├─ Alerts System                 ████░░░░░░░░░░░░░░░░  20%  ⚠️
│  └─ (Hardcoded only, no real data)
│
└─ Support Tickets (Chamados)    ██░░░░░░░░░░░░░░░░░░  10%  ⚠️
   ├─ Create form               ████████████░░░░░░░░  60%  ⚠️
   ├─ Form submission           ░░░░░░░░░░░░░░░░░░░░   0%  ❌
   └─ Manager view              ░░░░░░░░░░░░░░░░░░░░   0%  ❌

NOT IMPLEMENTED
├─ Chat/Messaging System          ██░░░░░░░░░░░░░░░░░░  10%  ❌
│  ├─ Firebase messages           ░░░░░░░░░░░░░░░░░░░░   0%  ❌
│  ├─ Send/receive messages       ░░░░░░░░░░░░░░░░░░░░   0%  ❌
│  └─ Real-time sync              ░░░░░░░░░░░░░░░░░░░░   0%  ❌
│
├─ File Upload System             ░░░░░░░░░░░░░░░░░░░░   0%  ❌
├─ Audio Recording                ░░░░░░░░░░░░░░░░░░░░   0%  ❌
├─ Push Notifications             ░░░░░░░░░░░░░░░░░░░░   0%  ❌
└─ Search/Filter                  ░░░░░░░░░░░░░░░░░░░░   0%  ❌

OVERALL COMPLETION: 56/100 points (56%) ⚠️
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                           │
│                    (MVVM Architecture)                       │
└─────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
            ┌───────┴────┐  ┌───┴────┐  ┌──┴───────┐
            │  Views     │  │Provider│  │ Services │
            │ (.dart UI) │  │ State  │  │          │
            └───────┬────┘  └───┬────┘  └──┬───────┘
                    │           │          │
         ┌──────────┴──────────┐│          │
         │                     ││      ┌───┴────────────┐
         │   ChangeNotifier    ││      │ Firebase SDK   │
         │    (ViewModels)     ││      └────┬───────────┘
         │   • ChatViewModel   ││           │
         │   • ChamadosVM      ││       ┌───┴───────────┐
         │   • FeedbacksVM     ││       │ Firestore DB  │
         │   • DashboardVM     ││       │ Collections:  │
         └─────────────────────┘│       │ • users       │
                               │       │ • feedbacks   │
                               │       │ • messages ❌  │
                               │       │ • chamados ❌  │
                               │       │ • alerts ❌    │
                               │       └───────────────┘
                               │
                     ┌─────────┴──────────┐
                     │  Repositories &    │
                     │  Services          │
                     │ • AuthService ✅   │
                     │ • FirestoreService │
                     │   (partial) ⚠️     │
                     │ • ChatRepository ❌│
                     └────────────────────┘
```

---

## 📱 User Journey Maps

### Cliente (Regular User) Flow

```
┌──────────────┐
│   Splash     │ (4 sec)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Login Page   │
└──────┬───────┘
       │ Enter email & password
       ▼
┌──────────────┐
│ Authenticate │ (Firebase Auth)
└──────┬───────┘
       │ tipo = "cliente"
       ▼
┌─────────────────────────────────┐
│   HomePageUsuario (Drawer)      │
├─────────────────────────────────┤
│ • Perfil ────────► PerfilPage   │
│ • Feedback ──────► FeedbackPage │
│                    └─► Firebase │
│                    └─► Success  │
│ • Chamados ──────► TicketCreate │
│ • Catálogo ──────► CatalogPage  │
│ • Chat ──────────► ChatPage ❌  │
│ • Sair ──────────► LoginPage    │
└─────────────────────────────────┘
```

### Gestor (Manager) Flow

```
┌──────────────┐
│   Splash     │ (4 sec)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Login Page   │
└──────┬───────┘
       │ Enter email & password
       ▼
┌──────────────┐
│ Authenticate │ (Firebase Auth)
└──────┬───────┘
       │ tipo = "empresa"
       ▼
┌────────────────────────────────────┐
│   HomePageGestor (Buttons)         │
├────────────────────────────────────┤
│ ┌─ Dashboard ──┐                  │
│ │ • Feedbacks  ├─► FeedbacksPage  │
│ │ • Alertas    ├─► AlertasPage    │
│ │ • Chamados   ├─► ChamadosPage ❌│
│ └────────────────────────────────┘ │
│ ┌─────────────────────────────────┐│
│ │ • Chat ────────► ChatPage ❌    ││
│ │ • Add Gestor ──► AddUserPage ✅ ││
│ │ • Logout ──────► LoginPage      ││
│ └─────────────────────────────────┘│
└────────────────────────────────────┘
```

---

## 💾 Firebase Data Structure (Current vs Needed)

### Implemented ✅

```
Firestore: projeto-integrado

collections/
├── users/ ✅ IMPLEMENTED
│   └── {uid}
│       ├── email: "user@email.com"
│       ├── nome: "João Silva"
│       ├── empresa: "Copperfio"
│       ├── tipo: "cliente" | "empresa"
│       ├── empresaId: "copperfio"
│       ├── createdAt: Timestamp
│       └── promotedAt: Timestamp (optional)
│
└── feedbacks/ ✅ IMPLEMENTED
    └── {auto-id}
        ├── mensagem: "Feedback text"
        ├── lote: "BATCH123"
        ├── userId: "uid_12345"
        ├── userName: "João Silva"
        ├── userEmail: "joao@email.com"
        ├── userType: "cliente"
        ├── empresaId: "copperfio"
        ├── data: Timestamp
        ├── status: "novo"
        └── isRead: false
```

### Needed ❌

```
collections/
├── messages/ ❌ NOT IMPLEMENTED
│   └── {auto-id}
│       ├── chatId: "chat_001"
│       ├── senderId: "uid_12345"
│       ├── senderName: "João"
│       ├── message: "Hello!"
│       ├── timestamp: Timestamp
│       ├── isRead: false
│       ├── messageType: "text"
│       └── attachmentUrl: "gs://..." (optional)
│
├── chamados/ ❌ NOT IMPLEMENTED
│   └── {auto-id}
│       ├── titulo: "MC - Qualidade..."
│       ├── descricao: "Full description"
│       ├── categoria: "Qualidade"
│       ├── lote: "BATCH123"
│       ├── userId: "uid_12345"
│       ├── userName: "João"
│       ├── userEmail: "joao@email.com"
│       ├── empresaId: "copperfio"
│       ├── createdAt: Timestamp
│       ├── updatedAt: Timestamp
│       ├── status: "novo" | "em_andamento" | "resolvido"
│       ├── prioridade: "baixa" | "media" | "alta"
│       ├── attachments: ["gs://...", "gs://..."]
│       └── respostaGestor: "Response text" (optional)
│
└── alerts/ ❌ NOT IMPLEMENTED
    └── {auto-id}
        ├── empresaId: "copperfio"
        ├── titulo: "Alert title"
        ├── descricao: "Alert description"
        ├── tipo: "sistema" | "network" | "dados"
        ├── severidade: "baixa" | "media" | "alta"
        ├── createdAt: Timestamp
        ├── resolvido: false
        └── resolvidoEm: Timestamp (optional)
```

---

## 🔧 Implementation Priority Matrix

```
┌─────────────────────────────────────────────────────────┐
│              PRIORITY × EFFORT MATRIX                   │
│                                                         │
│   CRITICAL    │      HIGH      │     MEDIUM    │ LOW  │
│   ────────    │      ────      │     ──────    │ ──  │
│  • Chat ✗    │  • Chamados   │  • Audio      │ Srch│
│    (Easy)     │    (Medium)   │    Recording  │     │
│               │  • Alerts ✗   │  • File Upload│     │
│               │    (Medium)   │  • Notif      │     │
│               │  • Dashboard  │                │     │
│               │    (Easy)     │                │     │
└─────────────────────────────────────────────────────────┘

Effort Estimate:
 ╔════════════════════════════════════════════╗
 ║ Chat System:       4-6 hours               ║
 ║ Chamados System:   6-8 hours               ║
 ║ Dashboard Data:    3-4 hours               ║
 ║ Alerts System:     3-4 hours               ║
 ║ File Upload:       4-5 hours               ║
 ║ Audio Recording:   4-5 hours               ║
 ╠════════════════════════════════════════════╣
 ║ TOTAL:             24-32 hours             ║
 ╚════════════════════════════════════════════╝
```

---

## 🎯 The 3 Most Critical Issues

### 1️⃣ Chat Repository is Empty

```
File: lib/data/repositories/chat_repository.dart

Current: ❌
┌────────────────────────────────┐
│ fetchMessages() → returns []   │  Always empty!
│ sendMessage() → does nothing   │  No-op
└────────────────────────────────┘

Needed: ✅
┌────────────────────────────────┐
│ fetchMessages()                │
│  └─ Query Firebase messages    │
│     └─ Return List<Message>    │
│                                │
│ sendMessage()                  │
│  └─ Save to Firebase          │
│     └─ Update UI in real-time  │
│                                │
│ messageStream()                │
│  └─ Real-time listener         │
│     └─ Update on new messages  │
└────────────────────────────────┘

Impact: Chat feature completely broken 🔴
```

---

### 2️⃣ Ticket Creation Form Doesn't Save

```
File: lib/features/chamados/view/ticket_create_page.dart

Current: ❌
┌───────────────────────────────────────┐
│ User fills form                       │
│   └─ Clicks "Enviar Chamado"         │
│       └─ Form validation passes       │
│           └─ Shows SnackBar "✓ sent!" │
│               └─ No database save ⚠️   │
└───────────────────────────────────────┘

Needed: ✅
┌───────────────────────────────────────┐
│ User fills form                       │
│   └─ Clicks "Enviar Chamado"         │
│       └─ Form validation passes       │
│           └─ Save to Firebase         │
│               └─ Shows success        │
│                   └─ Ticket in DB ✓   │
└───────────────────────────────────────┘

Impact: Ticket system completely non-functional 🔴
```

---

### 3️⃣ Dashboard Uses Mock Data

```
File: lib/features/dashboard/viewmodel/dashboard_viewmodel.dart

Current: ❌
┌─────────────────────────────────────┐
│ int feedbacks = 118;        // ❌   │
│ int satisfacao = 25;        // ❌   │
│ int alertas = 2;            // ❌   │
│ problemasPorLote = {...};   // ❌   │
└─────────────────────────────────────┘
All hardcoded, never updates!

Needed: ✅
┌─────────────────────────────────────┐
│ calculateFeedbackCount()            │
│ calculateSatisfaction()             │
│ calculateAlerts()                   │
│ groupProblemasByLote()              │
└─────────────────────────────────────┘
Real calculations from Firebase!

Impact: Analytics are meaningless 🟡
```

---

## 📋 File Checklist for Development

### Must Read (To Understand Current State)
- [ ] `lib/main.dart` - Provider setup
- [ ] `lib/services/auth_service.dart` - Auth implementation
- [ ] `lib/services/firestore_service.dart` - Firebase operations
- [ ] `lib/features/chat/viewmodel/chat_viewmodel.dart` - Where chat breaks
- [ ] `lib/features/chamados/view/ticket_create_page.dart` - Where form breaks
- [ ] `lib/features/dashboard/viewmodel/dashboard_viewmodel.dart` - Mock data

### Must Create (New Files)
- [ ] `lib/data/models/message_model.dart`
- [ ] `lib/data/models/chamado_model.dart` (enhanced)
- [ ] `lib/data/models/alert_model.dart`

### Must Update (Existing Files)
- [ ] `lib/data/repositories/chat_repository.dart` (implement methods)
- [ ] `lib/services/firestore_service.dart` (add new collections)
- [ ] `lib/features/chat/viewmodel/chat_viewmodel.dart` (use real data)
- [ ] `lib/features/chamados/view/ticket_create_page.dart` (wire to Firebase)
- [ ] `lib/features/dashboard/viewmodel/dashboard_viewmodel.dart` (calculate real metrics)

---

## ✅ Testing Strategy

```
┌─────────────────────────────────────────┐
│           TEST CHECKLIST               │
├─────────────────────────────────────────┤
│ Authentication                          │
│  ✅ [x] Login with valid credentials   │
│  ✅ [x] Login with invalid credentials │
│  ✅ [x] Signup creates user as cliente │
│  ✅ [x] Password reset works           │
│  ✅ [x] Navigate to correct home page  │
│                                         │
│ Feedback (Currently Working)            │
│  ✅ [x] Submit feedback                │
│  ✅ [x] Appears in manager view        │
│  ✅ [x] Real-time updates              │
│                                         │
│ Chat (Needs Implementation)             │
│  ⬜ [ ] Send message                   │
│  ⬜ [ ] Receive message                │
│  ⬜ [ ] Real-time sync                 │
│  ⬜ [ ] Message appears for both users│
│                                         │
│ Chamados (Needs Implementation)         │
│  ⬜ [ ] Create ticket                  │
│  ⬜ [ ] Save to Firebase               │
│  ⬜ [ ] Appears in manager view        │
│  ⬜ [ ] Update status                  │
│  ⬜ [ ] Attach evidence                │
│                                         │
│ Dashboard (Needs Real Data)             │
│  ⬜ [ ] Metrics match actual data      │
│  ⬜ [ ] Charts update in real-time     │
│  ⬜ [ ] Satisfaction calculated        │
└─────────────────────────────────────────┘
```

---

## 🚀 Success Criteria

```
MVP (Minimum Viable Product):
  ✅ Authentication
  ✅ Feedback system working
  ❌ Chat working (CRITICAL)
  ❌ Chamados working (CRITICAL)
  ⚠️ Dashboard shows real data (IMPORTANT)

Release Ready:
  ✅ All MVP features
  ✅ File uploads
  ✅ Push notifications
  ✅ Audio recording
  ✅ Advanced search
  ✅ Performance optimized
  ✅ Security rules enforced
```

---

## 📞 Support Summary

**What's Working Great**: Auth, Feedback, Navigation  
**What Needs Fixing**: Chat, Chamados (Forms without Firebase)  
**What Needs Enhancement**: Dashboard (Mock data only)  

**Total Estimated Effort to MVP**: 20-27 hours  
**Current Completion**: 56%  
**Recommended Next Action**: Implement Chat system (highest impact, lowest effort)
