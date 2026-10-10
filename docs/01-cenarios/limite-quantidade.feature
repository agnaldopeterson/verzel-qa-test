# language: pt
# Legenda das tags: ver cupom-desconto.feature

@VZS-142 @quantidade
Funcionalidade: Limite de 5 unidades por produto
  A regra vale para a interface e para a API (CA10)

  @CA10 @api @automatizado
  Cenário: A API aceita 5 unidades de um produto
    Quando envio 5 unidades de "Camiseta Essencial" (P001) para o cálculo do carrinho
    Então a resposta é 200
    E o subtotal é de R$ 299,50

  @CA10 @api @automatizado @bug-002
  Cenário: A API rejeita 6 unidades de um produto
    Quando envio 6 unidades de "Camiseta Essencial" (P001) para o cálculo do carrinho
    Então a resposta é 422
    E o código de erro é "QUANTIDADE_MAXIMA_EXCEDIDA"
    # FALHA: a API responde 200 e calcula o carrinho com 6 unidades (BUG-002)

  @CA10 @ui
  Cenário: A interface exibe o aviso e bloqueia o aumento ao chegar em 5 unidades
    Dado que o carrinho contém 5 unidades de "Garrafa Térmica 750ml"
    Então vejo o aviso "Limite de 5 unidades por produto."
    E o botão "+" está desabilitado

  @CA10 @nao-executado
  Cenário: O limite vale por produto, não pelo carrinho
    Quando envio 5 unidades de "Camiseta Essencial" e 5 unidades de "Calça Jeans Slim"
    Então a resposta é 200

  @CA10 @nao-executado
  Esquema do Cenário: Quantidades inválidas são rejeitadas
    Quando envio quantidade <quantidade> para o cálculo do carrinho
    Então a resposta é 422 com o código "QUANTIDADE_INVALIDA"

    Exemplos:
      | quantidade |
      | 0          |
      | -1         |
      | 1.5        |
      | "2"        |

  @pedido @nao-executado
  Cenário: O pedido também respeita o limite de 5 unidades
    Quando confirmo um pedido com 6 unidades de "Camiseta Essencial"
    Então a resposta é 422 com o código "QUANTIDADE_MAXIMA_EXCEDIDA"
