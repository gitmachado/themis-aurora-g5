# Camada de Repositórios (Persistência)

Esta camada é responsável por toda a interação direta com o banco de dados PostgreSQL. Seguimos o padrão **Data Access Object (DAO)** e a **ADR-0003**, utilizando apenas o driver nativo `pg` sem o uso de ORMs.

## 📂 Estrutura de Pastas

- `/interfaces`: Contém os contratos (interfaces TypeScript).
- `/implementations`: Contém a implementação concreta SQL puro.
- `index.ts`: Ponto de entrada (barrel) consolidado.

## 🔗 Aliases e Importações

Utilizamos o alias `@repositories` para simplificar o acesso à camada de dados:

```typescript
import { IUserRepository, UserRepository } from '@repositories';
```

## 📋 Padrões de Implementação

### 1. Mapeamento Manual
Como o banco de dados utiliza `snake_case` e o código TypeScript utiliza `camelCase`, realizamos o mapeamento explicitamente nas queries SQL:
```sql
SELECT whatsapp_number as "whatsappNumber" FROM users ...
```

### 2. Uso de Helpers
Todas as implementações devem utilizar os helpers definidos em `src/config/database.ts`:
- `dbGet`: Para resultados únicos (SELECT ou RETURNING).
- `dbAll`: Para listas.
- `dbRun`: Para comandos de execução simples.

### 3. Integridade e Tipagem
- Sempre utilize os modelos definidos em `@models` para o retorno dos métodos.
- Utilize `@dtos` para os parâmetros de criação quando necessário.

## 🚀 Como Adicionar um Novo Repositório

1. Defina a interface em `interfaces/novo-item.repository.ts`.
2. Implemente a classe em `implementations/novo-item.repository.ts`.
3. Garanta que a classe implemente a interface (`implements INovoItemRepository`).
4. Utilize a constante `private readonly selectFields` para manter as colunas SQL padronizadas em todos os métodos da classe.
