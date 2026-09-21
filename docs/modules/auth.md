# Módulo: Autenticação

Modulo de autenticação do sistema. Cobre registro, login, obtenção do usuário atual e proteção de rotas.

## Fluxo completo

```
1. Usuário preenche formulário (login ou registro)
2. Frontend valida campos localmente (obrigatórios)
3. AuthNotifier chama AuthRepository → AuthRemoteDataSource → API (Dio)
4. Backend valida (Pydantic) e processa (AuthService)
5a. Sucesso → token JWT + dados do usuário retornam ao frontend
5b. Erro → resposta HTTP com status + detail (+ extra, se for validação)
6. Token salvo em flutter_secure_storage
7. AuthState atualizado → GoRouter redireciona para /profile
```

## Backend

Endpoints (`app/modules/auth/controllers.py`):

| Rota | Método | Descrição |
|---|---|---|
| `/auth/register` | `POST` | Cria usuário, retorna token |
| `/auth/login` | `POST` | Valida credenciais, retorna token |
| `/auth/me` | `GET` | Retorna dados do usuário autenticado (requer `Authorization: Bearer <token>`) |

Regras principais (`services.py`):
- Registro falha com `400` se o e-mail já existir.
- Login falha com `401` se e-mail não existir ou senha não bater (mesma mensagem genérica nos dois casos, por segurança — não revela se o e-mail existe).
- Senha precisa ter no mínimo 6 caracteres (`UserRegisterDTO`, validado pelo Pydantic).

## Frontend

### Estado (`AuthState`)

```dart
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final Failure? failure;

  Map<String, String> get fieldErrors; // populado só se failure for ValidationFailure
}
```

### Tratamento de erro por campo

Esse foi o ponto mais delicado do módulo: um erro `400` de validação (ex: senha curta) precisa aparecer **no campo certo do formulário**, não como mensagem genérica.

O backend retorna:
```json
{
  "detail": "Validation failed for POST /auth/register",
  "extra": [{"key": "password", "message": "String should have at least 6 characters"}]
}
```

O `ErrorMapper` extrai `extra` e monta um `Map<String, String>` (`fieldErrors`), acessado na tela via:
```dart
errorText: authState.fieldErrors['password'],
```

Erros sem campo associado (401, 409, falha de rede, erro 5xx) caem em `failure.message`, exibido via `SnackBar`.

### Persistência do token

O token é salvo em `flutter_secure_storage` logo após login/registro bem-sucedido (`AuthRepositoryImpl`). No boot do app, `AuthNotifier.checkAuthStatus()` tenta ler o token salvo e validar via `/auth/me` — se falhar (token expirado, por exemplo), o usuário é deslogado automaticamente.

### Proteção de rota

`GoRouter` observa `authProvider` via `refreshListenable`. A lógica de redirecionamento está em `app_router.dart`: usuário não autenticado é sempre levado para `/login`, exceto durante os estados `loading`/`initial` (evita redirecionar antes da checagem inicial terminar).
