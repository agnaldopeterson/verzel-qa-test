# Premissas, interpretações e observações

Pontos em que a documentação (card VZS-142, v2.3.0) é ambígua ou omissa. Para cada um registro a interpretação adotada. O campo **Verificado** diz se o comportamento chegou a ser observado no ambiente.

## Interpretações adotadas

| # | Tema | Interpretação | Verificado |
|---|---|---|---|
| 1 | **CA06: limite do frete grátis** | "A partir de R$ 200,00, inclusive" significa subtotal **maior ou igual** a 200,00. A tabela de regras confirma ("igual ou maior"). O sistema diverge disso (BUG-001) | Sim (API e interface) |
| 2 | **CA08: base do frete grátis** | O frete usa o subtotal **bruto** (antes do cupom). Um carrinho de R$ 199,80 com cupom continua pagando frete | Sim (API) |
| 3 | **"Faltam R$ 0,00 para o frete grátis"** | Com subtotal de R$ 200,00, o valor faltante é 0 (fórmula `200 - subtotal`, mínimo 0). Esse valor é coerente com frete grátis, por isso a combinação com "Frete R$ 19,90" é contradição, não comportamento esperado | Sim |
| 4 | **CA02: espaços no meio do código** | A documentação cita só espaços no início e no fim. Interpreto que `BEM VINDO10` deve ser inválido | **Não** |
| 5 | **CA02: tab e quebra de linha** | A documentação fala em "espaços". Não está definido se `\t` e `\n` contam | **Não** |
| 6 | **CA05: um cupom por vez** | Na interface, o fluxo é remover o cupom atual e aplicar outro. Na API existe um único campo `cupom`, então a regra se aplica só à tela | API: sim. Interface: **não** |
| 7 | **CA05: dois cupons na API** | Enviar `BEMVINDO10,VERAO2026` em um só campo foi tratado como código inexistente ("Cupom inválido.") e não acumulou descontos. Considero o resultado compatível com a regra | Sim |
| 8 | **Cupom vazio** | Na interface, "Aplicar cupom" com o campo em branco mostra "Informe um cupom." A documentação não descreve esse caso. Considero comportamento aceitável, não bug | Sim (interface). API: **não** |
| 9 | **Cupom inválido: 200 x 422** | `/carrinho/calcular` retorna 200 com `aplicado: false`, e `/pedidos` retorna 422. Essa diferença está descrita na documentação, então não é bug | Sim |
| 10 | **CA10: limite na API** | O texto diz que a regra vale para interface **e** API. Trato a API como responsável por validar sozinha, sem depender da tela. A API aceitou 6 unidades (BUG-002) | Sim |
| 11 | **Contador do carrinho** | O número ao lado de "Carrinho" aparece igual à **quantidade de unidades** (2, 4 e 5 nos prints). A documentação não define se conta unidades ou itens distintos. Considero correto | Sim |
| 12 | **CA11: arredondamento** | Valores com 2 casas. Nos casos testados (P001 x3, P002 + P001) não apareceram erros de ponto flutuante | Sim (2 casos) |

## Fora do escopo ou não verificado

- **Testes de carga, estresse e segurança:** fora do escopo definido no enunciado.
- **`POST /api/pedidos` com 6 unidades e com subtotal de R$ 200,00:** não executei. Não sei se os dois bugs também atingem a confirmação do pedido.
- **BUG-001 com cupom pela interface:** só foi evidenciado pela API.
- **Automação de interface:** os testes automatizados cobrem a API. Nenhum teste de tela foi automatizado.
- **Respostas comuns do ambiente:** carrinho em memória na aba, pedidos fictícios, sem e-mail, cobrança ou estoque. Tudo isso consta como esperado na documentação e **não foi reportado como bug**.

## Resultado da execução

Foram analisadas 25 respostas de API: 22 passaram e 3 falharam (BUG-001 em duas delas e BUG-002 em uma). Detalhes em `docs/04-evidencias/evidencias.md`.
