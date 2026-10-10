# language: pt
# Legenda das tags: ver cupom-desconto.feature

@VZS-142 @frete
Funcionalidade: Frete grátis
  Como cliente da Verzel Store
  Quero ganhar frete grátis em compras maiores
  Para pagar menos nas minhas compras

  Contexto:
    Dado que o carrinho está vazio

  @CA07 @api @automatizado
  Cenário: Subtotal abaixo de R$ 200,00 cobra frete e informa o valor faltante
    Dado que o carrinho contém 1 "Calça Jeans Slim" (P002) e 1 "Camiseta Essencial" (P001)
    Então o subtotal é de R$ 199,80
    E o frete é de R$ 19,90
    E o valor faltante para o frete grátis é de R$ 0,20
    E o total é de R$ 219,70

  @CA06 @api @ui @automatizado @bug-001
  Cenário: Subtotal de exatamente R$ 200,00 tem frete grátis (limite inclusivo)
    Dado que o carrinho contém 2 unidades de "Mochila Urbana 20L" (P005, R$ 100,00)
    Então o subtotal é de R$ 200,00
    E o frete é de R$ 0,00
    E o carrinho indica frete grátis
    E o total é de R$ 200,00
    # FALHA: frete de R$ 19,90 e total de R$ 219,90 (BUG-001)

  @CA06 @ui @bug-001
  Cenário: Limite de R$ 200,00 alcançado com outro produto
    Dado que o carrinho contém 4 unidades de "Garrafa Térmica 750ml" (P008, R$ 50,00)
    Então o frete é de R$ 0,00
    E o total é de R$ 200,00
    # FALHA: frete de R$ 19,90 e total de R$ 219,90 (BUG-001)

  @CA06 @api
  Cenário: Subtotal acima de R$ 200,00 tem frete grátis
    Dado que o carrinho contém 5 unidades de "Camiseta Essencial" (P001)
    Então o subtotal é de R$ 299,50
    E o frete é de R$ 0,00

  @CA08 @api @automatizado @bug-001
  Cenário: Frete grátis considera o subtotal antes do cupom (limite exato)
    Dado que o carrinho contém 2 unidades de "Mochila Urbana 20L" (P005)
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de R$ 20,00
    E o frete é de R$ 0,00
    E o total é de R$ 180,00
    # FALHA: frete de R$ 19,90 e total de R$ 199,90 (BUG-001)

  @CA08 @api
  Cenário: Cupom não concede frete grátis a quem está abaixo do limite
    Dado que o carrinho contém 1 "Calça Jeans Slim" (P002) e 1 "Camiseta Essencial" (P001)
    Quando aplico o cupom "BEMVINDO10"
    Então o desconto é de R$ 19,98
    E o frete é de R$ 19,90
    E o total é de R$ 199,72

  @CA06 @nao-executado
  Cenário: Conquistar frete grátis ao aumentar a quantidade
    Dado que o carrinho contém 1 unidade de "Tênis Casual Urbano" (P003, R$ 189,90)
    Quando adiciono 1 unidade de "Boné Aba Curva" (P004)
    Então o frete passa de R$ 19,90 para R$ 0,00
    E a mensagem de valor faltante desaparece

  @CA07 @nao-executado
  Cenário: Perder o frete grátis ao reduzir a quantidade
    Dado que o carrinho contém 3 unidades de "Mochila Urbana 20L" (frete grátis)
    Quando reduzo a quantidade para 1
    Então o frete volta a ser R$ 19,90
    E o carrinho informa quanto falta para o frete grátis

  @formula @api
  Cenário: Total é subtotal menos desconto mais frete
    Dado que o carrinho contém 1 unidade de "Mochila Urbana 20L" (P005)
    Quando aplico o cupom "BEMVINDO10"
    Então o total é igual a R$ 100,00 - R$ 10,00 + R$ 19,90
