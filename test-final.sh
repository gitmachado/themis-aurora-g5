#!/bin/bash

AI_BASE="http://localhost:3005"
PHONE="5585999999999"  # Brand new customer

send_message() {
  local text=$1
  echo "   📱 $text"
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

echo ""
echo "═════════════════════════════════════════════════════════════"
echo "🧪 TESTE E2E: Complete Appointment Booking Flow"
echo "═════════════════════════════════════════════════════════════"
echo ""
echo "📋 STEP 1: Initial Contact"
send_message "Olá! Gostaria de agendar uma consulta"
echo ""
echo "📋 STEP 2-7: Collect Triagedata"
send_message "Dr. Roberto Silva"
send_message "roberto@example.com"
send_message "75355467652"
send_message "Inventário"
send_message "Abertura e partilha de herança"
send_message "Tarde"
echo ""
echo "📋 STEP 8: Confirm - Should call check_open_appointments then show horários"
send_message "Sim"
echo ""
echo "📋 STEP 9: Client selects time - Should schedule appointment"
send_message "Prefe 14:00"
echo ""
echo "════════════════════════════════════════════════════════════="
echo "✅ Teste finalizado!"
echo ""
echo "📊 Verificando logs..."
sleep 3
echo ""
docker logs themis-ai --tail 150 2>&1 > /tmp/final_logs.txt

echo "📌 Triagedata Registration:"
grep "Roberto Silva" /tmp/final_logs.txt | head -1

echo ""
echo "📌 Pre-check for open appointments:"
grep -E "(CHECK_OPEN|NENHUMA_REUNIAO)" /tmp/final_logs.txt | head -2

echo ""
echo "📌 Availability Check:"
grep "CHECK_AVAILABILITY" /tmp/final_logs.txt | head -1

echo ""
echo "📌 Horários Disponíveis:"
grep "HORARIOS_DISPONIVEIS" /tmp/final_logs.txt | head -1

echo ""
echo "📌 Appointment Scheduled:"
grep "pré-reservada" /tmp/final_logs.txt | head -1

echo ""
echo "════════════════════════════════════════════════════════════="
