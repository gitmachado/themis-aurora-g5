---
description: Analisa codebases de Server e Mobile para mapear rotas e funcionalidades com tom narrativo, identificando lacunas e observacoes.
---

# Prompt: Analista de Integracao Narrativo (Codebase Mapping)

## Objetivo

- Este prompt instrui a IA a analisar os repositorios de Backend e Mobile para explicar a conexao entre eles. O resultado deve mencionar as rotas especificas, como `GET /users`, mas o foco principal e uma explicacao fluida e "falada" sobre como o app e o servidor trabalham juntos, apontando o que falta em cada lado.

## Entrada

- `{SERVER_CODE}`: Codigo-fonte do backend, incluindo controllers, rotas e services.
- `{MOBILE_CODE}`: Codigo-fonte do mobile, incluindo api clients, hooks/services e telas.
- `{CONTEXTO_PROJETO}`: Opcional. Breve resumo do que o app faz.

## Diretrizes de Execucao

### 1. Leitura e Cruzamento

- Explore o `{SERVER_CODE}` para identificar as rotas disponiveis.
- Explore o `{MOBILE_CODE}` para ver onde essas rotas sao chamadas e em quais telas ou funcionalidades elas impactam.

### 2. Narrativa de Integracao

- Explique cada funcionalidade de forma textual.
- **Regra da Rota:** voce deve citar o nome da rota, como `POST /login`, mas nao deve detalhar excessivamente parametros tecnicos, headers ou tipos complexos, a menos que isso seja essencial para o entendimento.

### 3. Analise de Paridade (Gaps)

- Identifique "promessas vazias": funcionalidades no Mobile que tentam chamar algo que nao existe no Backend.
- Identifique "rotas esquecidas": endpoints no Backend que nao possuem utilidade aparente no codigo Mobile.

### 4. Adendos e Observacoes

- Inclua uma secao final para comentarios criticos, sugestoes de melhoria no fluxo e percepcoes sobre a saude da integracao.

## Template de Saida

Use obrigatoriamente esta estrutura:

```markdown
# Mapeamento de Integracao: Backend & Mobile

## 1. Como as coisas se conectam (Funcionalidades)

*Nesta secao, explique o fluxo do usuario mencionando a rota utilizada.*

- **Funcionalidade {Nome da Funcionalidade}:** {Explicacao narrada: "Quando o usuario acessa a tela de X, o app utiliza a rota `METODO /rota` para buscar as informacoes de Y e exibir para o usuario de forma Z."}

## 2. Analise de Paridade e Lacunas

### O que o Mobile espera (e nao encontrou no Backend)

- **Funcionalidade:** {Nome}
- **O que falta:** {Explicacao simples do que a UI tenta fazer mas o servidor nao suporta}.

### O que o Backend tem (e o Mobile nao usa)

- **Rota:** `METODO /rota`
- **Contexto:** {Por que essa rota parece estar sobrando no servidor?}

## 3. Adendos e Observacoes Gerais

- **Ponto de Atencao:** {Algo que pode dar erro ou que esta confuso}.
- **Sugestao de Melhoria:** {Como esse fluxo poderia ser mais simples ou eficiente}.
- **Observacao tecnica leve:** {Ex: "Notei que a rota X demora muito para responder devido ao volume de dados"}.
```

## Regras

- **Tom de voz:** informativo, explicativo e direto, como uma conversa entre desenvolvedores.
- **Visibilidade:** as rotas devem estar em destaque, com crase: `GET /exemplo`.
- **Nao detalhar excessivamente:** nao liste JSONs gigantes ou codigos de erro detalhados; foque na finalidade.
- **Fidelidade ao Codigo:** baseie-se estritamente no que foi fornecido no `{SERVER_CODE}` e `{MOBILE_CODE}`.
