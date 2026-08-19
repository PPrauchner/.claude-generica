# Grill — Generalização dos comandos commit e open-pr

**Início:** 2026-08-19 11:13

Objetivo: dar ao `/commit` e ao `/open-pr` o mesmo tratamento que a `v4.0.6` deu ao
`/start-issue` — remover pressupostos de projeto específico, fechar as lacunas de
precisão e alinhá-los ao contrato de tracker de `docs/agents/`.

## Diagnóstico inicial

| # | Achado | Onde |
|---|---|---|
| 1 | `gh issue view` cravado — mesma lacuna que o `/start-issue` fechou na v4.0.6 | `commit` passo 3 |
| 2 | Ninguém marca o checklist `## Plano de execução` criado na v4.0.6 | `commit` / `open-pr` |
| 3 | `git log --oneline -1` confere só o assunto, não a mensagem multilinha | `commit` passo 7 |
| 4 | Idioma da mensagem de commit não é definido em lugar nenhum | `commit` |
| 5 | "Uma camada por commit — `models/`, `services/`, `api/v1/`" presume app web em camadas | `atomicity-rules.md` |
| 6 | `git log <default>..HEAD` numa branch empilhada reivindica issues de outra branch | `open-pr` passo 2 |
| 7 | `gh` cravado de ponta a ponta, sem o contrato de tracker do `/start-issue` | `open-pr` |
| 8 | `commands/README.md` descreve o `/start-issue` como "issue do GitHub" — drift da v4.0.6 | `README` |

## Perguntas

**P:** Até onde generalizar o `/open-pr`, sendo ele uma operação de forge e não de
tracker?
**R:** GitHub-only, mas declarado no topo da skill. `gh pr create` fica; o que
generaliza é o trecho de issues (descoberta por `git log`, board que já degrada em
aviso). Quem usa GitLab abre o MR à mão.

**P:** O range `git log <branch-default>..HEAD` varre commits da branch-pai quando a
branch foi empilhada de propósito, e o PR reivindica issues que já têm PR. Como
corrigir?
**R:** Descobrir a base real: `<base>..HEAD`, onde base é o upstream configurado da
branch (`@{u}`) se houver, senão a branch default — e o PR abre contra essa base.
A branch empilhada vira um PR contra a branch-pai, que é o que ela de fato é.

**P:** Quem marca o checklist `## Plano de execução` criado na v4.0.6?
**R:** O `/commit`, depois de executar os commits — marca o que aconteceu, não o que
o agente pretendia, e funciona igual no `/afk-queue`. O `/start-issue` perde essa
responsabilidade: cria o checklist, não o mantém.

**P:** Qual o idioma da mensagem de commit, que nenhum arquivo de convenção define?
**R:** O que o histórico do repositório usar. O passo 2 passa a ler
`git log --format=%s -20` e imitar idioma, acentuação e formato do escopo. Sem
configuração: repo em inglês gera commit em inglês.

**P:** Como reescrever o `atomicity-rules.md`, que presume app web em camadas
(`models/`, `services/`, `api/v1/`) e Python (`pyproject.toml`)?
**R:** Generalizar os princípios (exemplos marcados como exemplo de um layout
possível) **e** acrescentar uma seção "Camadas deste projeto" preenchida na sessão
de grill — mesmo tratamento que a tabela de escopos já anuncia.

**P:** Como fechar a lacuna do `git log --oneline -1`, que não mostra mensagem
multilinha gravada errada por sintaxe de shell?
**R:** Conferir com `git log -1 --format=%B` sempre que a mensagem tiver corpo, e
`git commit --amend` no ato se o gravado não for o proposto. O amend é seguro
porque o commit acabou de nascer e nunca foi publicado.

**P:** O `/afk-queue` exige `docs/agents/issue-tracker.md` e para sem ele; o
`/start-issue` e o `/commit` caem em `gh` com aviso. Dois contratos no mesmo
pipeline — deixa assim?
**R:** Sim, e escrever a razão numa linha em cada skill: o `/afk-queue` roda sem
ninguém olhando, e uma suposição errada lá estraga N issues em silêncio; no caminho
interativo o usuário vê o aviso e corrige. Sem a razão escrita, alguém "conserta" a
diferença depois achando que é desleixo.

---

## Consenso

| # | Decisão |
|---|---|
| 1 | `/open-pr` continua GitHub-only, agora declarado no topo da skill |
| 2 | O range vira `<base>..HEAD` com base descoberta (`@{u}`, senão a default); o PR abre contra essa base |
| 3 | O `/commit` passa a marcar o checklist `## Plano de execução` após commitar; o `/start-issue` só o cria |
| 4 | Idioma/estilo da mensagem de commit vêm do histórico do repositório (`git log --format=%s -20`) |
| 5 | `atomicity-rules.md` generalizado + seção "Camadas deste projeto" calibrável |
| 6 | Conferência com `git log -1 --format=%B` quando há corpo, e `--amend` no ato se divergir |
| 7 | O `/commit` lê o tracker de `docs/agents/`, com fallback avisado — e a assimetria com o `/afk-queue` fica documentada nos dois |

**Também nesta rodada:** `commands/README.md` ainda descreve o `/start-issue` como
"issue do GitHub" — drift deixado pela `v4.0.6`.
