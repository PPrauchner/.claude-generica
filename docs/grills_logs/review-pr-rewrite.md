# Grill — Reescrita do comando review-pr

**Início:** 2026-07-08 15:40

Objetivo: chegar a consenso sobre como reescrever o comando `review-pr` de forma
genérica, reutilizando a skill `/code-review` para eliminar duplicação.

**P:** O que o `review-pr` reescrito deve possuir, versus delegar ao `/code-review`?
**R:** Conformance + orchestrate — o comando foca em "construíram a coisa certa?"
(conformidade com issue/DoD/docs) e **invoca** o `/code-review` para a análise de
qualidade de código, sem reescrevê-la.

**P:** Onde a saída da revisão deve parar, para um comando genérico reutilizável?
**R:** Inline + comentário opcional no PR. Sem arquivo local — elimina toda a
maquinaria de `docs/relatorios/.../Sprint_.../`.

**P:** Quais fontes definem "o que deveria ter sido feito" na checagem de conformidade?
**R:** Issue vinculada (primária) + `CONTEXT.md` + `docs/adr/`, lidos preguiçosamente
e ignorados com elegância se não existirem. Sem specs-map do SAGA.

**P:** Quais ações o `review-pr` deve oferecer, e deve mexer em board de issues?
**R:** Apenas ações de PR (aprovar / solicitar mudanças / comentar / nada) via `gh`.
Sem movimentação de board — remove a referência morta a `move-issue.sh`.

**P:** Como o veredito deve combinar achados de conformidade com a saída do `/code-review`?
**R:** Baldes de severidade unificados — BLOQUEADOR / DESVIO / MENOR; achados do
`/code-review` entram por severidade.

**P:** O que o `review-pr` faz quando o PR não tem issue vinculada?
**R:** Usa o título/corpo do PR como intenção declarada e registra no veredito que a
DoD foi inferida do PR.

**P:** Como o `review-pr` entrega as mudanças do PR ao `/code-review` (que revisa o diff local)?
**R:** Exigir árvore limpa → `gh pr checkout <N>` → rodar `/code-review` → restaurar a
branch original. Aborta se a árvore estiver suja.

---

**Consenso:** ver a tabela de decisões aplicada em
[`.claude/commands/review-pr/SKILL.md`](../../.claude/commands/review-pr/SKILL.md).
Arquivos `specs-map.md` e `report-template.md` (específicos do SAGA) removidos.
