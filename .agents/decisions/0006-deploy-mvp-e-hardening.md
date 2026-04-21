# Decisão 0006: Topologia Analítica de Deploy MVP e Hardening de Runtime (PR #20)

### 1. Título
Decisão 0006: Endurecimento do Runtime Backend para Produção e Deploy do MVP.

### 2. Status
- **Activated**

### 3. Contexto
Com a aproximação dos fluxos integrados do *app* (Mobile) com o *servidor* (Backend), surgiu a necessidade de garantir a segurança do backend rodando em Nuvem/VM, protegendo endpoints que não podem ficar vulneráveis ao público. Inicialmente desenvolvido com fallbacks condescendentes (como ausência de JWT secret obrigatória e chaves não checadas estritamente), o PR #20 consolidou um modelo engessado para proteção dos dados do MVP.

As razões para o endurecimento:
- Riscos de IDOR e endpoints vazados através do Swagger por agentes mal-intencionados na internet.
- Dificuldade na esteira de deploy por falta de health checks que provessem segurança.
- O Frontend precisa ter uma premissa madura sobre sua comunicação em Produção.

### 4. Decisão
Foi formalizado o seguinte padrão de hardening (endurecimento) para o ambiente backend MVP:
- **Separação de Ambientes Strict**: A API não servirá o `Swagger/OpenAPI` se `NODE_ENV=production`.
- **Fim dos Fallbacks Inseguros**: Variáveis Críticas como `JWT_SECRET`, `BOT_API_KEY` e `CORS_ORIGIN` tornaram-se obrigatoriamente estritas e o servidor não boota ou rejeita requisições se ausentes ou forjadas.
- **Isolamento Básico**: Acesso de Webhook exige autenticação com a `API_KEY` isolando inteiramente o bot da regra de negócio da plataforma. Implementação do `GET /health` para facilitar load-balancers ou verificação de runtime.

### 5. Consequências
- **Positivas:** Redução massiva de ataques de observabilidade no MVP. O tráfego do App precisa e deverá passar sempre com um Bearer token válido sem atalhos.
- **Negativas:** Exige maior burocracia no setup `.env` do desenvolvedor ou pipeline para simular homologação.
- **Impacto no Frontend:** A implementação em `.dart` para consumir estas rotas precisará interagir corretamente com interceptors (ApiClient) robustos. Não lidaremos com respostas flexíveis de autorização.

---
> [!IMPORTANT]
> A API não perdoa chamadas desprotegidas em rotas autenticadas. Todo código gerado em Mobile para API deve injetar os Bearer tokens e consumir as respostas padronizadas de erro (401, 403, 404).
