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

O `/code-review` roda **uma vez, sobre o PR inteiro** — nunca por issue. Recortar o
diff por issue é inviável (issues compartilham arquivos) e N execuções produziriam os
mesmos achados repetidos. A divisão é: *qualidade = PR inteiro, conformidade = por
issue*.

**Não restaure a branch ainda** — o passo 5 precisa da branch do PR em checkout.

### 5. Conformidade — o que deveria vs. o que foi feito

Com **2 ou mais issues** vinculadas e `PR_REVIEW_PARALLEL` diferente de `off`
(`.claude/settings.json`), avalie **uma issue por subagente, em paralelo**: um PR de 4
issues vira 4 revisões independentes em vez de uma análise que dilui as quatro DoDs.

1. Para cada issue, preencha o template de
   [ISSUE-REVIEW-BRIEF.md](./ISSUE-REVIEW-BRIEF.md) com o corpo da issue **verbatim**
   — o subagente não vê esta conversa.
2. Spawne todos com `Agent` (`subagent_type: general-purpose`) **numa única
   mensagem**, para que rodem concorrentemente.
3. Eles compartilham esta working tree em modo leitura. Por isso o brief proíbe
   escrever, commitar e trocar de branch: um subagente que mexesse na árvore
   corromperia a revisão dos outros.
4. Use apenas o relatório final de cada um — o formato de resposta já é o que entra no
   veredito, sem reescrita.

**Com 1 issue, nenhuma issue, ou `PR_REVIEW_PARALLEL=off`:** avalie inline, você
mesmo. Spawnar um subagente para uma issue só custa contexto e tempo sem paralelizar
nada.

```bash
gh pr diff $ARGUMENTS
```
Compare o baseline (passo 3) com o diff. Procure:
- Critérios de aceite da issue não cumpridos (DoD incompleta).
- Divergências de terminologia vs. `CONTEXT.md` (campo/conceito fora do glossário).
- Violações de decisões registradas em `docs/adr/`.

Leia com `Read` os arquivos alterados que precisarem de contexto.

Quando **todos** os subagentes tiverem terminado, restaure a branch original:
```bash
git checkout -   # ou a branch guardada no passo 1
```

### 6. Fundir em um veredito único
Severidade dos achados, venham eles da conformidade ou do `/code-review`:

- **BLOQUEADOR** — DoD não cumprida OU bug crítico. Impede aprovação.
- **DESVIO** — divergência de requisito, terminologia (`CONTEXT.md`) ou decisão (`docs/adr/`).
- **MENOR** — nit, convenção, sugestão de simplificação.

A conformidade é apresentada **por issue**, não fundida numa lista só: um PR pode
cumprir a issue #41 inteira e falhar na #42, e quem revisa precisa saber que a #41
pode fechar. A qualidade de código fica numa seção própria, porque é do PR inteiro e
não pertence a nenhuma issue.

Estrutura do veredito (exibir **inline**, não salvar arquivo):

```markdown
## Revisão — PR #<N> [vs. Issues #<A>, #<B> | DoD inferida do PR]

**Veredito:** APROVAR / SOLICITAR MUDANÇAS / COMENTAR
[1-2 frases: o que foi entregue e o julgamento geral.]

### Issue #<A> — ✓ DoD cumprida
[uma frase]
- ⚪ MENOR: [nit]

### Issue #<B> — ✗ DoD incompleta
[uma frase]
- 🔴 BLOQUEADOR: [critério de aceite não cumprido, com arquivo/linha]
- 🟡 DESVIO: [divergência, citando a issue / CONTEXT.md / ADR]

### Qualidade de código (PR inteiro)
- 🔴 BLOQUEADOR: [bug, com arquivo/linha]
- ⚪ MENOR: [simplificação]
```

As seções por issue são os relatórios dos subagentes, **coladas como vieram** — o
formato do brief já é este. Não reescreva nem resuma: reescrever achado de revisão é
como se perde a referência de arquivo/linha.

Omita seções e severidades vazias. Sem nenhum BLOQUEADOR, o PR é aprovável. Sem issues
vinculadas, use uma única seção "Conformidade (DoD inferida do PR)" no lugar das
seções por issue.

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
