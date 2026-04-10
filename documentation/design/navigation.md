# Arquitetura de Navegação - OmniConnect

Define como o usuário transita entre os perfis e acessa as 16 telas do app.

## 🧭 Bottom Tab Bar (4 Abas)

A barra inferior é persistente e muda conforme o perfil logado.

### Perfil: Cliente
1.  **Home**: Visão 360 e Atalho Notificações.
2.  **Processos**: Lista de casos ativos.
3.  **Documentos**: Central de arquivos.
4.  **Chat**: Histórico de suporte.

### Perfil: Advogado
1.  **Dash**: Métricas e Alertas.
2.  **Leads**: Triagem de novos contatos.
3.  **Processos**: Gestão global de casos.
4.  **Clientes & IA**: Diretório e RAG.

## 🗺️ Fluxo Visual (Mermaid)

```mermaid
graph TD
    A[Splash] --> B{Logado?}
    B -- Não --> C[Login]
    B -- Sim --> D{Perfil?}
    
    subgraph Cliente_Tabs
        D -- Cliente --> E[Home]
        E --> F[Notificações]
        D --> G[Processos]
        G --> H[Timeline Detalhada]
        D --> I[Documentos]
        D --> J[Chat Espelhado]
    end
    
    subgraph Advogado_Tabs
        D -- Advogado --> K[Dashboard]
        K --> L[Notificações Adv.]
        D --> M[Leads]
        M --> N[Conversão de Lead]
        D --> O[Gestão Processos]
        O --> P[Novo Processo]
        O --> Q[Editor Timeline]
        D --> R[Clientes & IA]
        R --> S[Review Docs]
        R --> T[Chat Handoff]
    end
```

## 📄 Detalhamento por Tela
Acesse a [Pasta de Blueprints](screens/README.md) para ver o mapeamento de campos e lógica de cada uma.
