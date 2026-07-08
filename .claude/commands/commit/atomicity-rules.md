# Regras de Atomicidade

## Princípios

- **Uma camada por commit** — `models/`, `services/`, `api/v1/` em commits separados, mesmo que do mesmo domínio
- **Config/deps separados de features** — `pyproject.toml`, `.env.example`, arquivos de configuração = commit independente
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
