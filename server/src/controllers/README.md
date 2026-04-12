# Camada de Controllers

Esta camada é responsável por interceptar as requisições HTTP, validar as permissões de acesso e orquestrar a chamada para os serviços de negócio.

## 🏗️ Padrão de Implementação

- **Classes**: Cada domínio possui seu próprio controlador implementado como uma classe.
- **RequestHandler**: Utilizamos o tipo `RequestHandler` do Express para garantir que os parâmetros `req`, `res` e `next` sejam tipados corretamente.
- **Injeção de Dependências**: Repositórios e Serviços são instanciados ou injetados no construtor para permitir validações rápidas (ex: Ownership check) antes da execução da lógica pesada.

## 🛡️ Validação de Propriedade (Ownership)

Como este projeto opera sem um ORM centralizado, a validação de que um usuário tem direito de acessar um recurso específico (ex: um processo jurídico que não é dele) deve ser feita explicitamente no Controller:

1. Busca-se o ID do registro via `Repository`.
2. Compara-se o `id` ou `whatsappNumber` do registro com o `req.user.id` vindo do token JWT.
3. Lança-se um `ForbiddenError` caso a validação falhe.

## ⚠️ Tratamento de Erros

**Nunca** utilize blocos `catch` para enviar respostas HTTP diretas. Sempre use `next(error)` para permitir que o `errorHandler` global processe a exceção e mantenha o padrão de resposta da API.
