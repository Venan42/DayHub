# DayHub

> ⚠️ **Disclaimer:** este projeto é desenvolvido majoritariamente com o auxílio de ferramentas de Inteligência Artificial (assistentes de código, geração e revisão de trechos). Ele tem propósito **exclusivamente pessoal e educacional**, uma forma de praticar tecnologias com as quais eu tinha pouca afinidade, como Flutter, Litestar, MongoDB e Docker. **Não é destinado a uso em produção** 

## Ideia

Uma plataforma pessoal para organizar, inicialmente, três áreas do dia a dia:

- **Finanças** — controle de transações e categorias.
- **Mídia** — armazenamento e visualização de arquivos.
- **Tarefas** — checklist simples de afazeres.

O projeto adota princípios de **Clean Architecture** tanto no backend quanto no frontend, priorizando modularidade e desacoplamento entre camadas — não porque a escala do projeto exige isso, mas porque o objetivo é justamente praticar esses padrões.

## Stack

### Backend
- **Linguagem:** Python 3.13+
- **Gerenciador de pacotes:** `uv` (ambiente virtual em `.venv`)
- **Framework Web (ASGI):** Litestar
- **Banco de Dados & ODM:** MongoDB + Beanie (ODM assíncrono baseado em Pydantic)
- **Driver assíncrono:** Motor
- **Validação de dados:** Pydantic
- **Segurança:** Passlib (Bcrypt) + python-jose (JWT)
- **Testes:** Pytest + pytest-asyncio

### Frontend
- **Framework:** Flutter (Android, Windows, Linux e Web)
- **Gerenciamento de estado:** Flutter Riverpod (API `Notifier`/`NotifierProvider`)
- **Roteamento:** GoRouter (com `refreshListenable` para rotas protegidas)
- **Cliente HTTP:** Dio
- **Armazenamento seguro:** `flutter_secure_storage` (persistência do JWT e da preferência de tema)
- **Tipografia:** Google Fonts (Orbitron + JetBrains Mono)

## Status atual

O módulo de **autenticação** (registro, login, `/auth/me`, proteção de rotas) está funcional ponta a ponta, incluindo:

- Tratamento de erros estruturado no frontend (`core/errors/`), com mapeamento de erros de validação por campo (400), credenciais inválidas (401), conflito de e-mail (409), falhas de rede e erro de servidor.
- Tema claro/escuro persistente, com identidade visual cyberpunk (preto + amarelo) no modo escuro.

Os módulos de **finanças**, **mídia** e **tarefas** ainda não têm implementação — apenas a estrutura de pastas reservada (`.gitkeep`).

Documentação detalhada de cada parte está disponível em [`docs/`](./docs):

- [`docs/backend.md`](./docs/backend.md) — arquitetura da API, módulos, autenticação e como rodar os testes.
- [`docs/frontend.md`](./docs/frontend.md) — arquitetura do app Flutter, gerenciamento de estado, tema e estrutura de pastas.
- [`docs/auth.md`](./docs/auth.md) — fluxo completo de autenticação (registro, login, refresh de rota, tratamento de erros).

## Estrutura do projeto

```text
DayHub/
├── docs/                           # Documentação detalhada (backend, frontend, auth)
├── backend/
│   ├── app/
│   │   ├── config.py               # Configurações e variáveis de ambiente
│   │   ├── main.py                 # Entry point Litestar + lifespan (conexão MongoDB)
│   │   ├── core/
│   │   │   ├── database.py
│   │   │   └── security.py         # Hash de senha e utilitários JWT
│   │   └── modules/
│   │       ├── auth/                # Autenticação (único módulo implementado)
│   │       │   ├── controllers.py
│   │       │   ├── dependencies.py
│   │       │   ├── models.py
│   │       │   ├── schemas.py
│   │       │   └── services.py
│   │       ├── finance/             # Reservado
│   │       ├── media/               # Reservado
│   │       └── tasks/               # Reservado
│   ├── tests/
│   │   └── auth/                    # Testes unitários e de integração
│   ├── docker-compose.yml           # MongoDB de desenvolvimento
│   ├── docker-compose.test.yml      # MongoDB de testes (porta 27018)
│   ├── pyproject.toml
│   └── .env.example
└── frontend/
    └── lib/
        ├── app.dart                 # MaterialApp.router + tema
        ├── main.dart
        ├── core/
        │   ├── errors/              # Failure + ErrorMapper (tratamento de erros da API)
        │   ├── network/
        │   ├── providers/           # Dio, SecureStorage
        │   ├── router/              # GoRouter + guarda de rotas
        │   ├── theme/               # AppColors, AppTheme, ThemeModeNotifier
        │   └── utils/
        ├── shared/
        │   └── widgets/             # CyberpunkBackground, GlowCard
        └── features/
            └── auth/
                ├── data/            # Datasources, models, repository impl
                ├── domain/          # Entities, repository interface
                └── presentation/    # Providers (Notifier), screens, widgets
```

## Como rodar o projeto

### Pré-requisitos

- Python 3.13+ e [`uv`](https://docs.astral.sh/uv/)
- Flutter SDK (3.44+) e Dart SDK (3.13+)
- Docker (recomendado) ou MongoDB instalado localmente

> **Atenção (Windows):** evite colocar o projeto em um caminho com acentos ou caracteres especiais (ex: `Programação`). Isso pode causar falhas de encoding em ferramentas como o `flutter analyze`. Prefira um caminho simples, como `C:\Dev\DayHub`.

### 1. Subir o MongoDB

Com Docker (recomendado):

```bash
cd backend
docker compose up -d
```

Isso sobe o MongoDB de desenvolvimento na porta `27017`, persistido em um volume Docker.

Se preferir um MongoDB instalado localmente, garanta que o serviço esteja rodando antes do próximo passo:

```powershell
# Windows
net start MongoDB
```

### 2. Configurar e rodar o backend

```bash
cd backend
uv venv
uv sync

# copie o arquivo de exemplo e ajuste se necessário
cp .env.example .env

uv run uvicorn app.main:app --reload
```

A API sobe em `http://127.0.0.1:8000`. Se aparecer um erro `ServerSelectionTimeoutError` no boot, o MongoDB não está acessível na porta configurada — confirme o passo 1 antes de tentar novamente.

Para rodar os testes automatizados:

```bash
# testes unitários (não precisam de banco)
uv run pytest tests/auth/test_controllers_auth.py tests/auth/test_services_auth.py tests/auth/test_dependencies_auth.py

# testes de integração (precisam do MongoDB de teste, porta 27018)
docker compose -f docker-compose.test.yml up -d
uv run pytest tests/auth/test_integration_auth.py
```

### 3. Configurar e rodar o frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome   # ou -d windows / -d linux / -d android
```

Por padrão, o app aponta para `http://127.0.0.1:8000` (definido em `lib/core/providers/core_providers.dart`). Se o backend estiver rodando em outro host/porta, ajuste esse valor.

### 4. Verificação rápida

```bash
cd frontend
flutter analyze     # deve retornar "No issues found!"
```

## Próximos passos

- Implementar os módulos de finanças, mídia e tarefas (backend e frontend).
- Expandir a documentação em `docs/` conforme novos módulos forem adicionados.