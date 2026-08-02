# Scripts

Utilitários chamados **por um comando** (ou por você, na mão). Diferente dos
[hooks](../hooks/README.md), nenhum deles roda sozinho.

- **[board-move.sh](./board-move.sh)** — move uma issue de coluna no board do GitHub
  Projects (v2). Chamado por `/start-issue` (*In progress*) e `/open-pr` (*In
  review*). **Nunca falha**: sem project linkado, sem permissão ou sem a coluna, vira
  aviso no stderr e `exit 0` — implementar uma issue não pode depender do board, ou
  um erro aqui abortaria a fila inteira do `/afk-queue`. Descobre e cacheia os IDs do
  board em `.claude/board.env`.
  ```bash
  bash .claude/scripts/board-move.sh <numero-da-issue> <in-progress|in-review>
  ```
- **[ensure-branch.sh](./ensure-branch.sh)** — cria a branch de trabalho quando a
  sessão está num tronco (`main`, `master`, `dev`, `develop`, `development` ou a
  branch default do repositório, lida de `refs/remotes/origin/HEAD`). Chamado por
  `/start-issue` (`issue/<N>-<slug>`) e `/afk-queue` (`afk/<números>`, com faixas:
  `1 2 3 7 20` → `afk/1-3_7_20`, hífen é "até" e underscore separa). Fora do tronco
  não faz nada. **Falha ruidosamente** (exit ≠ 0) se não conseguir criar a branch —
  ao contrário do `board-move.sh`, e de propósito: seguir sem o board não custa nada,
  seguir sem a branch despeja os commits no tronco, que é o que ele existe para
  evitar. Se a branch já existe, faz checkout dela e avisa. Imprime no stdout a
  branch resultante, ou nada quando não havia o que fazer.
  ```bash
  bash .claude/scripts/ensure-branch.sh issue 123 "Título da issue"
  bash .claude/scripts/ensure-branch.sh afk 12 15 20
  ```
- **[link-skills.sh](./link-skills.sh)** — cria symlinks de `skills/*` em
  `~/.claude/skills`, deixando as skills deste projeto disponíveis em qualquer outro.
  Preferência pessoal, não etapa obrigatória: sem rodar, as skills seguem funcionando
  a partir da cópia local.
- **[list-skills.sh](./list-skills.sh)** — lista os `SKILL.md` presentes em
  `.claude/`, comandos incluídos. Útil para conferir o que a pasta realmente carrega.

## Desligar

No bloco `env` de [`../settings.json`](../settings.json):

- `BOARD_SYNC=off` faz o `board-move.sh` sair na primeira linha — os comandos
  continuam funcionando, só não mexem no board.
- `AUTO_BRANCH=off` faz o `ensure-branch.sh` sair na primeira linha — a branch volta
  a ser inteiramente decisão sua, e o `/start-issue` e o `/afk-queue` implementam na
  branch que estiver em checkout, tronco ou não.

## Fim de linha

São arquivos `.sh` executados por bash — precisam de fim de linha **LF**. Com CRLF,
o bash falha com `\r: command not found`.
