# .claude-reutilzavel

Template reutilizável da pasta `.claude/` — convenções, skills e comandos
compartilhados entre projetos, para não reconstruir tudo do zero a cada
repositório novo.

## Modelo de reuso

**Cópia com atualização sob demanda.** Cada projeto copia esta pasta `.claude/`
uma vez e diverge livremente dali. Nada se propaga sozinho: quando quiser trazer
uma versão nova, rode `/update-claude` dentro do projeto — ele aplica o que mudou
aqui e preserva o que o projeto customizou (ver
[Como atualizar](#como-atualizar-um-projeto-que-já-copiou)).

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

## Como atualizar um projeto que já copiou

Rode o comando **`/update-claude`** dentro do projeto, sem argumentos. Ele traz o
`.claude/` para a versão vigente (a tag mais recente daqui) e preserva o que é do
projeto:

- **sobrescreve** skills, comandos, hooks, scripts e o `karpathy-principles.md`;
- **não toca** no `rules/code-conventions.md` — é ali que mora o modelo de domínio
  que o projeto escreveu;
- **acrescenta ao** `settings.json` só as chaves que faltam, mantendo os hooks
  próprios do projeto (sem isso, features novas chegam desligadas);
- pergunta **uma vez**, numa lista pré-marcada com o motivo de cada sugestão, sobre
  arquivos do projeto que sumiram da versão nova;
- grava `.claude/.template.json` com a versão aplicada, para o próximo update saber
  de onde partiu.

Se o repositório versiona o `.claude/`, ele fecha com um commit atômico só desses
caminhos — nunca faz push.

Num repositório que ainda não tem template instalado, `/update-claude` oferece o
`adopt-repo` como passo opcional antes de instalar.

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
publicado sob MIT. A rule `karpathy-principles.md` é uma tradução do `CLAUDE.md`
de [**multica-ai/andrej-karpathy-skills**](https://github.com/multica-ai/andrej-karpathy-skills).
Os comandos de workflow, as demais rules, os hooks, os scripts e a skill
`adopt-repo` foram escritos aqui.

A fronteira exata entre um e outro está em [`NOTICE.md`](./NOTICE.md).

## Licença

[MIT](./LICENSE) — copie, modifique e redistribua à vontade, mantendo o aviso de
copyright.
