# Grill — Precisão do comando update-claude

**Início:** 2026-08-20

Objetivo: aplicar ao `/update-claude` o mesmo tratamento que os cinco comandos do
pipeline receberam nas releases `v4.0.6`–`v4.0.9` — remover pressupostos, corrigir
justificativas envelhecidas e alinhar o comando aos contratos que o template passou
a ter desde que ele foi escrito (`docs/agents/`, `ensure-branch.sh`, seções
`<preencher>`).

Sessão conduzida por um agente sem interlocutor humano: o que os precedentes das
quatro releases já decidem foi aplicado direto; o que exige julgamento genuíno está
em [Perguntas em aberto](#perguntas-em-aberto), sem virar suposição silenciosa.

O grill original deste comando é [`update-claude.md`](./update-claude.md) — as
perguntas resolvidas lá não foram reabertas.

## Diagnóstico inicial

| # | Achado | Onde |
|---|---|---|
| 1 | O *porquê* do merge de `settings.json` está errado: diz que sem ele `BOARD_SYNC` e `PR_REVIEW_PARALLEL` "chegariam desligados", mas todos os toggles são lidos como `${CHAVE:-on}` — chave ausente já significa ligada. O que de fato chegaria morto é o **hook** | `Propriedade dos arquivos` |
| 2 | A linha **Local** lista `root-issue` e `worktrees/`, que nunca existiram em commit nenhum do template (`git log -S` confirma: nasceram no próprio commit do `/update-claude`) | tabela de propriedade |
| 3 | `.claude/.template.json` não está na tabela: cai em "qualquer outro caminho" → passo 5, contradizendo o passo 6, que o reescreve | tabela de propriedade |
| 4 | Passo 7 descobre a branch default com `gh repo view` — dependência de forge e de rede num comando que só precisa de git, e que ignora o tronco quando `origin/HEAD` não está definido | passo 7 |
| 5 | Passo 2 embute a régua de bump (odômetro/MAJOR/PATCH), que a `docs/release-policy.md` declara ser meta deste repositório e **não** viajar no `.claude/`; e o `ls-remote` sem `--sort` erra a ordem assim que houver dois dígitos | passo 2 |
| 6 | Exemplos envelhecidos: marcador cravado em `v4.0.0`; mensagem de commit atribui ao template a remoção de `commands/workflow/`, que o grill original provou nunca ter existido aqui | passos 6 e 7 |
| 7 | `docs/agents/*` não é mencionado em lugar nenhum, embora a atualização instale comandos que dependem dele — o `/afk-queue` **se recusa a rodar** sem `issue-tracker.md` | passo 8 |
| 8 | `complexity-guide.md` e `atomicity-rules.md` ganharam seções `<preencher>` nas `v4.0.6`/`v4.0.7`, mas vivem sob `commands/` — "Do template", **sobrescreve**: o update apaga calibragem de projeto | tabela de propriedade |
| 9 | O cabeçalho promete que "a origem vem do marcador"; o passo 2 sempre usa a URL cravada no arquivo e nunca lê o campo `repo` | cabeçalho e passo 2 |
| 10 | Com marcador, a base é aceita sem conferir que a tag existe no remoto — base falsa com cara de fato, o que o ADR-0001 recusa por heurística | passo 3 |

### Veredito das quatro pistas do handoff

| Pista | Veredito |
|---|---|
| Passo 3 lida com marcador ausente de forma coerente com o ADR-0001? | **Descartada.** Trata corretamente ("a base é desconhecida; não infira"). O buraco vizinho é outro: marcador *presente* apontando para tag inexistente (achado 10). |
| A lista de Sementes está desatualizada — `complexity-guide.md` e `atomicity-rules.md` viraram Sementes parciais? | **Confirmada** (achado 8). Não decidida aqui: ver Perguntas em aberto. |
| Postura do passo 7 sobre branch bate com `ensure-branch.sh` e `/open-pr`? | **Parcialmente confirmada.** A regra ("não crie branch por conta própria") está certa e a justificativa também — `ensure-branch.sh` exige número de issue e falha alto. Errado era só o *como* descobrir o tronco (achado 4). |
| `docs/agents/*` não é mencionado? | **Confirmada** (achado 7). Fica fora do alcance do update — é raiz, não `.claude/` — mas precisa aparecer no relatório. |

## Decisões tomadas

**P:** Por que juntar `settings.json`, já que os toggles ausentes valem `on`?
**R:** Pelos **hooks**. Toggle tem default no script (`${CHAVE:-on}`); hook não tem
default nenhum — se não estiver no bloco `hooks`, simplesmente nunca roda. A regra
continua a mesma; o motivo publicado estava invertido. *Precedente: "justificativa
envelhecida é achado" (`v4.0.8`) — sem corrigir o porquê, a próxima sessão conserta
na direção errada.*

**P:** O que é, de fato, artefato Local?
**R:** Os três de `.claude/.gitignore` — `settings.local.json`, `current-issue`,
`board.env`. É a mesma lista da tabela de artefatos do README, e ela viaja na cópia.
`root-issue` e `worktrees/` saem: o template nunca os produziu (o `/afk-queue`
paraleliza com worktrees do git, criadas fora do `.claude/`).

**P:** Quem manda no `.template.json`?
**R:** Papel próprio na tabela — **Marcador**, reescrito no passo 6. Sem a linha, o
arquivo caía em "Do projeto" e o passo 5 podia oferecer removê-lo, que é o oposto do
que a `v4.0.4` decidiu ao fazê-lo viajar na cópia.

**P:** Como o passo 7 descobre o tronco?
**R:** Com a mesma definição do `ensure-branch.sh` — `main`, `master`, `dev`,
`develop`, `development`, ou o que `origin/HEAD` apontar — e sem `gh`. Atualizar o
template não é operação de forge: um projeto que rastreia issues fora do GitHub
atualiza igual. *Precedente: "forge é GitHub, e isso se declara" (`v4.0.7`/`v4.0.8`)
— aqui o corolário, um comando que não precisa de forge não deve exigir uma.*

**P:** A régua de bump fica no comando?
**R:** **Não.** A `docs/release-policy.md` abre dizendo que vale só para este
repositório e que nada disso vive em `.claude/`. O comando precisa de uma coisa só:
ordenar as tags. Fica `--sort=-v:refname`, com o motivo registrado (em ordem
lexicográfica `v4.0.10` vem antes de `v4.0.9`, e a numeração daqui passa de 9 e
continua contando).

**P:** Marcador presente basta para fixar a base?
**R:** Só se a tag estiver na lista do passo 2. Não estando (marcador de outra
linhagem, tag apagada), a base volta a ser desconhecida. Medir diferença contra uma
base inexistente produz exatamente o "você removeu isto" falso que o
[ADR-0001](../adr/0001-nao-inferir-a-versao-de-origem.md) recusa — a diferença é que
aqui a invenção chega por um arquivo, não por heurística. *Precedente: "critério que
o agente não consegue verificar é bug" (`v4.0.6`).*

**P:** O que o comando faz com `docs/agents/`?
**R:** Nada — é raiz, fora do `.claude/`, e escrever lá seria adotar, não atualizar.
Mas **relata**: se `docs/agents/issue-tracker.md` não existir, o relatório diz que o
`/afk-queue` recém-instalado vai se recusar a rodar e que `/start-issue`, `/commit` e
`/review-pr` cairão no fallback GitHub, e sugere a `setup-matt-pocock-skills`. É a
mesma postura do passo 1 com o `adopt-repo`: detecta, explica, oferece — não é muro.

**P:** Os exemplos ficam?
**R:** Ficam, corrigidos. O marcador vira `<a tag do passo 2>` em vez de uma tag que
envelhece a cada release. Na mensagem de commit, `commands/workflow/` deixa de ser
"layout antigo" removido pelo template — ele nunca existiu aqui — e passa a ser
Órfão da Linhagem pré-tag confirmado no passo 5, que é o que ele de fato é; e a linha
sobre "ligar BOARD_SYNC" vira o registro do hook, coerente com a decisão 1.

---

## Consenso

| # | Decisão |
|---|---|
| 1 | O merge de `settings.json` se justifica pelos hooks; toggles ausentes já valem `on` |
| 2 | Artefatos Locais = os três de `.claude/.gitignore`; `root-issue` e `worktrees/` eram ficção |
| 3 | `.template.json` ganha papel próprio (Marcador), reescrito no passo 6 |
| 4 | Tronco descoberto como no `ensure-branch.sh`, sem `gh` e sem rede |
| 5 | A régua de bump sai do comando; fica só `--sort=-v:refname` para ordenar |
| 6 | Marcador cuja tag não existe no remoto ⇒ base desconhecida (ADR-0001) |
| 7 | `docs/agents/` fica fora do alcance da escrita, mas entra no relatório do passo 8 |
| 8 | Exemplos corrigidos: marcador sem tag cravada, órfão atribuído à linhagem certa |

**Fora de escopo desta rodada:** as duas perguntas abaixo, que mudam comportamento e
exigem decisão do usuário.

---

## Perguntas em aberto

### 1. O update sobrescreve as seções `<preencher>` de `complexity-guide.md` e `atomicity-rules.md`

As `v4.0.6` e `v4.0.7` deram a esses dois arquivos uma seção calibrável por projeto
("Ajustes deste projeto", "Camadas deste projeto"), preenchida em sessão de grill —
o mesmo padrão do `rules/code-conventions.md`, que é Semente justamente por isso.
Só que eles vivem sob `commands/`, marcado **sobrescreve**. Hoje, um
`/update-claude` apaga a calibragem sem avisar. O glossário do `CONTEXT.md` não tem
termo para "arquivo do template com uma região do projeto dentro": Semente é
substituição inteira, Extensão é acréscimo em volta.

- **(a) Terceiro papel — "Extensão em região delimitada".** O update reescreve o
  arquivo do template e reinjeta o conteúdo que estava sob o cabeçalho da seção
  calibrável. *Trade-off:* preserva o trabalho de grill **e** entrega o texto novo do
  template, mas é a única regra do comando que depende de estrutura interna do
  arquivo (um cabeçalho mudar de nome quebra em silêncio) e obriga a criar um termo
  no glossário.
- **(b) Sementes parciais anunciadas.** Continua sobrescrevendo, mas quando a seção
  do projeto não está vazia o arquivo entra na lista do passo 5 com sugestão
  *manter*, e o relatório diz o que ficou por reaplicar. *Trade-off:* não inventa
  vocabulário nem parsing e mantém a regra "conteúdo do projeto se decide na lista
  única", mas quem escolher *manter* fica sem as melhorias do template naquele
  arquivo — e alguém tem que reaplicar à mão.
- **(c) Mover a calibragem para fora de `commands/`.** As seções `<preencher>` saem
  para um arquivo do projeto (por exemplo `rules/project-calibration.md`), e os dois
  guias passam a apontar para lá. *Trade-off:* o problema deixa de existir — tudo sob
  `commands/` volta a ser 100% do template —, mas exige alterar `/start-issue` e
  `/commit` na mesma release e quebra os projetos que já preencheram no lugar antigo.

### 2. O campo `repo` do marcador é usado, ou a URL do comando manda sempre?

O cabeçalho promete "a origem vem do marcador `.claude/.template.json` e, na falta
dele, da URL fixada neste arquivo"; o passo 2 nunca lê o campo `repo`. A `v4.0.3`
(renomeação para ARK) argumentou que os marcadores já gravados "continuam
resolvendo" pelo redirect do GitHub — o que só faz sentido se o `repo` for usado.
Cabeçalho e passo dizem coisas diferentes, e qualquer das duas leituras é
defensável.

- **(a) A URL do comando manda; corrigir o cabeçalho.** O `repo` do marcador vira
  registro histórico. *Trade-off:* uma linha de correção e comportamento previsível —
  o `/update-claude` do ARK atualiza a partir do ARK, ponto —, mas um fork ou espelho
  privado do template deixa de ser atualizável sem editar o comando.
- **(b) O marcador manda; corrigir o passo 2.** Busca em `repo` quando ele existe,
  cai na URL fixa quando não. *Trade-off:* fork e espelho passam a funcionar e o
  cabeçalho vira verdade, mas o comando passa a clonar uma URL vinda de um arquivo do
  repositório — e o passo 1 ("estamos dentro do próprio ARK?") precisa comparar
  contra a origem certa, não contra a fixa.
- **(c) Marcador manda, com confirmação.** Usa o `repo` do marcador, mas quando ele
  difere da URL fixa mostra as duas e pergunta antes de clonar. *Trade-off:* cobre o
  fork sem clonar às cegas, ao custo de uma segunda interrupção num comando que hoje
  se orgulha de pedir **uma** confirmação só (passo 5).
