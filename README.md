# .claude-reutilzavel

Template reutilizável da pasta `.claude/` — convenções, skills e comandos
compartilhados entre projetos, para não reconstruir tudo do zero a cada
repositório novo.

## Modelo de reuso

**Copy-paste manual.** Cada projeto copia esta pasta `.claude/` uma vez e
diverge livremente dali — não há sincronização automática com este repositório.
Atualizações feitas aqui não se propagam sozinhas para quem já copiou.

## O que tem aqui

- **`.claude/rules/`** — convenções de base:
  - `karpathy-principles.md` — princípios de comportamento (simplicidade,
    mudanças cirúrgicas, execução orientada a metas). Carregado em toda sessão.
  - `code-conventions.md` — convenções gerais (idioma, clean code) + a seção
    **"Restrições deste projeto"**, que cada projeto preenche do zero (idealmente
    na sessão da skill `grill-with-docs`).
  - `python-conventions.md` — docstrings e type hints, só relevante para
    projetos Python. Para outras stacks, criar `<linguagem>-conventions.md`
    equivalente.
- **`.claude/skills/`** — skills reutilizáveis (grill-me, tdd, diagnose, triage,
  to-issues, to-prd, prototype, etc.) — ver [`skills/README.md`](.claude/skills/README.md).
- **`.claude/commands/`** — comandos de workflow (`/commit`, `/start-issue`,
  `/afk-queue`) que assumem as convenções deste template (issue tracker via
  `gh`, `current-issue`, commits atômicos) — ver [`commands/README.md`](.claude/commands/README.md).
- **`.claude/hooks/`** — hook de `Stop` que lembra de commitar mudanças pendentes
  ao encerrar a sessão.
- **`.claude/scripts/`** — utilitários (`link-skills.sh`, `list-skills.sh`).
- **`.claude/settings.json`** — settings versionadas (hooks).
  `settings.local.json.example` é o template para o `settings.local.json` de
  cada máquina/projeto — esse arquivo é local, nunca é commitado (ver
  `.gitignore`).

## Como usar num projeto novo

1. Copie a pasta `.claude/` inteira para a raiz do projeto.
2. Copie `.claude/settings.local.json.example` para `.claude/settings.local.json`
   e ajuste paths/permissões para aquele projeto.
3. Preencha "Restrições deste projeto" em `.claude/rules/code-conventions.md`.
4. Mantenha `python-conventions.md` se o projeto for Python; senão, crie o
   módulo de linguagem equivalente e remova o que não se aplica.

## Como usar num projeto que já existe

Rode a skill **`adopt-repo`**. Ela faz recon do repositório, deriva o `CLAUDE.md` do
que o código já responde (stack, comandos, estrutura) e usa uma sessão de
`grill-with-docs` para o que o código não sabe dizer — o glossário de domínio do
`CONTEXT.md` e as restrições do projeto. Nunca sobrescreve o que já existe: completa
apenas o que falta e leva contradições para o grill.

### Skills disponíveis globalmente (opcional)

Preferência pessoal, não uma etapa obrigatória do reuso: rodar
`.claude/scripts/link-skills.sh` cria symlinks de `skills/*` para
`~/.claude/skills`, deixando as skills disponíveis em qualquer projeto sem
precisar copiá-las. Quem não usar essa estratégia simplesmente não roda o
script — as skills continuam funcionando normalmente a partir da cópia local
em `.claude/skills/`.

## Créditos

Boa parte das skills em `.claude/skills/` vem de
[**mattpocock/skills**](https://github.com/mattpocock/skills), de Matt Pocock,
publicado sob MIT. Os comandos de workflow, as rules, os hooks, os scripts e a
skill `adopt-repo` foram escritos aqui.

A fronteira exata entre um e outro está em [`NOTICE.md`](./NOTICE.md).

## Licença

[MIT](./LICENSE) — copie, modifique e redistribua à vontade, mantendo o aviso de
copyright.
