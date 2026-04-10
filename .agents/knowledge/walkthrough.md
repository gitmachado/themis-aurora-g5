# Walkthrough: G5-8 Modelagem de Dados Backend

## O que foi feito

### 1. Branch e Padrão
- Branch criada: `feat/G5-8-modelagem-dados-backend`
- Padrão de branch documentado em [commit-pattern.md](file:///c:/Dev/omniconnect-aurora-g5/documentation/commit-pattern.md)
- Comentários adicionados nas issues G5-6, G5-7, G5-8 no Linear com o novo padrão

### 2. Setup TypeScript
- TypeScript + @types/node instalados como devDependencies
- [tsconfig.json](file:///c:/Dev/omniconnect-aurora-g5/server/tsconfig.json) configurado (ES2022, NodeNext, strict)

### 3. Estrutura de Pastas

```
server/src/
├── models/              (7 entidades + enums)
│   └── dtos/            (9 DTOs)
├── repositories/interfaces/  (7 contratos)
├── services/interfaces/      (7 contratos)
├── controllers/         (.gitkeep)
├── config/              (.gitkeep)
├── middlewares/          (.gitkeep)
└── utils/               (.gitkeep)
```

### 4. Entidades Criadas

| Entidade | Arquivo | Descrição |
|---|---|---|
| User | [user.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/user.model.ts) | Advogado e Cliente, com FCM token |
| Lead | [lead.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/lead.model.ts) | 6 campos PRD §2.1, coleta progressiva |
| Processo | [processo.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/processo.model.ts) | Múltiplos por cliente |
| TimelineEvento | [timeline-evento.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/timeline-evento.model.ts) | Append-only |
| Documento | [documento.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/documento.model.ts) | 10MB max, PDF/PNG/JPG |
| Mensagem | [mensagem.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/mensagem.model.ts) | Persistência completa WhatsApp |
| Notificacao | [notificacao.model.ts](file:///c:/Dev/omniconnect-aurora-g5/server/src/models/notificacao.model.ts) | FCM push |

### 5. Decisões Tomadas

- ❌ **Tarefa** removida do MVP (decisão do usuário)
- ✅ **Mensagem** com persistência completa de cada mensagem
- ⏳ **embeddings_rag** deixada para ticket de IA

## Validação

- `npx tsc --noEmit` → **0 erros** ✅
- Nenhuma dependência ORM no `package.json` ✅

## Pendente

- [ ] Diagrama ER em `documentation/architecture.md`
- [ ] Spec formal `documentation/specs/g5-8-*.md` (opcional)
