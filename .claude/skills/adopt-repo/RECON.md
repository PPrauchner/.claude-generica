# Checklist de recon

O que ler antes de perguntar qualquer coisa. Objetivo: chegar ao grill sabendo tudo
que o repositório já responde sozinho.

## 1. O que já existe dos seis artefatos

```bash
ls CLAUDE.md AGENTS.md CONTEXT.md CONTEXT-MAP.md 2>/dev/null
ls docs/adr/ docs/agents/ 2>/dev/null
ls .claude/settings.local.json 2>/dev/null
grep -n "<preencher>" .claude/rules/code-conventions.md
ls .claude/rules/
```

Um `CONTEXT.md` de 0 byte conta como **inexistente** — é stub, não conteúdo.

## 2. Stack e comandos

Leia o manifesto, não adivinhe pela extensão dos arquivos:

| Sinal no repo | Stack | Onde estão os comandos |
|---|---|---|
| `package.json` | Node/TS | campo `scripts` |
| `pnpm-lock.yaml` · `package-lock.json` · `yarn.lock` | qual gerenciador **de fato** | — |
| `pyproject.toml` · `requirements.txt` | Python | `[project.scripts]`, `[tool.*]` |
| `Cargo.toml` | Rust | `cargo build/test` |
| `go.mod` | Go | `go build ./...` |
| `docker-compose.yml` | ambiente | serviços = topologia real |
| `Makefile` · `Taskfile.yml` | qualquer | alvos = comandos canônicos |
| `.github/workflows/` | CI | **a fonte mais confiável de build/test/lint** |

O lockfile decide o gerenciador de pacotes — `package.json` não diz se é npm ou pnpm.
Quando houver mais de um lockfile, isso é uma contradição para o grill, não para você
resolver.

## 3. Domínio (matéria-prima do grill, não conclusão)

- Nomes de módulos/pastas de primeiro nível — costumam ser os conceitos centrais.
- Modelos/entidades: classes de ORM, schemas, `models/`, `entities/`, `types/`,
  migrations.
- Termos que aparecem no README em pt-BR e no código em inglês — são exatamente as
  pontes que o `CONTEXT.md` precisa registrar.

Anote os candidatos a conceito. **Não escreva glossário a partir daqui** — o código
mostra o identificador, não o termo que o usuário usa nem a fronteira entre conceitos.

## 4. Histórico

```bash
git log --oneline -30
git log --format='%an' | sort | uniq -c | sort -rn | head
ls docs/ 2>/dev/null
```

Convenção de commit em uso (o `/commit` deve segui-la, não impor a dele), se o projeto
é solo ou de time, e documentação já existente que não deve ser duplicada.

## 5. O que o recon **não** decide

Leve para o grill, sempre:

- Qual termo de domínio corresponde a cada identificador, e a fronteira entre conceitos
  parecidos.
- Por que uma dependência ou formato foi escolhido — e se é decisão ou acaso.
- O que não pode mudar no projeto.
- Qualquer contradição entre documentação existente e código.
