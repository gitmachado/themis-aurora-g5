# Types Module Documentation (`src/types`)

This directory centralizes all type definitions, interfaces, and data schemas used in the OmniConnect backend. The organization follows Clean Architecture principles, the **Nested Barrels** pattern, and **Separation of Concerns**.

## 📂 Directory Structure

The module is divided into specific categories to keep responsibilities clear:

### 1. `models/` (`@models`)
Contains interfaces representing the domain's "truth" and how data is structured in the database.
- **Usage:** Represent real entities (e.g., `User`, `Lead`, `LegalProcess`).
- **Pattern:** Always include system-managed properties such as `id`, `createdAt`, and `updatedAt`.

### 2. `dtos/` (`@dtos`)
**Data Transfer Objects**. Define the API input and output contracts. This is how the external world communicates with the system. Files are organized by **intent**:

*   **Create DTOs:** Focused on strictly necessary fields to generate something new. Most fields are mandatory and *never* includes `id` or system dates.
*   **Update DTOs:** Focused on modification. Fields are generally optional (`Partial`), allowing the client to send only what changed. May contain stricter validations than *Create*.
*   **Convert DTOs:** Focused on state/entity transition (e.g., `ConvertLeadDTO`). Carries metadata logic to transform one entity (Lead) into another (User/Client).
*   **Auth DTOs:** Isolate security, session, login, and registration contracts.

### 3. `enums/` (`@enums`)
Centralizes literal types, constant union types, and enums shared between `models` and `dtos`.
- **Examples:** `LeadStatus`, `CaseType`, `UserRole`.

### 4. `common/` (`@common`)
Intended for purely utility type definitions shared globally.
- **Examples:** Pagination interfaces (`IPaginatedResponse<T>`), global API responses, and generic TypeScript Utility Types.

---

## 🛠️ Nested Barrels Pattern

To keep the root clean and facilitate imports, we use the *Nested Barrels* pattern.

Inside `models/`, `dtos/`, and `enums/`, the actual code files reside within a `src/` subfolder. At the root of each of these folders, there is an `index.ts` file acting as a public exporter (Barrel).

**Visual Structure:**
```
src/types/
├── models/
│   ├── index.ts        <-- Barrel exporting everything
│   └── src/            <-- Concrete files (.model.ts)
```

---

## 🚀 How to Import (Path Aliases)

The project is configured (`tsconfig.json`) with absolute aliases to facilitate importing types from anywhere in the project cleanly, without using complex relative paths (like `../../../../`).

Always import from the "Barrel" using the aliases:

❌ **Incorrect (Don't do this):**
```typescript
import { User } from '../../types/models/src/user.model';
import { CreateLeadDTO } from '../dtos/src/create-lead.dto';
```

✅ **Correct:**
```typescript
import { User, Lead } from '@models';
import { CreateLeadDTO, ConvertLeadDTO } from '@dtos';
import { LeadStatus } from '@enums';
```
