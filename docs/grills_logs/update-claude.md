# Grill — Comando `/update-claude`

**Início:** 2026-07-22

Objetivo: dar ao template uma forma de se propagar para os projetos que já
copiaram a pasta `.claude/` — rodar um comando dentro do projeto e trazê-lo para
a versão vigente daqui.

## Achados de exploração (não perguntados)

- **Nenhum repositório sabe em que versão está.** Não existe marcador em lugar
  nenhum — a versão de cada projeto só existia na cabeça do usuário.
- **Quase toda a "divergência" é CRLF.** `karpathy-principles.md` e
  `skills/tdd/SKILL.md` acusam diff de 100% das linhas no SAGA e no Novelas, mas
  são byte-a-byte idênticos ignorando fim-de-linha. Comparar sem normalizar
  reportaria conflito em todos os arquivos, sempre.

  > **Correção pós-sessão (execução real contra o novelas-ia).** Durante o grill eu
  > afirmei "projetos em CRLF, template em LF" — é **o inverso**: o template (e seus
  > clones nesta máquina) vem em CRLF, os projetos estão em LF. `karpathy-principles.md`
  > tem 2392 bytes aqui e 2336 no Novelas, com 56 linhas nos dois — os 56 bytes de
  > diferença são os CR daqui. `grep -c $'\r'` e `awk '/\r$/'` deram respostas opostas
  > e ambas erradas neste ambiente; só a aritmética de bytes resolveu. O desenho não
  > muda (normalizar na comparação, gravar na convenção do destino), mas a
  > justificativa publicada estava de cabeça para baixo.
- Normalizando, a divergência real é **`rules/code-conventions.md`,
  `settings.json` e `skills/README.md`** — só. O SAGA tem *zero* skills
  customizadas: as 15 batem byte-a-byte. Os `commands/*` divergentes do Novelas
  não são customização, são o template antigo.
- `commands/workflow/` **nunca existiu em commit nenhum** deste repositório; a
  `v1.0.0` já nasceu com o layout de pastas. `python-conventions.md` existe desde o
  3º commit.
- O `settings.json` do Novelas tem só `GRILL_LOG`; o do SAGA não tem bloco `env`.
  Sem tocar nesse arquivo, `BOARD_SYNC` e `PR_REVIEW_PARALLEL` chegariam desligados.
- Existe uma **terceira cópia** das skills em `~/.claude/skills` (pastas reais, não
  symlinks), atrasada: falta `adopt-repo`, sobra `afk-queue` (virou comando). Nesta
  sessão o `grill-with-docs` carregou de lá, não do projeto.
- `.claude/` rastreada no git: SAGA 73 arquivos, Quadras 67, Novelas e Site 58,
  Trabalho de ED 50, **Peak Plan 8**, **MentorIA nem tem a pasta**.

---

## Formato e escopo

**P:** Skill ou comando?
**R:** Comando (`/update-claude`). Skill é o que o Claude decide invocar ao
reconhecer uma situação; aqui o gatilho é o usuário digitando o nome, com
procedimento fixo — mesma forma de `/commit`, `/open-pr`, `/start-issue`.
Sem argumentos.

**P:** Como o projeto registra em que versão está?
**R:** Marcador `.claude/.template.json` com **repo, tag, commit e data**. Um
`VERSION` de uma linha bastaria para o diff, mas a origem completa deixa o
registro autoexplicativo.

**P:** O comando também atualiza `~/.claude/skills`?
**R:** **Não** — só o `.claude/` do repositório onde foi rodado: território
versionado, revisável no diff, com dono claro. Escrever em `~/.claude` a partir de
um comando rodado dentro de um projeto seria mudar a máquina inteira sem diff nem
desfazer. Quando notar a cópia global atrasada, avisa no relatório e sugere o
`link-skills.sh`.

---

## Propriedade dos arquivos

**P:** O que o update pode sobrescrever?
**R:** Regra **fixa no próprio comando** — nenhum arquivo de configuração, nenhum
manifesto a manter. Hoje a lista de exceções tem duas entradas; o resto é do
template por padrão.

**P:** `code-conventions.md` e `settings.json` recebem o mesmo tratamento?
**R:** **Não** — as customizações têm formas diferentes:

- `code-conventions.md` o projeto **substitui** (o SAGA jogou fora o conteúdo
  genérico e escreveu o dele). Prosa não se junta: ou é um ou é outro. → **Semente**,
  intocável.
- `settings.json` o projeto **estende** (ninguém apagou nada, só acrescentou hooks
  em volta). Acrescentar chave ausente não destrói customização. → **Extensão**,
  junta só o que falta.

Tratar os dois como o mesmo caso entregaria board sync e review paralelo
instalados e desligados.

**P:** Fim-de-linha?
**R:** Comparar normalizado, gravar no padrão do destino. Gravar LF cru num repo
CRLF marcaria ~70 arquivos como modificados e afogaria a mudança real.

---

## Órfãos e base

**P:** O que fazer com arquivo que existe no projeto e não na versão nova?
**R:** **Remover, mas na dúvida perguntar.** Não pode ser "apaga tudo que o template
não tem": isso levaria junto `rules/architecture.md`, `backend.md`, `frontend.md` e
a skill `engineering` do SAGA, que nunca vieram daqui.

**P:** Como consultar sem virar entrevista de 15 rodadas?
**R:** **Uma lista única, pré-marcada** com a sugestão e o motivo em uma linha, e
uma confirmação só. O motivo visível é o ponto: o usuário não confirma um palpite
às cegas.

**P:** Dá para inferir a versão de origem casando o conteúdo com as tags?
**R:** **Não — e essa foi a correção mais importante da sessão.** A tentativa:
o SAGA tem 15 skills idênticas à `v1.0.0`, logo veio da `v1.0.0`, logo ele
"apagou `python-conventions.md` de propósito" e o update não deve reinstalá-lo.

Está errado. O SAGA vem da linhagem **`v0.0.1`**, anterior a este repositório, em
que o conteúdo Python vivia dentro do `code-conventions.md` — o
`python-conventions.md` foi extraído dali depois. O SAGA nunca o teve, e o certo é
justamente instalar. As skills não mudaram entre `v0.0.1` e `v1.0.0`, então casá-las
não prova nada.

**Consequência:** sem marcador, **não inferir base**. A primeira execução só afirma
o que enxerga com os próprios olhos ("existe aqui e não na versão nova") e a lista
pré-marcada tem um sentido só: órfãos. Tudo que falta do template é instalado. Da
segunda execução em diante o marcador dá a base real, e aí "você removeu isto"
passa a ser afirmação verificável.

> Uma heurística que erra assim é pior que nenhuma: apresenta um motivo
> convincente e falso, e o usuário confirma confiando nele.

---

## Pré-condições e fecho

**P:** E num repo que tem `.claude/` mas nunca foi adotado (Peak Plan), ou que não
tem a pasta (MentorIA)?
**R:** O `adopt-repo` vira **passo opcional do processo** — o comando detecta,
explica e oferece; não é um muro. Recusando, ele instala do mesmo jeito e o
relatório lista o que ficou por preencher. O `adopt-repo` rodado depois encontra o
terreno pronto em vez de vazio.

**P:** Qual o gatilho dessa oferta?
**R:** **Não haver template instalado** — sem `rules/karpathy-principles.md` e sem
`skills/`. O gatilho inicial pensado era "parentesco com alguma tag", descartado
junto com a inferência de base. Documentação faltando **não** é gatilho: o Quadras
tem `CONTEXT.md` de 0 bytes e 67 arquivos rastreados — atualiza normal, sem sermão.

**P:** O comando commita?
**R:** **Só se o repositório versionar o `.claude/`.** Havendo arquivos rastreados,
`git add .claude` e um commit atômico desses caminhos — funciona mesmo com o resto
do repo sujo. Não versionando (MentorIA), escreve e para. Nunca faz push.

---

## Termos registrados em `CONTEXT.md`

`Template`, `Projeto adotado`, `Versão vigente`, `Linhagem pré-tag (v0.0.1)`,
`Marcador de origem`, `Semente`, `Extensão`, `Órfão`.

## Resultado

- `.claude/commands/update-claude/SKILL.md` — comando novo.
- `CONTEXT.md` — criado; glossário da distribuição.
- `README.md` — "Modelo de reuso" corrigido (dizia que nada se propaga) + seção
  "Como atualizar um projeto que já copiou".
- `.claude/commands/README.md` — índice.
