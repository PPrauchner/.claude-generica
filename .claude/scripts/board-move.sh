#!/usr/bin/env bash
# Move uma issue de coluna no board do GitHub Projects (v2).
#
# Uso:
#   bash .claude/scripts/board-move.sh <numero-da-issue> <in-progress|in-review>
#
# CONTRATO: este script NUNCA falha. Qualquer problema (sem project linkado, sem
# permissao, coluna inexistente) vira aviso no stderr e `exit 0`. Implementar uma
# issue jamais pode depender do board — no /afk-queue, um erro aqui abortaria a
# fila inteira.
#
# Desativar: BOARD_SYNC=off no bloco "env" de .claude/settings.json.
#
# Cache dos IDs resolvidos: .claude/board.env (gitignored, um por repositorio).
# A descoberta e automatica; o cache so precisa ser editado a mao quando o
# script avisar que nao conseguiu resolver sozinho. Chaves reconhecidas:
#   BOARD_PROJECT_ID          id do project (PVT_...)
#   BOARD_STATUS_FIELD_ID     id do campo Status (PVTSSF_...)
#   BOARD_OPTION_IN_PROGRESS  id da opcao de "em progresso"
#   BOARD_OPTION_IN_REVIEW    id da opcao de "em revisao"
#   BOARD_STATUS_IN_PROGRESS  nome da coluna, se nao for "In progress"
#   BOARD_STATUS_IN_REVIEW    nome da coluna, se nao for "In review"

warn() { printf 'board: %s\n' "$1" >&2; }

# --- toggle de desativacao ---
case "$(printf '%s' "${BOARD_SYNC:-on}" | tr 'A-Z' 'a-z')" in
    off|0|false|no) exit 0 ;;
esac

ISSUE="$1"
TARGET="$2"

if [ -z "$ISSUE" ] || [ -z "$TARGET" ]; then
    warn "uso: board-move.sh <numero-da-issue> <in-progress|in-review>"
    exit 0
fi

CLAUDE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="$CLAUDE_DIR/board.env"
# shellcheck source=/dev/null
[ -f "$CACHE" ] && . "$CACHE"

case "$TARGET" in
    in-progress)
        WANT_NAME="${BOARD_STATUS_IN_PROGRESS:-In progress}"
        OPTION_ID="${BOARD_OPTION_IN_PROGRESS:-}"
        ;;
    in-review)
        WANT_NAME="${BOARD_STATUS_IN_REVIEW:-In review}"
        OPTION_ID="${BOARD_OPTION_IN_REVIEW:-}"
        ;;
    *)
        warn "alvo desconhecido '$TARGET' (use in-progress ou in-review)"
        exit 0
        ;;
esac

PROJECT_ID="${BOARD_PROJECT_ID:-}"
FIELD_ID="${BOARD_STATUS_FIELD_ID:-}"

# --- 1. descobrir o project linkado ao repositorio ---
if [ -z "$PROJECT_ID" ]; then
    REPO="$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null)"
    if [ -z "$REPO" ]; then
        warn "gh nao conseguiu identificar o repositorio — pulando"
        exit 0
    fi
    OWNER="${REPO%%/*}"
    NAME="${REPO##*/}"

    PROJECTS="$(gh api graphql \
        -f query='query($o:String!,$n:String!){repository(owner:$o,name:$n){projectsV2(first:10){nodes{id title}}}}' \
        -f o="$OWNER" -f n="$NAME" \
        --jq '.data.repository.projectsV2.nodes[] | .id + "  " + .title' 2>/dev/null)"

    COUNT="$(printf '%s' "$PROJECTS" | grep -c . )"
    if [ "$COUNT" -eq 0 ]; then
        warn "nenhum project linkado a $REPO — pulando"
        exit 0
    fi
    if [ "$COUNT" -gt 1 ]; then
        warn "$REPO tem $COUNT projects linkados; escolha um e grave em $CACHE:"
        printf '%s\n' "$PROJECTS" | sed 's/^/  BOARD_PROJECT_ID=/' >&2
        exit 0
    fi
    PROJECT_ID="$(printf '%s' "$PROJECTS" | awk '{print $1}')"
fi

# --- 2. resolver o campo Status e a opcao alvo ---
if [ -z "$FIELD_ID" ] || [ -z "$OPTION_ID" ]; then
    FIELD_QUERY='query($p:ID!){node(id:$p){... on ProjectV2{field(name:"Status"){... on ProjectV2SingleSelectField{id options{id name}}}}}}'

    if [ -z "$FIELD_ID" ]; then
        FIELD_ID="$(gh api graphql -f query="$FIELD_QUERY" -f p="$PROJECT_ID" \
            --jq '.data.node.field.id // empty' 2>/dev/null)"
    fi
    if [ -z "$FIELD_ID" ]; then
        warn "o project nao tem um campo 'Status' de selecao unica — pulando"
        exit 0
    fi

    OPTIONS="$(gh api graphql -f query="$FIELD_QUERY" -f p="$PROJECT_ID" \
        --jq '.data.node.field.options[] | .id + "\t" + .name' 2>/dev/null)"

    # Match case-insensitive: boards reais usam "In progress", nao "In Progress".
    OPTION_ID="$(printf '%s\n' "$OPTIONS" | awk -F'\t' -v want="$WANT_NAME" \
        'tolower($2) == tolower(want) { print $1; exit }')"

    if [ -z "$OPTION_ID" ]; then
        warn "nenhuma coluna chamada '$WANT_NAME' no board. Colunas disponiveis:"
        printf '%s\n' "$OPTIONS" | awk -F'\t' '{print "  " $2}' >&2
        warn "grave o nome correto em $CACHE (BOARD_STATUS_IN_PROGRESS / BOARD_STATUS_IN_REVIEW)"
        exit 0
    fi
fi

# --- 3. mover ---
CONTENT_ID="$(gh issue view "$ISSUE" --json id --jq '.id' 2>/dev/null)"
if [ -z "$CONTENT_ID" ]; then
    warn "issue #$ISSUE nao encontrada — pulando"
    exit 0
fi

# Idempotente: se a issue ja esta no project, devolve o item existente.
ITEM_ID="$(gh api graphql \
    -f query='mutation($p:ID!,$c:ID!){addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}}' \
    -f p="$PROJECT_ID" -f c="$CONTENT_ID" \
    --jq '.data.addProjectV2ItemById.item.id // empty' 2>/dev/null)"
if [ -z "$ITEM_ID" ]; then
    warn "nao consegui adicionar a issue #$ISSUE ao project (permissao?) — pulando"
    exit 0
fi

if ! gh api graphql \
    -f query='mutation($p:ID!,$i:ID!,$f:ID!,$o:String!){updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:{singleSelectOptionId:$o}}){projectV2Item{id}}}' \
    -f p="$PROJECT_ID" -f i="$ITEM_ID" -f f="$FIELD_ID" -f o="$OPTION_ID" >/dev/null 2>&1; then
    warn "falha ao mover a issue #$ISSUE para '$WANT_NAME' — pulando"
    exit 0
fi

# --- 4. gravar o cache com o que foi resolvido ---
case "$TARGET" in
    in-progress) BOARD_OPTION_IN_PROGRESS="$OPTION_ID" ;;
    in-review)   BOARD_OPTION_IN_REVIEW="$OPTION_ID" ;;
esac
{
    printf '# Gerado por board-move.sh — cache dos IDs do board deste repositorio.\n'
    printf 'BOARD_PROJECT_ID=%s\n' "$PROJECT_ID"
    printf 'BOARD_STATUS_FIELD_ID=%s\n' "$FIELD_ID"
    [ -n "${BOARD_OPTION_IN_PROGRESS:-}" ] && printf 'BOARD_OPTION_IN_PROGRESS=%s\n' "$BOARD_OPTION_IN_PROGRESS"
    [ -n "${BOARD_OPTION_IN_REVIEW:-}" ] && printf 'BOARD_OPTION_IN_REVIEW=%s\n' "$BOARD_OPTION_IN_REVIEW"
    [ -n "${BOARD_STATUS_IN_PROGRESS:-}" ] && printf 'BOARD_STATUS_IN_PROGRESS=%s\n' "$BOARD_STATUS_IN_PROGRESS"
    [ -n "${BOARD_STATUS_IN_REVIEW:-}" ] && printf 'BOARD_STATUS_IN_REVIEW=%s\n' "$BOARD_STATUS_IN_REVIEW"
} > "$CACHE"

printf 'board: issue #%s -> %s\n' "$ISSUE" "$WANT_NAME"
exit 0
