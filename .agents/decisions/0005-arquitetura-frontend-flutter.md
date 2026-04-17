# Decisão 0005: Arquitetura Frontend Flutter (Feature-First Clean Architecture)

### 1. Título
Decisão 0005: Adoção de Feature-First Clean Architecture no App Flutter

### 2. Status
- **Activated**

### 3. Contexto
O time está em fase de aprendizado e transição para o desenvolvimento "físico" do frontend. Com a complexidade do OmniConnect (múltiplos perfis, integração com API REST e gerenciamento de estado assíncrono), é necessário um padrão que evite o acoplamento excessivo e facilite o trabalho colaborativo.

As alternativas consideradas foram:
- **Layer-First (por camadas):** Mais simples no início, mas dificulta a escalabilidade em apps grandes.
- **MVC/MVVM Simples:** Frequentemente leva a Widgets gigantes com lógica misturada.

### 4. Decisão
Foi decidido adotar a **Feature-First Clean Architecture**. O projeto será organizado por funcionalidades (features), onde cada funcionalidade contém suas próprias camadas de dados, domínio e apresentação.

**Justificativa:**
- **Escalabilidade:** Novas funcionalidades podem ser adicionadas sem impactar as existentes.
- **Sincronia com Riverpod:** O Riverpod funciona melhor quando os Providers estão próximos aos domínios que eles gerenciam.
- **Manutenibilidade:** Facilita a localização de bugs e a implementação de testes unitários isolados.

### 5. Consequências
- **Positivas:** Código altamente modular, facilidade de injeção de dependência via Riverpod e separação clara entre UI e Lógica de Negócio.
- **Negativas:** Requer uma estrutura de pastas mais profunda (boilerplate inicial maior) e exige que o time mantenha a disciplina de não cruzar camadas indevidamente.

---
> [!NOTE]
> Esta decisão será refletida no Guia de Estudo e na estrutura inicial da pasta `mobile/`.
