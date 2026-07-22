---
name: open-pr
description: Abre o Pull Request da branch atual, descobrindo nos rodapés dos commits quais issues foram implementadas, e move essas issues para "In review" no board. Use when opening a pull request. $ARGUMENTS
---

# Open PR

Fecha o pipeline `start-issue → tdd → commit → open-pr`: publica a branch atual como
PR e move para *In review* as issues que ela implementou.

As issues **não** são passadas como argumento — são descobertas nos rodapés
`Closes #N` / `Fixes #N` / `Part of #N` dos commits, que é justamente o que o
`/commit` escreve. Um PR pode fechar várias issues (é o caso normal depois de um
`/afk-queue`, em que N issues empilham commits na mesma branch).

`$ARGUMENTS`, se fornecido, vira o título do PR; senão o título é derivado dos commits.

## Workflow

### 1. Pré-condições
```bash
git rev-parse --abbrev-ref HEAD
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
git status --porcelain
```

- **Branch atual == branch default:** **pare.** Não existe PR de `main` para `main`.
  Peça ao usuário para criar a branch — nada neste template cria branch
  automaticamente, é decisão dele.
- **Árvore suja:** **pare** e peça para rodar `/commit` antes. Abrir o PR deixando
  mudanças para trás produz um PR que não corresponde ao trabalho feito.
- **Já existe PR para esta branch** (`gh pr view --json url,state`): não crie outro.
  Informe a URL, pule para o passo 6 (o board ainda precisa ser atualizado) e diga
  que o PR foi apenas atualizado pelo push.

### 2. Descobrir as issues implementadas
```bash
git log <branch-default>..HEAD --pretty=%B
```
Extraia todo `Closes #N`, `Fixes #N`, `Part of #N`; deduplique preservando a ordem de
aparição. Se nenhuma issue for encontrada, siga mesmo assim, mas **avise no resumo**
que nenhuma issue será fechada no merge nem movida no board.

### 3. Montar título e corpo
- **Título:** `$ARGUMENTS` se houver. Senão, com uma issue só, o título dela; com
  várias, um resumo do tema comum dos commits.
- **Corpo:** o que mudou e por quê (a partir dos commits, não do diff linha a linha),
  seguido de uma linha `Closes #N` para cada issue descoberta.

Use `Closes` apenas para issues cujo escopo o PR **realmente completa**; para as que
seguem abertas depois do merge, use `Part of #N` — a linha errada aqui fecha issue
que não deveria fechar.

### 4. Apresentar e confirmar — aguardar
Mostre branch de origem/destino, título, corpo e a lista de issues que serão movidas
para *In review*. **Aguarde confirmação**: publicar um PR é ação externa e visível.

### 5. Publicar
```bash
git push -u origin <branch>
gh pr create --title "<título>" --body "<corpo>" --base <branch-default>
```

### 6. Mover as issues no board
Para **cada** issue descoberta no passo 2:
```bash
bash .claude/scripts/board-move.sh <N> in-review
```
O script é silencioso quando `BOARD_SYNC=off` e nunca falha o comando — se o board
não estiver configurado, ele avisa e o PR continua aberto normalmente. Não trate
aviso de board como erro do `/open-pr`.

### 7. Reportar
URL do PR, issues movidas e issues que ficaram de fora (e por quê).

Não peça review, não faça merge, não mexa em labels — isso é decisão do usuário.

> Quando o PR for mergeado, o `Closes #N` fecha as issues e o workflow nativo do
> GitHub Projects ("Item closed → Done") as move para *Done*. Por isso este comando
> não precisa cuidar da coluna final.
