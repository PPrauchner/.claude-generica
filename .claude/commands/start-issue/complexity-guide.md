# Guia de Complexidade

Régua para o passo 3 do `/start-issue` decidir se a issue vira uma implementação
direta ou um plano de sub-tarefas.

Os critérios abaixo são **observáveis no repositório antes de codar** — o agente
consegue verificar cada um lendo a issue e os arquivos. Estimativa de tempo não
entra: o agente não tem como medir, e um critério que ele só pode chutar não torna
a decisão reproduzível entre sessões.

Os limiares são defaults. Este projeto pode apertá-los ou afrouxá-los na seção
**Quebra de trabalho** de [`rules/work-calibration.md`](../../rules/work-calibration.md)
— leia-a antes de aplicar a régua abaixo. Seção vazia (ou arquivo ausente) significa:
valem os defaults.

## NÃO quebrar (issue simples)

Quando **todos** valem:

- Toca **um único módulo/diretório** — ou poucos arquivos vizinhos com a mesma
  responsabilidade.
- **Não cria interface pública nova** — nenhuma função, classe, endpoint, comando ou
  formato de arquivo que outra parte do sistema passe a depender.
- **Não exige teste dedicado novo** — a suíte existente já cobre o caminho, ou basta
  um caso a mais num teste que já existe.
- **Não tem dependência de ordem interna** — não há "isto precisa existir antes
  daquilo" dentro da própria issue.

## QUEBRAR em sub-tarefas (issue complexa)

Quando **qualquer um** vale:

- Toca **três ou mais módulos/diretórios distintos**.
- Cria **interface pública nova** que outra parte da issue já consome — a interface
  e seu consumidor são sub-tarefas separadas, nessa ordem.
- Exige **arquivo de teste novo** para comportamento que ainda não existe.
- Tem **dependência de ordem** entre partes: uma parte não roda enquanto a outra não
  estiver pronta.
- Junta **mudança de comportamento com migração/refatoração** do que já existe —
  duas coisas que devem poder ser revisadas (e revertidas) em separado.

Se a issue estoura essa régua com folga — a ponto de as sub-tarefas terem elas
mesmas sub-tarefas —, ela não é uma issue: pare e proponha `/to-issues`.

## Formato das sub-tarefas

Cada sub-tarefa precisa de:

- **Título** — curto, imperativo (ex.: "Implementar validação de entrada")
- **Escopo** — o que exatamente será feito
- **Referência** — ADR ou seção do `CONTEXT.md` relevante, se aplicável
- **Dependências** — quais sub-tarefas devem ser concluídas antes
