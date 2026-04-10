# Mapa de Navegação e Blueprints (v1)

Este diretório contém a documentação detalhada das **16 telas individuais** do app OmniConnect, organizada para guiar o time de design e desenvolvimento.

## 🧭 Estrutura de Navegação

O app utiliza uma **Bottom Tab Bar** persistente para as funcionalidades principais e uma **Stack** para fluxos de detalhe ou formulários. Cada arquivo possui uma seção de `Contexto de Navegação` para guiar a lógica de empilhamento (stacks).

### 👤 Perfil Cliente
- **Aba 1**: [Home](cliente/cl-01-home.md)
- **Aba 2**: [Lista de Processos](cliente/cl-02-lista-processos.md)
- **Aba 3**: [Central de Documentos](cliente/cl-03-documentos.md)
- **Aba 4**: [Chat Mirror](cliente/cl-04-chat.md)
- **Stack (Interno)**: [Timeline do Processo](cliente/cl-05-timeline.md)
- **Stack (Global)**: [Notificações](cliente/cl-06-notificacoes.md)

### ⚖️ Perfil Advogado
- **Aba 1**: [Dashboard](advogado/ad-01-dashboard.md)
- **Aba 2**: [Triagem de Leads](advogado/ad-02-triagem-leads.md)
- **Aba 3**: [Gestão de Processos](advogado/ad-04-gestao-processos.md)
- **Aba 4**: [Diretório de Clientes](advogado/ad-07-diretorio-clientes.md)
- **Fluxos de Stack**:
    - [Conversão de Lead](advogado/ad-03-detalhe-lead.md)
    - [Gestão do Processo (Admin)](advogado/ad-05-detalhe-processo.md)
    - [Cadastro Novo Processo](advogado/ad-06-novo-processo.md)
    - [Revisão de Documentos](advogado/ad-08-revisao-documentos.md)
    - [Configuração de IA](advogado/ad-09-gestao-ia.md)
    - [Handoff (Chat Humano)](advogado/ad-10-handoff.md)

---

## 🎨 Guia Visual Rápido
- **Cores**: Azul Profundo (#1A237E), Ouro Jurídico (#C5A059), Cinza Sólido (#F5F5F5).
- **Tipografia**: Inter.
- **Transições de Stack**: Usar animações de *Slide Transition* (Direita para Esquerda) para telas de detalhe e *Modal Popup* para formulários.
