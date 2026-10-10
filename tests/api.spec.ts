import { test, expect, APIRequestContext } from '@playwright/test';

/**
 * Testes automatizados da API da Verzel Store (card VZS-142).
 *
 * Bugs conhecidos (ver docs/03-bugs):
 *  - BUG-001: frete de R$ 19,90 cobrado quando o subtotal é exatamente R$ 200,00
 *  - BUG-002: API aceita mais de 5 unidades por produto
 *
 * Os testes que cobrem esses bugs estão marcados como "falha esperada"
 * (test.fail). Assim a suíte fica verde enquanto o bug existir, e quando ele
 * for corrigido o Playwright avisa que o teste passou inesperadamente.
 *
 * Para ver essas falhas de verdade:
 *   PowerShell:  $env:SHOW_BUGS=1; npx playwright test
 *   Bash/Mac:    SHOW_BUGS=1 npx playwright test
 */

type Item = { produtoId: string; quantidade: number };

function calcular(request: APIRequestContext, itens: Item[], cupom?: string) {
  const data = cupom === undefined ? { itens } : { itens, cupom };
  return request.post('/api/carrinho/calcular', { data });
}

function bugConhecido(bug: string) {
  test.fail(!process.env.SHOW_BUGS, `Bug conhecido: ${bug}`);
}

test.describe('Cupom de desconto (CA01 a CA04)', () => {
  test('CA01: BEMVINDO10 aplica 10% sobre o subtotal', async ({ request }) => {
    const r = await calcular(request, [{ produtoId: 'P005', quantidade: 1 }], 'BEMVINDO10');
    expect(r.status()).toBe(200);
    const body = await r.json();
    expect(body.subtotal).toBe(100);
    expect(body.desconto).toBe(10);
    expect(body.frete).toBe(19.9);
    expect(body.total).toBe(109.9); // subtotal - desconto + frete
    expect(body.cupom).toMatchObject({ codigo: 'BEMVINDO10', aplicado: true });
  });

  test('CA02: código ignora maiúsculas/minúsculas e espaços nas pontas', async ({ request }) => {
    const r = await calcular(request, [{ produtoId: 'P005', quantidade: 1 }], '  bemvindo10  ');
    expect(r.status()).toBe(200);
    const body = await r.json();
    expect(body.desconto).toBe(10);
    expect(body.cupom.aplicado).toBe(true);
  });

  test('CA04: cupom expirado não aplica desconto', async ({ request }) => {
    const r = await calcular(request, [{ produtoId: 'P005', quantidade: 1 }], 'VERAO2026');
    expect(r.status()).toBe(200);
    const body = await r.json();
    expect(body.desconto).toBe(0);
    expect(body.total).toBe(119.9);
    expect(body.cupom).toMatchObject({ aplicado: false, mensagem: 'Cupom expirado.' });
  });
});

test.describe('Frete grátis (CA06 a CA08)', () => {
  test('CA07: subtotal de R$ 199,80 cobra frete e informa o valor faltante', async ({ request }) => {
    const r = await calcular(request, [
      { produtoId: 'P002', quantidade: 1 },
      { produtoId: 'P001', quantidade: 1 },
    ]);
    const body = await r.json();
    expect(body.subtotal).toBe(199.8);
    expect(body.frete).toBe(19.9);
    expect(body.freteGratis).toBe(false);
    expect(body.valorFaltanteFreteGratis).toBe(0.2);
    expect(body.total).toBe(219.7);
  });

  test('CA06: subtotal de exatamente R$ 200,00 tem frete grátis (inclusive)', async ({ request }) => {
    bugConhecido('BUG-001 (docs/03-bugs/BUG-001.md)');
    const r = await calcular(request, [{ produtoId: 'P005', quantidade: 2 }]);
    const body = await r.json();
    expect(body.subtotal).toBe(200);
    expect(body.frete).toBe(0);
    expect(body.freteGratis).toBe(true);
    expect(body.total).toBe(200);
  });

  test('CA08: frete grátis no limite exato também vale com cupom (base é o subtotal antes do desconto)', async ({ request }) => {
    bugConhecido('BUG-001 (docs/03-bugs/BUG-001.md)');
    const r = await calcular(request, [{ produtoId: 'P005', quantidade: 2 }], 'BEMVINDO10');
    const body = await r.json();
    expect(body.desconto).toBe(20);
    expect(body.frete).toBe(0);
    expect(body.total).toBe(180);
  });
});

test.describe('Limite de 5 unidades por produto (CA10)', () => {
  test('CA10: 5 unidades de um produto são aceitas', async ({ request }) => {
    const r = await calcular(request, [{ produtoId: 'P001', quantidade: 5 }]);
    expect(r.status()).toBe(200);
    const body = await r.json();
    expect(body.subtotal).toBe(299.5);
    expect(body.freteGratis).toBe(true);
  });

  test('CA10: 6 unidades são rejeitadas com 422 QUANTIDADE_MAXIMA_EXCEDIDA', async ({ request }) => {
    bugConhecido('BUG-002 (docs/03-bugs/BUG-002.md)');
    const r = await calcular(request, [{ produtoId: 'P001', quantidade: 6 }]);
    expect(r.status()).toBe(422);
    const body = await r.json();
    expect(body.erro.codigo).toBe('QUANTIDADE_MAXIMA_EXCEDIDA');
  });
});
