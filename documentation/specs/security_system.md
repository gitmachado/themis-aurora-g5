# Especificação Técnica: Sistema de Segurança Backend

Este documento detalha os mecanismos de proteção, autenticação e autorização implementados no servidor Themis.

## 1. Autenticação (JWT)

O sistema utiliza JSON Web Tokens (JWT) para autenticação *stateless*.

- **Algoritmo**: HS256
- **Payload**:
  - `sub`: ID único do usuário (UUID).
  - `role`: Papel do usuário (`LAWYER` | `CLIENT`).
- **Middleware**: `authMiddleware.ts`
  - Extrai o token do header `Authorization: Bearer <token>`.
  - Injeta o objeto `user` na requisição para uso pelos controllers.

## 2. Autorização e RBAC

O controle de acesso baseado em papéis (Role-Based Access Control) é gerenciado pelo `roleMiddleware.ts`.

| Recurso | Acesso Cliente | Acesso Advogado |
|---|---|---|
| Leads | Bloqueado | Full (Leitura/Conversão) |
| Processos | Apenas próprios | Todos (ou onde é tutor) |
| Documentos | Upload/Ver próprios | Full (Delete apenas se tutor) |
| Notificações | Apenas próprias | Apenas próprias |

## 3. Validação de Propriedade (Ownership)

Para evitar ataques de ID aleatório (Insecure Direct Object Reference - IDOR), implementamos verificações de propriedade diretamente nos controladores.

### 🛡️ Regras de Propriedade:
- **Timeline**: Um cliente só pode visualizar a timeline se o `processoId` estiver vinculado ao seu `clienteId`.
- **Mensagens**: Um cliente só pode buscar o histórico de mensagens vinculado ao seu próprio número de WhatsApp.
- **Notificações**: Operações de "marcar como lida" validam se o `userId` da notificação coincide com o `sub` do token.

### ⚖️ Trava de "Tutor" (Advogado Responsável)
Determinadas ações críticas em processos e documentos são restritas ao advogado designado:
- **Update de Status**: Se um processo tem um `lawyerId`, apenas esse advogado pode atualizar o status.
- **Delete de Documento**: Apenas o advogado tutor pode remover arquivos de um processo.

## 4. Segurança de Integração (Bot API Key)

O robô de WhatsApp acessa endpoints sensíveis (`/leads` e `/messages/sync`) utilizando uma chave secreta estática.

- **Header**: `x-api-key`
- **Middleware**: `apiKeyMiddleware.ts`
- **Configuração**: Definida via variável de ambiente `BOT_API_KEY`.
- **Objetivo**: Impedir que usuários comuns ou agentes externos forjem a entrada de novos leads ou mensagens diretamente na API.

## 5. Tratamento de Erros e Segurança

O `errorHandler.ts` garante que:
1. Erros de falha de autenticação retornem `401 Unauthorized`.
2. Falhas de autorização de propriedade retornem `403 Forbidden`.
3. Stack traces e informações internas do banco de dados (PostgreSQL) sejam omitidos em produção, enviando apenas mensagens amigáveis e padronizadas.
