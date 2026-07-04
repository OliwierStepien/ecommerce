# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Flutter meal-planning app (recipes, planned meals calendar, shopping list, freezer inventory, friends/sharing) backed by Firebase (Auth + Firestore) with an offline-first Hive cache. The package name is `mealapp` (imports use `package:mealapp/...`) even though the repo directory is `ecommerce`. Code comments are largely in Polish.

## Commands

```bash
flutter pub get                 # install dependencies
flutter analyze                 # lint/static analysis (flutter_lints)
flutter test                    # run tests (test/widget_test.dart is currently empty)
flutter run                     # run the app (requires Firebase-configured device/simulator)
dart run build_runner build --delete-conflicting-outputs   # regenerate Hive *.g.dart adapters
flutter gen-l10n                # regenerate localizations from lib/l10n/*.arb (also runs on build; generate: true)
```

There is no CI or test suite to speak of — `flutter analyze` is the main verification gate.

## Architecture

Clean-architecture layering, repeated per feature (meal, planned_meal, favorite_meal, shopping_list_meal_ingredient, shopping_list_custom_item, freezer, grocery, category, ingredient, friends, auth, plus *_share features):

- `lib/domain/<feature>/` — entities, repository interfaces, use cases. Use cases return `Either<Failure, T>` (dartz).
- `lib/data/<feature>/` — `model/` (Hive models with generated adapters + Firestore mapping), `mapper/`, `source/` (`remote/` Firebase service, `local/` Hive service), `repository/` with `remote/`, `local/`, `manager/`, and sometimes `sync/`.
- `lib/presentation/<feature>/` — pages, widgets, and Cubits (flutter_bloc). States use Equatable.

### Offline-first data flow

The key pattern: for each feature a **`<Feature>RepositoryManager`** implements the domain repository interface and routes calls between the remote (Firebase) and local (Hive) implementations based on `NetworkInfo.checkInternetConnection()`. Online reads also overwrite the Hive cache (`_syncRemoteToLocal`); offline reads/writes go to Hive only, with items flagged for later sync.

Background synchronization (`lib/core/sync/`):
- `SyncController.syncData()` runs all per-feature `*SyncService`s (in `lib/data/<feature>/repository/sync/`) in parallel, then clears locally soft-deleted items that were synced. Guards against concurrent runs.
- `SyncStrategy` / `DebounceSyncStrategy` (singleton in get_it) debounces `onDataChanged()` (3 s) and syncs immediately on app resume/pause/network restore. Cubits call `_syncStrategy.onDataChanged()` after mutations. Do **not** dispose this singleton from a cubit's `close()` — it is shared app-wide.
- `ConnectionMonitor` (started by `SplashCubit`) listens to connectivity_plus and triggers `SyncStrategy.onNetworkRestored()`.
- `NetworkInfoImpl` returns optimistically `true` when physical connectivity exists and validates real internet access in the background (5 s cache).
- The `SyncService` interface lives in `lib/core/sync/sync_service.dart` (single definition — don't duplicate it).

### Wiring and app startup

- `lib/service_locator.dart` — all get_it registrations (services → repositories → use cases → cubits → sync services/monitor). Register new features here following the existing order.
- `lib/main.dart` → `HiveConfig.init()` (registers adapters, opens all boxes in `lib/core/storage/hive_init.dart`) → `Firebase.initializeApp` → `initializeDependencies()` → `MyAppWrapper` (root `MultiBlocProvider` providing app-wide cubits) → `MyApp`.
- New Hive models need: adapter registration + box opening in `hive_init.dart`, a type id in `lib/core/storage/hive_type_id.dart`, and build_runner regeneration.

### Navigation

go_router in `lib/routes/go_router.dart` with a `StatefulShellRoute.indexedStack` (bottom navigation via `LayoutScaffold`) holding 5 branches: favorites, freezer, home (with nested detail/search/category/user routes), planned-meal calendar, shopping list. Auth/splash routes sit outside the shell. Route paths are constants in `lib/routes/routes.dart`; entities are passed via `state.extra`.

### Cubit conventions

Mutating cubits (shopping list, freezer) do optimistic updates: emit the new list first, then call the use case, revert to the previous list on `Left`/exception, and finish with `_syncStrategy.onDataChanged()`. They keep a `_lastRemovedItem` (+original index) for undo/restore; when re-inserting, clamp the index to the current list length.

### Localization

`flutter gen-l10n` from `lib/l10n/app_en.arb` / `app_pl.arb`; access via `context.l10n` (see `lib/l10n/l10n.dart` and `lib/extensions/context_extension.dart`).
