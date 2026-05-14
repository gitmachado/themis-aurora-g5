#!/bin/bash

AI_BASE="http://localhost:3005"
PHONE="5585999888777"  # Same phone as previous test

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

echo "🧪 Teste: Cliente seleciona horário → Schedule"
echo "═════════════════════════════════════════════"

send_message "11:00 está ótimo"

echo ""
echo "✅ Teste enviado"
sleep 3
docker logs themis-ai --tail 50 2>&1 | grep -E "(schedule|SCHEDULE|pré-reservada|confirmada)" | tail -10
