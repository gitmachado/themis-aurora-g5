---
description: "Processo para registrar decisões técnicas, arquiteturais ou estratégicas no Themis."
---

# Workflow de Registro de Decisões

Mantenha o histórico do projeto limpo e acessível seguindo este fluxo estruturado para cada decisão importante do Grupo 5.

## Passos

1. **Identificar a Necessidade**: Decisões que impactam o futuro técnico ou estratégico do Themis devem ser registradas em `.agents/decisions`.
2. **Naming Convention**: Nomeie o arquivo como `NNNN-titulo-claro.md` (ex: `0002-uso-postgreSQL.md`).
3. **Aplicar o Template**: Use a estrutura abaixo, preenchendo todos os campos obrigatórios e omitindo o que não for relevante (como próximos passos, que devem ir para os artifacts).

---

## 📄 Template de Decisão

### 1. Título
`Decisão NNNN: [Título Curto e Descritivo]`

### 2. Status
- **Activated**: Aprovado e ativo.
- **Superseded**: Substituída por nova decisão (referenciar a nova ADR).

### 3. Contexto
- Qual problema estamos resolvendo?
- Quais alternativas foram consideradas?
- Quais limitações (técnicas, tempo, custo) existem?

### 4. Decisão
- O que foi decidido?
- Justificativa clara (por que esta opção e não as alternativas?).

### 5. Consequências
- **Positivas**: Ganhos imediatos e garantias.
- **Negativas**: Trade-offs e complexidades adicionais.

---
> [!TIP]
> Use este workflow sempre que houver mudanças significativas em: Arquitetura, IA, Design UX/UI ou Processos internos. As decisões registradas aqui servirão como memória histórica para a IA.
