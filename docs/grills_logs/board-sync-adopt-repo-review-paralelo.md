# Grill — Board sync, skill de adoção de repo, review-pr paralelo e política de releases

**Início:** 2026-07-21

Objetivo: definir (1) sincronização automática de issues com o board do GitHub
Projects, (2) uma skill que auto-preenche `CLAUDE.md`/`CONTEXT.md` ao colar o
template num repo já em andamento, (3) `review-pr` avaliando cada issue do PR em
subagentes paralelos — e a política de releases do próprio template.

## Achados de exploração (não perguntados)

- `gh` 2.93.0; os repos **já são linkados** a um Project v2 — `repository.projectsV2`
  devolve o project, então o ID é descobrível sem perguntar ao usuário.
- As colunas reais do board são `Backlog / Ready / In progress / In review / Done`
  — com **minúsculo** em "progress"/"review". Hardcodar `"In Progress"` quebraria.
- O repo não tem nenhuma tag git — a `v1.0.0` será criada do zero.

---

## Política de releases

**P:** Onde a política de versionamento deve morar, dado que "não deve ser
versionada pelo git"?
**R:** `CLAUDE.local.md` na raiz, adicionado ao `.gitignore`. É meta do repositório-
template, não parte do template — se fosse versionada em `.claude/rules/`, todo
projeto que copiasse a pasta herdaria uma regra sobre versionar o próprio template.

**P:** Qual a régua completa de bump, já que suas regras deixam o dígito do meio sem função?
**R:** Não é semver, é **odômetro**. PATCH sobe a cada alteração de skill/comando
existente; ao estourar 9, rola para o MINOR (`v1.0.9` → `v1.1.0`). MAJOR é reservado
para skill/comando novo. (MINOR rola além de 9 — `v1.10.0` — para nunca se disfarçar
de skill nova.)

**P:** O que conta como uma release — cada arquivo de skill tocado ou cada mudança lógica?
**R:** Por **mudança lógica**. Uma release por capacidade entregue, mesmo que toque
vários comandos; arquivos de apoio (`scripts/`, `hooks/`, `rules/`) entram na release
da skill que servem; `README`/`docs/` sozinhos não geram release.

---

## Item 1 — Sincronização com o board

**P:** Quem dispara a movimentação para "In review", já que nenhum comando do
template abre PR hoje (`/commit` só pergunta se quer push; o `afk-queue` proíbe PR)?
**R:** Um comando novo **`/open-pr`**. O pipeline fica
`afk-queue → start-issue (In progress) → tdd → commit → open-pr (In review)`, e
`start-issue` sozinho faz o mesmo com uma issue só. `afk-queue` e `start-issue`
continuam commitando automaticamente. Consequência: no AFK quem pergunta "abrir PR?"
é o **orquestrador ao fim da fila** — subagente unattended não tem a quem perguntar.

**P:** Um PR agrupa quantas issues, e de onde vem a branch?
**R:** **1 PR = N issues, branch criada por você.** Nada no template cria branch.
`/open-pr` abre o PR da branch atual e descobre as issues lendo os rodapés
`Closes #N` / `Part of #N` dos commits (que o `/commit` já escreve), movendo todas
para *In review*. Aborta se a branch atual for a default. É isso que faz o item 3
existir: no AFK sequencial N issues empilham commits na mesma branch → PR multi-issue.

**P:** Onde ficam o toggle do board sync e os IDs do project?
**R:** Toggle `BOARD_SYNC` no bloco `env` do `settings.json` (simétrico ao
`GRILL_LOG` já existente). IDs **auto-descobertos** via GraphQL e cacheados em
`.claude/board.env` — gitignored, mesmo tratamento do `current-issue`. Formato `.env`
em vez de `.json` porque `jq` não está instalado na máquina e ler JSON em bash sem ele
é sofrimento (`gh` traz JQ próprio para escrever, mas não ajuda a ler o cache).
Nomes de coluna resolvidos por match case-insensitive contra as opções reais do board;
se nada casar, pergunta uma vez e cacheia.

**P:** Como o movimento é executado — script compartilhado ou instruções em markdown?
**R:** **Script bash único** `.claude/scripts/board-move.sh <issue> <in-progress|in-review>`.
São 3 pontos de chamada e o GraphQL de Projects v2 exige converter a issue em item do
project antes de setar o campo — replicar isso em markdown divergiria, e subagente AFK
improvisando GraphQL é não-determinístico.

**P:** O que acontece quando o board sync falha?
**R:** **Nunca bloqueia.** `exit 0` sempre, aviso no stderr. Implementar a issue não
pode depender do board — no AFK, uma falha de board abortaria a fila inteira.

---

## Item 2 — Skill de adoção de repo (`adopt-repo`)

**P:** A skill cobre só `CLAUDE.md` + `CONTEXT.md` ou a checklist inteira de adoção?
**R:** **Checklist completa, delegando.** Os 6 artefatos que o template espera:
`CLAUDE.md`, `CONTEXT.md`, "Restrições deste projeto" em `code-conventions.md`,
`rules/<lang>-conventions.md`, `settings.local.json` (a partir do `.example`) e
`docs/agents/*` — este último **invocando** a `setup-matt-pocock-skills`, que já faz
isso, em vez de duplicar. Sem o `docs/agents/`, o `afk-queue` se recusa a rodar.

**P:** Como o grill se distribui entre os artefatos?
**R:** **Deriva o derivável, grelha o resto.** Stack, comandos e estrutura o repo
responde sozinho → `CLAUDE.md` é montado por recon e apresentado em uma rodada de
conferência. O grill é gasto onde o código é mudo: o `CONTEXT.md` é a ponte termo de
domínio (pt-BR) ↔ identificador (inglês) — o código mostra `class Chapter`, não diz se
você chama aquilo de "capítulo" ou "episódio".

**P:** O que fazer quando `CLAUDE.md`/`CONTEXT.md` já existem?
**R:** **Nunca sobrescreve, só completa.** Trata o existente como verdade, acrescenta
apenas seções ausentes, e leva contradições (doc diz `pnpm`, repo tem
`package-lock.json`) para o grill em vez de decidir sozinha. Idempotente.

---

## Item 3 — `review-pr` com um subagente por issue

Resolvido pela arquitetura, sem perguntar: o `/code-review` **continua global e único**
(recortar diff por issue é inviável — issues compartilham arquivos), e os subagentes
compartilham a working tree sem risco, porque revisor não escreve (o `gh pr checkout`
acontece uma vez; o `git checkout -` final espera todos).

**P:** Como o relatório funde os N vereditos de conformidade com o `/code-review` global?
**R:** **Seção por issue + veredito global.** Veredito do PR no topo, uma seção por
issue com julgamento próprio (DoD cumprida / incompleta) e seus achados, e ao final os
achados de qualidade sobre o PR inteiro. Responde "a issue #42 pode fechar?", que os
baldes globais não respondem.

**P:** Quando vale spawnar subagentes?
**R:** **Só com 2+ issues.** 1 issue (ou nenhuma) → avaliação inline, como hoje.
