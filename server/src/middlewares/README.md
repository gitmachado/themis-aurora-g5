# Camada de Middlewares

Esta camada contém as funções de interceptação global e específica que garantem a segurança, integridade e padronização das requisições na API OmniConnect.

## 🛡️ Middlewares de Segurança

- **`authMiddleware`**: Valida o token JWT no header `Authorization`. Injeta o payload decodificado (id, role) no `req.user`.
- **`roleMiddleware`**: Realiza o Role-Based Access Control (RBAC). Bloqueia acesso a rotas específicas baseando-se no papel do usuário (`LAWYER` vs `CLIENT`).
- **`apiKeyMiddleware`**: Valida a chave de API estática (`x-api-key`) para integrações de backend-to-backend (ex: Robô de WhatsApp).

## 📊 Middlewares de Utilidade

- **`errorHandler`**: O middleware de erro global. Captura exceções lançadas nos controllers, loga os detalhes e retorna um JSON padronizado conforme os DTOs de erro definidos no sistema.
- **`validationMiddleware`**: Utiliza esquemas (Zod/Joi) para validar o corpo das requisições antes que cheguem aos controladores.

## 📝 Como adicionar um Middleware

1. Crie o arquivo em `src/middlewares/`.
2. Exporte a função utilizando o tipo `RequestHandler` do Express.
3. Se o middleware for global, configure-o no `app.ts`. Caso contrário, aplique-o diretamente na definição da rota.
