---
name: review-pr
description: Revisa um Pull Request quanto à conformidade com a issue/DoD e a documentação do projeto, delega a análise de qualidade de código ao /code-review, e executa a ação escolhida (aprovar, solicitar mudanças, comentar). Use when reviewing a pull request. $ARGUMENTS
---

# Review PR

Revisa o PR `#$ARGUMENTS` em duas frentes complementares:

- **Conformidade** (foco deste comando): *construíram a coisa certa?* — o PR cumpre
  a Definition of Done da issue e respeita a terminologia (`CONTEXT.md`) e as
  decisões (`docs/adr/`).
- **Qualidade de código** (delegada): *o código está bom?* — bugs, simplificações,
  eficiência. Isso é responsabilidade do `/code-review`; este comando **o invoca**
  em vez de reescrever a análise.

O veredito final funde as duas frentes em um único relatório.

## Workflow

### 1. Pré-condição: working tree limpa
O passo de qualidade faz checkout da branch do PR, então a árvore precisa estar limpa.
```bash
git status --porcelain
git rev-parse --abbrev-ref HEAD   # branch atual — guardar para restaurar no fim
```
Se houver qualquer mudança pendente, **pare** e peça ao usuário para commitar ou
`git stash` antes de continuar.

### 2. Buscar dados do PR
```bash
gh pr view $ARGUMENTS --json number,title,body,headRefName,baseRefName,state,author,additions,deletions,files,url
```
Extraia do corpo as issues referenciadas (`Closes #N`, `Fixes #N`, `Part of #N`).

### 3. Estabelecer o baseline (o que deveria ter sido feito)
- **Com issue(s) vinculada(s):** `gh issue view N --json number,title,body,labels` — os
  critérios de aceite da issue são o baseline primário.
- **Sem issue vinculada:** use o título + corpo do PR como declaração de intenção.
  Registre no veredito que a DoD foi **inferida do PR** (não havia issue).
- **Documentação (ler preguiçosamente, só se existir):** `CONTEXT.md` para conferir
  a terminologia de domínio; `docs/adr/` para decisões que o PR possa violar. Se o
  projeto não tiver esses arquivos, siga sem eles.

### 4. Qualidade de código — delegar ao /code-review
Com a árvore limpa (passo 1), traga o diff do PR para o working tree local:
```bash
gh pr checkout $ARGUMENTS
```
Invoque o **`/code-review`** (nível `high` por padrão; **sem** `--comment` — quem
publica é este comando) sobre o diff da branch do PR e colete os achados.

Ao terminar, restaure a branch original:
```bash
git checkout -   # ou a branch guardada no passo 1
```

### 5. Conformidade — o que deveria vs. o que foi feito
```bash
gh pr diff $ARGUMENTS
```
Compare o baseline (passo 3) com o diff. Procure:
- Critérios de aceite da issue não cumpridos (DoD incompleta).
- Divergências de terminologia vs. `CONTEXT.md` (campo/conceito fora do glossário).
- Violações de decisões registradas em `docs/adr/`.

Leia com `Read` os arquivos alterados que precisarem de contexto.

### 6. Fundir em um veredito único
Classifique **todos** os achados (conformidade + os do `/code-review`) em três baldes:

- **BLOQUEADOR** — DoD não cumprida OU bug crítico do `/code-review`. Impede aprovação.
- **DESVIO** — divergência de requisito, terminologia (`CONTEXT.md`) ou decisão (`docs/adr/`).
- **MENOR** — nit, convenção, sugestão de simplificação.

Estrutura do veredito (exibir **inline**, não salvar arquivo):

```markdown
## Revisão — PR #<N> [vs. Issue #<M> | DoD inferida do PR]

**Veredito:** APROVAR / SOLICITAR MUDANÇAS / COMENTAR
[1-2 frases: o que foi entregue e o julgamento geral.]

### 🔴 BLOQUEADOR
- [achado, com referência a arquivo/linha e à origem: DoD ou bug]

### 🟡 DESVIO
- [divergência, com citação da issue / CONTEXT.md / ADR]

### ⚪ MENOR
- [nit / convenção]
```
Omita seções vazias. Sem BLOQUEADOR, o PR é aprovável.

### 7. Apresentar e perguntar a ação
Exiba o veredito. Se o PR estiver `OPEN`, pergunte qual ação tomar:

1. **Aprovar** — `gh pr review $ARGUMENTS --approve --body "<resumo>"`
2. **Solicitar mudanças** — `gh pr review $ARGUMENTS --request-changes --body "<bloqueadores>"`
3. **Apenas comentar** — `gh pr comment $ARGUMENTS --body "<veredito>"`
4. **Nada** — não escrever no GitHub, só deixar o veredito no chat

### 8. Executar a ação escolhida
Rode apenas o comando `gh` correspondente à escolha. **Não** mova issues em board
nem execute scripts externos — a integração com board é responsabilidade de cada
projeto, não deste comando genérico.
