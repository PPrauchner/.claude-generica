# Grill — Generalização do comando review-pr

**Início:** 2026-08-19 11:32

Objetivo: fechar no `/review-pr` as mesmas lacunas que as `v4.0.6` e `v4.0.7`
fecharam nos outros comandos do pipeline — caminhos de documentação fixos,
tracker cravado, e pressupostos de stack nos briefs.

## Diagnóstico inicial

| # | Achado | Onde |
|---|---|---|
| 1 | `CONTEXT.md` e `docs/adr/` cravados na raiz, sem `docs/agents/domain.md` nem `CONTEXT-MAP.md` | passo 3 e os dois briefs |
| 2 | `gh issue view` cravado para o baseline, sem o contrato de tracker | passo 3 |
| 3 | `git checkout -` para restaurar a branch; nada restaura se a revisão abortar no meio | passos 1 e 5 |
| 4 | "a integração com board é responsabilidade de cada projeto, não deste comando genérico" — mas `/start-issue` e `/open-pr` movem o board neste mesmo template | passo 8 |
| 5 | Armadilhas do brief de qualidade são Python (`except` largo); ruído de diff lista `uv.lock`, `poetry.lock` | `QUALITY-REVIEW-BRIEF.md` |
| 6 | `$ARGUMENTS` obrigatório: não há "revise o PR da branch atual", que o `/open-pr` sabe derivar | topo |
| 7 | PR fechado/mergeado não tem comportamento definido no passo 7 | passo 7 |

## Perguntas

**P:** Até onde generalizar o `/review-pr`, sendo revisar PR uma operação de forge?
**R:** Mesmo recorte do `/open-pr`: `gh pr` fica e a skill declara GitHub no topo. O
que generaliza é o baseline — issue pelo tracker de `docs/agents/`, docs de domínio
por `domain.md` → `CONTEXT-MAP.md` → raiz. Importa em monorepo, onde o `CONTEXT.md`
da raiz nem é o certo.

**P:** O `gh pr checkout` só é desfeito no fim do passo 5, com `git checkout -`. Se
algo falhar no meio, a sessão fica largada na branch do PR. Como tornar seguro?
**R:** Restaurar pela branch guardada no passo 1, **por nome**, nunca `-`, e também
em qualquer saída antecipada — erro, aborto, interrupção — antes de reportar o
problema. O relatório final confirma em que branch a sessão ficou.

**P:** O passo 8 recusa mexer no board por ser "responsabilidade de cada projeto",
mas os irmãos movem o board neste mesmo template. O que fazer?
**R:** Manter a recusa e trocar a justificativa: revisar não muda o estado da issue.
Aprovado, quem fecha é o merge; mudanças solicitadas, a issue segue em *In review*
até o autor voltar. Não há transição para representar.

**P:** Como generalizar as armadilhas do brief de qualidade (o `except` largo do
Python, os lockfiles) sem esvaziar a parte que faz o subagente achar coisa boa?
**R:** Nomear o padrão e manter o exemplo marcado como exemplo. Lockfiles viram
"lockfiles e arquivos gerados, quaisquer que sejam", com a lista atual entre
parênteses. O revisor num repo Go reconhece o padrão; o exemplo não atrapalha.

**P:** Fechar as duas pontas soltas — `$ARGUMENTS` obrigatório e PR não-`OPEN` sem
comportamento definido?
**R:** Sim. Sem argumento, deriva o PR da branch atual e para se não houver — mesma
postura do `/open-pr`. PR mergeado ou fechado rende revisão só inline, sem oferecer
ação de review: aprovar o que já foi mergeado não significa nada.

---

## Consenso

| # | Decisão |
|---|---|
| 1 | Forge GitHub declarado no topo; baseline (issue) via tracker de `docs/agents/`, docs via `domain.md` → `CONTEXT-MAP.md` → raiz |
| 2 | Branch restaurada por nome, sempre — inclusive em saída antecipada; o relatório diz onde a sessão ficou |
| 3 | Board segue intocado, mas pela razão certa: revisar não muda o estado da issue |
| 4 | Armadilhas e lockfiles do brief de qualidade viram padrão nomeado + exemplo marcado |
| 5 | Sem `$ARGUMENTS`, deriva o PR da branch atual; PR mergeado/fechado rende revisão inline sem ação |
