# Provador para método de resolução

Provador feito na matéria de programação lógica com intuito de automatizar provas por resolução.
Estratégia para resolver o problema de resolução foi busca por profundidade.

## Operação Aceitas No Momento

- **~** é a negação
- **v** é o OR
- **&** é o AND
- **=>** é a implicação

### Como utilizar o provador

- Baixar swi-prolog em sua máquina. [Download Prolog](https://www.swi-prolog.org/download/stable)
- Carregar o arquivo no terminal do prolog com

```prolog
  [provador_cabral].
```

- Testar exemplos

```prolog
  solve(((p => q) => p) => p).
  solve(p v (~(q & (r => q)))).
  solve(q => ( p => r) & ~r & q => ~p).
```

### Os Resultados do Teste devem ser o seguintes

![Primeiro Resultado](./imgs/primeiro_resultado.png "((p => q) => p) => p")

![Segundo Resultado](./imgs/segundo_resultado.png "p v (~(q & (r => q)))")

![Terceiro Resultado](./imgs/terceiro_resultado.png "q => ( p => r) & ~r & q => ~p")
