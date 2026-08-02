# Grill — Branch automática no `/start-issue` e no `/afk-queue`

**Início:** 2026-08-02

Objetivo: quando a sessão estiver num tronco (`main`, `dev`, `development`), o
`/start-issue` e o `/afk-queue` devem criar uma branch nova a partir dele, nomeada
pela issue (ou pela fila de issues), com possibilidade de desativação via settings.

Esta sessão **reverte** uma decisão registrada em
[`board-sync-adopt-repo-review-paralelo.md`](./board-sync-adopt-repo-review-paralelo.md)
("Nada no template cria branch"), que estava escrita no `/open-pr`, no *Out of scope*
do `/afk-queue` e no `/update-claude`.

**P:** Como detectar que a branch atual é um tronco?
**R:** Lista fixa de nomes (`main`, `master`, `dev`, `develop`, `development`) **mais**
a branch default do repositório, lida de `refs/remotes/origin/HEAD` — local, sem
rede. A lista sozinha não cobriria um tronco chamado `versao_vigente` ou `trunk`.

**P:** E quando a branch atual não é um tronco?
**R:** Não faz nada, segue nela. Preserva o caso de empilhar duas issues relacionadas
na mesma branch de propósito — e é o que faz o `/afk-queue` sequencial manter a fila
inteira numa branch só.

**P:** Qual o formato do nome no `/start-issue`?
**R:** `issue/<N>-<slug-do-título>`, slug em minúsculas, sem acento, truncado em 50
caracteres. Determinístico, gerado por script, sem julgamento do agente. Descartadas
as variantes com prefixo derivado das labels (`fix/`, `feat/`) — dependeriam de as
labels do repo existirem e estarem certas.

**P:** E no `/afk-queue`?
**R:** `afk/<números da fila>`, com sequências consecutivas colapsadas em faixas.

**P:** Aí `afk/1-5` fica ambíguo (issues 1 e 5, ou 1 até 5?). Que separador usar?
**R:** `_` separa itens, `-` significa exclusivamente "até": `1,2,3,4,5` → `afk/1-5`;
`12,15,20` → `afk/12_15_20`; `1,2,3,7,20` → `afk/1-3_7_20`.

**P:** Em que ponto do fluxo a branch nasce?
**R:** Logo **depois** do checkpoint de confirmação que as duas skills já têm
(`/start-issue` passo 4, `/afk-queue` passo 2) — o nome da branch entra no resumo
apresentado ali. Zero pergunta nova, e uma recusa não deixa branch órfã para trás.

**P:** E se a branch alvo já existir?
**R:** Faz checkout dela e avisa. Retomar o trabalho da mesma issue é o caso normal.

**P:** Onde mora a lógica?
**R:** Num script, `.claude/scripts/ensure-branch.sh`, e não em prosa dentro das duas
`SKILL.md` — assim slug e faixas são determinísticos e testáveis, e as duas skills
não podem divergir uma da outra.

**P:** O modo paralelo do `/afk-queue` (worktree por subagente) muda?
**R:** Não. Cada worktree já nasce isolado numa branch própria; uma branch `afk/` por
cima nunca receberia commit. E o `/start-issue` rodando dentro do worktree também é
no-op, porque a branch do worktree já não é tronco.

**P:** Se o `git checkout -b` falhar, o script segue ou para?
**R:** **Falha ruidosa** (exit ≠ 0) e a skill para. É o contrário deliberado do
`board-move.sh`: lá, seguir sem o board não custa nada; aqui, seguir sem a branch
despeja os commits no tronco, exatamente o que a feature existe para evitar. No
`/afk-queue` isso aborta a fila antes do primeiro subagente — melhor que descobrir 5
issues empilhadas na `main`.

**P:** Nome e default do toggle?
**R:** `AUTO_BRANCH: "on"` no bloco `env` do `settings.json`, seguindo o padrão de
`BOARD_SYNC` e `GRILL_LOG`. Ligado por default, ciente de que o `/update-claude`
"acrescenta o que falta" no `settings.json` e portanto a chave chega ligada em todo
repo que atualizar o template — aceitável porque só dispara em tronco, e o pior caso
é uma branch a mais, reversível.

---

**Consenso e implementação:**
- [`.claude/scripts/ensure-branch.sh`](../../.claude/scripts/ensure-branch.sh):
  detecta o tronco, monta o nome, cria ou reaproveita a branch. Modos `issue` e `afk`.
- [`/start-issue`](../../.claude/commands/start-issue/SKILL.md): passo 5 novo entre a
  confirmação e a implementação; o nome da branch entra no resumo do passo 4.
- [`/afk-queue`](../../.claude/commands/afk-queue/SKILL.md): passo 3 novo (só no modo
  sequencial); *Out of scope* reescrito de "doesn't create branches" para "uma branch
  por batelada".
- [`/open-pr`](../../.claude/commands/open-pr/SKILL.md) e
  [`/update-claude`](../../.claude/commands/update-claude/SKILL.md): continuam **não**
  criando branch — no `/open-pr` os commits já estão no tronco quando ele roda, e
  atualizar o template não é uma issue. Só a justificativa foi reescrita.
- Toggle `AUTO_BRANCH` no [`settings.json`](../../.claude/settings.json), documentado
  no [README](../../README.md#toggles) e no
  [`scripts/README.md`](../../.claude/scripts/README.md).

**Decisões tomadas sem perguntar** (baixo risco, comportamento padrão do git):
- Árvore suja não bloqueia: `git checkout -b` a partir do mesmo commit sempre
  funciona e leva as mudanças não-commitadas junto.
- O script nunca dá push — publicar a branch continua sendo do `/open-pr`.
- `HEAD` destacado é no-op com aviso: não há branch de tronco a proteger.
