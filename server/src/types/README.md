# Documentação do Módulo de Tipos (`src/types`)

Este diretório centraliza todas as definições de tipos, interfaces e esquemas de dados usados no backend do projeto Themis. A organização segue princípios de Arquitetura Limpa (Clean Architecture), o padrão de **Barrels Nidificados (Nested Barrels)** e **Separação de Preocupações (Separation of Concerns)**.

## 📂 Estrutura de Diretórios

O módulo está dividido em categorias específicas para manter as responsabilidades claras:

### 1. `models/` (`@models`)
Contém as interfaces que representam a "verdade" do domínio e como os dados são estruturados no banco de dados.
- **Uso:** Representam entidades reais (ex: `User`, `Lead`, `LegalProcess`).
- **Padrão:** Sempre possuem propriedades gerenciadas pelo sistema como `id`, `createdAt` e `updatedAt`.

### 2. `dtos/` (`@dtos`)
**Data Transfer Objects**. Definem os contratos de entrada e saída da API. É como o mundo externo se comunica com o sistema. Estes arquivos são organizados por sua **intenção**:

*   **Create DTOs:** Focados no que é estritamente necessário para gerar algo novo. A maioria dos campos é obrigatória e *nunca* possuem `id` ou datas de sistema.
*   **Update DTOs:** Focados em modificação. Os campos são geralmente opcionais (`Partial`), permitindo que o cliente envie apenas o que mudou. Pode conter validações mais restritas que o *Create*.
*   **Convert DTOs:** Focados em transição de estado/entidade (ex: `ConvertLeadDTO`). Carregam lógicas de metadados para transformar uma entidade (Lead) em outra (User/Cliente), o que difere de um simples *Update*.
*   **Auth DTOs:** Isolam contratos de segurança, sessão, login e registro.

### 3. `enums/` (`@enums`)
Centraliza tipos literais, union types constantes e enums que são compartilhados entre `models` e `dtos`.
- **Exemplos:** `LeadStatus`, `CaseType`, `UserRole`.

### 4. `common/` (`@common`)
Destinado a definições de tipos puramente utilitárias que são compartilhadas globalmente.
- **Exemplos:** Interfaces de paginação (`IPaginatedResponse<T>`), respostas globais da API, e TypeScript Utility Types genéricos.

---

## 🛠️ Padrão de Barrels Nidificados (Nested Barrels)

Para manter a raiz limpa e facilitar importações, usamos o padrão de *Nested Barrels*.

Dentro de `models/`, `dtos/` e `enums/`, os arquivos reais de código ficam dentro de uma subpasta `src/`. Na raiz de cada uma dessas pastas, há um arquivo `index.ts` que atua como um exportador público (Barrel).

**Estrutura visual:**
```
src/types/
├── models/
│   ├── index.ts        <-- Barrel exportando tudo
│   └── src/            <-- Arquivos concretos (.model.ts)
```

---

## 🚀 Como Importar (Path Aliases)

O projeto está configurado (`tsconfig.json`) com aliases absolutos para facilitar a importação de tipos de qualquer lugar do projeto de forma limpa, sem usar caminhos relativos complexos (como `../../../../`).

Sempre importe a partir do "Barrel" usando os aliases:

❌ **Incorreto (Não faça):**
```typescript
import { User } from '../../types/models/src/user.model';
import { CreateLeadDTO } from '../dtos/src/create-lead.dto';
```

✅ **Correto:**
```typescript
import { User, Lead } from '@models';
import { CreateLeadDTO, ConvertLeadDTO } from '@dtos';
import { LeadStatus } from '@enums';
```
