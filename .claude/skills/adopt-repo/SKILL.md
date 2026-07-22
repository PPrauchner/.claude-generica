---
name: adopt-repo
description: Preenche os artefatos que o template .claude/ espera (CLAUDE.md, CONTEXT.md, restrições, convenções de linguagem, docs/agents, settings.local.json) quando a pasta é colada num repositório que já estava em andamento. Deriva do código o que o código sabe responder e grelha o resto. Use when adopting an existing repository into this template, or when CLAUDE.md/CONTEXT.md are missing or empty.
---

# Adopt Repo

A pasta `.claude/` foi copiada para um repositório que já tem código, histórico e
decisões tomadas — mas os arquivos que as skills leem estão vazios ou não existem.
Esta skill fecha essa lacuna.

**Princípio central:** o repositório responde sozinho a stack, comandos e estrutura —
derive isso e apenas confirme. O grill é gasto onde o código é mudo: o código mostra
`class Chapter`, mas não diz se você chama aquilo de "capítulo" ou "episódio", nem por
que aquela decisão foi tomada.

## Regras invioláveis

1. **Nunca sobrescreva.** O que já existe é verdade; acrescente apenas o que falta.
   Rodar duas vezes não pode duplicar seção nem reescrever texto do usuário.
2. **Contradição vai para o grill, não para o seu palpite.** Se o `CLAUDE.md` diz
   `pnpm` e o repo tem `package-lock.json`, pergunte qual vale — não escolha.
3. **Nada de escrever antes de confirmar.** Cada artefato é apresentado antes de ir
   para o disco.

## Os seis artefatos

| # | Artefato | Origem |
|---|----------|--------|
| 1 | `CLAUDE.md` | derivado do recon + 1 rodada de conferência |
| 2 | `CONTEXT.md` | grill (glossário de domínio) |
| 3 | "Restrições deste projeto" em `.claude/rules/code-conventions.md` | grill |
| 4 | `.claude/rules/<linguagem>-conventions.md` | derivado + confirmação |
| 5 | `docs/agents/*` | delegado à skill `setup-matt-pocock-skills` |
| 6 | `.claude/settings.local.json` | derivado de `settings.local.json.example` |

## Workflow

### 1. Recon

Levante o estado atual antes de perguntar qualquer coisa. Use o
[checklist de recon](./RECON.md) — ele diz o que ler por tipo de stack e o que cada
sinal significa.

Ao final você deve saber: linguagem(ns) e versão, gerenciador de pacotes, comandos de
dev/build/test/lint, estrutura de pastas, e **o que já existe** dos seis artefatos.

### 2. Apresentar o mapa da adoção

Mostre em uma tabela o que encontrou e o que falta — o usuário precisa ver o tamanho
do trabalho antes de entrar num grill. Confirme a stack detectada; se você errar aqui,
tudo depois herda o erro.

### 3. `CLAUDE.md` — derivar e conferir

Monte o rascunho a partir do recon: o que o projeto é, stack, comandos, estrutura de
pastas e apontadores para `CONTEXT.md` e `docs/adr/`. **Uma rodada** de conferência —
não vire isso em entrevista, o repo já respondeu.

Se `CLAUDE.md` já existir: leia, trate como verdade, e proponha **apenas** as seções
ausentes. Liste as contradições encontradas em vez de resolvê-las sozinho.

### 4. `CONTEXT.md` e restrições — grelhar

Aqui sim, invoque a skill **`grill-with-docs`**. Ela já entrevista uma pergunta por
vez, desafia termos contra o glossário e escreve o `CONTEXT.md` incrementalmente no
formato certo — não reimplemente isso.

Foque o grill no que o código não entrega:

- **Glossário:** para cada conceito central que o recon encontrou, qual é o termo de
  domínio em pt-BR e qual identificador em inglês o representa. Fronteiras entre
  conceitos parecidos (`User` × `Customer`, `Chapter` × `Episode`).
- **Restrições deste projeto:** o que **não** pode mudar — dependência que é decisão e
  não acaso, formato de persistência, exigência de reprodutibilidade, limite de
  ambiente. Escreva o resultado na seção "Restrições deste projeto" de
  `.claude/rules/code-conventions.md`, substituindo o `<preencher>`.
- **ADRs retroativos:** só ofereça quando a decisão for difícil de reverter,
  surpreendente sem contexto e fruto de trade-off real — os três critérios da
  `grill-with-docs`. Não documente retroativamente o que foi acaso.

### 5. Convenções da linguagem

O template traz apenas `python-conventions.md`. Se o projeto não for Python, crie
`.claude/rules/<linguagem>-conventions.md` no mesmo espírito (docstrings/documentação,
tipagem, naming) e ajuste o link em `code-conventions.md`. Se for Python, mantenha o
arquivo existente e não o toque.

Remova apenas os arquivos de linguagem que **não se aplicam** ao projeto, e só depois
de confirmar com o usuário.

### 6. `docs/agents/` — delegar

Invoque a skill **`setup-matt-pocock-skills`**. Ela configura issue tracker, labels de
triagem e layout dos docs de domínio, e escreve o bloco `## Agent skills` no
`CLAUDE.md`. Não reescreva o que ela faz.

Este passo não é opcional: sem `docs/agents/issue-tracker.md` o `/afk-queue` se recusa
a rodar.

### 7. `settings.local.json`

Copie `.claude/settings.local.json.example` para `.claude/settings.local.json` e
substitua o caminho placeholder pelo caminho real do repositório. Se o arquivo já
existir, não toque nele.

### 8. Relatório final

Uma tabela com os seis artefatos: criado / completado / já existia / pulado (e por
quê). Termine dizendo o que ficou pendente de decisão humana — restrição que o usuário
não soube responder na hora vale mais explícita como pendência do que preenchida com
um chute.
