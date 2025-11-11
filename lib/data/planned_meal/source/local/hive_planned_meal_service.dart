// data/planned_meal/source/local/hive_planned_meal_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/data/planned_meal/model/planned_meal_model.dart';

abstract class HivePlannedMealService {
  Future<List<PlannedMealModel>> getPlannedMeals();
  Future<List<PlannedMealModel>> getUnsyncedPlannedMeals();
  Future<List<PlannedMealModel>> getUnsyncedChanges();
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal);
  Future<void> markAsSynced(DateTime date, String mealId);
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal, {bool isOnline});
  Future<void> removePlannedMealsInDateRange(DateTime start, DateTime end, {bool isOnline});
  Future<void> updatePlannedMeal(PlannedMealModel plannedMeal);
}

class HivePlannedMealServiceImpl implements HivePlannedMealService {
  HivePlannedMealServiceImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Box<PlannedMealModel> get _box => Hive.box<PlannedMealModel>('plannedMeals');

  String get _uid => _auth.currentUser?.uid ?? '';

  String _key(DateTime date, String mealId) => '${_uid}_${date}_$mealId';

  bool _isMine(PlannedMealModel m) => m.ownerUid == _uid || (_uid.isNotEmpty && m.ownerUid.isEmpty == true);

  @override
  Future<List<PlannedMealModel>> getPlannedMeals() async {
    final all = _box.values.toList();
    final mine = all.where((m) => !m.isDeleted && _isMine(m)).toList();
    mine.sort((a, b) => a.position.compareTo(b.position));

    debugLog('📦 HIVE getPlannedMeals(): total=${all.length}, mine=${mine.length}, uid=$_uid', name: 'HivePM');
    return mine;
  }

  @override
  Future<List<PlannedMealModel>> getUnsyncedPlannedMeals() async {
    final mine = _box.values.where((m) => !m.isSynced && !m.isDeleted && _isMine(m)).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    debugLog('📦 HIVE getUnsyncedPlannedMeals(): ${mine.length}, uid=$_uid', name: 'HivePM');
    return mine;
  }

  @override
  Future<List<PlannedMealModel>> getUnsyncedChanges() async {
    final mine = _box.values.where((m) => !m.isSynced && _isMine(m)).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    debugLog('📦 HIVE getUnsyncedChanges(): ${mine.length}, uid=$_uid', name: 'HivePM');
    return mine;
  }

  @override
  Future<void> addPlannedMeal(PlannedMealModel plannedMeal) async {
    final enriched = plannedMeal.copyWith(ownerUid: _uid, isSynced: false);
    final key = _key(enriched.date, enriched.meal.mealId);
    await _box.put(key, enriched);
    debugLog('➕ HIVE add: key=$key pos=${enriched.position} uid=$_uid', name: 'HivePM');
  }

  @override
  Future<void> markAsSynced(DateTime date, String mealId) async {
    final key = _key(date, mealId);
    final model = _box.get(key);
    if (model != null && !model.isDeleted) {
      await _box.put(key, model.copyWith(isSynced: true, ownerUid: _uid));
      debugLog('🔖 HIVE markAsSynced: key=$key', name: 'HivePM');
    }
  }

  @override
  Future<void> removePlannedMeal(PlannedMealModel plannedMeal, {bool isOnline = false}) async {
    final key = _key(plannedMeal.date, plannedMeal.meal.mealId);
    final model = _box.get(key);
    if (model == null) {
      debugLog('⚠️ HIVE remove: not found key=$key', name: 'HivePM');
      return;
    }
    if (isOnline) {
      await _box.delete(key);
      debugLog('🗑️ HIVE delete permanent (online): key=$key', name: 'HivePM');
    } else {
      await _box.put(key, model.copyWith(isDeleted: true, isSynced: false));
      debugLog('❌ HIVE mark deleted (local): key=$key', name: 'HivePM');
    }
  }

  @override
  Future<void> removePlannedMealsInDateRange(DateTime start, DateTime end, {bool isOnline = false}) async {
    final toProcess = _box.values.where((m) {
      if (!_isMine(m)) return false;
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      return d.isAfter(start.subtract(const Duration(days: 1))) &&
             d.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    debugLog('🧹 HIVE removeRange: count=${toProcess.length} uid=$_uid (online=$isOnline)', name: 'HivePM');

    for (final m in toProcess) {
      await removePlannedMeal(m, isOnline: isOnline);
    }
  }

  @override
  Future<void> updatePlannedMeal(PlannedMealModel plannedMeal) async {
    final enriched = plannedMeal.copyWith(ownerUid: _uid, isSynced: false);
    final key = _key(enriched.date, enriched.meal.mealId);
    await _box.put(key, enriched);
    debugLog('✏️ HIVE update: key=$key newPos=${enriched.position}', name: 'HivePM');
  }
}