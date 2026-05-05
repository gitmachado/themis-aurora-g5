# Decisão 0005: Arquitetura Frontend Flutter (Full Vertical Slicing)

### 1. Título
Decisão 0005: Adoção de Full Vertical Slicing com Clean Architecture no App Flutter

### 2. Status
- **Activated** (Atualizado Pós-PR #21)

### 3. Contexto
Inicialmente, o aplicativo baseou-se em uma organização onde as features eram separadas fortemente pelos "perfis" globais (Client/Lawyer) com pastas planas de `presentation`, `domain`, `data`. Conforme as entregas cresceram e os 20+ arquivos visuais foram consolidados, a estrutura plana revelou-se ineficiente para escalar. Buscar pedaços de domínio em uma pasta gigantesca aumentou o acoplamento arquitetural.

### 4. Decisão
Migramos a arquitetura para **Full Vertical Slicing (Fatiamento Vertical) por Sub-Funcionalidade**, mesclada aos rigores da **Clean Architecture**.

**Como Funciona:**
Cada aba ou recurso da aplicação (ex: *Home do cliente*, *Leads do Advogado*) é tratada como um mini-projeto independente contendo *Domain*, *Data* e *Presentation*. A hierarquia física de pastas agora consiste em `lib/features/<role>/<sub-feature>/...`.

Estrutura anatômica exata contida na pasta de cada sub-feature:
```
<sub-feature_name>/
├── data/
│   ├── data_sources/    ← Chamadas Remote (API) / Local (Cache)
│   ├── models/          ← DTOs
│   └── repositories/    ← Implementações dos Repositórios
├── domain/
│   ├── entities/        ← Regras e Modelos de Negócio
│   ├── repositories/    ← Contratos Abstratos
│   └── usecases/        ← Casos de Uso (ex: GetLeads)
└── presentation/
    ├── providers/       ← Riverpod Providers
    ├── screens/         ← UI Scaffolds
    └── widgets/         ← Componentes Exclusivos desta sub-feature
```

### 5. Consequências
- **Positivas:** Altíssima desacoplabilidade. Se amanhã a documentação do cliente não for mais necessária, deletar a pasta `features/client/documents` aniquila 100% de seus dados, domínio e estado sem gerar dependências órfãs.
- **Negativas:** Exige criação massiva de sub-diretórios para coisas que parecem pequenas a princípio.
- **Desenvolvimento Agêntico:** Os agentes de IA DEVEM sempre mapear seus componentes, modelos e estado estritamente dentro da sua sub-feature respectiva, sem subir os dados para o nível do `role` (ex. injetar dados do Lead direto na aba Advogado em vez da sub-feature lead resultaria em erro grave de arquitetura).

---
> [!NOTE]
> Componentes visuais **comuns a múltiplas sub-features** e essenciais para a identidade da marca como AppBars, NavBars e Botões são as únicas peças que ganham passe livre para viver em `lib/shared/widgets/`.
