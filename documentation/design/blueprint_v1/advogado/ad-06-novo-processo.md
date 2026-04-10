# Tela: AD-06 - Cadastro de Novo Processo (Advogado)

- **Tipo**: [Stack] Formulário
- **Atalho**: `@advogado-novo-processo`

## 🧭 Navegação (Stack)
- **Origem**: [AD-04: Gestão de Processos](ad-04-gestao-processos.md)
- **Fluxo**: Ao clicar em "+".

## 🏗️ Anatomia Visual
- **Formulário**: Campo de busca de cliente (Autocomplete), Título, Número CNJ, Tipo de Caso.
- **Dropzone**: Área para subir a Petição Inicial.

## 📊 Mapeamento de Dados (G5-8)
- `Processo`: Objeto a ser instanciado via `POST`.
- `User`: Busca por clientes existentes para vinculação.
