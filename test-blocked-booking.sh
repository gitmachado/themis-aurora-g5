#!/bin/bash

AI_BASE="http://localhost:3005"
PHONE="5585999888888"  # New customer - no prior appointments

send_message() {
  local text=$1
  echo "📱 Enviando: \"$text\""
  curl -s -X POST "$AI_BASE/webhook" \
    -H "Content-Type: application/json" \
    -d @- << EOF
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

echo "🧪 Teste: Novo cliente com Triagedata completa"
echo "════════════════════════════════════════════════════════"

send_message "Olá, gostaria de agendar uma consulta"
send_message "Carlos Oliveira"
send_message "carlos@example.com"
send_message "22244488812"
send_message "Herança"
send_message "Partilha de bens"
send_message "Manhã"
send_message "Sim"

echo ""
echo "✅ Teste enviado"
echo ""
echo "Verificando resposta com horários..."
sleep 3
docker logs themis-ai --tail 100 2>&1 | grep -E "(Carlos|pré-reservada|disponíveis)" | tail -10
