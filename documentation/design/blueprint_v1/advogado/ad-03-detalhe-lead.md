# Tela: AD-03 - Detalhe e Conversão de Lead (Advogado)

- **Tipo**: [Stack] Fluxo de Cadastro
- **Atalho**: `@advogado-conversao`

## 🧭 Navegação (Stack)
- **Origem**: [AD-02: Triagem de Leads](ad-02-triagem-leads.md)
- **Próximo Passo**:
    - Ao converter: Navega para [AD-05: Detalhe do Processo](ad-05-detalhe-processo.md) (Opcional) ou retorna à lista.

## 🏗️ Anatomia Visual
- **Data Sheet**: Campos editáveis com dados extraídos pela IA.
- **Chat Transcript**: Acordeão com a conversa do WhatsApp.
- **Actions**: Botão "Converter em Cliente", "Recusar Lead".

## 📊 Mapeamento de Dados (G5-8)
- `Lead`: Objeto completo para validação manual.
- `Mensagem[]`: Filtro pelo ID do lead.
