#!/bin/bash

echo "🧪 Teste: Notificações para agendamentos da IA"
echo "═════════════════════════════════════════════════════════"
echo ""

# Usar curl para simular o fluxo completo
AI_BASE="http://localhost:3005"
SERVER_BASE="http://localhost:3000/api"

PHONE="5585999777888"
LAWYER_ID="11111111-1111-1111-1111-111111111111" # ID do advogado padrão

# Passo 1: Enviar mensagens para AI criar agendamento
echo "📱 PASSO 1: Enviando mensagens para criar agendamento via IA..."
send_ai_msg() {
  local text=$1
  curl -s -X POST "$AI_BASE/webhook" \
    -H "Content-Type: application/json" \
    -d @- << EOF >/dev/null
{
  "entry": [{
    "changes": [{
      "value": {
        "messages": [{
          "from": "$PHONE",
          "type": "text",
          "text": { "body": "$text" },
          "timestamp": "$(date -Iseconds)",
          "id": "msg_$(date +%s)"
        }]
      }
    }]
  }]
}
EOF
  sleep 2
}

send_ai_msg "Olá, gostaria de agendar"
send_ai_msg "Paulo Santos"
send_ai_msg "paulo@example.com"
send_ai_msg "75355467652"
send_ai_msg "Herança"
send_ai_msg "Partilha de bens"
send_ai_msg "Tarde"
send_ai_msg "Sim"

echo "✅ Agendamento criado via IA"
echo ""
sleep 2

# Passo 2: Verificar notificações ao advogado
echo "📢 PASSO 2: Verificando notificações do advogado..."
docker logs themis-server --tail 50 2>&1 | grep -i "NEW_APPOINTMENT_AI\|notificação" | tail -5

echo ""
echo "📋 PASSO 3: Verificar agendamentos pendentes..."
curl -s "$SERVER_BASE/v1/appointments/pending" \
  -H "Authorization: Bearer fake-token" \
  -H "Content-Type: application/json" | jq '.[] | {id, title, status, clientName, clientWhatsappNumber}' | head -20

echo ""
echo "════════════════════════════════════════════════════════="
echo "✅ Teste realizado. Verificar logs para mais detalhes."
