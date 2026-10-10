# language: pt
# Legenda das tags: ver cupom-desconto.feature

@VZS-142 @pedido
Funcionalidade: Confirmação de pedido e validações da API

  @api
  Cenário: Pedido válido com cupom
    Quando confirmo um pedido com dados válidos, 1 unidade de "Mochila Urbana 20L" e o cupom "BEMVINDO10"
    Então a resposta é 201
    E o número do pedido segue o formato "VZ-" seguido de 6 dígitos
    E o subtotal é R$ 100,00, o desconto R$ 10,00, o frete R$ 19,90 e o total R$ 109,90
    E o CEP é devolvido sem hífen

  @api
  Cenário: Pedido com cupom inexistente é rejeitado
    Quando confirmo um pedido com o cupom "NAOEXISTE"
    Então a resposta é 422 com o código "CUPOM_INVALIDO"

  @api
  Cenário: Pedido com cupom expirado é rejeitado
    Quando confirmo um pedido com o cupom "VERAO2026"
    Então a resposta é 422 com o código "CUPOM_EXPIRADO"

  @api
  Cenário: Nome sem sobrenome é rejeitado
    Quando confirmo um pedido com o nome "Maria"
    Então a resposta é 422 com o código "DADOS_INVALIDOS"

  @api
  Cenário: CEP com menos de 8 dígitos é rejeitado
    Quando confirmo um pedido com o CEP "0131010"
    Então a resposta é 422 com o código "DADOS_INVALIDOS"

  @api
  Cenário: O mesmo produto repetido na lista de itens é rejeitado
    Quando envio "Camiseta Essencial" (P001) duas vezes na lista de itens
    Então a resposta é 422 com o código "ITEM_DUPLICADO"

  @api
  Cenário: Corpo da requisição com JSON inválido
    Quando envio o corpo "{abc" para o cálculo do carrinho
    Então a resposta é 400 com o código "JSON_INVALIDO"

  @nao-executado
  Cenário: E-mail em formato inválido é rejeitado
    Quando confirmo um pedido com o e-mail "maria@exemplo"
    Então a resposta é 422 com o código "DADOS_INVALIDOS"
