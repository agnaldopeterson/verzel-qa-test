# language: pt
# Legenda das tags de execução:
#   @api            executado manualmente via API (docs/02-execucao/api.http)
#   @ui             executado manualmente pela interface
#   @nao-executado  levantado a partir da documentação, ainda não executado
#   @automatizado   coberto por teste Playwright (tests/api.spec.ts)
#   @bug-NNN        falhou e originou o bug indicado (docs/03-bugs)

@VZS-142 @cupom
Funcionalidade: Cupom de desconto
  Como cliente da Verzel Store
  Quero aplicar um cupom de desconto no carrinho
  Para pagar menos nas minhas compras

  Contexto:
    Dado que o carrinho está vazio

  @CA01 @api @automatizado
  Cenário: Aplicar o cupom BEMVINDO10 em um carrinho com frete cobrado
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005, R$ 100,00)
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de R$ 10,00
    E o frete é de R$ 19,90
    E o total é de R$ 109,90
    E a mensagem é "Cupom aplicado: 10% de desconto nos produtos."

  @CA01 @api
  Cenário: Desconto de 10% sobre o subtotal de vários produtos
    Dado que o carrinho contém 1 "Calça Jeans Slim" (P002) e 2 "Boné Aba Curva" (P004)
    Quando aplico o cupom "BEMVINDO10"
    Então o subtotal é de R$ 239,70
    E o desconto é de R$ 23,97
    E o frete é de R$ 0,00
    E o total é de R$ 215,73

  @CA02 @api @automatizado
  Esquema do Cenário: Código do cupom ignora maiúsculas, minúsculas e espaços nas pontas
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005)
    Quando aplico o cupom "<digitado>"
    Então o cupom é aplicado com desconto de R$ 10,00

    Exemplos:
      | digitado        |
      | bemvindo10      |
      |   BEMVINDO10    |

    @nao-executado
    Exemplos:
      | digitado        |
      | BemVindo10      |
      |   bemvindo10    |

  @CA02 @nao-executado
  Esquema do Cenário: Espaços no meio do código tornam o cupom inválido
    Quando aplico o cupom "<digitado>"
    Então vejo a mensagem "Cupom inválido."

    Exemplos:
      | digitado      |
      | BEM VINDO10   |
      | BEMVINDO 10   |

  @CA03 @api
  Cenário: Cupom inexistente
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005)
    Quando aplico o cupom "NAOEXISTE"
    Então vejo a mensagem "Cupom inválido."
    E o desconto é de R$ 0,00
    E o total é de R$ 119,90

  @CA04 @api @automatizado
  Cenário: Cupom fora da validade
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005)
    Quando aplico o cupom "VERAO2026"
    Então vejo a mensagem "Cupom expirado."
    E o desconto é de R$ 0,00
    E o total é de R$ 119,90

  @CA05 @api
  Cenário: A API não acumula dois cupons enviados juntos
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005)
    Quando envio os cupons "BEMVINDO10,VERAO2026" na mesma requisição
    Então nenhum desconto acumulado é aplicado

  @CA05 @nao-executado
  Cenário: Trocar de cupom exige remover o atual (interface)
    Dado que apliquei o cupom "BEMVINDO10"
    Quando tento aplicar outro cupom sem remover o atual
    Então apenas um cupom permanece aplicado
    Quando removo o cupom atual
    Então consigo aplicar outro cupom

  @CA03 @ui
  Cenário: Aplicar cupom sem digitar nada
    Dado que o carrinho contém 1 produto
    Quando clico em "Aplicar cupom" com o campo vazio
    Então vejo a mensagem "Informe um cupom."
    # Comportamento observado; a documentação não define este caso (ver premissas.md)

  @CA09 @api
  Cenário: O desconto não incide sobre o frete
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005, R$ 100,00)
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de R$ 10,00, e não de R$ 11,99
    E o total é de R$ 109,90

  @CA11 @api
  Cenário: Valores sem erro de arredondamento (ponto flutuante)
    Dado que o carrinho contém 3 unidades de "Camiseta Essencial" (P001, R$ 59,90)
    Então o subtotal é de R$ 179,70
    E o valor faltante para frete grátis é de R$ 20,30
    E nenhum valor tem mais de 2 casas decimais
