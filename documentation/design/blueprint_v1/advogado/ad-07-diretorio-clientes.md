# Tela: AD-07 - Diretório de Clientes (Advogado)

- **Tipo**: [Tab Bar] Aba 4
- **Atalho**: `@advogado-clientes`

## 🧭 Navegação (Stack)
- **Destinos possíveis**:
    - Perfil do Cliente (Resumo).
    - [AD-10: Handoff Chat](ad-10-handoff-chat.md) (Atalho rápido para suporte).

## 🏗️ Anatomia Visual
- **Lista de Usuários**: Filtro por Nome/CPF.
- **Metric Badge**: Qtd de processos ativos por cliente.

## 📊 Mapeamento de Dados (G5-8)
- `User[]`: Onde `role == CLIENTE`.
- `Processo.count(userId)`: Exibição de estatísticas.
