#!/bin/bash

AI_BASE="http://localhost:3005"
PHONE="5585999888777"  # Brand new phone
DELAY=2000

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

echo "🧪 Teste LIMPO: Cliente novo → Triagedata → Sim → Horários"
echo "═════════════════════════════════════════════════════════"

send_message "Olá, quero agendar uma consulta"
send_message "Maria Santos"
send_message "maria@example.com"
send_message "11144477735"
send_message "Trabalhista"
send_message "Demissão sem justa causa"
send_message "Tarde"
send_message "Sim"

echo ""
echo "✅ Teste enviado"
echo "Verificando logs..."
sleep 3
docker logs themis-ai --tail 80 2>&1 | grep -E "(NENHUMA|HORARIOS|Resposta:|fallback|Tool calls)" | tail -30
