# ARK — Agent Rules Kit

Template reutilizável da pasta `.claude/` — convenções, skills e comandos
compartilhados entre projetos, para não reconstruir tudo do zero a cada
repositório novo. A arca que carrega o mesmo processo de repositório em
repositório.

## Modelo de reuso

**Cópia com atualização sob demanda.** Cada projeto copia esta pasta `.claude/`
uma vez e diverge livremente dali. Nada se propaga sozinho: quando quiser trazer
uma versão nova, rode `/update-claude` dentro do projeto — ele aplica o que mudou
aqui e preserva o que o projeto customizou (ver
[Como atualizar](#como-atualizar-um-projeto-que-já-copiou)).

## O que tem aqui

- **`.claude/rules/`** — convenções de base, carregadas em toda sessão:
  - `karpathy-principles.md` — princípios de comportamento (simplicidade,
    mudanças cirúrgicas, execução orientada a metas).
  - `code-conventions.md` — convenções gerais (idioma, clean code) + a seção
    **"Restrições deste projeto"**, que cada projeto preenche do zero (idealmente
    na sessão da skill `grill-with-docs`).
  - `python-conventions.md` — docstrings e type hints, só relevante para
    projetos Python. Para outras stacks, criar `<linguagem>-conventions.md`
    equivalente.
- **`.claude/skills/`** — skills reutilizáveis, de `tdd` e `diagnose` a `grill-me`
  e `handoff` — lista completa em [`skills/README.md`](.claude/skills/README.md).
- **`.claude/commands/`** — comandos de workflow encadeados num pipeline:
  `/start-issue` → `/tdd` → `/commit` → `/open-pr` → `/review-pr`, com `/afk-queue`
  orquestrando o trecho `start-issue → commit` para uma fila inteira de issues.
  Fora do pipeline, `/update-claude`. Detalhes em
  [`commands/README.md`](.claude/commands/README.md).
- **`.claude/hooks/`** — o que roda sozinho em eventos da sessão (lembrete de commit
  ao encerrar, log das sessões de grill) — ver
  [`hooks/README.md`](.claude/hooks/README.md).
- **`.claude/scripts/`** — utilitários chamados pelos comandos ou na mão (sync do
  board, symlinks das skills) — ver [`scripts/README.md`](.claude/scripts/README.md).
- **`.claude/settings.json`** — settings versionadas: registro dos hooks e os
  [toggles](#toggles). `settings.local.json.example` é o template do
  `settings.local.json` de cada máquina/projeto, que nunca é commitado.

## Pré-requisitos

- **[`gh`](https://cli.github.com/) autenticado** (`gh auth login`) — todo o pipeline
  de issues e PR depende dele: `/start-issue`, `/open-pr`, `/review-pr`, `/afk-queue`
  e as skills `triage`, `to-issues`, `to-prd`.
- **bash** — hooks e scripts são `.sh`. No Windows, o Git Bash que vem com o Git
  resolve. Atenção ao fim de linha: `.sh` gravado com CRLF não roda (`\r: command
  not found`).
- **Board do GitHub Projects (v2)** — *opcional*. Sem ele o `board-move.sh` só avisa
  no stderr e segue; nada no pipeline quebra.

## Como usar num projeto novo

1. Copie a pasta `.claude/` inteira para a raiz do projeto.
2. Copie `.claude/settings.local.json.example` para `.claude/settings.local.json`
   e ajuste paths/permissões para aquele projeto.
3. Preencha "Restrições deste projeto" em `.claude/rules/code-conventions.md`.
4. Mantenha `python-conventions.md` se o projeto for Python; senão, crie o
   módulo de linguagem equivalente e remova o que não se aplica.
5. Revise os [toggles](#toggles) — eles chegam **ligados**.

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

## Toggles

Comportamentos que chegam **ligados** ao copiar a pasta. Desligam-se com `off`
(ou `0`/`false`/`no`) no bloco `env` de `.claude/settings.json`:

| Chave | Efeito quando `off` |
|-------|---------------------|
| `BOARD_SYNC` | Issues não são movidas no board por `/start-issue` e `/open-pr`. |
| `PR_REVIEW_PARALLEL` | `/review-pr` avalia a conformidade de todas as issues inline, sem subagentes. |
| `GRILL_LOG` | Sessões de grill não são registradas em `docs/grills_logs/`. |

## Arquivos gerados

Aparecem dentro de `.claude/` conforme você usa o template — nenhum precisa ser
criado à mão:

| Arquivo | Quem cria | Versionar? |
|---------|-----------|------------|
| `settings.local.json` | você, a partir do `.example` | **não** — tem caminhos da sua máquina |
| `current-issue` | `/start-issue` | **não** — estado da sessão |
| `board.env` | `board-move.sh` (cache dos IDs do board) | **não** — específico do repositório |
| `.template.json` | já vem na cópia (tag da release); `/update-claude` reescreve | **sim** — sem ele o próximo update não sabe de onde partiu |

Os três primeiros já estão em `.claude/.gitignore`, que viaja junto na cópia.

## Versões

Cada versão é uma tag anotada com uma [Release](https://github.com/PPrauchner/ARK-Agent-Rules-Kit/releases)
descrevendo o que mudou e por quê. A numeração é um **odômetro, não semver**:

- **MAJOR** — skill ou comando novo (capacidade nova).
- **PATCH** — alteração de skill ou comando existente.
- **MINOR** — só transbordo do PATCH quando ele passaria de 9.

Não há breaking change a sinalizar: quem consome é o `/update-claude`, e ele preserva
o que o projeto customizou independentemente do número. Para saber qual versão um
projeto carrega, veja o `.claude/.template.json` dele.

### Skills disponíveis globalmente (opcional)

Preferência pessoal, não uma etapa obrigatória do reuso: rodar
`.claude/scripts/link-skills.sh` cria symlinks de `skills/*` para
`~/.claude/skills`, deixando as skills disponíveis em qualquer projeto sem
precisar copiá-las. Quem não usar essa estratégia simplesmente não roda o
script — as skills continuam funcionando normalmente a partir da cópia local
em `.claude/skills/`.

## Manutenção deste repositório

O template usa as próprias skills em si mesmo, e a documentação da raiz **não** é
copiada para os projetos:

- [`CONTEXT.md`](./CONTEXT.md) — glossário do domínio deste repositório, que é a
  própria distribuição (Template, Projeto adotado, Versão vigente, Semente, Órfão).
- [`docs/adr/`](./docs/adr/) — decisões de arquitetura e seus porquês.
- [`docs/grills_logs/`](./docs/grills_logs/) — as sessões de grill que geraram essas
  decisões, pergunta a pergunta.
- [`docs/release-policy.md`](./docs/release-policy.md) — régua de bump, unidade de
  release e o procedimento de corte.

Um hook local (`scripts/readme-drift.sh`, não versionado, registrado no
`settings.local.json`) barra o `git tag -a` enquanto houver skill, comando, script,
hook, rule, toggle ou artefato gerado sem linha no README correspondente.

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
