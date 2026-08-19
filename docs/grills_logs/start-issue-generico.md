# Grill — Generalização do comando start-issue

**Início:** 2026-08-19 10:45

Objetivo: tornar o `/start-issue` genérico e preciso para qualquer repositório,
removendo pressupostos herdados de um projeto específico (SAGA) e alinhando-o aos
contratos que os comandos irmãos já usam.

## Diagnóstico inicial

| # | Achado | Onde |
|---|---|---|
| 1 | Tracker cravado no `gh`, mas o ecossistema tem `docs/agents/issue-tracker.md` (GitHub/GitLab/markdown local/outro) e o `/afk-queue` exige esse arquivo | `SKILL.md` passo 2 |
| 2 | "etapas do pipeline ou camadas" + estimativas em horas — vocabulário de projeto específico e critério não verificável pelo agente | `complexity-guide.md` |
| 3 | Passo 1 grava `current-issue` e move o board antes de ler a issue | `SKILL.md` passo 1 |
| 4 | Lê só `CONTEXT.md` + `docs/adr/` na raiz; ignora `CONTEXT-MAP.md` (multi-contexto) | passo 3 |
| 5 | Não lê comentários da issue — perde o "Agent Brief" do `/triage` | passo 2 |
| 6 | Impõe TDD sem escapatória | passo 6 |

## Perguntas

**P:** O README declara `gh` como pré-requisito de todo o pipeline, mas o
`setup-matt-pocock-skills` oferece GitLab e markdown local e o `/afk-queue` exige
`docs/agents/issue-tracker.md`. Qual contrato vale para o `/start-issue`?
**R:** Ler o tracker de `docs/agents/issue-tracker.md` e usar o comando que estiver
lá. O board (Projects v2) e o `/open-pr` seguem GitHub-only — a genericidade é
parcial e assumida.

**P:** O que o `/start-issue` faz quando `docs/agents/issue-tracker.md` não existe?
**R:** Fallback para GitHub via `gh`, com um aviso de uma linha ("assumindo GitHub;
rode /setup-matt-pocock-skills se não for"). Não bloqueia trabalho por falta de
configuração opcional — ao contrário do `/afk-queue`, que se recusa.

**P:** Qual o destino das sub-tarefas quando a issue é julgada complexa? Hoje elas
são apresentadas no chat e morrem ali.
**R:** Viram checklist na própria issue, marcado conforme o trabalho avança.
Sobrevive à perda de contexto e dá rastro para o revisor.

**P:** Onde mora o checklist e quem marca os itens?
**R:** Um comentário próprio do agente, com título fixo ("## Plano de execução"),
reescrito a cada sub-tarefa concluída. Nunca toca o corpo escrito pelo humano;
re-rodar `/start-issue` na mesma issue atualiza o mesmo comentário em vez de
duplicar.

**P:** Como reescrever a régua de complexidade, hoje baseada em estimativa de horas
e no vocabulário de um projeto específico ("etapas do pipeline")?
**R:** Régua calibrável: critérios genéricos como default, mais uma seção "Ajustes
deste projeto" preenchida na sessão de grill — mesmo padrão de
`rules/code-conventions.md`.

**P:** O que sobra como default genérico da régua, já que a seção do projeto nasce
vazia em todo repo novo?
**R:** Só sinais observáveis, sem horas: quantos módulos/diretórios distintos o
trabalho toca, se cria interface pública nova, se exige teste dedicado novo, se há
dependência de ordem entre partes. A seção do projeto só aperta ou afrouxa
limiares.

**P:** O passo 6 impõe TDD sem escapatória. Como se comportar em repo sem runner de
teste ou em issue de documentação/config?
**R:** TDD segue como default, mas a skill nomeia as exceções (sem runner no repo;
issue que não altera comportamento executável) e exige que o agente declare qual
caminho escolheu e por quê, no mesmo resumo do passo 4. Evita tanto o TDD-teatro
quanto a fuga silenciosa.

**P:** O passo 1 grava `current-issue` e move o board antes de ler a issue e antes
da confirmação, enquanto a branch só é criada depois. O mesmo argumento ("uma
recusa não pode deixar rastro") vale para o board?
**R:** Sim. Ler a issue vira o primeiro passo; `current-issue`, board e branch
passam a acontecer juntos, só após a confirmação. Um número errado ou um plano
recusado não deixa rastro nenhum.

**P:** O passo 2 lê só o corpo da issue e ignora o "Agent Brief" que o `/triage`
posta — que o `/afk-queue` faz questão de buscar. O que o `/start-issue` deve ler?
**R:** Corpo + comentários, com o Agent Brief tratado como a especificação mais
recente, acima do corpo original. Alinha o caminho interativo ao automático.

**P:** Como o passo 3 acha a documentação de domínio, hoje cravada em `CONTEXT.md`
+ `docs/adr/` na raiz?
**R:** Via `docs/agents/domain.md`; sem ele, tenta `CONTEXT-MAP.md` e depois a raiz;
sem nada disso, segue em silêncio. Mesmo padrão de fallback-com-aviso decidido para
o tracker, e funciona em monorepo.

---

## Consenso

| # | Decisão |
|---|---|
| 1 | Tracker lido de `docs/agents/issue-tracker.md`; board e `/open-pr` seguem GitHub-only |
| 2 | Sem esse arquivo: fallback para `gh` com aviso de uma linha — não bloqueia |
| 3 | Sub-tarefas viram checklist na issue, não plano efêmero de chat |
| 4 | O checklist é um comentário próprio do agente ("## Plano de execução"), reescrito a cada item; nunca toca o corpo do humano; re-rodar atualiza em vez de duplicar |
| 5 | Régua de complexidade calibrável: defaults genéricos + seção "Ajustes deste projeto" |
| 6 | Defaults sem estimativa de horas — só sinais observáveis no repositório |
| 7 | TDD é default com exceções nomeadas e escolha declarada no resumo do passo 4 |
| 8 | `current-issue`, board e branch só depois da confirmação; ler a issue vira o passo 1 |
| 9 | Lê corpo + comentários, com o "Agent Brief" do `/triage` como especificação mais recente |
| 10 | Documentação achada via `docs/agents/domain.md`, com fallback para `CONTEXT-MAP.md` e depois a raiz |

**Fora de escopo desta rodada:** generalizar `/commit` e `/open-pr` para trackers
não-GitHub; o board (Projects v2) continua um recurso GitHub que degrada em aviso.
