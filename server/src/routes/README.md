# Camada de Rotas API

Aqui são definidas todas as rotas públicas e privadas do servidor Themis, organizadas por versão e por domínio.

## 🧭 Estrutura de Diretórios

- **`index.ts`**: Ponto de entrada das rotas. Agrega todos os módulos de versão (ex: `/v1`).
- **`v1/`**: Contém as rotas da versão 1 da API. Cada domínio (auth, legal-process, messages, etc) possui seu próprio arquivo de rotas.

## 🛠️ Padrão de Roteamento

As rotas são estruturadas seguindo o padrão RESTful:

```typescript
router.post('/login', controller.login); // Rota Pública
router.get('/my', authMiddleware, controller.listMyResources); // Rota Privada
router.delete('/:id', authMiddleware, roleMiddleware(['LAWYER']), controller.delete); // Rota Restrita
```

## 🏗️ Como adicionar uma nova rota

1. Crie o arquivo no diretório da versão correspondente (ex: `src/routes/v1/new-feature.routes.ts`).
2. Defina os endpoints e aplique os middlewares necessários (`authMiddleware`, `roleMiddleware`).
3. Importe e registre o novo arquivo no `src/routes/v1/index.ts` (ou no barrel correspondente).
4. O prefixo global das rotas é definido no `app.ts` (geralmente `/api/v1`).
