# Grill — Hook de log das sessões de grill

**Início:** 2026-07-08 15:47

Objetivo: chegar a consenso sobre um hook que registra cada sessão de `grill-me` /
`grill-with-docs` (data/hora + todas as perguntas e respostas) em
`docs/grills_logs/<assunto>.md`, com possibilidade de desativação.

**P:** Como o corpo do log deve ser preenchido com as perguntas e respostas, dado que
um hook dispara em um instante e não existe evento de "grill terminou"?
**R:** O agente faz tudo; o hook apenas manda algumas linhas de contexto para que o
agente registre — inclusive porque o hook não conseguiria definir o assunto da
sessão sozinho.

**P:** Como o log deve poder ser desativado/ativado?
**R:** Variável de ambiente no `settings.json` (`GRILL_LOG`; `off`/`0`/`false`/`no`
desativa, qualquer outro valor mantém ativo).

**P:** Qual caminho de pasta é canônico — `docs/grill_logs/` (da tarefa) ou
`docs/grills_logs/` (do `code-conventions.md`)?
**R:** `docs/grills_logs/` (mantém consistência com o `code-conventions.md` existente).

---

**Consenso e implementação:**
- Hook `UserPromptExpansion` (matcher `grill-(me|with-docs)`) em
  [`.claude/hooks/grill-log.sh`](../../.claude/hooks/grill-log.sh): injeta um
  `additionalContext` com o timestamp de início e a diretiva de log. Não toca no
  filesystem; o agente escolhe o slug do assunto e escreve o arquivo.
- Registro e toggle em
  [`.claude/settings.json`](../../.claude/settings.json) (`env.GRILL_LOG`).
