# Regras de Atuação dos Agentes (AI Rules)

Este diretório contém os comportamentos esperados e as diretrizes de código para todos os agentes de IA que atuarem no projeto **Themis**.

## 🔴 Regra Global (Prioritária)
**Sempre responda da forma mais prática possível, diminuindo a leitura do usuário apenas com o que é objetivo e mais importante.**

## 🛠️ Diretrizes Técnicas
- **Simplicidade**: Siga o princípio YAGNI (You Ain't Gonna Need It). Não implemente complexidade desnecessária.
- **Contextualização**: Para entender como está o status atual do app (Flutter Mobile), navegue diretamente para `documentation/architecture.md` (o antigo `frontend-overview` foi depreciado e transferido para lá).
- **Documentação**: Toda decisão arquitetural nova deve ser registrada via workflow `/decision`.
- **Commits**: Use sempre o workflow `/commit` (Conventional Commits).
- **Consistência**: Mantenha os padrões definidos pelo Grupo 5 (Edge-to-edge UI, Clean Architecture com Vertical Slicing e gerenciamento via Riverpod).

---
> [!IMPORTANT]
> Estas regras devem ser respeitadas em cada interação. O descumprimento pode gerar retrabalho ou inconsistências no projeto.
