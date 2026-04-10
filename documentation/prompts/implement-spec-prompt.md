---
description: Implementar uma spec tecnica, incluindo ajustes de rota durante a execucao e mudancas em implementacoes ja existentes.
---

# Prompt: Implementar Spec

## Objetivo

Executar uma spec tecnica de forma pragmatica, incremental e validada,
respeitando o contexto atual do repositorio.

## Este prompt tambem cobre

- ajustes na implementacao depois que ela ja existe
- mudancas de escopo tecnico descobertas durante a execucao
- atualizacao da spec quando a implementacao real precisar divergir do plano inicial

Ou seja: nao e necessario um prompt separado para `update-spec` ou
`change-implementation` quando a alteracao fizer parte do mesmo fluxo de entrega.

## Entrada

- Caminho da spec
- Plano de implementacao, se ja existir
- Descricao da mudanca, quando for um ajuste em algo ja implementado

## Leituras obrigatorias

- `documentation/prd.md`
- `documentation/requisitos.md`
- `documentation/architecture.md`
- a spec informada
- o plano, se existir

## Como implementar

1. Entenda o recorte antes de codar.
   - Identifique fluxo principal, limites de escopo, dados afetados e workspaces
     impactados.

2. Se nao houver plano, derive um plano curto da spec antes de editar.
   - Quebre em tarefas pequenas e ordene por dependencia real.

3. Implemente em etapas.
   - Reutilize codigo e estrutura existentes.
   - Entregue primeiro a base que destrava o fluxo principal.
   - Se estiver alterando algo ja existente, aplique a menor mudanca possivel
     que resolva o problema.

4. Trate divergencias e side effects durante a execucao.
   - Se a implementacao real divergir da spec, atualize a propria spec antes de
     encerrar.
   - Revise side effects: contratos quebrados, regressao de fluxo, validacoes,
     dados compartilhados, integracoes e documentacao afetada.
   - Corrija os impactos encontrados antes de concluir.

5. Valide por etapa e no final.
   - Rode os checks disponiveis no workspace alterado.
   - No `mobile/`, use `flutter analyze` e `flutter test` quando aplicavel.
   - No `server/`, rode os scripts disponiveis no `package.json`, quando existirem.
   - Se nao houver automacao configurada, registre essa limitacao.

6. Reporte o resultado.
   - O que foi implementado ou alterado
   - O que ficou pendente e por que
   - Arquivos principais alterados
   - Side effects tratados
   - Validacoes executadas

## Regras

- Nao invente camadas, ferramentas ou pastas que nao existam no projeto.
- Nao deixe divergencia silenciosa entre codigo e spec.
- Nao trate `Linear` como opcional quando a tarefa estiver vinculada a ticket.
