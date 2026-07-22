---
name: start-issue
description: Inicia o trabalho em uma issue do GitHub. Lê a issue, identifica docs relevantes, avalia complexidade e prepara a implementação. Use when starting work on an issue. $ARGUMENTS
---

# Start Issue

Inicia o trabalho na issue `#$ARGUMENTS`.

## Workflow

### 1. Registrar issue ativa
```bash
echo "$ARGUMENTS" > .claude/current-issue
bash .claude/scripts/board-move.sh $ARGUMENTS in-progress
```
O `board-move.sh` move a issue para *In progress* no GitHub Projects. Ele é
silencioso com `BOARD_SYNC=off` (`.claude/settings.json`) e **nunca falha** — se o
board não estiver configurado, avisa e o trabalho segue. Não trate aviso de board
como erro.

### 2. Ler a issue
```bash
gh issue view $ARGUMENTS --json number,title,body,labels,assignees
```

### 3. Ler docs e código relevantes
- Consulte `CONTEXT.md` (modelo de domínio) e `docs/adr/` (decisões) para usar a
  terminologia correta e respeitar as decisões já tomadas.
- Leia os arquivos de código diretamente relacionados à issue para entender o que
  já existe antes de implementar.

### 4. Avaliar complexidade
Consulte o [guia de complexidade](./complexity-guide.md) para decidir se a issue
deve ser quebrada.

**Se SIMPLES** — apresente: resumo do que será feito + arquivos a modificar.
Aguardar confirmação.

**Se COMPLEXA** — apresente: avaliação de complexidade + lista de sub-tarefas
propostas (título, escopo, dependências). Aguardar confirmação e ajustes antes de
seguir.

### 5. Iniciar implementação
Comece pela primeira sub-tarefa (ou pela issue diretamente, se simples). Implemente via tdd (skill em `.claude/skills/tdd/SKILL.md`).

Ao terminar, o pipeline segue em `/commit` e depois `/open-pr` — é o `/open-pr` que
move a issue para *In review*, ao publicar o PR.
