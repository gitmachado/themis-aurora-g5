# Diagnóstico e Plano de Correção 100% Garantido - Módulo de IA

## 1. Erros Lógicos e Bugs Identificados

### 🔴 Crítico: Erros de Runtime no Nó de Triagem (`triage.ts`)
*   **Problema:** O código tenta chamar `.trim()` em `response.extractedValue` sem verificar se é nulo (o que ocorre quando a IA não extrai o dado).
*   **Problema:** A função `mapToEnglish` em `triage.ts` quebra a aplicação caso receba um valor `null` da triagem, o que acontece por conta da chamada prematura de `createLead`.
*   **Impacto:** O fluxo de triagem trava e o bot para de responder (Falha Silenciosa).

### 🔴 Crítico: Falhas Silenciosas de Infraestrutura (Queda de API)
*   **Problema:** O Webhook (`whatsapp.ts`) envelopa a invocação do Grafo num `try/catch` genérico que apenas faz `console.error`. Se a API da OpenAI cair (Timeout) ou o banco de vetores falhar, o código lança exceção e o usuário **nunca recebe resposta**.
*   **Impacto:** Usuário abandonado sem feedback do que aconteceu.

### 🔴 Crítico: "Despausa" Indesejada do Handoff (`whatsapp.ts`)
*   **Problema:** A cada mensagem, o Webhook consulta o banco (`getLeadByPhone`) para saber se o bot está pausado. O problema: se houver erro de rede e a chamada falhar (`.catch(() => null)`), o código assume `isPausedInDB = false` e **sobrescreve o estado local do grafo**.
*   **Impacto:** Se o banco ficar lento por 1 segundo, a IA pode se "despausar" sozinha no meio de um atendimento humano e começar a falar com o cliente, gerando extrema confusão.

### 🟡 Médio: Ineficiência no Roteador (`router.ts`)
*   **Problema:** Mesmo quando `needsHandoff` é `true`, o roteador executa a classificação por LLM antes de decidir ir para o `sync_node`.

### 🟢 Baixo: UX na Consulta de Processos (`status.ts`)
*   **Problema:** Seleção de múltipla escolha via números não possui retenção de contexto no roteador, lançando o cliente num loop errado de triagem/dúvida.

---

## 2. Plano de Ação Detalhado (Garantia de 100%)

### Fase 1: Blindagem de Resiliência (Zero Falhas Silenciosas)
1.  **Tratamento de Exceções Global (`ai/src/webhooks/whatsapp.ts`):**
    *   No bloco `catch` principal do webhook, implementar o envio de uma mensagem de feedback amigável (fallback): *"Desculpe, nosso sistema está passando por uma instabilidade momentânea. Já notificamos a equipe técnica e em breve um humano assumirá seu atendimento."*
    *   Forçar disparo de uma notificação/handoff para o advogado nesse catch (Graceful Degradation).
2.  **Blindagem do LLM:**
    *   Envelopar chamadas da OpenAI (`router.ts`, `triage.ts`, `rag.ts`) em `try/catch` locais para retornar mensagens de segurança em caso de timeout da API, ao invés de derrubar o fluxo todo.

### Fase 2: Correção do Handoff (Single Source of Truth)
1.  **Ajuste no Webhook (`whatsapp.ts`):**
    *   Ao consultar o banco para saber se está pausado, se a requisição falhar, **manter o estado anterior** (`currentState.values.needsHandoff`) ao invés de forçar `false`. Isso garante que uma falha de rede nunca un-pause o bot.
2.  **Respeito no Roteador (`router.ts`):**
    *   A primeira linha do roteador deve ser: `if (state.needsHandoff) return { currentNode: "sync_node" };`. Nunca invocar o LLM se estiver pausado.

### Fase 3: Estabilização da Triagem e Leads
1.  **Refactor `triage.ts`:**
    *   Implementar `null-checks` agressivos na hora de atualizar `updatedTriage`.
    *   **Mudança na Regra de Negócio de Leads:** Só criar o lead (`createLead`) quando os campos básicos e obrigatórios (Nome e CPF) estiverem capturados com segurança.
    *   Corrigir o helper `mapToEnglish` para tratar inputs indefinos.

### Fase 4: Melhorias de UX
1.  **Memória de Interação:** Adicionar campo ao estado para saber que o usuário está no meio de uma escolha de lista numérica.

---

## 3. Próximos Passos
1.  Vou começar aplicando as correções de **Fase 1 e Fase 2 (Webhooks e Resiliência Global)**, que garantem que o bot nunca ficará mudo e nunca vai "atropelar" o advogado.
2.  Em seguida, aplico a correção na Triagem para resolver o crash atual de extração.
