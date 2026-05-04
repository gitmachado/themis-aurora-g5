# ADR 0006: Hospedagem do MVP publico em VM unica

## Status
Aceito, atualizado pela ADR 0009 para manter auth e storage locais

## Nota de atualizacao
Em 2026-05-02, a ADR 0009 substituiu as decisoes de usar Supabase Auth e Supabase Storage. A topologia de VM unica, proxy HTTPS, backend em container, PostgreSQL sem exposicao publica e volume local persistente para uploads volta a ser a decisao ativa para o MVP.

## Contexto
O OmniConnect precisa publicar o backend `server/` em ambiente acessivel pela internet para suportar o app Flutter e as futuras integracoes externas previstas no PRD. O repositorio ja trabalha com Docker, PostgreSQL e storage local de documentos, mas ainda nao possui pipeline CI/CD, storage remoto, reverse proxy versionado ou estrategia de hospedagem horizontal.

As principais restricoes deste momento sao:

1. O backend ja funciona em container e usa PostgreSQL no mesmo monorepo.
2. O upload de documentos ainda depende de volume local persistente.
3. O MVP precisa privilegiar simplicidade operacional e menor distancia entre o ambiente atual e o primeiro deploy publico.

## Decisao
Adotamos para o primeiro deploy publico do MVP a seguinte topologia:

1. Uma unica VM/VPS Linux publica hospedara a stack do MVP.
2. O backend `server` rodara em container Docker nessa mesma VM.
3. O PostgreSQL rodara na mesma VM, sem exposicao publica de porta, acessivel apenas pela rede interna da stack.
4. O trafego externo entrara somente por HTTPS em um proxy reverso na borda da VM.
5. O storage de documentos continuara em volume local persistente da mesma VM apenas para o MVP.
6. O endpoint `/health` sera um healthcheck de liveness simples.
7. O Swagger ficara desabilitado quando `NODE_ENV=production`.

## Consequencias

### Positivas
- Menor complexidade operacional para o primeiro deploy.
- Aderencia direta ao estado atual do repositorio e da stack local.
- Menos moving parts para o time manter durante a fase inicial.
- Permite publicar rapidamente a API sem exigir migracao imediata para storage remoto.

### Negativas
- Banco e storage ficam acoplados a uma unica VM, sem alta disponibilidade.
- Escalabilidade horizontal continua bloqueada pelo uso de filesystem local.
- Recuperacao de desastres depende de disciplina operacional de backup da VM e do banco.

## Alternativas rejeitadas

### PaaS stateless no primeiro deploy
Rejeitada porque o backend ainda depende de filesystem local para documentos e o repositorio nao implementa provider remoto.

### Banco gerenciado privado ja no primeiro deploy
Rejeitada neste momento por aumentar a superficie operacional sem necessidade para o MVP. Pode ser reavaliada apos estabilizacao do fluxo publico.

### Expor Swagger em producao
Rejeitada para reduzir superficie publica do ambiente.

## Referencias
- Spec: `documentation/specs/g5-7-deploy-caso-de-estudo.md`
- Arquitetura: `documentation/architecture.md`
- Runbook: `documentation/deploy-mvp.md`
