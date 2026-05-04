---
description: Criar e ajustar testes unitarios e de integracao para o projeto.
---

# Prompt: Criar Testes

## Objetivo

Adicionar ou ajustar testes unitarios e de integracao para garantir confiabilidade
nas entregas do Themis.

## Quando usar

- Cobrir comportamento novo implementado
- Reforcar regressao em bug corrigido
- Criar testes antes de uma refatoracao maior
- Aumentar seguranca de fluxos entre modulos e integracoes

## Entrada

- Caminho do codigo a ser coberto
- Spec relacionada, se existir
- Tipo de teste desejado:
  - unitario
  - integracao
  - ambos

## Como executar

1. Entenda o comportamento esperado.
   - Leia a spec, o PRD e o codigo impactado antes de escrever testes.

2. Defina o recorte correto.
   - Teste unitario: regra isolada, funcao, classe, mapper, validacao, caso de uso.
   - Teste de integracao: fluxo entre modulos, camadas, adaptadores, APIs ou
     componentes que precisam funcionar juntos.

3. Escreva testes verificaveis.
   - Cubra caminho feliz, erros relevantes e casos de borda.
   - Evite acoplamento desnecessario a detalhes internos da implementacao.
   - Prefira nomes de teste que expliquem comportamento, nao implementacao.

4. Rode as validacoes.
   - Execute os comandos de teste disponiveis no workspace afetado.
   - Se necessario, rode primeiro o subconjunto alterado e depois a suite mais ampla.

## Saida esperada

- Lista dos testes criados ou alterados
- Comportamentos cobertos
- Comandos executados
- Resultado dos testes
- Lacunas remanescentes, se houver

## Regras

- Nao invente infraestrutura de teste que o projeto nao usa.
- Nao escreva testes de integracao quando um teste unitario isolado resolver o risco.
- Nao encerre sem informar claramente o que ficou coberto e o que ainda nao ficou.
