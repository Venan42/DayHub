# Frontend

Visão técnica do frontend Flutter. Para instruções de setup e execução, veja o [README](../README.md).

## Arquitetura

Cada feature (`lib/features/<nome>`) segue Clean Architecture em três camadas:

```
presentation/  →  domain/  →  data/
```

- **`domain/`** — regras de negócio puras. `entities/` (modelos internos do app, sem dependência de JSON ou API) e `repositories/` (interfaces abstratas, ex: `AuthRepository`).
- **`data/`** — implementação concreta. `datasources/` fala diretamente com a API via Dio; `models/` são DTOs com `fromJson`/`toJson`; `repositories/` implementa a interface do domínio, traduzindo model → entity.
- **`presentation/`** — UI e estado. `providers/` (Riverpod `Notifier` + estado imutável), `screens/`, `widgets/`.

A ideia é que `domain/` nunca dependa de `data/` ou `presentation/` — só o contrário. Isso permite, em teoria, trocar Dio por outro cliente HTTP sem tocar em regra de negócio.

## Gerenciamento de estado (Riverpod)

Usamos a API moderna `Notifier`/`NotifierProvider` (Riverpod 3.x), não o `StateNotifier` legado. Cada feature com estado próprio segue o padrão:

```dart
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async { ... }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
```

O estado (`AuthState`, `ThemeMode`, etc.) é sempre imutável, atualizado via `copyWith`.

## Tratamento de erros

`core/errors/` centraliza a tradução de erros HTTP em tipos conhecidos pela UI:

- **`failure.dart`** — hierarquia selada: `ValidationFailure` (com `fieldErrors` por campo), `UnauthorizedFailure`, `ConflictFailure`, `NetworkFailure`, `ServerFailure`, `UnknownFailure`.
- **`error_mapper.dart`** — `ErrorMapper.fromDioException()` nunca lança exceção (protegido por `try/catch` interno); sempre devolve uma `Failure`. Interpreta o campo `extra` retornado pelo backend em erros `400` para popular `fieldErrors`.

Padrão de uso numa tela:

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'E-mail',
    errorText: authState.fieldErrors['email'], // erro específico do campo
  ),
),
```

Erros sem campo associado (senha errada, e-mail duplicado, falha de rede) são exibidos via `SnackBar`, usando `failure.message`.

Ao criar um novo módulo (finanças, tarefas, etc.), o mesmo `ErrorMapper` deve ser reaproveitado — não criar um novo por feature.

## Tema

`core/theme/` define dois temas (`AppTheme.light` e `AppTheme.dark`), com preferência persistida via `flutter_secure_storage` (`ThemeModeNotifier`).

- **`app_colors.dart`** — paleta central. Qualquer mudança de cor do app deve começar aqui, nunca com cor "hardcoded" direto num widget.
- **`app_theme.dart`** — `ThemeData` completo por modo. Tipografia usa Google Fonts (Orbitron para títulos, JetBrains Mono para corpo/campos) apenas no modo escuro.
- **`theme_provider.dart`** — expõe `themeModeProvider`, consumido no `MaterialApp.router` (`app.dart`) e no botão de toggle das telas.

Componentes visuais reutilizáveis da identidade cyberpunk ficam em `shared/widgets/`:
- **`CyberpunkBackground`** — grid de fundo + glow pulsante (só ativo no modo escuro).
- **`GlowCard`** — card com borda e sombra amarela, usado como moldura dos formulários.

## Roteamento

`core/router/app_router.dart` usa GoRouter com `refreshListenable` observando `authProvider`, redirecionando automaticamente:
- não autenticado tentando acessar rota protegida → `/login`
- autenticado em `/login` ou `/register` → `/profile`
