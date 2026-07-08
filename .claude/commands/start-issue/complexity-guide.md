# Guia de Complexidade

## NÃO quebrar (issue simples)

- Bug fix em arquivo único ou poucos arquivos do mesmo módulo
- Ajuste isolado, sem impacto em outras partes do sistema
- Mudança em um único componente sem efeito cross-module
- Adição de campo/parâmetro simples sem lógica nova
- Estimativa menor que 1 hora de trabalho

## QUEBRAR em sub-tarefas (issue complexa)

- Nova feature que atravessa várias etapas do pipeline ou camadas
- Mudança que afeta múltiplos módulos ao mesmo tempo
- Criação de 3 ou mais arquivos em partes distintas do projeto
- Envolve lógica nova que exige testes dedicados
- Estimativa maior que 1,5 horas

## Formato das sub-tarefas

Cada sub-tarefa precisa de:
- **Título** — curto, imperativo (ex: "Implementar validação de entrada")
- **Escopo** — o que exatamente será feito
- **Referência** — ADR ou seção de `CONTEXT.md` relevante, se aplicável
- **Dependências** — quais sub-tarefas devem ser concluídas antes
