#!/bin/bash

# Script simples para testar o fluxo de triagedata e agendamento

AI_BASE="http://localhost:3005"
PHONE="5585988882001"
DELAY=2000  # 2 seconds

echo "🧪 TESTE - Fluxo de Triagedata e Agendamento"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

send_message() {
  local text=$1
  local desc=$2

  echo "[*] $desc"
  echo "    📱 Enviando: \"$text\""

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

  echo ""
  echo "    ✅ Webhook recebeu"
  sleep 2
}

# Fluxo
send_message "Olá" "Abertura"
send_message "Quero agendar uma consulta" "Intent de agendamento"
send_message "João Silva" "Nome completo"
send_message "joao@example.com" "Email"
send_message "11144477735" "CPF (válido para teste)"
send_message "Direito Civil" "Tipo de caso"
send_message "Disputa contratual" "Descrição"
send_message "Manhã" "Disponibilidade"
send_message "Sim" "**CRÍTICO** - Deve chamar check_open_appointments e depois check_availability"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Teste concluído"
echo ""
echo "📌 Próximos passos: Verifique os logs do servidor para confirmar que a IA respondeu corretamente."
