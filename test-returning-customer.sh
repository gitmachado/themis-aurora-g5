#!/bin/bash

AI_BASE="http://localhost:3005"
PHONE="5585999888777"  # Same customer from previous tests

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

echo "🧪 Teste: Cliente retornando - NÃO deve re-coletar triagedata"
echo "═════════════════════════════════════════════════════════════════"

send_message "Oi, gostaria de marcar outra reunião sobre um novo caso"
send_message "Previdenciário"
send_message "Aposentadoria por tempo de contribuição"

echo ""
echo "✅ Teste enviado"
echo "Verificando que NÃO pediu: nome, email, cpf, disponibilidade"
sleep 3
docker logs themis-ai --tail 60 2>&1 | grep -E "(Maria|Resposta:|enviando:|horário)" | tail -30
