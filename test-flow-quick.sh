#!/bin/bash

AI_BASE="http://localhost:3005"
PHONE="5585988882099"  # Different phone to start fresh
DELAY=2000

send_message() {
  local text=$1
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

echo "🧪 Teste rápido: Triagedata → Sim → Horários"
send_message "Quero agendar"
send_message "João Silva"
send_message "joao@example.com"
send_message "11144477735"
send_message "Civil"
send_message "Disputa"
send_message "Manhã"
send_message "Sim"

echo "✅ Teste enviado - verifique os logs..."
