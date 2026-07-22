# Workflow

Commands de workflow

- **[afk-queue](./afk-queue/SKILL.md)** — Work through a queue of AFK-ready issues unattended, one clean-context subagent per issue, so the session never accumulates unrelated history.
- **[commit](./commit/SKILL.md)** — Analisa mudanças não-commitadas e realiza commits atômicos seguindo as convenções do projeto.
- **[start-issue](./start-issue/SKILL.md)** — Inicia o trabalho em uma issue do GitHub: lê a issue, avalia complexidade e prepara a implementação. Move a issue para *In progress* no board.
- **[open-pr](./open-pr/SKILL.md)** — Abre o PR da branch atual, descobrindo nos rodapés dos commits quais issues foram implementadas, e move essas issues para *In review*.
- **[review-pr](./review-pr/SKILL.md)** — Revisa um PR quanto à conformidade com a issue/DoD e a documentação, delegando a análise de qualidade de código ao `/code-review`, e executa a ação escolhida no GitHub.

## Pipeline

`/start-issue` → `/tdd` → `/commit` → `/open-pr` → `/review-pr`, com o `/afk-queue`
orquestrando o trecho `start-issue → commit` para uma fila inteira de issues.

A sincronização com o GitHub Projects (*In progress* ao iniciar, *In review* ao abrir
o PR) é feita por [`scripts/board-move.sh`](../scripts/board-move.sh) e se desliga com
`BOARD_SYNC=off` no bloco `env` de `.claude/settings.json`.
