---
name: update-claude
description: Atualiza a pasta .claude/ deste repositório para a versão vigente do template .claude-generica, preservando o que o projeto customizou. Use when updating the .claude folder to the latest template version.
---

# Update Claude

Traz o `.claude/` **deste** repositório para a versão vigente do template
`PPrauchner/.claude-generica`, sem atropelar o que o projeto customizou.

Não recebe argumentos: a origem vem do marcador `.claude/.template.json` e, na
falta dele, da URL fixada neste arquivo.

## Propriedade dos arquivos

Quem manda em cada caminho — a regra é fixa e mora aqui, não em configuração:

| Papel | Caminhos | O update faz |
|---|---|---|
| **Do template** | `skills/`, `commands/`, `hooks/`, `scripts/`, `rules/karpathy-principles.md`, `rules/python-conventions.md`, `settings.local.json.example`, `.gitignore` | sobrescreve |
| **Semente** | `rules/code-conventions.md` | só instala se faltar |
| **Extensão** | `settings.json` | acrescenta o que falta; nunca altera nem remove |
| **Local** | `settings.local.json`, `current-issue`, `root-issue`, `board.env`, `worktrees/` | não toca |
| **Do projeto** | qualquer outro caminho | passo 5 |

A **Semente** é intocável porque o projeto a *substitui*: o `code-conventions.md`
do SAGA tem o modelo de domínio dele (aspectos, Join Point/Advice/Weaving),
escrito numa sessão de grill. Sobrescrever apaga isso.

O `settings.json` é diferente porque o projeto o *estende*: ninguém apagou nada
do template, só acrescentou hooks em volta. Acrescentar chave que falta não
destrói customização — e sem isso as features novas chegam desligadas
(`BOARD_SYNC`, `PR_REVIEW_PARALLEL` e o hook do `grill-log` não existem nos
projetos antigos, então o board sync e o review paralelo seriam instalados
mortos).

## Workflow

### 1. Pré-condições

```bash
git rev-parse --show-toplevel
git remote get-url origin
cat .claude/.template.json 2>/dev/null
ls .claude/rules/karpathy-principles.md .claude/skills 2>/dev/null
```

- **Estamos dentro do próprio `.claude-generica`** (o `origin` é a origem): **pare.**
  Aqui a pasta se edita, não se atualiza.
- **Não há `.claude/`, ou não há `rules/karpathy-principles.md` nem `skills/`:**
  não existe template instalado para atualizar — instalar 70 arquivos aqui é uma
  adoção, não uma atualização. Explique o que viu e ofereça `/adopt-repo` como
  **passo opcional**. Se o usuário recusar, siga normalmente: a instalação
  acontece do mesmo jeito e o relatório (passo 8) lista o que ficou por preencher.

### 2. Descobrir a versão vigente

```bash
git ls-remote --tags --refs https://github.com/PPrauchner/.claude-generica.git
```

A tag mais alta em ordem de versão é a vigente. A numeração é **odômetro, não
semver** — comando/skill novo sobe o MAJOR, alteração sobe o PATCH, e o MINOR só
existe como transbordo do PATCH (`v1.0.9` → `v1.1.0`).

Se a tag do marcador já é a vigente, diga isso e vá direto ao passo 8 — o aviso
sobre as skills globais ainda pode valer.

Clone raso da tag numa pasta temporária e apague no fim:

```bash
git clone --depth 1 --branch <tag> https://github.com/PPrauchner/.claude-generica.git <tmp>
git -C <tmp> rev-parse HEAD
```

O `rev-parse` no clone é a única forma confiável de obter o commit da versão. As
tags aqui são **anotadas**, então o `ls-remote` do passo anterior devolve o SHA do
*objeto tag*, não o do commit — gravar aquele SHA no marcador registra um
identificador que não resolve para conteúdo nenhum.

### 3. Estabelecer a base

- **Com marcador:** a base é a tag registrada nele. Dá para saber o que o template
  mudou entre ela e a vigente.
- **Sem marcador:** a base é **desconhecida**. Não infira.

> Inferir a base casando o conteúdo com as tags **não funciona** e já produziu
> conclusão errada: o SAGA tem 15 skills idênticas à `v1.0.0`, mas veio da
> linhagem pré-tag (`v0.0.1`), anterior a este repositório. As skills não mudaram
> entre uma e outra, então elas não distinguem nada. Casando o SAGA com a `v1.0.0`
> concluiríamos que ele "apagou `python-conventions.md` de propósito" — quando na
> verdade ele nunca o teve, porque na `v0.0.1` o conteúdo Python vivia dentro do
> `code-conventions.md`. Uma heurística que erra assim é pior que nenhuma: ela
> apresenta um motivo convincente e falso, e o usuário confirma confiando nele.

Sem base, o comando só afirma o que enxerga com os próprios olhos: *este arquivo
existe aqui e não existe na versão vigente*. Nada de "você removeu isto".

### 4. Aplicar

**Compare normalizando fim-de-linha e espaço em fim de linha.** Template e projeto
quase nunca coincidem: o `core.autocrlf` da máquina decide o que sai no checkout,
então o mesmo clone vem CRLF aqui e LF ali. Sem normalizar, os ~70 arquivos
aparecem 100% alterados e nenhuma mudança real fica visível.

**Não assuma a direção — meça.** Compare o tamanho em bytes com a contagem de
linhas: se `bytes - linhas` bate com o total de linhas, o arquivo é CRLF.
`grep -c $'\r'` e `awk '/\r$/'` mentem em ambientes Windows (um casa toda linha
com padrão vazio, o outro descarta o CR na leitura) e já produziram a conclusão
oposta à realidade.

**Grave no fim-de-linha do destino** — o do arquivo que está sendo substituído, ou
o dominante no `.claude/` do projeto quando o arquivo é novo. Copiar cru marcaria
o repo inteiro como modificado e afogaria o diff. Pior: **um `.sh` com CRLF não
executa sob bash**, então `board-move.sh` e os hooks quebram em silêncio se
chegarem com o fim-de-linha errado. O `git add` normaliza o que vai para o
histórico, mas quem roda o script é o disco.

Então aplique a tabela de propriedade. Para o `settings.json`, junte
recursivamente: chave ausente entra; chave existente fica como está. Em listas de
hooks, acrescente a entrada só se ainda não houver uma com o mesmo `command`.

### 5. Uma confirmação, com motivo

Junte tudo que precisa de decisão numa **lista única, já pré-marcada com a
sugestão e o motivo em uma linha**, e peça uma confirmação só. Não pergunte
arquivo por arquivo.

- **Órfãos** — existem no projeto e não na versão vigente. Marque *remover* quando
  houver evidência visível (duplica um comando recém-instalado, pasta vazia,
  ponteiro para caminho inexistente); marque *manter* quando não houver.
- **Reinstalações** — existem na versão vigente e não no projeto. Só entram na
  lista **quando há base** e o arquivo existia nela: aí é remoção deliberada do
  projeto e vale perguntar. Sem base, tudo que falta é simplesmente instalado.

O motivo tem que ser verificável na hora. Se não houver motivo checável, a
sugestão é *manter*.

### 6. Gravar o marcador

```json
{
  "repo": "PPrauchner/.claude-generica",
  "tag": "v4.0.0",
  "commit": "<saída do rev-parse do passo 2 — o commit, não o objeto tag>",
  "updated_at": "<AAAA-MM-DD>"
}
```

Em `.claude/.template.json`, versionado junto com o resto — sem ele o próximo
update volta a ser cego.

### 7. Fechar no git

```bash
git ls-files .claude
git rev-parse --abbrev-ref HEAD
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

- **Nenhum arquivo rastreado** (o projeto não versiona `.claude/`): escreva os
  arquivos e não commite nada. Fim.
- **Há arquivos rastreados, na branch default:** `git add .claude` e um commit
  atômico só desses caminhos — funciona mesmo com o resto do repo sujo, sem
  encostar em trabalho em andamento.
- **Há arquivos rastreados, numa branch de tópico:** **pare e pergunte.** Commitar
  aqui enfia a atualização do template dentro de um PR sobre outro assunto. Ofereça
  as três saídas — deixar sem commitar, commitar na branch atual mesmo, ou uma
  branch nova a partir da default — e siga a escolha. **Não crie branch por conta
  própria:** branch é decisão do usuário neste template, a mesma regra que o
  `/open-pr` segue.

> Se o usuário escolher a branch nova, avise que os arquivos **somem da branch de
> trabalho** ao voltar para ela — o comando fica commitado, mas indisponível onde
> ele está sentado até haver merge.

**Nunca faça push.** Mensagem no formato do projeto, por exemplo:

```
chore(claude): atualiza template v1.0.0 -> v4.0.0

- adiciona a skill adopt-repo e os comandos /open-pr e /update-claude
- liga BOARD_SYNC e PR_REVIEW_PARALLEL no settings.json
- remove o layout antigo commands/workflow/
- preserva rules/code-conventions.md e os hooks do projeto
```

### 8. Reportar

Versão de origem → versão nova, o que entrou, o que foi atualizado, o que foi
removido e **o que foi preservado por ser do projeto** — essa última linha é a que
dá confiança para rodar o comando de novo.

Confira também a cópia global:

```bash
ls ~/.claude/skills
```

Se ela estiver atrás da versão vigente, avise — as skills globais têm precedência,
e uma cópia velha ali faz o update "funcionar" sem mudar nada na prática. Sugira
`bash .claude/scripts/link-skills.sh`, mas **não escreva fora do repositório**.
