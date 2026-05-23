# 🔧 Correção: Email Recovery - Debugar e Normalizar

## Problema Identificado

O login não estava normalizando emails com **lowercase**, enquanto o registro sim. Isso causava inconsistências ao procurar o email em Firestore durante a recuperação de senha.

### Antes (❌ PROBLEMA):
```dart
// No login - apenas trim, sem lowercase
signInWithEmailAndPassword(email: email.trim(), ...)

// No registro - trim + lowercase
_normalizeEmail(email) => email.trim().toLowerCase()
```

## Correções Implementadas

### 1. **Frontend (lib/services/auth_service.dart)**
- ✅ `signIn()` agora normaliza email com `.toLowerCase().trim()`
- ✅ Adicionados logs detalhados em `sendPasswordRecoveryCode()`
- ✅ Adicionados logs em `existsUserByEmail()` com debug detalhado

### 2. **Backend (functions/index.js)**
- ✅ Logs adicionados em `sendPasswordRecoveryCode()`
- ✅ Logs adicionados em `validatePasswordRecoveryCode()`
- ✅ Logs adicionados em `resetPasswordWithCode()`

### 3. **Script de Migração (functions/normalize_emails.js)**
- ✅ Script para verificar e normalizar todos os emails em Firestore
- ✅ Verifica fields `email` e `email_lower`
- ✅ Valida dados em `password_recovery`

---

## 📋 Instruções de Teste

### Passo 1: Limpar dados de teste (OPCIONAL)
Se havia usuários de teste com emails não-normalizados, delete-os do Firestore antes de testar.

### Passo 2: Deploy do Backend
```bash
cd functions
npm install  # se necessário
firebase deploy --only functions
```

### Passo 3: Executar App em Debug
```bash
flutter run -v
```

Isso mostrará os logs da aplicação.

### Passo 4: Testar Recuperação de Senha
1. Abra a tela de Login
2. Clique em "Esqueci minha senha"
3. Digite o email registrado (pode ter maiúsculas, espaços)
4. **Verifique os logs do console** para ver:
   ```
   [EXISTE_EMAIL] Procurando por: seu@email.com
   [EXISTE_EMAIL] Email normalizado: seu@email.com
   [EXISTE_EMAIL] ✓ Encontrado em email_lower
   ```

### Passo 5: Verificar Logs do Backend
1. Vá para [Firebase Console](https://console.firebase.google.com)
2. Projeto > Funções > Logs
3. Procure por:
   ```
   [RECUPERAÇÃO] Email original: seu@email.com
   [RECUPERAÇÃO] Email normalizado: seu@email.com
   Procurando email recuperação: seu@email.com
   ```

---

## 🐛 Se Ainda Não Funcionar

### Checklist:
- [ ] O email é exatamente igual em Firestore e Firebase Auth?
- [ ] Há espaços invisíveis antes/depois?
- [ ] O documento do usuário existe em Firestore?
- [ ] O campo `email_lower` está preenchido?

### Debug Avançado:
```javascript
// No Firebase Console -> Firestore, verifique:
// Collection: users
// Procure por um documento
// Verifique os campos: email, email_lower, uid, etc.

// Se faltam dados, pode precisar recadastrar o usuário
```

---

## 📊 Checklist de Validação

- [ ] Login funciona com email registrado
- [ ] Tela "Esqueci Senha" aparece
- [ ] Digitar email e clicar em "Enviar Código"
- [ ] Código é recebido por email
- [ ] Código é aceito na próxima tela
- [ ] Pode fazer login com nova senha
- [ ] Logs aparecem no console do Flutter e Firebase

---

## 🔍 Logs Esperados

### Frontend Console:
```
[RECUPERAÇÃO] Email original: usuario@email.com
[RECUPERAÇÃO] Email normalizado: usuario@email.com
[RECUPERAÇÃO] Chamando função backend com email: usuario@email.com
[EXISTE_EMAIL] Procurando por: usuario@email.com
[EXISTE_EMAIL] Email normalizado: usuario@email.com
[EXISTE_EMAIL] ✓ Encontrado em email_lower
[RECUPERAÇÃO] Código enviado com sucesso para: usuario@email.com
```

### Backend Console (Firebase Functions):
```
Procurando email recuperação: usuario@email.com
Usuário encontrado para email: usuario@email.com
Validando código para email: usuario@email.com código: 12345
Código validado com sucesso para: usuario@email.com
Resetando senha para email: usuario@email.com
Atualizando senha para usuário: uid123
Senha resetada com sucesso para: usuario@email.com
```

---

## 💡 Próximas Etapas

Se tudo funcionar:
1. ✅ Remover logs de debug (opcional, ajuda a manter o app limpo)
2. ✅ Testar com vários usuários
3. ✅ Testar expiração do código (espere > 1 minuto)
4. ✅ Testar reenviar código
