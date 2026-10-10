import { test, expect } from '@playwright/test';

test('API lista os 8 produtos documentados', async ({ request }) => {
  const resposta = await request.get('/api/produtos');
  expect(resposta.status()).toBe(200);
  const produtos = await resposta.json();
  expect(produtos).toHaveLength(8);
});

test('Home da loja carrega', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Verzel/i);
});