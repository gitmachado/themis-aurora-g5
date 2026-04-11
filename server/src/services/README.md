# Camada de Serviços (Regras de Negócio)

Esta camada é responsável por centralizar a lógica de negócio do OmniConnect, orquestrar os repositórios de dados e disparar efeitos colaterais (notificações, registro de timeline, etc.).

## 📂 Estrutura de Pastas

- `/interfaces`: Contém os contratos (interfaces TypeScript).
- `/implementations`: Contém a lógica concreta e integração de repositórios.
- `index.ts`: Ponto de entrada (barrel) que centraliza todos os exports.

## 🔗 Aliases e Importações

Configuramos o alias `@services` para facilitar as importações em toda a aplicação:

```typescript
// Exemplo de uso
import { IAuthService, AuthService } from '@services';
```

## 📋 Padrões de Implementação

### 1. Injeção de Dependência (DI)
Seguimos o princípio da inversão de dependência (DIP). Os serviços recebem suas dependências (repositórios ou outros serviços) via construtor através de suas **interfaces**:

```typescript
constructor(
  private readonly userRepository: IUserRepository,
  private readonly authService: IAuthService
) {}
```

### 2. Tratamento de Erros
Utilizamos a classe base `AppError` e suas subclasses (localizadas em `implementations/errors.ts`) para garantir respostas consistentes e códigos HTTP semânticos:
- `UnauthorizedError` (401)
- `ForbiddenError` (403)
- `NotFoundError` (404)
- `ValidationError` (400)
- `ConflictError` (409)

### 3. Efeitos Colaterais (Side-Effects)
Operações que impactam múltiplos domínios são coordenadas aqui. Por exemplo, ao atualizar o status de um processo jurídico:
1. O repositório de processos é atualizado.
2. Um evento é criado no repositório de Timeline.
3. Uma notificação é disparada via `NotificationService`.

### 4. Segurança e Validação
- **AuthService**: Centraliza o uso de `jsonwebtoken` e `bcryptjs`.
- **DocumentService**: Implementa validações de limite de tamanho (10MB) e formatos permitidos (PDF/Imagens).

## 🚀 Como Adicionar um Novo Serviço

1. Defina a interface em `interfaces/nome-do-servico.service.ts`.
2. Implemente a classe em `implementations/nome-do-servico.service.ts`.
3. Adicione o export no barrel `implementations/index.ts`.
4. Garanta que a classe utilize apenas interfaces para depender de outros módulos.

## 🧪 Verificação
Sempre execute a verificação de tipos após alterações:
```bash
cd server
npx tsc --noEmit
```
