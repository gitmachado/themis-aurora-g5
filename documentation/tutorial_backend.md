# Tutorial: Rodando o Backend do Themis

Este guia explica como configurar e rodar o ecossistema de backend do Themis Aurora G5, que inclui o servidor principal (Node.js/Express), o serviço de IA e o banco de dados PostgreSQL com suporte a vetores (pgvector).

## 🚀 Método Recomendado: Docker (Fácil e Rápido)

O Docker é a forma mais simples de garantir que todas as dependências (incluindo o `pgvector`) estejam configuradas corretamente.

### 1. Pré-requisitos
- [Docker](https://www.docker.com/products/docker-desktop/) instalado e rodando.
- Node.js instalado (apenas para rodar os scripts de conveniência do `package.json`).

### 2. Configuração de Ambiente
Na raiz do projeto, você precisa configurar os arquivos `.env`:

1.  **Server**: Entre na pasta `server/`, copie o arquivo `.env.example` para `.env` e preencha as variáveis (especialmente as de segurança e Supabase).
    ```bash
    cp server/.env.example server/.env
    ```
2.  **AI**: Entre na pasta `ai/`, copie o arquivo `.env.example` para `.env`.
    ```bash
    cp ai/.env.example ai/.env
    ```

### 3. Subindo os Serviços
Na raiz do projeto, execute:
```bash
npm run docker:up
```
*Ou se preferir usar Docker diretamente:* `docker compose up`

Este comando irá subir:
- **PostgreSQL**: Porta `5433` (com schema e seeds automáticos).
- **Server**: Porta `3000`.
- **AI Service**: Porta `3001`.

---

## 🛠️ Método Nativo (Desenvolvimento Local)

Use este método se quiser rodar o Node.js diretamente na sua máquina sem containers para o código, mas ainda precisará de um banco de dados compatível.

### 1. Pré-requisitos
- **Node.js** (v18+ recomendado).
- **PostgreSQL 17+** com a extensão [pgvector](https://github.com/pgvector/pgvector) instalada.
- **Supabase Account** (para autenticação e armazenamento).

### 2. Configuração do Banco de Dados
Se não estiver usando o Docker para o banco, você precisará:
1.  Criar um banco chamado `Themis_db`.
2.  Habilitar as extensões `uuid-ossp` e `vector`.
3.  Rodar os scripts em `server/database/schema.sql` e `server/database/seed.sql`.

### 3. Instalando Dependências
Em terminais separados:

**Para o Server:**
```bash
cd server
npm install
npm run dev
```

**Para o AI Service:**
```bash
cd ai
npm install
npm run dev
```

---

## 🔍 Comandos Úteis

| Comando | Descrição |
| :--- | :--- |
| `npm run docker:logs` | Vê os logs de todos os containers em tempo real. |
| `npm run docker:build` | Reconstrói as imagens e sobe os containers. |
| `npm run docker:reset` | Apaga os dados do banco e reconstrói tudo do zero. |
| `npm run docker:down` | Para e remove os containers. |

## ✅ Verificação
Para garantir que tudo está ok:
- Acesse `http://localhost:3000/health` (ou a rota de status configurada).
- Verifique se o banco está acessível na porta `5433` (Docker) ou `5432` (Local).
- O Swagger (documentação da API) geralmente fica disponível em `http://localhost:3000/api-docs`.

---
> [!IMPORTANT]
> Certifique-se de que as credenciais do Supabase no `.env` estão corretas, caso contrário a autenticação de usuários falhará.
