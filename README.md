# 🛍️ E-commerce Backend com Supabase

Backend para sistema de e-commerce desenvolvido como **teste técnico (Supabase)**, com foco em **clientes, produtos, pedidos e automações**.  

Este projeto demonstra boas práticas de **estrutura de banco, RLS (Row-Level Security), funções SQL, Edge Functions e documentação com Swagger**.

---

## 🎯 Objetivo do Projeto

Implementar um backend completo em Supabase para um e-commerce, atendendo aos seguintes pontos:

1. Criação de tabelas para **clientes, produtos, pedidos e itens de pedido**.  
2. **RLS (Row-Level Security)** para garantir acesso seguro aos dados.  
3. Funções SQL para automação (**recalcular total do pedido, atualizar status**).  
4. Views para consultas otimizadas (ex.: resumo de pedidos).  
5. **Edge Functions** para envio de confirmação por e-mail e exportação de pedidos em CSV.  

---

## 🚀 Funcionalidades

- 🔐 **Autenticação e Segurança**
  - Políticas de RLS configuradas
  - Uso de Service Role para operações administrativas

- 📦 **Gerenciamento de Produtos**
  - CRUD completo
  - Controle de estoque
  - SKU, preço e descrição

- 👥 **Gerenciamento de Clientes**
  - CRUD completo
  - Histórico de pedidos
  - Dados protegidos via RLS

- 🛒 **Pedidos**
  - Criação com validação de estoque
  - Cálculo automático de total
  - Itens vinculados a produtos
  - Exportação em CSV (Edge Function)

- 💳 **Pagamentos**
  - Métodos disponíveis: Cartão de Crédito e PIX  

---

## 🛠️ Pré-requisitos

- Node.js v18+  
- Conta gratuita no [Supabase](https://supabase.com/)  
- Git  

---

## ⚙️ Instalação e Uso

# 🛍️ E-commerce Backend com Supabase

Backend para sistema de e-commerce (exemplo/poC) usando Supabase + Express + TypeScript.

O projeto demonstra o uso de RLS (Row-Level Security), funções SQL (RPC), views, Edge Functions e documentação OpenAPI (Swagger).

---

## 🎯 Resumo

- Tabelas principais: `customers`, `products`, `orders`, `order_items` e uma view para resumo de pedidos.
- RLS aplicada para proteger dados por usuário; existe um client `supabaseAdmin` (service role) para operações administrativas.
- Endpoints documentados em OpenAPI e disponíveis em `/docs` via Swagger UI.

---

## 🛠️ Pré-requisitos

- Node.js v18+ (recomendado)
- Uma instância Supabase (projeto) com URL e chaves
- Git

---

## ⚙️ Variáveis de ambiente

Crie um arquivo `.env` na raiz com pelo menos as variáveis abaixo:

- `SUPABASE_URL` — URL do seu projeto Supabase
- `SUPABASE_ANON_KEY` — public anon key
- `SUPABASE_SERVICE_ROLE_KEY` — (opcional, recomendado para desenvolvimento) service_role key para operações que precisam burlar RLS
- `PORT` — porta do servidor (opcional, default 3000)

Exemplo `.env`:

```env
SUPABASE_URL=https://xyzcompany.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...anon...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...service_role...
PORT=3000
```

> Segurança: NUNCA comite `SUPABASE_SERVICE_ROLE_KEY` em repositórios públicos. Use secret manager / CI variables para deploy.

---

## 📦 Instalação

```bash
git clone <url-do-repo>
cd ecommerce-supabase-ts
npm install
```

## 🚀 Executando localmente (desenvolvimento)

- Rodar em modo dev (usa `ts-node`):

```bash
npm run dev
```

- A API será iniciada em `http://localhost:3000` (ou `PORT` configurada). A UI do Swagger estará em:

```
http://localhost:3000/docs
```

## 🧪 Testar conexão com o banco

Tem um script útil para testar a conexão com o Supabase (usando `ts-node`):

```bash
npm run test:db
```

---

## 🧭 Rotas principais e comportamento RLS

- `GET /products` — lista produtos (público)
- `POST /orders` — cria pedido (aplica RLS na inserção, se configurado)
- `POST /orders/:id/approve` — endpoint server-side para aprovar um pedido (usa o client conectado ao request)
- `GET /customers` — lista clientes (pode usar `supabaseAdmin` se `?rls=false`)

Swagger (OpenAPI) descreve todos os endpoints em `openapi.json` e está exposto em `/docs`.

RLS toggle (somente para desenvolvimento/ops):

- Você pode forçar a aplicação a usar o client de service role (burlar RLS) por requisição adicionando o query param `?rls=false` ou o header `x-rls-enabled: false`.
- Exemplo com curl (usar com cuidado):

```bash
# Usando query
curl "http://localhost:3000/customers?rls=false"

# Usando header
curl -H "x-rls-enabled: false" http://localhost:3000/customers
```

Aviso: permitir `?rls=false` em produção é um risco de segurança. Recomendamos:

- Proteger essa opção via uma flag de ambiente (por ex.: só habilitar RLS bypass quando `NODE_ENV=development` ou quando uma variável `ALLOW_RLS_BYPASS=true` estiver setada).

---

## ✅ Endpoint: Aprovar pedido

Rota: `POST /orders/:id/approve`

- Comportamento: verifica se o pedido existe, atualiza `status` para `approved` e tenta executar a função SQL `recalc_order_total` (se existir).
- Uso típico (curl):

```bash
curl -X POST http://localhost:3000/orders/<ORDER_ID>/approve
```

Se seu projeto exigir permissão especial para aprovar, chame essa rota usando `?rls=false` ou faça-a ser chamada a partir de um processo de backend que tenha `SUPABASE_SERVICE_ROLE_KEY` configurado.

---

## 📄 Documentação / OpenAPI

- O arquivo `openapi.json` contém a especificação da API e é consumido pelo Swagger UI.
- Após iniciar o servidor, abra `http://localhost:3000/docs` para inspecionar os endpoints e testar via UI.

---

## 🧩 Edge Functions (automations)

As funções em `supabase/functions/` (ex.: `export-order-csv`, `send-order-confirmation`) são projetadas para serem deployadas como Edge Functions do Supabase.

Para deploy, use o CLI do Supabase (exemplo):

```bash
# instalar supabase CLI e logar
supabase functions deploy <nome-da-funcao>
```

> O `package.json` contém uma dica (`functions:deploy`) — o deploy real é feito com o `supabase` CLI.

---

## 🧰 Dicas para produção

- Nunca exponha a `SUPABASE_SERVICE_ROLE_KEY` para o cliente.
- Habilite RLS e escreva políticas claras. O servidor só deve burlar RLS em tarefas internas.
- Configure variáveis de ambiente no provedor de hospedagem (Vercel, Fly, Heroku, etc.) e use o `supabase` client server-side com a service role apenas em processos de backend.

---

## 🧪 Testes e Qualidade

- Atualmente não há testes automatizados no repositório. Sugestões:
  - Adicionar testes de integração para `POST /orders` e `POST /orders/:id/approve`.
  - Adicionar lint / format (ESLint / Prettier) e rodar `npx tsc --noEmit` em CI.

---

## Contribuindo

- Pull requests são bem-vindos. Abra uma issue antes de mudanças grandes de arquitetura.

---

## Licença

Projeto com finalidade de exemplo / PoC. Ajuste a licença conforme necessário.
