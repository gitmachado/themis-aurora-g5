# Common and Utility Types

This folder is intended for type definitions shared across multiple entities or representing global system structures.

### Examples of what to place here:
- Pagination interfaces (e.g., `IPaginatedResponse<T>`)
- Global API response types
- Type utilities (e.g., `DeepPartial`, `OmitID`)

### How to Import:
Always use the `@common/...` alias:
```typescript
import { IPaginatedResponse } from '@common/pagination.type';
```
