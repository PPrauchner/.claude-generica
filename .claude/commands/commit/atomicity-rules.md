# Regras de Atomicidade

## Princípios

- **Uma camada arquitetural por commit** — se o projeto separa responsabilidades em
  camadas, cada uma vai num commit, mesmo que do mesmo domínio. Num app web em
  camadas isso seria `models/`, `services/`, `api/v1/`; noutro layout serão outras
  pastas. As camadas deste projeto, quando definidas, ficam
  [abaixo](#camadas-deste-projeto).
- **Config/deps separados de features** — o manifesto de dependências do projeto
  (qualquer que seja: `pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`) e os
  arquivos de configuração de ambiente = commit independente.
- **Scaffolding separado de implementação** — criar estrutura de arquivo ≠ implementar lógica
- **Um domínio por commit** — mudanças em dois módulos de domínio distintos (ex.:
  `<módulo_a>/` e `<módulo_b>/`) = dois commits
- **Teste separado do código que testa** — o teste vai em outro commit separado da função que ele testa
- **Docs junto com o que documentam** — docstrings e README do módulo vão no commit do módulo

## Tipos

`feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `style`, `perf`, `ci`

## Escopos sugeridos

> Os escopos por módulo serão definidos quando a estrutura de pastas do projeto
> for decidida (sessão de *grill with docs* → `CONTEXT.md` / `docs/adr/`). Por
> enquanto, valem os escopos transversais abaixo.

| Escopo | Quando usar |
|--------|-------------|
| `docs` | Documentação (ADRs, CONTEXT.md, README) |
| `config` | Configuração de ambiente/build |
| `scripts` | Scripts utilitários |

## Camadas deste projeto

> Preencher na sessão de *grill with docs* deste projeto (skill `grill-with-docs`,
> log em `docs/grills_logs/`). O que entra aqui: quais pastas são camadas neste
> repositório, ou a declaração de que ele não é organizado em camadas — nesse caso
> vale só "um domínio por commit".
>
> Vazio significa: o agente infere as camadas da estrutura que encontrar.

<preencher>
