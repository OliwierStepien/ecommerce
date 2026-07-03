import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/freezer/entity/freezer_item_entity.dart';
import 'package:mealapp/domain/freezer/usecase/add_freezer_item_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/get_freezer_items_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/remove_freezer_item_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/restore_freezer_item_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/update_freezer_item_usecase.dart';
import 'package:mealapp/presentation/freezer/bloc/freezer_item_state.dart';

class FreezerItemCubit extends Cubit<FreezerItemState> {
  final AddFreezerItemUseCase _addUseCase;
  final RemoveFreezerItemUseCase _removeUseCase;
  final RestoreFreezerItemUseCase _restoreUseCase;
  final GetFreezerItemsUseCase _getUseCase;
  final UpdateFreezerItemUseCase _updateUseCase;
  final SyncStrategy _syncStrategy;

  Map<String, dynamic>? _lastRemoved;
  bool _suppressNotifications = false;

  FreezerItemCubit({
    required AddFreezerItemUseCase addUseCase,
    required RemoveFreezerItemUseCase removeUseCase,
    required RestoreFreezerItemUseCase restoreUseCase,
    required GetFreezerItemsUseCase getUseCase,
    required UpdateFreezerItemUseCase updateUseCase,
    required SyncStrategy syncStrategy,
  })  : _addUseCase = addUseCase,
        _removeUseCase = removeUseCase,
        _restoreUseCase = restoreUseCase,
        _getUseCase = getUseCase,
        _updateUseCase = updateUseCase,
        _syncStrategy = syncStrategy,
        super(const FreezerItemInitial()) {
    _load();
  }

  Future<void> _load() async {
    emit(const FreezerItemLoading());
    final res = await _getUseCase.call(NoParams());
    res.fold(
      (f) => emit(FreezerItemError(message: f.toString())),
      (items) => emit(FreezerItemLoaded(items: items)),
    );
  }

  bool get shouldShowNotification => !_suppressNotifications;

  Future<void> addItem(
    FreezerItemEntity item, {
    bool suppressNotification = false,
  }) async {
    if (state is! FreezerItemLoaded) return;
    final s = state as FreezerItemLoaded;
    final prev = s.items;

    try {
      _suppressNotifications = suppressNotification;

      final next = List<FreezerItemEntity>.from(prev)..add(item);
      emit(s.copyWith(items: next));

      final res = await _addUseCase.call(item);
      res.fold(
        (_) => emit(s.copyWith(items: prev)),
        (_) {},
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> removeItem(
    String itemId, {
    bool suppressNotification = false,
  }) async {
    if (state is! FreezerItemLoaded) return;
    final s = state as FreezerItemLoaded;
    final prev = s.items;

    try {
      _suppressNotifications = suppressNotification;

      final idx = prev.indexWhere((x) => x.itemId == itemId);
      if (idx == -1) return;

      _lastRemoved = {'item': prev[idx], 'index': idx};

      final next = List<FreezerItemEntity>.from(prev)..removeAt(idx);
      emit(s.copyWith(items: next));

      final res = await _removeUseCase.call(itemId);
      res.fold(
        (_) => emit(s.copyWith(items: prev)),
        (_) {},
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> restoreLastRemoved() async {
    if (_lastRemoved == null) return;
    if (state is! FreezerItemLoaded) return;

    final s = state as FreezerItemLoaded;
    final prev = s.items;

    final item = _lastRemoved!['item'] as FreezerItemEntity;
    final idx = _lastRemoved!['index'] as int;

    try {
      _suppressNotifications = true;

      final res = await _restoreUseCase.call(item);
      res.fold(
        (_) => emit(s.copyWith(items: prev)),
        (_) {
          // lista mogła się skrócić od czasu usunięcia — nie wychodź poza zakres
          final insertIndex = idx > prev.length ? prev.length : idx;
          final next = List<FreezerItemEntity>.from(prev)
            ..insert(insertIndex, item);
          emit(s.copyWith(items: next));
          _lastRemoved = null;
        },
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }

  Future<void> updateItem(
    FreezerItemEntity updated, {
    bool suppressNotification = false,
  }) async {
    if (state is! FreezerItemLoaded) return;
    final s = state as FreezerItemLoaded;
    final prev = s.items;

    final idx = prev.indexWhere((x) => x.itemId == updated.itemId);
    if (idx == -1) return;

    try {
      _suppressNotifications = suppressNotification;

      final next = List<FreezerItemEntity>.from(prev);
      next[idx] = updated;
      emit(s.copyWith(items: next));

      final res = await _updateUseCase.call(updated);
      res.fold(
        (_) => emit(s.copyWith(items: prev)),
        (_) {},
      );

      await _syncStrategy.onDataChanged();
    } finally {
      _suppressNotifications = false;
    }
  }
}