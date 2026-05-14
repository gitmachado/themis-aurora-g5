# 🔧 Correção: AI Agendamento - Erro 401

## 🔴 Problema Identificado

Quando cliente solicita agendamento via WhatsApp, AI recebe erro:

```
GET /api/v1/appointments/slots?lawyerId=9e3aa25d-c8be-46d3-834d-ef4dd0c2fd96 401 UNAUTHORIZED
```

## 🔍 Causa Raiz

### Erro 1: lawyerId Incorreto
```
lawyerId sendo enviado: 9e3aa25d-c8be-46d3-834d-ef4dd0c2fd96
            ↑ Isso é o ID do LEAD/CLIENTE, não do ADVOGADO!
```

**O que deveria ser:**
- `lawyerId`: ID do advogado designado ao caso
- `clientId`: ID do lead/cliente (onde está erroneamente usar)

### Erro 2: Falta de Autenticação
Endpoint `/api/v1/appointments/slots` requer:
- Header: `Authorization: Bearer <valid_token>`
- Papel: LAWYER ou ADMIN

Mas AI está chamando sem token válido (ou com token genérico que não autentica).

---

## ✅ Solução

### 1. Corrigir Tool de Agendamento (AI)

**Arquivo**: `ai/src/tools/appointment.ts` (ou similar)

**Mudança**:

```typescript
// ANTES (ERRADO)
const slots = await apiClient.get(`/appointments/slots?lawyerId=${lead.id}`);

// DEPOIS (CORRETO)
const slots = await apiClient.get(`/appointments/slots?lawyerId=${process.env.DEFAULT_LAWYER_ID}`);
// Ou buscar o advogado correto do banco
```

### 2. Adicionar Token de Autenticação (AI → Server)

**Arquivo**: `ai/src/services/appointment-service.ts` (ou similar)

```typescript
// Gerar token com role SYSTEM ou ADMIN
const token = jwt.sign(
  { 
    id: 'ai-system',
    email: 'ai@themis.local',
    role: 'SYSTEM'  // Role especial para IA
  },
  process.env.JWT_SECRET,
  { expiresIn: '24h' }
);

// Usar em chamadas
headers: {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json'
}
```

### 3. Adicionar Role SYSTEM (Backend)

**Arquivo**: `server/src/types/models/user.ts` (ou similar)

```typescript
export type UserRole = 'CLIENT' | 'LAWYER' | 'ADMIN' | 'SYSTEM';
```

**Arquivo**: `server/src/middlewares/authMiddleware.ts`

```typescript
// SYSTEM role pode fazer chamadas de agendamento
if (user.role === 'SYSTEM' || user.role === 'ADMIN') {
  // Permitir acesso
}
```

### 4. Configurar Advogado Padrão

**Arquivo**: `.env`

```env
# Advogado para quem agendar quando não há outro disponível
DEFAULT_LAWYER_ID=<uuid-do-advogado-principal>
DEFAULT_LAWYER_EMAIL=advogado@themis.local
```

---

## 🔄 Fluxo Correto (Após Correção)

```
Cliente: "Quero agendar uma reunião"
   ↓
AI: Coleta informações
   ↓
AI: Busca advogado disponível
   ├─ GET /api/v1/appointments/slots?lawyerId=<LAWYER_UUID>
   ├─ Header: Authorization: Bearer <SYSTEM_TOKEN>
   └─ Response: 200 OK [slots disponíveis]
   ↓
AI: Oferece horários
   ↓
Cliente: "Terça 18h"
   ↓
AI: Cria agendamento
   ├─ POST /api/v1/appointments
   ├─ Body: { lawyerId: <LAWYER_UUID>, clientId: <CLIENT_UUID>, ... }
   ├─ Header: Authorization: Bearer <SYSTEM_TOKEN>
   └─ Response: 201 Created { id, status: "PENDING_APPROVAL" }
   ↓
Cliente: "✅ Pré-reservado! Advogado revisará em breve"
```

---

## 📋 Checklist de Correção

- [ ] Identificar ID correto do advogado padrão
- [ ] Gerar SYSTEM token na inicialização da AI
- [ ] Adicionar role SYSTEM ao backend
- [ ] Atualizar tool de agendamento para usar lawyerId correto
- [ ] Adicionar headers de autenticação nas chamadas
- [ ] Testar fluxo completo

---

## 🧪 Teste Rápido

```bash
# 1. Obter token SYSTEM
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/system-token \
  -H "Content-Type: application/json" \
  -d '{}' | jq -r '.token')

echo "Token: $TOKEN"

# 2. Testar endpoint com autenticação
curl http://localhost:3000/api/v1/appointments/slots \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"lawyerId":"<UUID-do-advogado>", "date":"2026-05-15"}'

# Resposta esperada: 200 OK com slots disponíveis
```

---

## 📞 Integração com G5-79

Esta correção é **independente** da feature G5-79, mas **complementar**:

- G5-79: Aprova/rejeita agendamentos criados (workflow de advogado)
- Isto: Permite que AI crie agendamentos inicialmente (workflow de cliente)

Ambas trabalham juntas perfeitamente! ✅

---

**Status**: ⏳ Pendente de Implementação
**Impacto**: Crítico para fluxo de agendamento via AI
**Deadline**: ASAP (bloqueia demo do cliente)
