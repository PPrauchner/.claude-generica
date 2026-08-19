---
name: review-pr
description: Revisa um Pull Request quanto à conformidade com a issue/DoD e a documentação do projeto, delega a análise de qualidade de código a um subagente, e executa a ação escolhida (aprovar, solicitar mudanças, comentar). Use when reviewing a pull request. $ARGUMENTS
---

# Review PR

Revisa o PR `#$ARGUMENTS` em duas frentes complementares:

- **Conformidade** (foco deste comando): *construíram a coisa certa?* — o PR cumpre
  a Definition of Done da issue e respeita a terminologia (`CONTEXT.md`) e as
  decisões (`docs/adr/`).
- **Qualidade de código** (delegada): *o código está bom?* — bugs, simplificações,
  eficiência. Vai para um subagente próprio, que analisa o PR inteiro de uma vez.

O veredito final funde as duas frentes em um único relatório.

> **Este comando é GitHub.** Revisar PR é operação de forge, não de tracker: usa
> `gh pr` de ponta a ponta e não tem equivalente configurável. O que ele lê do
> projeto — a issue que serve de baseline e a documentação de domínio — é genérico.

`$ARGUMENTS` é opcional: sem ele, o PR é derivado da branch atual
(`gh pr view --json number --jq .number`). Se a branch não tiver PR aberto, **pare**
e peça o número — é a mesma postura do `/open-pr`, que também trabalha a partir da
branch.

## Workflow

### 1. Pré-condição: working tree limpa
O passo de qualidade faz checkout da branch do PR, então a árvore precisa estar limpa.
```bash
git status --porcelain
git rev-parse --abbrev-ref HEAD   # branch atual — guardar para restaurar no fim
```
Se houver qualquer mudança pendente, **pare** e peça ao usuário para commitar ou
`git stash` antes de continuar.

**Guarde o nome da branch atual.** A restauração no passo 5 usa esse nome, nunca
`git checkout -` — `-` significa "a branch anterior", que deixa de ser a certa assim
que qualquer outra troca acontecer no meio.

E restaure **em toda saída antecipada**: subagente que aborta, `gh` que erra, revisão
interrompida. Terminar largado na branch do PR é pior que não revisar — o próximo
`/commit` comita lá.

### 2. Buscar dados do PR
```bash
gh pr view $ARGUMENTS --json number,title,body,headRefName,baseRefName,state,author,additions,deletions,files,url
```
Extraia do corpo as issues referenciadas (`Closes #N`, `Fixes #N`, `Part of #N`).

### 3. Estabelecer o baseline (o que deveria ter sido feito)
- **Com issue(s) vinculada(s):** busque cada uma com o comando que
  [`docs/agents/issue-tracker.md`](../../../docs/agents/issue-tracker.md) define para
  este repositório. Sem esse arquivo, assuma GitHub
  (`gh issue view N --json number,title,body,labels`) e avise em uma linha. Os
  critérios de aceite da issue são o baseline primário.
- **Sem issue vinculada:** use o título + corpo do PR como declaração de intenção.
  Registre no veredito que a DoD foi **inferida do PR** (não havia issue).
- **Documentação (ler preguiçosamente, só se existir):** onde ela mora, em ordem —
  `docs/agents/domain.md`; senão `CONTEXT-MAP.md` na raiz, seguindo o mapa até o
  contexto que o PR toca; senão `CONTEXT.md` + `docs/adr/` na raiz; senão siga sem
  eles. Num monorepo, o `CONTEXT.md` da raiz costuma não ser o certo — é por isso que
  a ordem importa.

### 4. Qualidade de código — preparar o subagente
Com a árvore limpa (passo 1), traga o diff do PR para o working tree local:
```bash
gh pr checkout $ARGUMENTS
```
Preencha o template de [QUALITY-REVIEW-BRIEF.md](./QUALITY-REVIEW-BRIEF.md) com o
título e o corpo do PR **verbatim** — o subagente não vê esta conversa, e é do corpo
que ele tira os pontos de julgamento que o autor deixou em aberto.

**Não spawne ainda:** o passo 5 dispara este agente na mesma mensagem que os de
conformidade, para que rodem concorrentes. Se a conformidade for inline (1 issue,
nenhuma, ou `PR_REVIEW_PARALLEL=off`), spawne-o aqui e siga para o passo 5 enquanto
ele roda.

Este agente roda **uma vez, sobre o PR inteiro** — nunca por issue. Recortar o diff
por issue é inviável (issues compartilham arquivos) e N execuções produziriam os
mesmos achados repetidos. A divisão é: *qualidade = PR inteiro, conformidade = por
issue*.

Ele roda **sempre**, inclusive com `PR_REVIEW_PARALLEL=off`: aquele toggle existe para
não multiplicar agentes de conformidade, e a qualidade é sempre um agente só.

**Não restaure a branch ainda** — o passo 5 precisa da branch do PR em checkout.

### 5. Conformidade — o que deveria vs. o que foi feito

Com **2 ou mais issues** vinculadas e `PR_REVIEW_PARALLEL` diferente de `off`
(`.claude/settings.json`), avalie **uma issue por subagente, em paralelo**: um PR de 4
issues vira 4 revisões independentes em vez de uma análise que dilui as quatro DoDs.

1. Para cada issue, preencha o template de
   [ISSUE-REVIEW-BRIEF.md](./ISSUE-REVIEW-BRIEF.md) com o corpo da issue **verbatim**
   — o subagente não vê esta conversa. Passe também os **caminhos** do glossário e
   dos ADRs que você localizou no passo 3: o subagente não repete essa busca.
2. Spawne todos com `Agent` (`subagent_type: general-purpose`) **numa única
   mensagem**, junto com o agente de qualidade do passo 4, para que rodem
   concorrentemente.
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

Quando **todos** os subagentes tiverem terminado, restaure a branch guardada no
passo 1, pelo nome:
```bash
git checkout <branch guardada no passo 1>
```

### 6. Fundir em um veredito único
Severidade dos achados, venham eles da conformidade ou da qualidade:

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

Tanto as seções por issue quanto a de qualidade são os relatórios dos subagentes,
**colados como vieram** — o formato dos briefs já é este. Não reescreva nem resuma:
reescrever achado de revisão é como se perde a referência de arquivo/linha.

Omita seções e severidades vazias. Sem nenhum BLOQUEADOR, o PR é aprovável. Sem issues
vinculadas, use uma única seção "Conformidade (DoD inferida do PR)" no lugar das
seções por issue.

### 7. Apresentar e perguntar a ação
Exiba o veredito.

**PR mergeado ou fechado:** a revisão para aqui, inline. Não ofereça ação de review —
aprovar o que já foi mergeado não significa nada, e solicitar mudanças num PR fechado
não tem a quem endereçar. Diga o estado do PR no relatório.

**PR `OPEN`:** pergunte qual ação tomar:

1. **Aprovar** — `gh pr review $ARGUMENTS --approve --body "<resumo>"`
2. **Solicitar mudanças** — `gh pr review $ARGUMENTS --request-changes --body "<bloqueadores>"`
3. **Apenas comentar** — `gh pr comment $ARGUMENTS --body "<veredito>"`
4. **Nada** — não escrever no GitHub, só deixar o veredito no chat

### 8. Executar a ação escolhida
Rode apenas o comando `gh` correspondente à escolha. Confirme no relatório final em
qual branch a sessão ficou.

**Não** mova issues em board. Não é que board seja assunto de outro comando — o
`/start-issue` e o `/open-pr` movem, via `board-move.sh`. É que **revisar não muda o
estado da issue**: aprovado, quem fecha é o merge; mudanças solicitadas, a issue
segue em *In review* até o autor voltar. Não há transição para representar.
