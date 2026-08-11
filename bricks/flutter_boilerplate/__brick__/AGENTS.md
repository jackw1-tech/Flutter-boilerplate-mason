# AGENTS.md — Pine Architecture Contract

> **Read this file before writing a single line of code in this repository.**
>
> This is the architecture contract for **any** AI coding agent working on this project — Claude Code, Cursor, GitHub Copilot, Codex, Gemini CLI, Windsurf, Cline, Aider, or a human. It is not a suggestion document: the rules below are the definition of "correct" here. A change that works but breaks a rule below is a **defective** change.
>
> If a rule in this file conflicts with your general Flutter habits, **this file wins**. If a rule here conflicts with an explicit instruction from the user in the current task, ask before deviating, then follow the user.

This project follows **Pine**, a lightweight architecture for Flutter by Angelo Cassano:
<https://angeloavv.medium.com/pine-a-lightweight-architecture-helper-for-your-flutter-projects-1ce69ac63f74>

It was generated from the boilerplate <https://github.com/jackw1-tech/Flutter-Boilerplate> (Mason brick: <https://github.com/jackw1-tech/Flutter-boilerplate-mason>).

---

## 0. The rules in one screen

1. There are exactly **four Pine layers**: `Mapper` → `Provider (Service)` → `Repository` → `BLoC/Cubit`, plus a pure **UI** layer on top.
2. Dependencies point **downwards only**. A lower layer must never import, read, or know about a higher one.
3. **Every** dependency is injected through the widget tree via `DependencyInjector` (`lib/di/`) and resolved with `context.read<T>()`. Never `new` a Service/Repository/Mapper/BLoC inline in the code.
4. UI talks **only** to BLoC/Cubit (or a `ChangeNotifier` in `state_management/providers/`). UI never touches a Repository, Service, Mapper, DTO, or DB client.
5. BLoC talks **only** to Repositories. Never to a Service, never to a Mapper, never to raw network/DB.
6. Repository talks **only** to Services and Mappers. It returns **domain models**, never DTOs, never `Map<String, dynamic>`.
7. Service (= Pine's "Provider" layer, living in `lib/network/service/`) does **raw I/O only** and returns raw data/DTOs. No business logic, no mapping to domain models.
8. Mapper does **pure data transformation** DTO ↔ Model. No I/O, no state, no business rules, no dependency on any other layer.
9. Every abstraction pair is `Base<X>` → `<Feature><X>` (abstract) → `<Feature><X>Impl` (concrete, inside `impl/`). Do not collapse the two levels.
10. New files are `snake_case.dart`. Classes are `PascalCase`. (Some legacy files break this — see §11.)
11. Do **not** introduce a competing architecture or DI mechanism: no Riverpod, no GetX, no `get_it`/service locator, no Clean-Architecture "use case" layer, no `MultiProvider`/`MultiBlocProvider` outside `lib/di/`.
12. Adding a feature means adding **all** the layers it needs, wired in DI — not shortcutting one layer because it "feels like overkill".

---

## 1. Stack (do not swap these without being asked)

From `pubspec.yaml`:

| Concern | Package | Notes |
| --- | --- | --- |
| Architecture helper / DI | `pine: ^1.0.4` | `DependencyInjectorHelper`, `DTO`, `DTOMapper`, `Mapper` |
| State management | `flutter_bloc: ^9.1.1` | `Bloc`, `Cubit`, `BlocProvider`, `RepositoryProvider` |
| DI plumbing | `provider: ^6.1.5` | `Provider`, `SingleChildWidget`, `context.read/watch` |
| Routing | `auto_route: ^11.1.0` (+ `auto_route_generator: ^10.5.0`) | codegen into `app_router.gr.dart`; the generator has no major 11 — the 10.5.x line is the one that supports auto_route 11.x, do not "align" the versions |
| Serialization annotations | `json_annotation: ^4.12.0` | ⚠️ `json_serializable` is **not** in `dev_dependencies`: `@JsonSerializable` codegen will **not** run. Either hand-write `fromJson`/`toJson` or add the dev dependency first. |
| IDs | `uuid: ^4.6.0` | available for `BaseModel` ids |
| Dates/formatting | `intl: ^0.20.3` | used by `DateTimeUtils` |
| Codegen runner | `build_runner: ^2.5.2` | dev |
| Lints | `flutter_lints: ^6.0.0` | via `analysis_options.yaml` |

Dart SDK constraint: `^3.8.0`. Modern idioms are therefore available and expected in new code: `super.key` instead of `Key? key`, `Color.withValues(alpha:)` instead of the deprecated `withOpacity`, pattern matching / `switch` expressions.

There is **no** HTTP client dependency (`dio`/`http`/`retrofit`) and **no** `supabase_flutter`/`firebase_core` in `pubspec.yaml` yet — `lib/network/firebase_config.dart` and `lib/network/supabase_config.dart` are stubs. If a task needs real networking, add the dependency explicitly and say so; do not assume one is present.

`equatable` is **not** a dependency either. Implement `==`/`hashCode` by hand in states/models, or add the package deliberately.

---

## 2. The four layers and the direction of dependencies

Injection flows **top-down** in the widget tree; access flows **bottom-up** in code:

```
        outermost in the widget tree
┌──────────────────────────────────────────────┐
│ Mapper        pure DTO <-> Model transforms  │  depends on: nothing
│   ↑ readable by                              │
│ Provider      lib/network/service/*          │  depends on: Mapper (rarely), raw clients
│   ↑ readable by                              │
│ Repository    lib/repositories/*             │  depends on: Provider(Service) + Mapper
│   ↑ readable by                              │
│ BLoC / Cubit  lib/state_management/*         │  depends on: Repository
│   ↑ readable by                              │
│ UI            lib/ui/*                       │  depends on: BLoC/Cubit only
└──────────────────────────────────────────────┘
        innermost in the widget tree
```

⚠️ **Naming trap, memorize it:** in Pine the "**Provider**" layer is the *data source / service* layer, and in this project it lives in **`lib/network/service/`**. It has nothing to do with `state_management/providers/` (those are `ChangeNotifier` state holders) and nothing to do with the `Provider` widget from `package:provider` (that is just the DI mechanism).

### What each layer may and may not do

| Layer | MUST do | MUST NOT do |
| --- | --- | --- |
| **Mapper** (`lib/mappers/`) | Convert `DTO → Model` and `Model → DTO`, field by field. Be `const`-constructible and stateless. | Business logic. Any I/O (network, DB, disk, prefs). Hold state. Import a Service, Repository, BLoC or widget. |
| **Provider / Service** (`lib/network/service/`) | Talk to REST/Supabase/Firebase/DAO. Return raw payloads or DTOs. Own timeouts, headers, endpoints. | Convert to domain models (that's the Mapper). Business rules. App state. Import a Repository, BLoC, or anything under `lib/ui/`. |
| **Repository** (`lib/repositories/`) | Orchestrate one or more Services, apply Mappers, expose an API in terms of **domain models**. Own domain-level error translation and caching policy. | Mutate app state directly. Import BLoC or widgets. Contain presentation logic. Do its own inline mapping instead of calling a Mapper. Leak DTOs or `Map<String, dynamic>` to callers. |
| **BLoC / Cubit** (`lib/state_management/`) | Receive events / expose methods, call Repositories, `emit` states. Hold all screen logic. | Call a Service or a DB directly. Perform mapping. Touch `BuildContext`, navigate, or show dialogs/snackbars (emit a state and let the UI react). |
| **UI** (`lib/ui/`) | Render state, dispatch events/methods, navigate. | Contain business logic. Read a Repository/Service/Mapper. Import DTOs. Use `setState` for anything beyond ephemeral, purely-visual local state (a text controller, an animation flag, an expansion toggle). |

### Access rules in code

- `context.read<T>()` — one-shot access: inside `create:` callbacks in DI, inside event handlers, inside `onPressed`. **This is the default.**
- `context.watch<T>()` / `BlocBuilder` / `BlocSelector` — only to *observe* state and rebuild.
- `context.read<T>()` in `build()` for a value you then render is a bug: it will not rebuild.
- Never call `context.read` inside a Repository/Service/Mapper implementation. They receive their dependencies through their **constructor**; only the `create:` callbacks in `lib/di/` resolve them.

---

## 3. Directory map — the single source of truth for "where does this file go"

```
lib/
├── main.dart                       app entry; wraps MaterialApp.router in DependencyInjector
├── di/                             ← ALL dependency injection lives here, nowhere else
│   ├── dependency_injector.dart      the DependencyInjector widget + `part` directives
│   ├── mappers.dart                  part: final List<SingleChildWidget> _mappers
│   ├── providers.dart                part: final List<SingleChildWidget> _providers   (= Services)
│   ├── repositories.dart             part: final List<RepositoryProvider> repositories
│   ├── blocs.dart                    part: final List<BlocProvider> blocs
│   └── service_locator.dart          ⚠️ empty legacy stub — DO NOT USE, see §10
├── network/
│   ├── service/                    ← PINE "PROVIDER" LAYER (data sources)
│   │   ├── base_service.dart         abstract BaseService: generic CRUD contract
│   │   ├── <feature>_service.dart    abstract <Feature>Service extends BaseService
│   │   └── impl/
│   │       ├── base_service_impl.dart
│   │       └── <feature>_service_impl.dart   concrete implementation
│   ├── dto/                        raw wire/DB shapes; consumed ONLY by Mappers
│   ├── interceptor/                HTTP interceptors and pure network plumbing
│   ├── firebase_config.dart        static config stub
│   └── supabase_config.dart        static config stub
├── mappers/                        ← PINE MAPPER LAYER
│   ├── mappers.dart                  ⚠️ legacy local DTOMapper — see §11.2
│   └── <feature>_mapper.dart         one mapper per DTO↔Model pair
├── model/                          domain models (what the app actually manipulates)
│   ├── base_model.dart               abstract BaseModel (id, toJson, copyWith)
│   └── entities/                     one file per domain entity
├── repositories/                   ← PINE REPOSITORY LAYER
│   ├── base_repository.dart          abstract BaseRepository<T extends BaseModel>
│   ├── <feature>_repository.dart     abstract <Feature>Repository extends BaseRepository<T>
│   └── impl/
│       └── <feature>_repository_impl.dart
├── state_management/               ← PINE BLOC LAYER
│   ├── blocs/<feature>_bloc/
│   │   ├── <feature>_bloc.dart
│   │   ├── <feature>_bloc_event.dart
│   │   └── <feature>_bloc_state.dart
│   ├── cubits/<feature>_cubit/
│   │   ├── <feature>_cubit.dart
│   │   └── <feature>_cubit_state.dart
│   └── providers/                    ChangeNotifier state holders (NOT the Pine Provider layer)
├── ui/
│   ├── pages/                        one file per screen, annotated @RoutePage()
│   └── widgets/                      reusable presentational widgets
├── routers/
│   ├── app_router.dart               AutoRouter config (routes list)
│   ├── app_router.gr.dart            GENERATED — never edit by hand
│   └── auth_guard.dart               AutoRouteGuard
├── theme/                          app_theme.dart, color_palette.dart, app_text_styles.dart, dimensions.dart
├── utils/                          pure stateless helpers (string_utils.dart, date_time_utils.dart)
└── other/
    ├── constants/                    api_constants.dart (ApiConstants), app_constants.dart (AppConstants)
    └── media/images/                 assets, declared in pubspec.yaml
```

Rules attached to this map:

- `theme/`, `utils/`, `other/` are **cross-cutting and pure**: no I/O, no state, no imports from any Pine layer.
- `routers/` is **not** a Pine layer. `auth_guard.dart` may *read* state (e.g. an auth BLoC/Repository through the injected context), but must not implement authorization logic itself — that belongs to a Repository/BLoC.
- Anything that does not obviously belong to one of these folders is a signal that the design is wrong. Do not create new top-level folders under `lib/` (`core/`, `features/`, `domain/`, `usecases/`, …) — this project is layer-first, not feature-first.

---

## 4. Dependency injection — exactly how it works

`lib/di/dependency_injector.dart` is a single Dart library split into four `part` files:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pine/pine.dart';
import 'package:provider/single_child_widget.dart';

part 'blocs.dart';
part 'mappers.dart';
part 'providers.dart';
part 'repositories.dart';

class DependencyInjector extends StatelessWidget {
  final Widget child;

  const DependencyInjector({required this.child, super.key});

  @override
  Widget build(BuildContext context) => DependencyInjectorHelper(
        blocs: blocs,
        mappers: _mappers,
        repositories: repositories,
        providers: _providers,
        child: child,
      );
}
```

`DependencyInjectorHelper` (from `package:pine`) nests them in a **fixed** order, regardless of the order you pass the named arguments:

```
MultiProvider(mappers)
  └── MultiProvider(providers)          ← Services
        └── MultiRepositoryProvider(repositories)
              └── MultiBlocProvider(blocs)
                    └── child
```

Consequences you must respect:

- A **Repository** `create:` callback can `context.read()` a Service and a Mapper. ✅
- A **BLoC** `create:` callback can `context.read()` a Repository (and, technically, anything above it — but rule §0.5 still forbids reading a Service from a BLoC). ✅
- A **Service** `create:` callback can `context.read()` a Mapper or another Service declared **earlier in the same list**. ✅
- A **Mapper** cannot read anything. ✅
- Reading a BLoC from a Repository is impossible by construction — if you feel the need, the design is wrong.

Notes:

- The order of the `part` directives is alphabetical and has **no runtime effect**. Do not "fix" it; do not rely on it.
- The four lists are inconsistently named in the generated code: `_mappers` and `_providers` are private, `repositories` and `blocs` are public. They are all `part` of the same library, so privacy is irrelevant here. Leave the names as they are unless the user asks for a cleanup; if you do clean up, rename **all four** consistently and update `dependency_injector.dart`.
- `main.dart` must keep `DependencyInjector` **above** `MaterialApp.router`, so every route sees the injected tree.

### How to register each layer

`lib/di/mappers.dart`
```dart
part of 'dependency_injector.dart';

final List<SingleChildWidget> _mappers = [
  Provider<DTOMapper<UserDTO, User>>(
    create: (_) => const UserMapper(),
  ),
];
```
Register mappers under the **interface** type `DTOMapper<D, M>`, not the concrete class — that is what makes `context.read()` resolve inside repositories.

`lib/di/providers.dart` (Services)
```dart
part of 'dependency_injector.dart';

final List<SingleChildWidget> _providers = [
  Provider<UserService>(
    create: (context) => UserServiceImpl(),
  ),
];
```
Register under the **abstract** `UserService` type, create the `...Impl`.

`lib/di/repositories.dart`
```dart
part of 'dependency_injector.dart';

final List<RepositoryProvider> repositories = [
  RepositoryProvider<UserRepository>(
    create: (context) => UserRepositoryImpl(
      service: context.read(),
      mapper: context.read(),
    ),
  ),
];
```

`lib/di/blocs.dart`
```dart
part of 'dependency_injector.dart';

final List<BlocProvider> blocs = [
  BlocProvider<UserBloc>(
    create: (context) => UserBloc(repository: context.read()),
  ),
];
```
Use `lazy: false` only when a BLoC must start work before its first consumer mounts. Prefer dispatching the initial event from the page (`context.read<UserBloc>().add(...)` in `initState`) over eager global work.

**Scoped BLoCs.** A BLoC used by exactly one page, that must be recreated per visit (e.g. a form tied to a route parameter), is the one legitimate exception to "everything in `lib/di/`": wrap that page in a `BlocProvider` locally. Resolve its dependencies with `context.read<SomeRepository>()` from the injected tree — never construct a Repository there. Anything global-lifetime goes in `lib/di/blocs.dart`.

---

## 5. Naming conventions

| Thing | Convention | Example |
| --- | --- | --- |
| File names | `snake_case.dart`, always | `user_dto.dart`, `base_model.dart` |
| Classes | `PascalCase` | `UserRepositoryImpl` |
| DTOs | `<Name>DTO` in `network/dto/<name>_dto.dart` | `UserDTO` |
| Models | `<Name>` in `model/entities/<name>.dart` | `User` |
| Mappers | `<Name>Mapper` in `mappers/<name>_mapper.dart` | `UserMapper` |
| Service contract | `<Feature>Service` in `network/service/<feature>_service.dart` | `UserService` |
| Service impl | `<Feature>ServiceImpl` in `network/service/impl/<feature>_service_impl.dart` | `UserServiceImpl` |
| Repository contract | `<Feature>Repository` in `repositories/<feature>_repository.dart` | `UserRepository` |
| Repository impl | `<Feature>RepositoryImpl` in `repositories/impl/<feature>_repository_impl.dart` | `UserRepositoryImpl` |
| BLoC | `<Feature>Bloc` in `state_management/blocs/<feature>_bloc/` | `UserBloc` |
| Events | `<Verb><Feature>Event` | `FetchUsersEvent` |
| States | `<Participle><Feature>State` | `FetchingUsersState`, `FetchedUsersState`, `ErrorUsersState` |
| Cubit | `<Feature>Cubit` in `state_management/cubits/<feature>_cubit/` | `UserCubit` |
| Pages | `<Name>Page` in `ui/pages/<name>_page.dart` | `HomePage` |
| Routes (generated) | `<Name>Route` | `HomeRoute`, `ExampleDetailRoute` |

Imports: use **absolute package imports** everywhere — `import 'package:{{project_name}}/repositories/user_repository.dart';` — not relative ones. This matches every existing file.

When you rename or move a file, grep the whole project for the old path/symbol and fix **every** reference in the same change. A rename with broken imports is not compliance, it is breakage.

---

## 6. Recipe: add a complete feature (the canonical path)

Follow the steps in this order. Do not skip a step; if a layer is genuinely trivial it still exists, it is just small.

**Step 1 — DTO** — `lib/network/dto/user_dto.dart`
```dart
import 'package:pine/pine.dart';

class UserDTO extends DTO {
  final String id;
  final String fullName;
  final String? avatarUrl;

  const UserDTO({required this.id, required this.fullName, this.avatarUrl});

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
      };
}
```
DTO field names mirror the **wire format**. Never rename or reshape data here — that is the Mapper's job.

**Step 2 — Model** — `lib/model/entities/user.dart`
```dart
import 'package:{{project_name}}/model/base_model.dart';

class User implements BaseModel {
  @override
  final String id;
  final String fullName;
  final String? avatarUrl;

  const User({required this.id, required this.fullName, this.avatarUrl});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
      };

  @override
  User copyWith({String? id, String? fullName, String? avatarUrl}) => User(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
```

**Step 3 — Mapper** — `lib/mappers/user_mapper.dart`
```dart
import 'package:pine/pine.dart';
import 'package:{{project_name}}/model/entities/user.dart';
import 'package:{{project_name}}/network/dto/user_dto.dart';

class UserMapper extends DTOMapper<UserDTO, User> {
  const UserMapper();

  @override
  User fromDTO(UserDTO dto) => User(
        id: dto.id,
        fullName: dto.fullName,
        avatarUrl: dto.avatarUrl,
      );

  @override
  UserDTO toDTO(User model) => UserDTO(
        id: model.id,
        fullName: model.fullName,
        avatarUrl: model.avatarUrl,
      );
}
```
Use pine's `DTOMapper<Source extends DTO, Model>`: `fromDTO(dto) → model`, `toDTO(model) → dto`. Lists come free via the `fromDTOMany` / `toDTOMany` extensions.

**Step 4 — Service** — contract in `lib/network/service/user_service.dart`, implementation in `impl/`
```dart
// user_service.dart
import 'package:{{project_name}}/network/service/base_service.dart';

abstract class UserService extends BaseService {
  Future<List<Map<String, dynamic>>> search(String query);
}
```
```dart
// impl/user_service_impl.dart
import 'package:{{project_name}}/network/service/user_service.dart';

class UserServiceImpl implements UserService {
  @override
  String get tableName => 'users';

  @override
  Future<Map<String, dynamic>?> getById(String id) async { /* raw call */ }

  @override
  Future<List<Map<String, dynamic>>> getAll() async { /* raw call */ }

  @override
  Future<List<Map<String, dynamic>>> search(String query) async { /* raw call */ }

  // ...insert / update / delete
}
```
`BaseService` already declares `tableName`, `getById`, `getAll`, `insert`, `update`, `delete`. Add only feature-specific calls in `UserService`. The Service returns raw maps/DTOs — never a `User`.

**Step 5 — Repository** — contract + impl
```dart
// repositories/user_repository.dart
import 'package:{{project_name}}/model/entities/user.dart';
import 'package:{{project_name}}/repositories/base_repository.dart';

abstract class UserRepository extends BaseRepository<User> {
  Future<List<User>> search(String query);
}
```
```dart
// repositories/impl/user_repository_impl.dart
import 'package:pine/pine.dart';
import 'package:{{project_name}}/model/entities/user.dart';
import 'package:{{project_name}}/network/dto/user_dto.dart';
import 'package:{{project_name}}/network/service/user_service.dart';
import 'package:{{project_name}}/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService service;
  final DTOMapper<UserDTO, User> mapper;

  UserRepositoryImpl({required this.service, required this.mapper});

  @override
  Future<List<User>> getAll() async {
    final raw = await service.getAll();
    return raw
        .map(UserDTO.fromJson)
        .map(mapper.fromDTO)
        .toList(growable: false);
  }

  @override
  Future<User?> get(String id) async {
    final raw = await service.getById(id);
    return raw == null ? null : mapper.fromDTO(UserDTO.fromJson(raw));
  }

  // create / update / delete / search follow the same shape
}
```
Note the generic: `BaseRepository<User>`, **not** `BaseRepository<BaseModel>`. The repository's public API speaks in concrete domain models.

**Step 6 — BLoC** — `lib/state_management/blocs/user_bloc/`
```dart
// user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/model/entities/user.dart';
import 'package:{{project_name}}/repositories/user_repository.dart';

part 'user_bloc_event.dart';
part 'user_bloc_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(const FetchingUsersState()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(const FetchingUsersState());
    try {
      final users = await repository.getAll();
      emit(users.isEmpty ? const NoUsersState() : FetchedUsersState(users));
    } catch (error) {
      emit(ErrorUsersState(error.toString()));
    }
  }
}
```
Events and states are `part` files of the BLoC — that is why they are named `<feature>_bloc_event.dart` / `<feature>_bloc_state.dart`. Errors become **states**; never swallow them in a bare `catch` that emits nothing, and never let a raw exception reach the widget layer.

**Step 7 — DI registration** — add one entry to each of the four files in `lib/di/` (see §4). **A feature that is not registered in `lib/di/` is not done.**

**Step 8 — UI** — `lib/ui/pages/users_page.dart`
```dart
@RoutePage()
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) => switch (state) {
            FetchingUsersState() => const Center(child: CircularProgressIndicator()),
            FetchedUsersState(:final users) => _list(users),
            NoUsersState() => const Center(child: Text('No users')),
            ErrorUsersState(:final error) => Center(child: Text(error)),
            _ => const SizedBox.shrink(),
          },
        ),
      );
}
```

**Step 9 — verify**: `dart run build_runner build` (if routes changed), then `flutter analyze`, then `flutter test`.

---

## 7. Recipe: add a page / route

1. Create `lib/ui/pages/<name>_page.dart` with a class `<Name>Page` annotated `@RoutePage()`.
2. Path parameters go through `@PathParam('id')` in the constructor (see `detail_page.dart`).
3. Add an `AutoRoute` entry in `lib/routers/app_router.dart`. The generated route class name is the page class name with `Page` → `Route` (`ExampleDetailPage` → `ExampleDetailRoute`).
4. Run `dart run build_runner build` to regenerate `app_router.gr.dart`. **Never hand-edit that file.**
5. Navigate with `context.router.push(SomeRoute(...))` / `context.router.pop()` — from the UI layer only. A BLoC never navigates: it emits a state and the page reacts (`BlocListener`).
6. Guards go in `lib/routers/` and extend `AutoRouteGuard`. The guard reads state; it does not implement the auth rules.

---

## 8. "Where do I put this code?" — decision table

| What you are writing | Where it goes |
| --- | --- |
| An HTTP/Supabase/Firebase call, a SQL query | `lib/network/service/impl/` |
| The shape of a JSON payload | `lib/network/dto/` |
| Converting that payload into something the app understands | `lib/mappers/` |
| A domain concept with identity and fields | `lib/model/entities/` |
| "Fetch the user, then merge in their settings, then cache" | `lib/repositories/impl/` |
| "When the user taps Save, validate, persist, show success" | `lib/state_management/blocs/…` |
| "Show a spinner while loading" | a **state** from the BLoC, rendered by `lib/ui/` |
| A reusable button/card/list tile | `lib/ui/widgets/` |
| A whole screen | `lib/ui/pages/` + a route in `lib/routers/app_router.dart` |
| A colour, spacing, or text style | `lib/theme/` |
| A pure function on strings/dates | `lib/utils/` |
| An endpoint URL, a prefs key, a page size | `lib/other/constants/` |
| Wiring any of the above together | `lib/di/` |

---

## 9. Commands

```bash
flutter pub get                                          # dependencies
dart run build_runner build                              # auto_route (+ any codegen)
dart run build_runner watch                              # during development
flutter analyze                                          # MUST be clean before you report done
dart format lib test                                     # formatting
flutter test                                             # tests
flutter run                                              # run the app
```

`flutter analyze` must pass with no new errors or warnings before any task is considered complete. If you renamed or moved files, run it — that is where broken imports surface.

---

## 10. Hard "no" list

Doing any of these is a defect, even if the app compiles and runs:

- Instantiating a Service/Repository/Mapper/BLoC directly in a widget, a page, or another layer (`UserRepositoryImpl()` outside `lib/di/`).
- Using `lib/di/service_locator.dart` (an empty legacy stub), or introducing `get_it`/any global singleton registry to bypass `context.read()`.
- Declaring `MultiProvider`, `MultiBlocProvider`, or `MultiRepositoryProvider` anywhere except inside `DependencyInjectorHelper`.
- A widget calling a Repository or Service.
- A BLoC calling a Service, a DTO, or `http`/Supabase/Firebase directly.
- A Repository returning a DTO or a `Map<String, dynamic>` to its caller.
- Mapping logic written inline in a Repository, a Service, or a widget instead of in `lib/mappers/`.
- A Mapper that performs I/O, holds state, or imports another layer.
- `setState` used to hold application/domain state, or business logic inside `build()`.
- Adding Riverpod, GetX, MobX, `get_it`, or a Clean-Architecture "use case"/"interactor" layer to solve a structural problem. The answer is always inside the four Pine layers.
- New top-level folders under `lib/` outside the map in §3.
- Editing `lib/routers/app_router.gr.dart` by hand.
- Committing secrets into `firebase_config.dart` / `supabase_config.dart` (they are placeholder stubs; real values belong in `--dart-define` / env config).
- Silently swallowing an exception (`catch (_) {}`) instead of emitting an error state.

---

## 11. Known inconsistencies in the generated boilerplate

The template ships with a few things that violate its own rules. **Do not imitate them.** When a task takes you into one of these files, fix it in passing (updating every reference), and mention the fix in your report.

**11.1 — File naming.** Earlier revisions of this template mixed `camelCase`/`PascalCase` file names (`baseModel.dart`, `UserDto.dart`, `ApiContants.dart`, …). The tree is now normalized to `snake_case.dart`; keep it that way for every new file. One typo survives: `lib/model/entities/first_entitiy.dart` (→ `first_entity.dart`) — rename it when you replace it with a real entity.

**11.2 — Duplicated `DTOMapper`.** `lib/mappers/mappers.dart` declares a *local* `abstract class DTOMapper<D, M extends BaseModel>` whose signature is inverted with respect to pine's (`D fromDTO(M dto)`). The authoritative contract is **pine's** `DTOMapper<Source extends DTO, Model>` from `package:pine/pine.dart`. Always import pine's version; never import both in the same file. Remove the local duplicate the first time you touch the mapper layer.

**11.3 — `FirstRepository` generic bug.** `abstract class FirstRepository<T> extends BaseRepository<BaseModel>` declares an unused `T` and binds the base to `BaseModel` instead of a concrete entity. The correct form is `abstract class FooRepository extends BaseRepository<Foo>`.

**11.4 — `BaseModel.create()`** is a factory that throws `UnimplementedError`. Do not call it and do not replicate the pattern; construct models explicitly (use `uuid`'s `Uuid().v4()` when you need a new id).

**11.5 — Asset paths.** `lib/ui/pages/detail_page.dart` used to load its image from a hard-coded absolute path on the template author's machine; it now uses the declared asset `lib/other/media/images/pine.png`. Assets must always be referenced by the path declared under `flutter: assets:` in `pubspec.yaml` — never an absolute one.

**11.6 — Placeholder files.** `first_service_impl.dart`, `first_repository_impl.dart` (commented-out body), `first_bloc*.dart`, `first_cubit*.dart`, `first_provider.dart`, `first_widget.dart`, `first_interceptor.dart`, `first_entitiy.dart`, `user_model.dart`, `user_dto.dart` are empty or commented scaffolding. They are **templates showing where things go**, not working code. Replace them with real feature files (properly named) rather than growing code inside them; delete the leftovers once a real equivalent exists.

**11.9 — `lib/mappers/mappers.dart` is a single shared file.** New mappers get **one file each** (`lib/mappers/user_mapper.dart`), not appended to `mappers.dart`.

**11.7 — `HomePage` uses `setState` for its counter demo.** That is demo code, not a pattern to follow for real state.

**11.8 — `main.dart` init.** The `FirebaseConfig.init()` / `SupabaseConfig.init()` calls are commented out. If you enable them, `main` must become `async` and `await` them **before** `runApp`.

---

## 12. Testing conventions

Tests live in `test/`, mirroring the `lib/` structure (`test/repositories/user_repository_test.dart`, …).

- **Mappers**: pure unit tests, no mocks needed. Cheapest, highest-value tests — always write them.
- **Repositories**: unit tests with a fake/stub Service and a real Mapper. Assert that domain models come out and DTOs never leak.
- **BLoCs**: unit tests with a fake Repository; assert the emitted state sequence.
- **UI**: widget tests wrapping the widget in the required `BlocProvider`s (or the whole `DependencyInjector` when an integration-flavoured test is warranted).

The layering exists precisely so that each layer is testable without the ones above it. If something is hard to test, it is almost always because a rule in §0 was broken.

---

## 13. Checklist before you declare a task done

- [ ] Every new dependency is registered in the right file under `lib/di/`, and nothing is instantiated outside it.
- [ ] No layer imports a layer above it (grep your new imports and check them against §2).
- [ ] The Repository exposes domain models only; the Service returns raw data only; the Mapper is the only place doing conversion.
- [ ] No business logic in widgets; the BLoC does not touch `BuildContext` or navigation.
- [ ] File names are `snake_case`, classes are `PascalCase`, and the `Base` / `<Feature>` / `<Feature>Impl` triad is respected.
- [ ] Moved/renamed files: every import in the project updated.
- [ ] Routes changed → `build_runner` re-run; `app_router.gr.dart` regenerated, not hand-edited.
- [ ] `flutter analyze` is clean; `flutter test` passes.
- [ ] In your final report, state for each touched feature which layers exist and are wired: **Service / Mapper / Repository / BLoC / DI**. Anything you could not complete is called out explicitly as a gap — never left silently unfinished.
