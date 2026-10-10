# Verzel Store: teste técnico de QA Júnior

Validação da entrega **VZS-142 (cupom de desconto e frete grátis)** da Verzel Store, com cenários em Gherkin, execução manual e exploratória (API e interface), report de bugs, evidências e automação com Playwright.

- Loja: https://verzel-store.qa-test-verzel-store.workers.dev/
- Documentação da entrega: https://verzel-store.qa-test-verzel-store.workers.dev/documentacao

## Resultado em resumo

| | |
|---|---|
| Respostas de API analisadas | 25 (22 passaram, 3 falharam) |
| Bugs encontrados | **2** |
| Testes automatizados (Playwright) | 8 testes de API |

| Bug | Resumo | Severidade |
|---|---|---|
| [BUG-001](docs/03-bugs/BUG-001.md) | Frete de R$ 19,90 é cobrado quando o subtotal é exatamente R$ 200,00 (interface e API). Contradiz o CA06 ("inclusive") | Alta |
| [BUG-002](docs/03-bugs/BUG-002.md) | A API aceita mais de 5 unidades por produto; a validação só existe na interface (CA10) | Média |

## Onde encontrar cada entrega

| Entrega pedida | Onde está |
|---|---|
| Cenários de teste em Gherkin | [`docs/01-cenarios/`](docs/01-cenarios) (3 arquivos `.feature`) |
| Execução manual e exploratória, com o resultado de cada caso | [`docs/02-execucao/api.http`](docs/02-execucao/api.http) (requisições) e a tabela de resultados em [`docs/04-evidencias/evidencias.md`](docs/04-evidencias/evidencias.md) |
| Report de bugs | [`docs/03-bugs/`](docs/03-bugs) |
| Documento com evidências | [`docs/04-evidencias/evidencias.md`](docs/04-evidencias/evidencias.md) (prints em `docs/04-evidencias/`, respostas brutas da API em `docs/04-evidencias/api-raw/`) |
| Automação com Playwright | [`tests/`](tests) |
| Interpretações das ambiguidades | [`docs/premissas.md`](docs/premissas.md) |

## Como rodar a automação

**Pré-requisitos:** [Node.js](https://nodejs.org/) 20 ou superior e Git.

```bash
git clone https://github.com/agnaldopeterson/verzel-qa-test.git
cd verzel-qa-test
npm install
npx playwright install
```

**Executar todos os testes:**

```bash
npx playwright test
```

**Ver o relatório HTML:**

```bash
npx playwright show-report
```

### Testes que cobrem bugs conhecidos

Três testes verificam o comportamento **correto** documentado e, hoje, falham por causa dos bugs. Eles estão marcados com `test.fail()` ("falha esperada"):

| Teste | Bug |
|---|---|
| CA06: subtotal de exatamente R$ 200,00 tem frete grátis | BUG-001 |
| CA08: o mesmo limite com cupom | BUG-001 |
| CA10: 6 unidades são rejeitadas com 422 | BUG-002 |

Por isso, no modo normal a execução termina com todos os testes **aprovados**, e esses três aparecem com o símbolo ✘ na lista mas contam como passados (falha esperada). **Quando o bug for corrigido**, o Playwright avisa que o teste passou inesperadamente, sinal de que a marcação deve ser removida.

Para ver as **falhas reais** (valor esperado versus recebido):

```powershell
# PowerShell (Windows)
$env:SHOW_BUGS=1; npx playwright test
```

```bash
# Bash / Mac / Linux
SHOW_BUGS=1 npx playwright test
```

A URL da loja pode ser trocada com `BASE_URL=<url> npx playwright test`.

### Cenários automatizados

| Teste | Critério | Resultado esperado hoje |
|---|---|---|
| BEMVINDO10 aplica 10% sobre o subtotal | CA01 | passa |
| Código ignora caixa e espaços nas pontas | CA02 | passa |
| Cupom expirado não aplica desconto | CA04 | passa |
| Subtotal de R$ 199,80 cobra frete e informa o faltante | CA07 | passa |
| Subtotal de R$ 200,00 tem frete grátis | CA06 | falha (BUG-001) |
| Limite de R$ 200,00 também com cupom | CA08 | falha (BUG-001) |
| 5 unidades são aceitas | CA10 | passa |
| 6 unidades são rejeitadas com 422 | CA10 | falha (BUG-002) |

Existe ainda o teste de sanidade em `tests/sanidade.spec.ts` (catálogo com 8 produtos e home da loja carregando).

## Como foi a execução manual

- **API:** o arquivo `docs/02-execucao/api.http` reúne 24 casos escolhidos por risco (valores-limite, regras de negócio e validações), executados com a extensão **REST Client** do VS Code. As 25 respostas salvas em `docs/04-evidencias/api-raw/` correspondem a esses casos, com o CA02 executado em duas variações e uma repetição de pedido com cupom expirado (P04).
- **Interface:** teste exploratório do carrinho com cupom, frete e limite de quantidade, com prints em `docs/04-evidencias/`.
- **Ambiente:** cada pessoa tem seu próprio carrinho; testes de carga, estresse e segurança ficaram de fora conforme o enunciado.

## Limitações

- A automação cobre **API**. Nenhum teste de interface foi automatizado.
- Não executei `POST /api/pedidos` com 6 unidades nem com subtotal de R$ 200,00, então não sei se os bugs também atingem a confirmação do pedido.
- Os cenários marcados com `@nao-executado` nos `.feature` foram levantados a partir da documentação, mas não executados.

## Estrutura do repositório

```
verzel-qa-test/
├── README.md
├── playwright.config.ts
├── tests/
│   ├── api.spec.ts            # automação de API (8 testes)
│   └── sanidade.spec.ts       # teste de sanidade
└── docs/
    ├── premissas.md
    ├── 01-cenarios/           # Gherkin (.feature)
    ├── 02-execucao/api.http   # requisições da execução manual
    ├── 03-bugs/               # BUG-001.md e BUG-002.md
    └── 04-evidencias/         # evidencias.md, prints e respostas brutas
```

## Uso de IA

Usei IA (Claude) como apoio ao longo do teste: para levantar cenários a partir da documentação, estruturar o repositório e redigir os rascunhos dos relatórios e do código de automação. A execução dos testes, a leitura dos resultados e a confirmação dos bugs foram feitas por mim, e os textos foram revisados antes da entrega.
