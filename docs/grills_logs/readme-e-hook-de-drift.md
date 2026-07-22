# Grill — README completo e hook de drift de documentação

**Início:** 2026-07-22 14:10

Objetivo: fechar o que falta no `README.md` (ele lista 3 dos 6 comandos, 1 dos 2
hooks, 2 dos 3 scripts e nenhum dos toggles) e decidir um hook que force a
atualização da documentação a cada versão nova.

**P:** O README raiz deve continuar enumerando comandos/skills/hooks um a um, ou
delegar o inventário para os READMEs de dentro do `.claude/`?
**R:** Delegar. O README descreve as categorias e linka; nomeia comandos só na forma
da cadeia do pipeline, sem descrição por comando. Os quatro buracos do README tinham
a mesma causa — ele repetia um inventário que `commands/README.md` e
`skills/README.md` já mantinham certo.

**P:** O que entra no README sobre versionamento — e a política de release continua
só no `CLAUDE.local.md` não-versionado?
**R:** O README ensina a *ler* uma versão (o que MAJOR/PATCH significam, onde ver o
que mudou, como saber a versão que se carrega). A régua completa e o procedimento de
corte viram `docs/release-policy.md` versionado, e o `CLAUDE.local.md` vira um
ponteiro. O motivo original de manter a política fora do git — "todo projeto que
copiasse a pasta herdaria uma regra sobre versionar o template" — vale para
`.claude/`, não para a raiz: só o `.claude/` é copiado. Como estava, a regra que
decide toda release existia em uma única máquina.

**P:** Quais seções ausentes entram no README raiz?
**R:** Todas as quatro: pré-requisitos (`gh` autenticado, bash/Git Bash, aviso de
CRLF), tabela de toggles (chegam ligados ao copiar a pasta), arquivos gerados e
gitignored (`board.env`, `current-issue`, `.template.json`, `settings.local.json`) e
uma nota sobre como o próprio repositório se documenta (`CONTEXT.md`, `docs/adr/`,
`docs/grills_logs/`).

**P:** O que o hook deve verificar?
**R:** Drift verificável de conteúdo — comparar o README com fatos do repositório e
falar só quando existe algo concreto não documentado. A alternativa temporal ("tag
nova sem README tocado") foi descartada: com o inventário delegado, a maioria das
releases legitimamente não toca o README raiz, e o aviso viraria lobo.

**P:** Em que evento o hook dispara — e ele chega a bloquear?
**R:** `PreToolUse` sobre o Bash, filtrando `git tag -a`, bloqueando. É o único
desenho que de fato força, e como a checagem não tem falso positivo, bloquear é
seguro. Furo aceito: tag cortada em terminal fora do Claude Code não dispara nada.

**P:** O hook é para todos os projetos?
**R:** Não. É ferramenta *deste* repositório: fica na máquina, não vai no git, não
chega em projeto nenhum. Os projetos adotados não usam releases desse jeito — lá a
ativação seria outra (via PR ou outra forma), e isso fica para depois.

**P:** Onde fica o script, então?
**R:** `scripts/readme-drift.sh` na raiz (fora do `.claude/`, logo não é copiado),
com uma linha no `.gitignore` da raiz para nunca ser commitado por acidente — mesmo
tratamento que o `CLAUDE.local.md` já recebe. O registro do hook vai no
`.claude/settings.local.json`, que já é ignorado.

**P:** `hooks/` e `scripts/` não têm README próprio. Como o inventário deles é
mantido?
**R:** Criando `hooks/README.md` e `scripts/README.md`, simétrico com `commands/` e
`skills/`. A recomendação inicial era o contrário — README raiz nomeando os cinco
arquivos — e caiu por um fato: **o README raiz é o único arquivo que não viaja**. Um
projeto adotado recebe cinco executáveis, dois deles rodando automaticamente e um
mexendo no GitHub Projects, documentados só na página que ficou para trás. Os dois
argumentos a favor de manter na raiz cederam: o custo real não é o arquivo extra, é a
sincronia (a opção recriava em `hooks/`/`scripts/` o drift que a delegação acabara de
eliminar, para depois policiá-lo com um hook); e a divulgação do "chega ligado" já
está coberta pela tabela de toggles no README raiz.

**P:** Com o inventário todo delegado, o `readme-drift.sh` fiscaliza só o README raiz
ou também os quatro sub-READMEs?
**R:** Raiz + os quatro sub-READMEs. Cada arquivo responde pelo que é dele. Sem isso
o hook só vigiaria toggles e diretórios, que mudam uma vez por ano, e o caso comum de
release — skill ou comando novo — passaria direto.

---

**Consenso e implementação:**

- `README.md` reescrito: delega o inventário, ganha pré-requisitos, toggles,
  arquivos gerados, leitura de versões e nota de meta-documentação. H1 corrigido para
  `.claude-generica` (batia com nada: o nome do repositório é esse, e "reutilzavel"
  ainda estava escrito errado).
- [`docs/release-policy.md`](../release-policy.md) — régua de bump, unidade de
  release, procedimento e histórico, versionados. `CLAUDE.local.md` encolhe para um
  ponteiro.
- [`.claude/hooks/README.md`](../../.claude/hooks/README.md) e
  [`.claude/scripts/README.md`](../../.claude/scripts/README.md) — inventário que
  viaja junto com a pasta.
- `scripts/readme-drift.sh` (**não versionado**, ignorado pelo `.gitignore` da raiz)
  — hook `PreToolUse` registrado em `.claude/settings.local.json`. Barra `git tag -a`
  enquanto houver skill, comando, script, hook, toggle, diretório de `.claude/` ou
  artefato gerado sem linha no README correspondente. Desliga com `README_DRIFT=off`.
