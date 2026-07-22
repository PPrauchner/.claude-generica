# .claude-generica

Repositório-template da pasta `.claude/`: convenções, skills e comandos que são
copiados para outros projetos e evoluem aqui. O domínio deste repositório é a
própria distribuição — como uma versão sai daqui e chega (ou volta a chegar) nos
projetos que já copiaram.

## Language

### Distribuição

**Template**:
Este repositório. A fonte da verdade das skills, comandos, rules, hooks e scripts
que os projetos reusam.
_Avoid_: biblioteca, framework, boilerplate

**Projeto adotado**:
Um repositório que já tem a pasta `.claude/` copiada do Template e evolui em git
próprio.
_Avoid_: cliente, consumidor, fork

**Versão vigente**:
A tag mais recente do Template — o estado que um Projeto adotado deveria alcançar
ao se atualizar. Numerada por odômetro (skill/comando novo = MAJOR, alteração =
PATCH), não por semver.
_Avoid_: latest, HEAD, última release

**Linhagem pré-tag (v0.0.1)**:
O estado do `.claude/` anterior a este repositório, do qual SAGA e Peak Plan
foram copiados. Não existe em commit nenhum aqui — este repositório já nasceu
depois dela, com o `python-conventions.md` extraído do `code-conventions.md`.
Projetos dessa linhagem não têm Versão vigente reconstruível.
_Avoid_: v1.0.0 antiga, versão zero

**Marcador de origem**:
O registro, dentro do Projeto adotado, de qual Versão vigente ele carrega —
repositório de origem, tag, commit e data. Sem ele não há como distinguir o que o
Template mudou do que o projeto customizou.
_Avoid_: lockfile, manifesto

### Propriedade dos arquivos

**Semente**:
Arquivo que o Template entrega uma vez para o Projeto adotado **substituir** por
conteúdo próprio — hoje, `rules/code-conventions.md`. A atualização nunca o toca:
sobrescrever uma Semente apaga conhecimento de domínio do projeto.
_Avoid_: stub, placeholder, exemplo

**Extensão**:
Customização que o Projeto adotado faz **em volta** do que o Template entregou,
sem remover nada — hoje, os hooks próprios no `settings.json`. Ao contrário da
Semente, admite juntar: a atualização acrescenta o que falta e preserva o resto.
_Avoid_: override, patch local

**Órfão**:
Arquivo presente no `.claude/` do Projeto adotado e ausente da Versão vigente. Ou
é resto de um layout que o Template aposentou, ou é conteúdo do próprio projeto —
e distinguir os dois nem sempre é possível, porque a linhagem de alguns projetos
antecede a primeira tag.
_Avoid_: sobra, resíduo, arquivo morto
