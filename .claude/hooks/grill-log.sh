#!/bin/bash
# Hook: UserPromptExpansion  (matcher: grill-(me|with-docs))
#
# Quando uma sessão de grill-me ou grill-with-docs inicia, injeta no contexto do
# agente uma diretiva para registrar a sessão (data/hora de início + todas as
# perguntas e respostas) em docs/grills_logs/<assunto>.md.
#
# O hook NÃO cria arquivos nem conhece o assunto da sessão — ele apenas fornece as
# linhas de contexto e o timestamp de início. Quem escolhe o slug do assunto e
# escreve o log é o próprio agente (ele tem o contexto semântico da conversa).
#
# COBERTURA (verificado empiricamente): o evento UserPromptExpansion dispara apenas
# quando o USUÁRIO DIGITA o comando (/grill-me ou /grill-with-docs). NÃO dispara
# quando o modelo invoca a skill a partir de linguagem natural ("me grelha sobre
# X"). Para garantir o log, inicie o grill digitando o comando.
#
# Desativar: definir GRILL_LOG=off (ou 0/false/no) no bloco "env" de
# .claude/settings.json. Qualquer outro valor (ou ausência) mantém o log ativo.

# --- toggle de desativação ---
case "$(printf '%s' "${GRILL_LOG:-on}" | tr 'A-Z' 'a-z')" in
    off|0|false|no) exit 0 ;;
esac

# --- timestamp do início da sessão ---
NOW="$(date '+%Y-%m-%d %H:%M')"

# --- diretiva injetada como additionalContext ---
# O conteúdo é uma única string JSON; \n são quebras de linha literais no JSON e
# não há aspas duplas nem barras invertidas soltas, então não é preciso escapar.
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptExpansion","additionalContext":"%s"}}\n' \
"📋 Log de grill ativo (hook grill-log). Registre ESTA sessão de grill em docs/grills_logs/<assunto>.md:\n- <assunto>: slug curto em kebab-case derivado do tema da sessão (ex.: review-pr-rewrite).\n- Se o arquivo não existir, crie-o com um título e o cabeçalho de início: ${NOW}.\n- Se já existir, acrescente uma nova seção: ## Sessão — ${NOW}.\n- Após CADA pergunta respondida, anexe ao arquivo a pergunta e a resposta do usuário (formato **P:** ... / **R:** ...), de forma incremental.\n- Para desativar este log: definir GRILL_LOG=off no bloco env de .claude/settings.json."

exit 0
