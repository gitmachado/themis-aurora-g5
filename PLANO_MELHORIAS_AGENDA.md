# 📋 Plano: Melhorias na Feature de Agenda

## 🎯 Requisitos

1. ✅ Mostrar **número e nome do cliente/lead** no card de agendamento pendente
2. ✅ Mostrar essas informações na **tela de detalhes** do agendamento
3. ✅ Ao aprovar, **direcionar para tela de detalhes** do evento aprovado na agenda do escritório
4. ✅ **Garantir infos corretas** cadastradas pela IA
5. ✅ Implementar **validação na ferramenta de agendamento** (similar à triagem)

---

## 🔍 Análise Atual

### Estado do Card de Agendamento (`lawyer_appointment_approval_screen.dart:107-150`)

**O que existe:**
- ✅ Já busca clientName e whatsappNumber do banco de dados
- ✅ Tenta encontrar por `appointment.clientId`
- ✅ Fallback para buscar pelo nome no título/descrição
- ✅ Tenta `aiOriginalData` se vazio

**O que falta:**
- ❌ Campo `clientPhoneNumber` ou `whatsappNumber` no modelo Appointment
- ❌ Exibição do número no card (UI)
- ❌ Tela de detalhes completa do appointment pending

---

### Estado da Ferramenta de Agendamento (`appointment.ts:78-100`)

**O que existe:**
- ✅ Validação: se falta `time` para schedule, retorna mensagem
- ✅ Validação: se falta slots, sugere outra data

**O que falta:**
- ❌ Validação dos PRÉ-REQUISITOS para agendar:
  - Falta verificar se cliente foi **triado** (tem nome, email, cpf)
  - Falta verificar se **tipo de caso** foi coletado
  - Falta verificar se **descrição do caso** foi coletada
- ❌ Se faltar dados, REJEITAR com mensagem clara (similar à triagem)

---

### Estado do Fluxo de Aprovação

**O que existe:**
- ✅ Endpoint `PATCH /appointments/:id/approve`
- ✅ Notificação para cliente
- ✅ Socket event disparado

**O que falta:**
- ❌ Navegar automaticamente para a tela de detalhes após aprovação
- ❌ Passar appointmentId para a rota

---

### Estado do Modelo Appointment

**Arquivo:** `server/src/types/models/src/appointment.model.ts`

**O que pode estar faltando:**
- ❌ Campo para armazenar informações do cliente/lead (nome, whatsapp)
- ❌ Rastreabilidade de dados cadastrados pela IA

---

## 📐 Plano de Implementação

### Fase 1: Backend - Enriquecer Dados de Appointment

#### 1.1 Expandir Modelo Appointment
**Arquivo:** `server/src/types/models/src/appointment.model.ts`

Adicionar campos opcionais:
```typescript
clientName?: string;          // "Jonas Lacerda"
clientWhatsappNumber?: string; // "5585988..." (normalizado)
```

#### 1.2 Expandir Create/Get Appointment
**Arquivo:** `server/src/services/implementations/appointment.service.ts`

Ao criar appointment from triageData:
```typescript
// Ao criar, capturar nome e whatsapp do lead
const appointment = await appointmentRepository.create({
  // ... campos existentes
  clientName: dto.clientName,           // Vem do triage
  clientWhatsappNumber: dto.whatsappNumber, // Vem do triage
});
```

#### 1.3 Validação na Ferramenta de Agendamento
**Arquivo:** `ai/src/tools/appointment.ts:78-100`

NOVOS: Validadores PRÉ-AGENDAMENTO

```typescript
async function handleScheduleAppointment(...) {
  // NOVO: Validar triagedata antes de agendar
  const validation = {
    hasName: !!triage.name,
    hasEmail: !!triage.email,
    hasCPF: !!triage.cpf,
    hasCaseType: !!triage.caseType,
    hasCaseDescription: !!triage.caseDescription,
    hasAvailability: !!triage.contactAvailability,
  };
  
  const missing = [
    !validation.hasName && "nome completo",
    !validation.hasEmail && "e-mail",
    !validation.hasCPF && "CPF",
    !validation.hasCaseType && "tipo de caso",
    !validation.hasCaseDescription && "descrição do caso",
  ].filter(Boolean);
  
  if (missing.length > 0) {
    return `NÃO posso agendar ainda. Faltam os seguintes dados: ${missing.join(", ")}. 
Por favor, peça ao cliente que forneça essas informações antes de agendar.`;
  }
  
  // Continuar com agendamento...
}
```

---

### Fase 2: API Response - Incluir Dados do Cliente

#### 2.1 Expandir Resposta GET Appointment
**Arquivo:** `server/src/repositories/implementations/appointment.repository.ts`

```typescript
// Ao retornar appointment, incluir clientName e clientWhatsappNumber
SELECT ..., client_name as "clientName", client_whatsapp_number as "clientWhatsappNumber"
```

---

### Fase 3: Mobile - Exibir e Navegar

#### 3.1 Card de Agendamento Pendente
**Arquivo:** `mobile/lib/features/lawyer/schedule/presentation/widgets/appointment_card.dart`

Adicionar:
```dart
// No card, exibir:
- Nome: "Jonas Lacerda"
- WhatsApp: "(85) 98882-5242" (formatado)
```

#### 3.2 Tela de Detalhes do Appointment
**Arquivo:** `mobile/lib/features/lawyer/schedule/presentation/screens/appointment_detail_screen.dart` (criar ou expandir)

Exibir:
```dart
// Seção de Cliente
clientName: "Jonas Lacerda"
clientPhone: "(85) 98882-5242"
clientCPF: "086.625.424-25" (mascarado)

// Seção de Caso
caseType: "Direito Trabalhista"
caseDescription: "Demissão sem justa causa"
urgency: "Alta"

// Seção de Reunião
date: "14 de maio de 2026 às 13:00"
duration: "1 hora"
status: "PENDING_APPROVAL"
```

#### 3.3 Navegação Pós-Aprovação
**Arquivo:** `mobile/lib/features/lawyer/schedule/presentation/providers/appointment_providers.dart`

```dart
// No approvAppointment, após sucesso:
_ref.read(appRouterProvider).pushNamed(
  'appointment-detail',
  extra: appointmentId,
);
```

---

## 🔄 Fluxo Completo (Após Implementação)

### Cenário: Lawyer Aprova Agendamento da IA

```
1. IA coleta: Nome, Email, CPF, Tipo Caso, Descrição, Disponibilidade
   
2. IA tenta agendar
   ├─ VALIDAR: Todos os campos preenchidos?
   ├─ SIM → Agendar com clientName e clientWhatsappNumber
   └─ NÃO → REJEITAR: "Faltam: [lista]. Por favor, peça ao cliente..."

3. Compromisso criado em PENDING_APPROVAL com dados do cliente

4. Lawyer vê na tela "Agendamentos da IA":
   ├─ Card mostra: 
   │  ├─ "Jonas Lacerda"
   │  ├─ "(85) 98882-5242"
   │  ├─ "Direito Trabalhista"
   │  └─ "14 de maio, 13:00"
   
5. Lawyer toca no card → Tela de detalhes
   ├─ Mostra:
   │  ├─ Nome: Jonas Lacerda
   │  ├─ CPF: 086.625.424-25
   │  ├─ Email: jonas@cliente.com
   │  ├─ Caso: Demissão sem justa causa
   │  ├─ Urgência: Alta
   │  └─ Data/Hora: 14 de maio, 13:00
   
6. Lawyer clica "Aprovar"
   ├─ Compromisso vira SCHEDULED
   ├─ Socket event dispara
   ├─ Navega AUTOMÁTICamente para agenda do escritório
   └─ Mostra evento aprovado na agenda ✅
```

---

## 🗄️ Impacto nos Bancos de Dados

### Schema SQL

**Adicionar colunas a `appointments`:**
```sql
ALTER TABLE appointments ADD COLUMN client_name VARCHAR(255) NULL;
ALTER TABLE appointments ADD COLUMN client_whatsapp_number VARCHAR(20) NULL;
```

---

## 📋 Checklist de Implementação

### Backend
- [x] Expandir modelo Appointment (clientName, clientWhatsappNumber)
- [x] Atualizar migration SQL
- [x] Atualizar repository para salvar esses campos
- [x] Atualizar service.create() para capturar dados
- [x] Adicionar validação pré-agendamento (triagedata)
- [x] Testar: agendar SEM todos os dados = REJEITA e pede mais

### API
- [x] Expandir GET /appointments retornar clientName, clientWhatsappNumber
- [x] Expandir bot.controller para incluir esses campos na resposta

### AI
- [x] Atualizar appointment.ts com validação
- [x] Passar whatsappNumber na chamada de scheduleAppointment

### Mobile
- [ ] Atualizar modelo Appointment (adicionar clientName, clientWhatsappNumber)
- [ ] Atualizar appointment_card.dart para exibir nome e número
- [ ] Criar/expandir appointment_detail_screen.dart
- [ ] Adicionar rota para appointment-detail com ID
- [ ] Adicionar navegação automática pós-aprovação
- [ ] Integrar socket event para atualizar após aprovação

### Testes
- [ ] E2E: IA coleta dados → Agenda → Lawyer aprova → Navega para detalhes → Vê dados corretos
- [ ] Validação: IA tenta agendar SEM preencher tudo → Rejeita
- [ ] Sync: Múltiplos lawyers veem agendamento atualizado em tempo real

---

## 🎯 Prioridade

1. 🔴 ALTA - Backend: Enriquecer dados + Validação (bloqueia tudo mais)
2. 🔴 ALTA - Mobile: Card com nome/número (UX básica)
3. 🟡 MÉDIA - Mobile: Tela de detalhes
4. 🟡 MÉDIA - Mobile: Navegação pós-aprovação

---

## 📝 Arquivos a Modificar

### Backend (Server)
1. `server/src/types/models/src/appointment.model.ts` - Adicionar campos
2. `server/database/schema.sql` - Adicionar colunas
3. `server/src/repositories/implementations/appointment.repository.ts` - Salvar dados
4. `server/src/services/implementations/appointment.service.ts` - Capturar dados
5. `server/src/controllers/implementations/bot.controller.ts` - Retornar dados
6. `ai/src/tools/appointment.ts` - Validar triagedata

### Mobile (Flutter)
1. `mobile/lib/features/lawyer/schedule/domain/entities/appointment.dart` - Adicionar campos
2. `mobile/lib/features/lawyer/schedule/data/models/appointment_model.dart` - Adicionar campos
3. `mobile/lib/features/lawyer/schedule/presentation/widgets/appointment_card.dart` - Exibir dados
4. `mobile/lib/features/lawyer/schedule/presentation/screens/lawyer_appointment_approval_screen.dart` - Melhorar
5. `mobile/lib/features/lawyer/schedule/presentation/screens/appointment_detail_screen.dart` - Criar/expandir
6. `mobile/lib/app/routes/app_router.dart` - Adicionar rota + navegação

---

## 🚀 Impacto Estimado

- Mudanças: ~15-20 arquivos
- Linhas: ~300-400 adicionadas
- Comple xidade: Média
- Tempo: ~4-6 horas
- Risco: Baixo (mudanças bem isoladas)

---

## ✅ Confirmação Necessária

Confirmar com o usuário ANTES de implementar:
1. ✅ Entendimento do fluxo?
2. ✅ Ordem de prioridade correta?
3. ✅ Todas as mudanças cobertas?
4. ✅ Algo a adicionar?
