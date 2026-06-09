# Proteo Alerts — API de Alertas de Monitoramento

API REST em Ruby on Rails para gerenciamento de alertas de monitoramento
(débito, crédito, PEP e sanção), com regras de negócio em camada de domínio,
tratamento de erros consistente e cobertura de testes com RSpec.

## Stack

- Ruby 3.3
- Rails 7.2 (modo `--api`)
- PostgreSQL 16 (via Docker)
- RSpec + FactoryBot + shoulda-matchers

## Como rodar o projeto

Pré-requisitos: Ruby 3.3, Bundler e Docker (com Docker Compose).

```bash
# 1. Instalar as dependências
bundle install

# 2. Subir o PostgreSQL (container)
docker compose up -d

# 3. Criar e migrar o banco
bin/rails db:create db:migrate

# 4. Subir o servidor (porta 3000)
bin/rails server
```

O banco roda em container exposto na porta **5433** do host (para não
conflitar com instalações locais na 5432). As credenciais têm defaults
para desenvolvimento e podem ser sobrescritas por variáveis de ambiente:
`DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USER`, `DATABASE_PASSWORD`.

## Como rodar os testes

```bash
# garanta que o banco está no ar (docker compose up -d)
bundle exec rspec
```

São 60 exemplos cobrindo models, services (camada de domínio) e requests
(todos os endpoints, incluindo os caminhos de erro).

## Endpoints

| Método | Rota | Descrição |
|--------|------|-----------|
| POST   | `/people` | Cria uma pessoa |
| POST   | `/monitoring_alerts` | Cria um alerta (nasce `pending`) |
| GET    | `/monitoring_alerts` | Lista com filtros, ordenação e paginação |
| PATCH  | `/monitoring_alerts/:id/approve` | Aprova (só se `pending`) |
| PATCH  | `/monitoring_alerts/:id/reject` | Rejeita (só se `pending`) |

### Exemplos

```bash
# Criar pessoa
curl -X POST http://localhost:3000/people \
  -H "Content-Type: application/json" \
  -d '{"person":{"name":"Ana","document":"12345678901"}}'

# Criar alerta financeiro
curl -X POST http://localhost:3000/monitoring_alerts \
  -H "Content-Type: application/json" \
  -d '{"monitoring_alert":{"person_id":1,"kind":"debit","amount":150.5,"reference_at":"2026-01-01T10:00:00Z"}}'

# Listar com filtro, ordenação e paginação
curl "http://localhost:3000/monitoring_alerts?status=pending&kind=debit&order=desc&page=1&per_page=20"

# Aprovar / rejeitar
curl -X PATCH http://localhost:3000/monitoring_alerts/1/approve
curl -X PATCH http://localhost:3000/monitoring_alerts/1/reject
```

### Parâmetros da listagem

- `status`: `pending` | `approved` | `rejected`
- `kind`: `debit` | `credit` | `pep` | `sanction`
- `order`: `asc` | `desc` (por `reference_at`; default `desc`)
- `page` (default 1), `per_page` (default 20, máx. 100)

A resposta inclui metadados de paginação:

```json
{
  "data": [ ... ],
  "meta": { "page": 1, "per_page": 20, "total_count": 42, "total_pages": 3 }
}
```

### Formato de erro

Todos os erros seguem o mesmo formato, com status HTTP adequado
(`422` para validação/regra de negócio, `404` para registro inexistente):

```json
{ "errors": ["Valor deve ser maior que 0"] }
```

## Regras de negócio

- `reference_at` não pode estar no futuro.
- Para `kind` financeiro (`debit`/`credit`), `amount` é obrigatório e maior que zero.
- Para `kind` não financeiro (`pep`/`sanction`), `amount` é dispensável.
- Aprovar/rejeitar só é permitido quando o alerta está `pending`.
- `document` da pessoa é único.

## Decisões técnicas

- **Camada de domínio com Service Objects (POROs).** Cada operação de
  negócio (`CreatePerson`, `CreateMonitoringAlert`, `ApproveAlert`,
  `RejectAlert`) é um service que retorna um objeto `Result`
  (sucesso/falha + valor + mensagens). Os controllers ficam finos: apenas
  traduzem o `Result` em resposta HTTP. Optei por POROs em vez de
  dry-monads/Trailblazer pela simplicidade adequada ao escopo.

- **Transição de estado fora das validações do model.** Aprovar/rejeitar
  é uma regra de transição, não uma validação de persistência. Por isso
  vive nos services `ApproveAlert`/`RejectAlert`, que retornam falha de
  negócio (HTTP 422) ao tentar transicionar um alerta não-`pending` —
  em vez de um 200 silencioso ou uma exception.

- **Listagem como query object.** `ListMonitoringAlerts` monta a relation
  (filtros + ordenação) reaproveitando scopes do model. A paginação fica
  no controller, pois `page`/`per_page` são conceitos de transporte HTTP.

- **Enums com `prefix: true`.** Evita colisão entre métodos de `kind` e
  `status` e deixa explícito o domínio (`status_pending?`, `kind_debit?`).

- **Tratamento de erro centralizado.** `rescue_from` no
  `ApplicationController` padroniza `RecordNotFound` (404) e
  `ParameterMissing` (422) num formato único `{ "errors": [...] }`.

- **Unicidade de `document` no banco e no model.** Índice único no
  PostgreSQL garante a integridade mesmo sob concorrência; a validação no
  model fornece a mensagem amigável no fluxo normal.

- **`status` não é aceito na criação.** Todo alerta nasce `pending` e só
  muda via endpoints de transição — evita criar um alerta já aprovado
  burlando a regra de negócio.

- **Localização pt-BR.** Mensagens de validação e de erro em português,
  coerentes com o domínio.

## Trade-offs conhecidos

- **Paginação manual (limit/offset)** em vez de uma gem (kaminari/pagy):
  menos dependências e controle total para o escopo. Em volumes muito
  grandes, _cursor pagination_ seria mais eficiente que offset.

- **Filtros inválidos são ignorados** (ex.: `status=foo` retorna a lista
  sem aplicar o filtro) em vez de retornar 422. Escolha por robustez e
  simplicidade; uma versão mais estrita poderia validar e rejeitar.

- **Sem autenticação/autorização.** Fora do escopo do teste; em produção
  haveria autenticação (ex.: JWT) e escopo de acesso por usuário.

- **Sem versionamento de API nem serializers dedicados.** As respostas
  usam o JSON padrão do Rails. Em um projeto maior, eu adicionaria
  namespace `/api/v1` e serializers (ex.: `ActiveModel::Serializer`/`jsonapi`).
