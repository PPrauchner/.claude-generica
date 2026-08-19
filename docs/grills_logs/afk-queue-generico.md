# Grill — Revisão do comando afk-queue

**Início:** 2026-08-19 11:47

Objetivo: fechar no `/afk-queue` o que sobrou da série que generalizou o pipeline
(`v4.0.6` a `v4.0.8`) — inclusive o drift que essas próprias releases deixaram no
brief do subagente.

## Diagnóstico inicial

| # | Achado | Onde |
|---|---|---|
| 1 | `SKILL.md` e `BRIEF.md` em inglês; os outros comandos em português | ambos |
| 2 | O subagente unattended posta o checklist `## Plano de execução` (v4.0.6) — escrita externa sem ninguém olhando | `BRIEF.md` |
| 3 | "reads the issue and `CONTEXT.md`/`docs/adr/`" e "registers it as current" descrevem o `/start-issue` de antes da v4.0.6 | `BRIEF.md` passo 1 |
| 4 | "the first time you use this mode in a repo" — o agente não tem como saber se é a primeira vez | `SKILL.md`, modo paralelo |
| 5 | O brief exige suíte verde; a v4.0.6 admitiu issues sem comportamento executável | `BRIEF.md` passo 3 |
| 6 | A confirmação mostra a branch do lote, calculada só no passo seguinte | `SKILL.md` passo 2 |

## Perguntas

**P:** O subagente unattended passa a postar o checklist `## Plano de execução` na
issue. Num comando que proíbe push e PR, comentar não é escrita externa também?
**R:** Permitir. A proibição existe contra o que é difícil de desfazer e pede
julgamento humano — push e PR. Um comentário de plano na issue que o agente está
implementando é o rastro que falta quando a fila roda à noite e o relatório só diz
"done". A skill passa a dizer isso, para a distinção não parecer descuido.

**P:** O `/afk-queue` é o único comando em inglês. Traduzir?
**R:** Não — deixa em inglês. A direção é a inversa: o usuário pretende passar
**todas** as skills e comandos para inglês mais adiante. Traduzir este agora seria
andar contra essa direção.

**P:** "The first time you use this mode in a repo" é instrução que o agente não
consegue verificar. Como resolver?
**R:** Vira pergunta na confirmação única que o passo 2 já faz: ao propor o modo
paralelo, o agente avisa que a isolação por worktree precisa ser validada uma vez
neste repositório e pergunta se já foi. O humano sabe a resposta.

**P:** O brief exige suíte verde, mas a v4.0.6 admitiu issues sem comportamento
executável. Como alinhar?
**R:** Espelhar as duas exceções (repo sem runner; issue que não altera
comportamento executável) e exigir que o subagente **declare no relatório** qual
caminho tomou. Contrato único entre o interativo e o unattended; a declaração é o
que impede a exceção de virar desculpa para pular teste.

---

## Consenso

| # | Decisão |
|---|---|
| 1 | O checklist na issue é permitido no modo unattended — é rastro, não publicação; a razão fica escrita |
| 2 | `SKILL.md` e `BRIEF.md` seguem em inglês: a direção do projeto é passar **tudo** para inglês depois |
| 3 | A validação da isolação por worktree vira pergunta na confirmação do passo 2 |
| 4 | O brief espelha as exceções de TDD da v4.0.6, com o caminho declarado no relatório |

**Também nesta rodada:** o `BRIEF.md` ainda descreve o `/start-issue` de antes da
v4.0.6 ("registers it as current", `CONTEXT.md`/`docs/adr/`), e a confirmação do
passo 2 anuncia uma branch que só é calculada no passo 3.
