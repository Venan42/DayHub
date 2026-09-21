# Backend

Visão técnica do backend. Para instruções de setup e execução, veja o [README](../README.md).

## Arquitetura

O backend segue uma variação simples de Clean Architecture, organizada por módulo de domínio (`app/modules/<nome>`), não por tipo de arquivo. Cada módulo é isolado e, futuramente, deve conseguir ser adicionado ou removido sem afetar os demais.

Dentro de um módulo, o fluxo de uma requisição passa por três camadas:

```
Controller → Service → Model (Beanie Document)
```

- **`controllers.py`** — define as rotas HTTP (Litestar `Controller`), recebe DTOs de entrada e devolve DTOs de saída. Não contém lógica de negócio.
- **`services.py`** — contém as regras de negócio (ex: verificar se e-mail já existe, gerar hash de senha, emitir token). É a camada testada com mocks nos testes unitários.
- **`models.py`** — documentos Beanie, que mapeiam diretamente para coleções do MongoDB.
- **`schemas.py`** — DTOs Pydantic de entrada/saída, desacoplados dos models (o cliente nunca recebe o `Document` diretamente).
- **`dependencies.py`** — providers injetados via `Provide()` do Litestar (ex: `provide_current_user`, que decodifica o JWT e busca o usuário).

Essa separação existe principalmente para treinar o padrão, dado o porte pessoal do projeto — não é uma exigência de escala.

## Autenticação

Detalhes do fluxo completo estão em [`modules/auth.md`](./modules/auth.md). Resumo técnico:

- Senhas com hash via Bcrypt (`passlib`).
- Tokens JWT (`python-jose`), com `sub` = ID do usuário e expiração configurável via `.env`.
- `provide_current_user` é injetado como dependency em rotas protegidas e lança `401` se o header `Authorization` estiver ausente, inválido ou expirado.

## Banco de dados

MongoDB + [Beanie](https://beanie-odm.dev/) (ODM assíncrono sobre Pydantic). A conexão é inicializada no `lifespan` da aplicação (`app/main.py`), junto com o registro dos `document_models`.

Existem **dois bancos separados**, ambos via Docker:

| Ambiente | Porta | Compose |
|---|---|---|
| Desenvolvimento | `27017` | `docker-compose.yml` |
| Testes | `27018` | `docker-compose.test.yml` |

Isso evita que rodar a suíte de testes de integração apague dados que você esteja usando manualmente durante o desenvolvimento.

## Testes

```bash
# Unitários (mocks, sem banco)
uv run pytest tests/auth/test_controllers_auth.py tests/auth/test_services_auth.py tests/auth/test_dependencies_auth.py

# Integração (precisa do MongoDB de teste rodando)
docker compose -f docker-compose.test.yml up -d
uv run pytest tests/auth/test_integration_auth.py
```

Os testes unitários usam `unittest.mock` (`AsyncMock`, `patch`) para isolar a camada de service/controller do banco real. Os testes de integração validam a persistência de fato no MongoDB.

## Erros retornados pela API

Para erros de validação (status `400`), o Litestar retorna um corpo no formato:

```json
{
  "status_code": 400,
  "detail": "Validation failed for POST /auth/register",
  "extra": [
    {"key": "password", "message": "String should have at least 6 characters"}
  ]
}
```

O campo `extra` é consumido pelo frontend (`ErrorMapper`) para exibir o erro no campo específico do formulário — ver [`frontend.md`](./frontend.md).
