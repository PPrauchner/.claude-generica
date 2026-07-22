# Não depender do `/code-review` embutido para a frente de qualidade

O `/review-pr` divide a revisão em conformidade (por issue) e qualidade de código (PR
inteiro). Da `v3.0.1` até a `v4.0.3`, a segunda frente era um `/code-review` invocado
pelo orquestrador. **Decidimos parar de invocá-lo:** a qualidade passa a ser um
subagente `general-purpose` guiado por um brief do próprio Template
([`QUALITY-REVIEW-BRIEF.md`](../../.claude/commands/review-pr/QUALITY-REVIEW-BRIEF.md)),
o mesmo padrão que a conformidade já usava.

## Por quê

A instrução era **inexecutável**. O `/code-review` embutido do Claude Code declara
`disable-model-invocation: true`; chamá-lo pela tool `Skill` devolve
`Skill code-review cannot be used with Skill tool due to disable-model-invocation`.
Na prática o passo falhava calado: quem rodava o `/review-pr` ou pulava a frente de
qualidade, ou improvisava uma análise inline, sem formato garantido.

As três saídas óbvias não servem:

- **Delegar a um subagente não contorna.** O flag é propriedade da skill, não de quem
  chama — o subagente usa o mesmo registro e bate na mesma parede.
- **Não há arquivo para editar.** O `code-review` não existe em `~/.claude/skills/`
  nem nos projetos; é embutido no CLI.
- **O plugin oficial não serve como está.** O
  `claude-plugins-official/plugins/code-review` tem `disable-model-invocation: false`,
  mas não vem instalado e lista `gh pr comment` nas `allowed-tools` — ele publica no PR
  sozinho, violando a regra do `/review-pr` de que só o orquestrador escreve no GitHub.

Por baixo dos três está a razão que sobrevive a qualquer um deles mudar: **o Template
não pode depender de uma capacidade do CLI hospedeiro que ele não consegue enviar,
verificar nem versionar.** O que um Projeto adotado recebe é a pasta `.claude/`; a
invocabilidade do `/code-review` não viaja junto, e nada aqui detecta que ela sumiu.
Um brief é conteúdo nosso — chega pelo `/update-claude` como qualquer outro arquivo.

## Consequências

- A calibragem da revisão de qualidade vira coisa nossa, ajustável: o que conta como
  achado, o que é ruído de lockfile, quanto ler além do diff. O brief nasce calibrado
  pelo veredito manual do
  [PR #38 do `novelas-ia`](https://github.com/PPrauchner/novelas-ia/pull/38#issuecomment-5051628077),
  feito à mão justamente porque este passo falhava.
- O custo é manutenção: o `/code-review` embutido evolui com o CLI e nós não herdamos
  mais essa evolução.
- O `PR_REVIEW_PARALLEL` continua valendo **só para conformidade**. Ele existe para
  não multiplicar agentes por issue, e a qualidade é sempre um agente só — desligá-la
  junto devolveria exatamente o buraco que este ADR fecha.
- Nada impede um Projeto adotado de rodar `/code-review` na mão, fora do `/review-pr`.
  O que deixou de existir é a dependência.
