# Evidências da execução

Ambiente: https://verzel-store.qa-test-verzel-store.workers.dev
Execução da API em 09/10/2026 (REST Client do VS Code, arquivo `docs/02-execucao/api.http`).

## Resumo

| | Quantidade |
|---|---|
| Respostas de API analisadas | 25 |
| Passou | 22 |
| Falhou | 3 (correspondem a **2 bugs**) |
| Bugs abertos | [BUG-001](../03-bugs/BUG-001.md), [BUG-002](../03-bugs/BUG-002.md) |

> As respostas brutas ficam em `api-raw/`. Adicione a extensão `.txt` aos arquivos exportados (ex.: `CA06` vira `CA06.txt`). As requisições abaixo foram identificadas pelo conteúdo de cada resposta.

## Execução da API

| Arquivo | Caso | Requisição | Resultado esperado | Resultado obtido | Status |
|---|---|---|---|---|---|
| [CA00](api-raw/CA00.txt) | Catálogo | `GET /api/produtos` | 200, 8 produtos | 200, 8 produtos, preços conferem | Passou |
| [CA01](api-raw/CA01.txt) | CA01, 10% de desconto | P002 x1 + P004 x2, `BEMVINDO10` | desconto 23,97, frete 0, total 215,73 | igual ao esperado | Passou |
| [CA01.2](api-raw/CA01.2.txt) | CA01, 10% de desconto | P005 x1, `BEMVINDO10` | desconto 10, frete 19,90, total 109,90 | igual ao esperado | Passou |
| [CA02.1](api-raw/CA02.1.txt) | CA02, variação do código | P005 x1, cupom com variação de caixa/espaços | cupom aplicado, desconto 10 | aplicado, `codigo` normalizado | Passou |
| [CA02.2](api-raw/CA02.2.txt) | CA02, variação do código | P005 x1, cupom com variação de caixa/espaços | cupom aplicado, desconto 10 | aplicado, `codigo` normalizado | Passou |
| [CA03](api-raw/CA03.txt) | CA03, cupom inexistente | P005 x1, `NAOEXISTE` | 200, desconto 0, "Cupom inválido." | igual ao esperado | Passou |
| [CA04](api-raw/CA04.txt) | CA04, cupom expirado | P005 x1, `VERAO2026` | 200, desconto 0, "Cupom expirado." | igual ao esperado | Passou |
| [CA05](api-raw/CA05.txt) | CA05, dois cupons (exploratório) | P005 x1, `BEMVINDO10,VERAO2026` | não acumular descontos | tratado como "Cupom inválido.", sem desconto | Passou (ver premissas) |
| [CA06](api-raw/CA06.txt) | CA06, limite exato de frete grátis | P005 x2, sem cupom | frete 0, total 200,00 | frete **19,90**, total **219,90** | **Falhou** ([BUG-001](../03-bugs/BUG-001.md)) |
| [CA07](api-raw/CA07.txt) | CA07, abaixo do limite | P002 + P001 (199,80) | frete 19,90, faltante 0,20, total 219,70 | igual ao esperado | Passou |
| [CA08.1](api-raw/CA08.1.txt) | CA08, limite exato com cupom | P005 x2, `BEMVINDO10` | desconto 20, frete 0, total 180,00 | frete **19,90**, total **199,90** | **Falhou** ([BUG-001](../03-bugs/BUG-001.md)) |
| [CA08.2](api-raw/CA08.2.txt) | CA08, cupom não dá frete grátis | P002 + P001, `BEMVINDO10` | desconto 19,98, frete 19,90, total 199,72 | igual ao esperado | Passou |
| [CA09](api-raw/CA09.txt) | CA09, desconto não incide no frete | P005 x1, `BEMVINDO10` | desconto 10 (não 11,99), total 109,90 | igual ao esperado | Passou |
| [CA10.1](api-raw/CA10.1.txt) | CA10, 5 unidades | P001 x5 | 200, subtotal 299,50, frete grátis | igual ao esperado | Passou |
| [CA10.2](api-raw/CA10.2.txt) | CA10, 6 unidades | P001 x6 | 422 `QUANTIDADE_MAXIMA_EXCEDIDA` | **200**, quantidade 6, subtotal 359,40 | **Falhou** ([BUG-002](../03-bugs/BUG-002.md)) |
| [CA11.1](api-raw/CA11.1.txt) | CA11, ponto flutuante | P001 x3 | subtotal 179,7, faltante 20,3, total 199,6 | igual ao esperado, sem casas extras | Passou |
| [CA11.2](api-raw/CA11.2.txt) | CA11, ponto flutuante | P002 + P001 | faltante 0,2, total 219,7 | igual ao esperado, sem casas extras | Passou |
| [P01](api-raw/P01.txt) | Pedido válido | `POST /api/pedidos`, P005 x1, `BEMVINDO10` | 201, `VZ-` + 6 dígitos, total 109,90, CEP sem hífen | 201, `VZ-722293`, total 109,90, CEP `01310100` | Passou |
| [P02](api-raw/P02.txt) | Pedido com cupom inexistente | `POST /api/pedidos` | 422 `CUPOM_INVALIDO` | igual ao esperado | Passou |
| [P03](api-raw/P03.txt) | Pedido com cupom expirado | `POST /api/pedidos` | 422 `CUPOM_EXPIRADO` | igual ao esperado | Passou |
| [P04](api-raw/P04.txt) | Pedido com cupom expirado (repetição) | `POST /api/pedidos` | 422 `CUPOM_EXPIRADO` | igual ao esperado | Passou (repetição do pedido com cupom expirado; a requisição exata não foi registrada) |
| [P05](api-raw/P05.txt) | Nome sem sobrenome | `POST /api/pedidos` | 422 `DADOS_INVALIDOS` (nome) | igual ao esperado | Passou |
| [P06](api-raw/P06.txt) | CEP com menos de 8 dígitos | `POST /api/pedidos` | 422 `DADOS_INVALIDOS` (cep) | igual ao esperado | Passou |
| [V01](api-raw/V01.txt) | Produto duplicado | `POST /api/carrinho/calcular`, P001 repetido | 422 `ITEM_DUPLICADO` | igual ao esperado | Passou |
| [V02](api-raw/V02.txt) | JSON inválido | `POST /api/carrinho/calcular`, corpo `{abc` | 400 `JSON_INVALIDO` | igual ao esperado | Passou |

## Execução da interface

| Print | Caso | Resultado esperado | Resultado obtido | Status |
|---|---|---|---|---|
| ![](BUG-001-ui-garrafa-x4.png) | Garrafa Térmica x4 (subtotal 200,00) | Frete grátis, total 200,00 | Frete 19,90, total 219,90, "Faltam R$ 0,00 para o frete grátis." | **Falhou** ([BUG-001](../03-bugs/BUG-001.md)) |
| ![](BUG-001-ui-mochila-x2.png) | Mochila Urbana x2 (subtotal 200,00) | Frete grátis, total 200,00 | Frete 19,90, total 219,90, "Faltam R$ 0,00 para o frete grátis." | **Falhou** ([BUG-001](../03-bugs/BUG-001.md)) |
| ![](CA10-ui-camiseta-x5.png) | Camiseta x5 (subtotal 299,50) | Frete grátis; aviso do limite de 5 | Frete Grátis, total 299,50, aviso "Limite de 5 unidades por produto." | Passou |
| ![](BUG-002-api-ca10-2.png) | Garrafa Térmica com 5 unidades (lado esquerdo do print) | Aviso do limite e aumento bloqueado | Aviso "Limite de 5 unidades por produto." e botão `+` desabilitado | Passou |

## Comportamentos observados (não são bugs)

- **Cupom vazio na interface:** ao clicar em "Aplicar cupom" sem digitar nada, a tela exibe "Informe um cupom." A documentação não define esse caso.
- **Dois cupons na API:** `BEMVINDO10,VERAO2026` retorna "Cupom inválido." e não acumula descontos, coerente com o CA05.

## Arquivos de evidência desta pasta

| Arquivo | O que mostra |
|---|---|
| `BUG-001-ui-mochila-x2.png` | Carrinho com Mochila x2: subtotal R$ 200,00, frete R$ 19,90 |
| `BUG-001-ui-garrafa-x4.png` | Carrinho com Garrafa Térmica x4: subtotal R$ 200,00, frete R$ 19,90 |
| `BUG-001-api-ca06.png` | Interface e requisição/resposta da API lado a lado: `frete: 19.9`, `freteGratis: false` |
| `BUG-002-api-ca10-2.png` | Resposta 200 com 6 unidades na API, e a interface travada em 5 unidades |
| `CA10-ui-camiseta-x5.png` | Carrinho com 5 unidades, frete grátis e aviso do limite |
