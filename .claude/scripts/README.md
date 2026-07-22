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
- **[link-skills.sh](./link-skills.sh)** — cria symlinks de `skills/*` em
  `~/.claude/skills`, deixando as skills deste projeto disponíveis em qualquer outro.
  Preferência pessoal, não etapa obrigatória: sem rodar, as skills seguem funcionando
  a partir da cópia local.
- **[list-skills.sh](./list-skills.sh)** — lista os `SKILL.md` presentes em
  `.claude/`, comandos incluídos. Útil para conferir o que a pasta realmente carrega.

## Desligar

`BOARD_SYNC=off` no bloco `env` de [`../settings.json`](../settings.json) faz o
`board-move.sh` sair na primeira linha — os comandos continuam funcionando, só não
mexem no board.

## Fim de linha

São arquivos `.sh` executados por bash — precisam de fim de linha **LF**. Com CRLF,
o bash falha com `\r: command not found`.
