# Convenções de Código

> Lido pelo agente ao escrever ou revisar código. Para o modelo de domínio, ver
> `CONTEXT.md`; para as decisões de arquitetura e seus porquês, `docs/adr/`.
>
> As restrições específicas deste projeto devem ser definidas na sessão de *grill
> with docs* (skill `grill-with-docs`, log em `docs/grills_logs/`) e registradas na
> seção [Restrições deste projeto](#restrições-deste-projeto) abaixo.

---

## Idioma

- **Código** (módulos, identificadores, docstrings) em **inglês**.
- **Documentação** (ADRs, `CONTEXT.md`, README, log) em **português**.
- O glossário em `CONTEXT.md` faz a ponte entre o termo de domínio (pt-BR) e o
  identificador no código (inglês).

---

## Convenções por linguagem

As regras específicas de cada linguagem vivem em arquivos separados, para não
assumir uma stack que o projeto não usa:

- **Python** → [`python-conventions.md`](./python-conventions.md)
- Outras linguagens: adicionar `rules/<linguagem>-conventions.md` conforme o
  projeto precisar (ex.: `typescript-conventions.md`).

---

## Clean Code

- Funções com responsabilidade única — se o nome precisar de "e"/"ou", dividir.
- Nomes descritivos: sem abreviações opacas (`nd` → `node`, `sz` → `size`).
- Constantes em `UPPER_SNAKE_CASE`; variáveis e funções em `snake_case`; classes em
  `PascalCase`.
- Comentários explicam *por quê*, não *o quê*.
- Ver também `.claude/rules/karpathy-principles.md` (simplicidade primeiro,
  mudanças cirúrgicas, execução orientada a metas).

---

## Restrições deste projeto

> Preencher na sessão de *grill with docs* deste projeto. Modelo de domínio em
> [`CONTEXT.md`](../../CONTEXT.md); decisões e porquês em [`docs/adr/`](../../docs/adr/).
>
> Exemplos do que entra aqui: linguagem/versão, dependências centrais vs.
> opcionais, tipo de interface (CLI/web/API), formato de persistência,
> reprodutibilidade, estrutura de pastas — o que for específico e não-óbvio deste
> projeto.

<preencher>
