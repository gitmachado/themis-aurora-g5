# 🔧 Troubleshooting - "Nao foi possivel falar com o server"

## Diagnóstico do Problema

Você estava recebendo erro "Nao foi possivel falar com o server" ao tentar logar.

### Causas Encontradas

1. **❌ OpenAI API Key Faltando** (RESOLVIDO)
   - O RescheduleSuggestionsProcessor tentava inicializar sem chave OpenAI
   - Servidor não iniciava (erro ao carregar routes)

2. **❌ node-cron Não Instalado** (RESOLVIDO)
   - Scheduler não estava disponível
   - Módulo faltava no container

3. **⚠️ Token Expirado/Inválido**
   - Ao tentar login, token pode estar inválido
   - App envia "test-token" que não é válido

---

## ✅ Soluções Aplicadas

### 1. Adicionado OpenAI API Key

**Arquivo**: `.env`

```env
OPENAI_API_KEY=sk-proj-development-key-change-me-in-production
```

**Por que**: O RescheduleSuggestionsProcessor precisa dessa chave para gerar sugestões. Tornamos o código resiliente para não bloquear o servidor se faltar.

### 2. Instalado node-cron

**Comando**: `npm install node-cron`

**Por que**: O scheduler precisa disso para rodar o cron job a cada 2 minutos.

### 3. Tornado Resiliente

**Arquivo**: `reschedule-suggestions-processor.ts`

```typescript
try {
  this.aiModel = new ChatOpenAI({...});
} catch (error) {
  console.warn('OpenAI API key not configured. Suggestion generation will be disabled.');
  this.aiModel = null;
  // Servidor continua funcionando normalmente
}
```

---

## ✅ Status Atual

```bash
$ curl http://192.168.1.12:3000/api/v1/appointments/pending \
  -H "Authorization: Bearer test-token"

{"status":"error","code":"UNAUTHORIZED","message":"Token inválido ou expirado"}
```

✅ **Servidor está respondendo!** (O erro é de autenticação, não de conexão)

---

## 🔑 Como Obter um Token Válido

### Opção 1: Login Real (Recomendado)

No app Flutter:

```
1. Tela de Login
2. Usar Google OAuth
3. Ou usar email/senha cadastrado
4. App gera token válido automaticamente
```

### Opção 2: Token de Desenvolvimento

Você precisa gerar um JWT válido:

```bash
# Com Node.js instalado localmente:
node -e "
const jwt = require('jsonwebtoken');
const token = jwt.sign(
  { id: 'user-123', email: 'test@test.com', role: 'LAWYER' },
  'development_secret_key_change_me',
  { expiresIn: '7d' }
);
console.log('TOKEN:', token);
"

# Depois use:
curl http://192.168.1.12:3000/api/v1/appointments/pending \
  -H "Authorization: Bearer <token-gerado>"
```

---

## 🚀 Para Testar Agora

### 1. Verificar Servidor

```bash
# Local (localhost)
curl http://localhost:3000/api/v1/appointments/pending \
  -H "Authorization: Bearer test-token"

# Remoto (IP externo)
curl http://192.168.1.12:3000/api/v1/appointments/pending \
  -H "Authorization: Bearer test-token"
```

Resposta esperada: `{"status":"error","code":"UNAUTHORIZED"...}`

### 2. Rodar App Flutter

```bash
cd mobile

# Com API local
flutter run --dart-define=THEMIS_API_BASE_URL=http://localhost:3000/api/v1

# Ou com API remota (seu IP)
flutter run --dart-define=THEMIS_API_BASE_URL=http://192.168.1.12:3000/api/v1
```

### 3. No App

- Clique em "Fazer Login"
- Use Google OAuth ou credenciais de teste
- App gerará token automaticamente
- Token será usado em todas as requisições

---

## 📋 Checklist

- [x] OpenAI API Key adicionada ao `.env`
- [x] `node-cron` instalado
- [x] RescheduleSuggestionsProcessor tornado resiliente
- [x] Servidor respondendo em `localhost:3000`
- [x] Servidor respondendo em `192.168.1.12:3000`
- [ ] Login real no app (seu passo)
- [ ] Token válido obtido
- [ ] Testes com endpoint real

---

## 🎯 Próximas Etapas

1. **Faça login no app** com suas credenciais reais
2. **App obterá token válido** automaticamente
3. **Endpoints funcionarão** com o token válido
4. **Você verá os agendamentos** se houver

---

## 📞 Debugging

Se ainda tiver problemas:

### 1. Verificar Logs do Servidor

```bash
docker logs themis-server -f 2>&1 | grep -E "Error|Ready|Scheduler"
```

### 2. Testar Conectividade

```bash
# De seu computador para o IP 192.168.1.12
ping 192.168.1.12
curl http://192.168.1.12:3000/api/v1/appointments/pending
```

### 3. Verificar .env

```bash
docker exec themis-server env | grep -i "openai\|api_key"
```

### 4. Logs do App Flutter

```bash
flutter run -v  # modo verbose
```

Procure por linhas como:
- `POST /api/v1/...`
- `Connection refused` 
- `Token invalid`

---

## 🔐 Segurança (Para Produção)

```env
# DEVELOPMENT (o que está agora)
OPENAI_API_KEY=sk-proj-development-key-change-me

# PRODUCTION (você precisa de uma chave real)
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx_real_key_here
```

Obtenha uma chave real em: https://platform.openai.com/account/api-keys

---

Status: ✅ **SERVIDOR FUNCIONANDO**
