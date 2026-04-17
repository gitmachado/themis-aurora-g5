# ADR 0004: Sistema de Segurança Granular e Propriedade (Tutor-based)

## Status
Aceito

## Contexto
O OmniConnect lida com dados jurídicos sensíveis. Clientes não podem acessar processos de terceiros, e mesmo dentro da equipe jurídica, precisamos de uma camada de responsabilidade (Tutor) para evitar que advogados não envolvidos em um caso façam alterações críticas acidentalmente ou por má-fé.

Sem um ORM (Object-Relational Mapping), a validação de propriedade não acontece automaticamente no nível de query/repositório sem injeção de contexto de usuário em todas as camadas, o que aumentaria a complexidade do driver de banco de dados.

## Decisão
Implementamos a validação de propriedade (**Ownership**) e autorização (**RBAC**) diretamente na camada de **Controllers** utilizando middlewares e injeção de repositórios nos controladores.

1. **Camada de Controller**: Responsável por buscar o registro e validar se o `user.id` do token tem permissão sobre o recurso antes de invocar o `Service`.
2. **Sistema de Tutor**: Introduzida a lógica de que, se um processo tem um advogado designado, apenas esse advogado pode deletar documentos ou atualizar o status.
3. **API Key**: Uso de uma chave estática para o robô de WhatsApp, separando o tráfego do sistema do tráfego do usuário final.

## Consequências

### Positivas:
- **Segurança Visível**: A lógica de permissão está clara nos endpoints, facilitando auditorias.
- **Desacoplamento**: A camada de banco de dados e serviços permanece pura, sem conhecimento do contexto de sessão HTTP (JWT).
- **Proteção IDOR**: Bloqueia acessos via manipulação de IDs de UUIDs na URL.

### Negativas:
- **Repetição**: Alguns controladores precisam buscar o registro (ex: `findById`) apenas para validar a permissão antes de proceder com a ação real.
- **Acoplamento de Controller/Repo**: Alguns controladores agora dependem de repositórios adicionais para realizar verificações cruzadas.

## Referências
- Implementado em: `server/src/controllers/`
- Middleware: `server/src/middlewares/authMiddleware.ts`
