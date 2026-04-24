# 03 — Fluxos Conversacionais

Mapeamento de cada cenário de conversa do bot com exemplos de diálogo.

---

## Fluxo 1: Novo Lead (Triagem)

**Gatilho**: Número desconhecido envia qualquer mensagem.

```
CLIENTE: Olá, boa tarde!
BOT: Olá! 👋 Bem-vindo ao escritório Machado & Associados. Sou o assistente jurídico virtual. Para atendê-lo, preciso de algumas informações. Qual o seu nome completo?
CLIENTE: Maria da Silva Oliveira
BOT: Prazer, Maria! Agora preciso do seu CPF para cadastro.
CLIENTE: 123.456.789-00
BOT: Obrigado! Qual o tipo de caso? (Trabalhista, Cível, Família, Criminal, Previdenciário)
CLIENTE: Trabalhista
BOT: Pode descrever brevemente a sua situação?
CLIENTE: Fui demitida sem justa causa há 3 meses e não recebi verbas rescisórias.
BOT: Qual a urgência? (Alta, Média, Baixa)
CLIENTE: Alta
BOT: Melhor horário para contato? (Manhã, Tarde, Noite)
CLIENTE: Tarde
BOT: ✅ Informações registradas! Um advogado trabalhista entrará em contato no período da Tarde.
```

**Ações pós-conclusão**: `POST /leads` → cria lead PENDING. `POST /messages/sync` → salva mensagens. Notificação push ao advogado.

**Validações**: CPF com Regex + dígitos. Respostas fora do enum pedem correção educada.

---

## Fluxo 2: Retomar Triagem Incompleta

**Gatilho**: Lead PENDING com triagem parcial.

O `triage.currentStep` no estado indica onde parou. Bot retoma daquele ponto.

---

## Fluxo 3: Consulta de Status (1 processo)

```
CLIENTE: Qual o status do meu processo?
BOT: Olá, João! 📋 Ação Indenizatória | Nº 1234567-89... | Status: Em Análise | Última movimentação: 15/04/2026 | Nota: "Petição protocolada. Aguardando citação."
```

## Fluxo 4: Consulta de Status (N processos)

Lista numerada → cliente escolhe o número → exibe detalhes.

## Fluxo 5: Sem Processos

Informa que não há processos e oferece abertura de novo caso.

---

## Fluxo 6: Dúvida Jurídica (RAG)

```
CLIENTE: Quais documentos preciso para um divórcio?
BOT: De acordo com as orientações do escritório: Certidão de casamento, RG, CPF, comprovante de residência... Quer enviar pelo app?
```

Fonte: vector search dos PDFs indexados.

---

## Fluxo 7: RAG sem Confiança → Handoff

Se o RAG não tem contexto suficiente, transfere automaticamente.

## Fluxo 8: Handoff por Palavra-Chave

Palavras-chave: `ajuda`, `falar com alguem`, `advogado`, `humano`, `pessoa real` → Pausa bot, notifica advogado.

## Fluxo 9: Fora do Horário

Compara hora atual com `config.serviceHoursStart/End`. Retorna `awayMessage` sem LLM.

## Fluxo 10: Mensagem Não-Texto

Responde que só processa texto na v1. Oferece handoff.

---

## Prompt de Sistema Base

```
Você é o assistente jurídico do escritório Machado & Associados.
REGRAS:
- Tom: {config.toneOfVoice}
- NUNCA invente informações fora da base de conhecimento
- NUNCA peça dados além dos 6 campos na triagem
- Emojis com moderação (máx. 2 por msg)
- Direto mas empático
- Em dúvida → ofereça handoff
- Máximo ~300 caracteres por mensagem
```
