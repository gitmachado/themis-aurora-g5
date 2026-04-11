# Configuração de Banco de Dados

Este diretório contém a lógica de conexão com o PostgreSQL e os helpers de abstração para facilitar o acesso aos dados sem o uso de ORM.

## 🛠️ Helpers de Query

Para manter o código limpo e evitar o tratamento repetitivo de objetos de resposta do `pg`, utilizamos três funções principais:

### `dbGet<T>(sql: string, params?: any[]): Promise<T | null>`
- **Finalidade:** Consultas que retornam um único registro.
- **Retorno:** Retorna o objeto diretamente ou `null` se nada for encontrado.
- **Uso Comum:** Find by ID, Find by Email, ou INSERTs com `RETURNING`.

### `dbAll<T>(sql: string, params?: any[]): Promise<T[]>`
- **Finalidade:** Consultas que retornam listas.
- **Retorno:** Sempre retorna um Array (vazio se não houver resultados).
- **Uso Comum:** Listagens filtradas e relatórios.

### `dbRun(sql: string, params?: any[]): Promise<number>`
- **Finalidade:** Comandos de execução que não retornam dados.
- **Retorno:** O número de linhas afetadas (`rowCount`).
- **Uso Comum:** DELETE, UPDATE de campos simples ou migrações.

## ⚙️ Variáveis de Ambiente

A conexão utiliza as seguintes variáveis do arquivo `.env` na raiz do servidor:

- `DB_HOST`: Endereço do servidor (ex: localhost).
- `DB_PORT`: Porta (padrão 5432).
- `DB_USER`: Usuário do Postgres.
- `DB_PASSWORD`: Senha do usuário.
- `DB_NAME`: Nome do banco de dados.

## 🚀 Inicialização do Banco de Dados

Para facilitar o setup, temos um script que automatiza a criação do banco, das tabelas e a inserção de dados iniciais (Seed):

1. Certifique-se de que o seu `.env` está configurado corretamente.
2. Certifique-se de que o serviço do PostgreSQL está rodando.
3. Execute o comando:
   ```bash
   npm run db:setup
   ```

Este comando irá:
- Criar o banco de dados caso ele não exista.
- Criar todas as tabelas e chaves estrangeiras (`schema.sql`).
- Popular o banco com dados de teste (`seed.sql`).

## 💡 Exemplo de Uso no Repository

```typescript
import { dbGet, dbAll } from '../../config/database';

// Buscar um usuário
const user = await dbGet<User>('SELECT * FROM users WHERE id = $1', [id]);

// Listar todos os usuários
const allUsers = await dbAll<User>('SELECT * FROM users');
```
