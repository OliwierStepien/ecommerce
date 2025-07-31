import 'package:hive/hive.dart';
import 'package:mealapp/common/helper/debug_log/debug_log.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/model/shopping_list_meal_ingredient_model.dart';


abstract class HiveShoppingListMealIngredientService {
 Future<List<ShoppingListMealIngredientModel>>
     getMealIngredientFromShoppingList();
 Future<void> addMealIngredientToShoppingList(
     ShoppingListMealIngredientModel item);
 Future<void> removeMealIngredientFromShoppingList(
   ShoppingListMealIngredientModel item, {
   bool isOnline = false,
 });
 Future<List<ShoppingListMealIngredientModel>>
     getUnsyncedShoppingListMealIngredient();
 Future<void> markShoppingListMealIngredientAsSynced(
     String mealId, String ingredientId);
 Future<List<ShoppingListMealIngredientModel>>
     getUnsyncedChangesForShoppingListMealIngredient();
 Future<void> restoreMealIngredientToShoppingList(
     ShoppingListMealIngredientModel item);
 Future<void> clearSyncedDeletedItems();
}


class HiveShoppingListMealIngredientServiceImpl
   implements HiveShoppingListMealIngredientService {
 Box<ShoppingListMealIngredientModel> get _box =>
     Hive.box<ShoppingListMealIngredientModel>('shoppingListMealIngredients');


 String _key(ShoppingListMealIngredientModel item) =>
     '${item.meal.mealId}_${item.ingredient.ingredientId}';


 @override
 Future<List<ShoppingListMealIngredientModel>>
     getMealIngredientFromShoppingList() async {
   return _box.values.where((model) => !model.isDeleted).toList();
 }


 @override
 Future<void> addMealIngredientToShoppingList(
     ShoppingListMealIngredientModel item) async {
   final key = _key(item);
   final model = _box.get(key);


   await _box.put(
     key,
     item.copyWith(
       isSynced: model?.isSynced ?? false,
       isDeleted: false,
     ),
   );


   final allIngredients = await getMealIngredientFromShoppingList();
   debugLog(
       '✅ Dodano składnik: ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
       name: 'HiveService');
   debugLog('🛒 Liczba składników w shopping list: ${allIngredients.length}',
       name: 'HiveService');
   debugLog('📋 Składniki:', name: 'HiveService');
   for (final item in allIngredients) {
     debugLog(
         ' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
         name: 'HiveService');
   }
 }


 @override
 Future<void> removeMealIngredientFromShoppingList(
     ShoppingListMealIngredientModel item,
     {bool isOnline = false}) async {
   final key = '${item.meal.mealId}_${item.ingredient.ingredientId}';
   final model = _box.get(key);


   if (model != null) {
     await _box.put(
       key,
       model.copyWith(
         isSynced: false,
         isDeleted: true,
       ),
     );
   }


   final allIngredients = await getMealIngredientFromShoppingList();
   debugLog(
       '❌ Usunięto składnik: ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
       name: 'HiveService');
   debugLog('🛒 Liczba składników w shopping list: ${allIngredients.length}',
       name: 'HiveService');
   debugLog('📋 Składniki:', name: 'HiveService');
   for (final item in allIngredients) {
     debugLog(
         ' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
         name: 'HiveService');
   }
 }


 @override
 Future<List<ShoppingListMealIngredientModel>>
     getUnsyncedShoppingListMealIngredient() async {
   return _box.values
       .where((model) => !model.isSynced && !model.isDeleted)
       .toList();
 }


 @override
 Future<List<ShoppingListMealIngredientModel>>
     getUnsyncedChangesForShoppingListMealIngredient() async {
   return _box.values.where((model) => !model.isSynced).toList();
 }


 @override
 Future<void> markShoppingListMealIngredientAsSynced(
     String mealId, String ingredientId) async {
   final key = '${mealId}_$ingredientId';
   final model = _box.get(key);


 if (model != null) {
   await _box.put(
     key,
     model.copyWith(isSynced: true),
   ); 


     debugLog(
         '✅ Zaznaczono jako zsynchronizowany: $ingredientId (z posiłku: $mealId)',
         name: 'HiveService');
   }
 }


 @override
 Future<void> restoreMealIngredientToShoppingList(
     ShoppingListMealIngredientModel item) async {
   final key = _key(item);
   final existingModel = _box.get(key);


   final modelToSave = existingModel != null
       ? existingModel.copyWith(
           isDeleted: false,
           portionCount: item.portionCount,
           // isSynced zostaje jak jest (po „delete” powinno być false)
         )
       : item.copyWith(
           isDeleted: false,
           isSynced: false, // nowy wpis => do synchronizacji
         );


   await _box.put(key, modelToSave);




   // Logowanie stanu po przywróceniu składnika
   final allIngredients = await getMealIngredientFromShoppingList();
   final allItemsInBox = _box.values.toList();


   debugLog(
       '♻️ Przywrócono składnik: ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
       name: 'HiveService');
   debugLog('🔑 Klucz: $key', name: 'HiveService');
   debugLog('📦 Ilość wpisów w Hive: ${allItemsInBox.length}',
       name: 'HiveService');
   debugLog(
       '🛒 Liczba aktywnych składników w shopping list: ${allIngredients.length}',
       name: 'HiveService');
   debugLog('📋 Aktywne składniki:', name: 'HiveService');
   for (final item in allIngredients) {
     debugLog(
         ' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
         name: 'HiveService');
   }
   debugLog('🗑️ Usunięte składniki:', name: 'HiveService');
   for (final item in allItemsInBox.where((m) => m.isDeleted)) {
     debugLog(
         ' - ${item.ingredient.ingredientName} (z posiłku: ${item.meal.title})',
         name: 'HiveService');
   }
 }


 @override
 Future<void> clearSyncedDeletedItems() async {
   final keysToDelete = _box.keys.where((key) {
     final item = _box.get(key);
     return item != null && item.isDeleted && item.isSynced;
   }).toList();


   for (final key in keysToDelete) {
     await _box.delete(key);
     debugLog('🧹 Usunięto trwale zsynchronizowany składnik z kluczem: $key',
         name: 'HiveService');
   }
 }
}