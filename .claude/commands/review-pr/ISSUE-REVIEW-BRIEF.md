# Brief do subagente de conformidade

Um subagente por issue. Preencha **todos** os placeholders antes de spawnar — o
subagente não vê esta conversa, e a issue precisa chegar nele por inteiro.

Spawn com `Agent`, `subagent_type: general-purpose`, todos numa única mensagem para
que rodem em paralelo.

```
Você revisa a conformidade do PR #<PR> com UMA issue específica: a issue #<N>.
Você não conhece nenhuma outra issue deste PR — não comente sobre elas.

O repositório já está com a branch do PR em checkout no seu diretório de trabalho.

## Issue #<N> — "<TÍTULO>" (autoritativa — prefira este texto a um re-fetch)
<CORPO DA ISSUE, VERBATIM>

## Documentação do projeto
<"CONTEXT.md existe — leia para conferir a terminologia de domínio." | "Sem CONTEXT.md.">
<"docs/adr/ existe — leia as decisões que o PR possa violar." | "Sem docs/adr/.">

## Sua pergunta, e só ela
"Este PR cumpre a Definition of Done DESTA issue?"

Você NÃO avalia qualidade de código — bugs, performance e simplificação são de outro
revisor, que analisa o PR inteiro. Reportá-los aqui gera achado duplicado.

Avalie três coisas:
1. Cada critério de aceite da issue foi implementado? Nomeie os que não foram.
2. A terminologia bate com o glossário do CONTEXT.md?
3. Alguma decisão registrada em docs/adr/ foi violada?

## Como investigar
- `gh pr diff <PR>` para o diff completo.
- `Read` nos arquivos alterados que precisarem de contexto — o diff isolado engana.
- Se a issue exige comportamento verificável, procure o teste que o cobre.

## Proibido
- Escrever ou editar qualquer arquivo.
- Trocar de branch, commitar, ou rodar qualquer comando que altere o repositório —
  outros subagentes estão lendo esta mesma working tree agora.
- Postar no GitHub (`gh pr review`, `gh pr comment`, `gh issue ...`). Quem publica é
  o orquestrador.
- Rodar `/code-review`.

## Responda EXATAMENTE neste formato, sem preâmbulo

### Issue #<N> — <✓ DoD cumprida | ✗ DoD incompleta>
<Uma frase: o que o PR entregou desta issue.>

- 🔴 BLOQUEADOR: <critério de aceite não cumprido — cite o critério e o arquivo>
- 🟡 DESVIO: <divergência de terminologia (CONTEXT.md) ou de decisão (docs/adr/)>
- ⚪ MENOR: <nit ou convenção>

Omita as linhas de severidade que não tiverem achados. Sem achado nenhum, deixe só o
cabeçalho e a frase. Máximo de 150 palavras. Não invente achado para parecer útil:
"✓ DoD cumprida" sem bullets é uma resposta legítima e frequente.
```
