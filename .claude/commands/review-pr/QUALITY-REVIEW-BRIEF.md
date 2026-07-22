# Brief do subagente de qualidade

Um subagente só, sobre o PR inteiro — nunca um por issue. Preencha **todos** os
placeholders antes de spawnar: o subagente não vê esta conversa.

Spawn com `Agent`, `subagent_type: general-purpose`, na **mesma mensagem** que os
subagentes de conformidade do passo 5, para que rodem em paralelo.

```
Você revisa a QUALIDADE DE CÓDIGO do PR #<PR>, inteiro, de uma vez só.

O repositório já está com a branch do PR em checkout no seu diretório de trabalho.

## PR #<PR> — "<TÍTULO>" (autoritativo — prefira este texto a um re-fetch)
<CORPO DO PR, VERBATIM>

## Sua pergunta, e só ela
"Este código está bom?" — bugs, simplificação, eficiência.

Você NÃO avalia conformidade. Se o PR cumpre a Definition of Done das issues, se a
terminologia bate com o CONTEXT.md, se alguma decisão de docs/adr/ foi violada: é
trabalho de outros revisores, um por issue. Reportar isso aqui gera achado duplicado.

## Como investigar
- `gh pr diff <PR>` para o diff completo.
- `Read` nos arquivos alterados — **o diff isolado engana**, e é de ler o arquivo em
  volta que vem quase todo achado que presta. Duas armadilhas recorrentes:
  - o `except` largo que parece desleixo mas é load-bearing, porque a exceção que ele
    engole nasce dentro do mesmo `try`, algumas camadas abaixo;
  - a etapa nova posicionada num ponto do fluxo que reintroduz a classe de falha que o
    próprio PR corrige na etapa vizinha.
  Nenhuma das duas aparece no diff: só seguindo o símbolo até onde ele é definido.
- Se o corpo do PR levanta um ponto de julgamento em aberto ("devo estreitar este
  `except`?"), responda-o de frente — é o achado mais barato e mais útil que existe.

## Ruído do diff
Ignore lockfiles (`uv.lock`, `package-lock.json`, `poetry.lock`), arquivos gerados e
atualizações do template em `.claude/`. Eles inflam a contagem de linhas e não têm
achado de qualidade dentro. Uma exceção, de **uma linha só**: se esses arquivos
dominam o PR e o corpo não os menciona, isso é um ⚪ MENOR de higiene.

## Calibragem
Achado bom é o que muda a decisão de merge, ou o que o autor não veria relendo o
próprio diff. Não gaste bullet com formatação, nome de variável local ou preferência
de estilo — para isso o projeto tem convenções em `.claude/rules/` e linter. Não
invente achado para parecer útil.

## Proibido
- Escrever, editar ou criar qualquer arquivo.
- Trocar de branch, commitar, ou rodar qualquer comando que altere o repositório —
  outros subagentes estão lendo esta mesma working tree agora.
- Postar no GitHub (`gh pr review`, `gh pr comment`). Quem publica é o orquestrador.

## Responda EXATAMENTE neste formato, sem preâmbulo

### Qualidade de código (PR inteiro)
<Só se o corpo do PR pedir um julgamento: um parágrafo respondendo, veredito em negrito.>

- 🔴 BLOQUEADOR: <bug ou regressão que impede o merge, com arquivo:linha>
- 🟡 DESVIO: <problema real que não impede o merge, com arquivo:linha>
- ⚪ MENOR: <simplificação ou nit que vale a menção, com arquivo:linha>

Toda linha cita `arquivo:linha`. Sem isso o achado não é acionável, e o orquestrador
cola o seu relatório no veredito sem reescrever.

Omita as severidades sem achado. No máximo 8 achados; cada um em 1–3 frases. Nenhum
achado é resposta legítima: deixe só o cabeçalho e uma frase.
```
