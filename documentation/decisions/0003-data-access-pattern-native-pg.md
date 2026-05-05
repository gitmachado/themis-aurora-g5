# ADR 0003: Padrão de Acesso a Dados com Driver Nativo (pg)

## Status
Aceito

## Contexto
O projeto Themis exige alto controle sobre o SQL gerado para lidar com:
1.  **JSONB**: Armazenamento flexível de metadados e logs de eventos.
2.  **Performance**: Evitar o overhead de abstrações de ORMs tradicionais.
3.  **PGVector (AI/RAG)**: Integração facilitada com extensões de busca vetorial no futuro.
4.  **Tipagem Estrita**: O uso de TypeScript exige interfaces claras de entrada e saída, o que muitas vezes é ocultado ou complicado por ORMs.

## Decisão
Decidimos utilizar o driver nativo `pg` (PostgreSQL Client para Node.js) em conjunto com um padrão de Repositório manual e uma utilidade centralizada de banco de dados.

### Componentes da Solução:
1.  **Database Wrapper**: Uso de um helper `Database` que abstrai `dbGet` (uma única linha), `dbAll` (múltiplas linhas) e `dbRun` (inserção/atualização).
2.  **Interface Segregated Repositories**: Contratos definidos em `interfaces/` e implementados em `implementations/`.
3.  **Manual Mapping**: Os resultados do banco são mapeados manualmente para DTOs em Inglês, garantindo que o banco possa ser alterado ou normalizado sem quebrar o contrato da API imediatamente.

## Consequências
- **Positivas**: Controle total do SQL, facilidade em debugar queries complexas, performance otimizada, ausência de migrações automáticas "mágicas" que podem falhar em produção.
- **Negativas**: Maior verbosidade (necessário escrever o SQL manualmente), necessidade de scripts manuais de criação de tabelas (`db-setup.ts`).
