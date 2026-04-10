# Types Comuns e Utilitários

Pasta destinada a definições de tipos que são compartilhados por múltiplas entidades ou que representam estruturas globais do sistema.

### Exemplos do que colocar aqui:
- Interfaces de Paginação (ex: `IPaginatedResponse<T>`)
- Tipos de Resposta Global de API
- Utilitários de Tipo (ex: `DeepPartial`, `OmitID`)

### Como importar:
Sempre utilize o alias `@common/...`:
```typescript
import { IPaginatedResponse } from '@common/pagination.type';
```
