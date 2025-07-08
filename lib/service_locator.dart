import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/network/network_info_impl.dart';
import 'package:mealapp/data/auth/repository/local/hive_auth_repository_impl.dart';
import 'package:mealapp/data/auth/repository/auth_repository_manager.dart';
import 'package:mealapp/data/auth/repository/remote/firebase_auth_repository_impl.dart';
import 'package:mealapp/data/auth/source/local/hive_auth_service.dart';
import 'package:mealapp/data/auth/source/remote/firebase_auth_service.dart';
import 'package:mealapp/data/category/repository/remote/firebase_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/local/hive_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/category_repository_manager.dart';
import 'package:mealapp/data/category/source/remote/firebase_category_service.dart';
import 'package:mealapp/data/category/source/local/hive_category_service.dart';
import 'package:mealapp/data/favorite_meal/repository/local/hive_favorite_meal_repository_impl.dart';
import 'package:mealapp/data/favorite_meal/repository/manager/favorite_meal_repository_manager.dart';
import 'package:mealapp/data/favorite_meal/repository/remote/firebase_favorite_meal_repository_impl.dart';
import 'package:mealapp/data/favorite_meal/repository/sync/favorite_meal_sync_service.dart';
import 'package:mealapp/data/favorite_meal/source/local/hive_favorite_meal_service.dart';
import 'package:mealapp/data/favorite_meal/source/remote/firebase_favorite_meal_service.dart';
import 'package:mealapp/data/meal/repository/local/hive_meal_repository_impl.dart';
import 'package:mealapp/data/meal/repository/meal_repository_manager.dart';
import 'package:mealapp/data/meal/repository/remote/firebase_meal_repository_impl.dart';
import 'package:mealapp/data/meal/source/local/hive_meal_service.dart';
import 'package:mealapp/data/meal/source/remote/firebase_meal_service.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/manager/planned_meal_repository_manager.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/sync/planned_meal_sync_service.dart';
import 'package:mealapp/data/planned_meal/source/local/hive_planned_meal_service.dart';
import 'package:mealapp/data/planned_meal/source/remote/firebase_planned_meal_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/local/hive_shopping_list_custom_item_repository.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/manager/shopping_list_custom_item_repository_manager.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/remote/firebase_shopping_list_custom_item_repository.dart';
import 'package:mealapp/data/shopping_list_custom_item/repository/sync/shopping_list_custom_item_sync_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/local/hive_shopping_list_custom_item_service.dart';
import 'package:mealapp/data/shopping_list_custom_item/source/remote/firebase_shopping_list_custom_item_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/local/hive_shopping_list_meal_ingredient_repository.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/manager/shopping_list_meal_ingredient_repository_manager.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/remote/firebase_shopping_list_meal_ingredient_repository.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/repository/sync/shopping_list_meal_ingredient_sync_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/local/hive_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient/source/remote/firebase_shopping_list_meal_ingredient_service.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/domain/auth/usecase/get_user.dart';
import 'package:mealapp/domain/auth/usecase/is_logged_in.dart';
import 'package:mealapp/domain/auth/usecase/send_password_reset_email.dart';
import 'package:mealapp/domain/auth/usecase/signin.dart';
import 'package:mealapp/domain/auth/usecase/signout.dart';
import 'package:mealapp/domain/auth/usecase/signup.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/domain/category/usecase/get_categories.dart';
import 'package:mealapp/domain/favorite_meal/repository/favorite_meal_repository.dart';
import 'package:mealapp/domain/favorite_meal/usecase/add_favorite_meal.dart';
import 'package:mealapp/domain/favorite_meal/usecase/remove_favorite_meal.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_ingredients_for_meal.dart';
import 'package:mealapp/domain/favorite_meal/usecase/get_favorites_meal.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_category_id.dart';
import 'package:mealapp/domain/meal/usecase/get_meal.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_title.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/add_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/get_shopping_list_custom_item.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/remove_custom_item_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/get_shopping_list.dart';
import 'package:get_it/get_it.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';
import 'package:mealapp/domain/planned_meal/usecase/planned_meal_usecase.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
// Internet connection

  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );

  // SERVICES

  // Auth services

  sl.registerSingleton<FirebaseAuthService>(FirebaseAuthServiceImpl());

  sl.registerSingleton<HiveAuthService>(HiveAuthServiceImpl());

  // Category services

  sl.registerSingleton<FirebaseCategoryService>(FirebaseCategoryServiceImpl());

  sl.registerSingleton<HiveCategoryService>(HiveCategoryServiceImpl());

  // Meal services

  sl.registerSingleton<FirebaseMealService>(FirebaseMealServiceImpl());

  sl.registerSingleton<HiveMealService>(HiveMealServiceImpl());

  // Planned Meal services

  sl.registerSingleton<FirebasePlannedMealService>(
      FirebasePlannedMealServiceImpl());
  sl.registerSingleton<HivePlannedMealService>(HivePlannedMealServiceImpl());

  // Favorite Meal services

  sl.registerSingleton<FirebaseFavoriteMealService>(
      FirebaseFavoriteMealServiceImpl());
  sl.registerSingleton<HiveFavoriteMealService>(HiveFavoriteMealServiceImpl());

  // Shopping List Meal Ingredient services

  sl.registerSingleton<FirebaseShoppingListMealIngredientService>(
      FirebaseShoppingListMealIngredientServiceImpl());
  sl.registerSingleton<HiveShoppingListMealIngredientService>(
      HiveShoppingListMealIngredientServiceImpl());

  // Shopping List Custom Item services

  sl.registerSingleton<FirebaseShoppingListCustomItemService>(
      FirebaseShoppingListCustomItemServiceImpl());
  sl.registerSingleton<HiveShoppingListCustomItemService>(
      HiveShoppingListCustomItemServiceImpl());

  // REPOSITORIES

  // Auth repositories

  sl.registerLazySingleton<FirebaseAuthRepositoryImpl>(
      () => FirebaseAuthRepositoryImpl());

  sl.registerLazySingleton<HiveAuthRepositoryImpl>(
      () => HiveAuthRepositoryImpl());

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryManager());

  // Category repositories

  sl.registerLazySingleton<FirebaseCategoryRepositoryImpl>(
      () => FirebaseCategoryRepositoryImpl());

  sl.registerLazySingleton<HiveCategoryRepositoryImpl>(
      () => HiveCategoryRepositoryImpl());

  sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryManager());

  // Meal repositories

  sl.registerLazySingleton<FirebaseMealRepositoryImpl>(
      () => FirebaseMealRepositoryImpl());

  sl.registerLazySingleton<HiveMealRepositoryImpl>(
      () => HiveMealRepositoryImpl());

  sl.registerLazySingleton<MealRepository>(() => MealRepositoryManager());

  // Planned Meal repositories

  sl.registerLazySingleton<FirebasePlannedMealRepositoryImpl>(() =>
      FirebasePlannedMealRepositoryImpl(
          firebasePlannedMealService: sl<FirebasePlannedMealService>()));
  sl.registerLazySingleton<HivePlannedMealRepositoryImpl>(() =>
      HivePlannedMealRepositoryImpl(
          hivePlannedMealService: sl<HivePlannedMealService>(),
          networkInfo: sl<NetworkInfo>()));
  sl.registerLazySingleton<PlannedMealRepository>(() =>
      PlannedMealRepositoryManager(
          localRepository: sl<HivePlannedMealRepositoryImpl>(),
          remoteRepository: sl<FirebasePlannedMealRepositoryImpl>(),
          networkInfo: sl<NetworkInfo>()));

  // Favorite Meal repositories

  sl.registerLazySingleton<FirebaseFavoriteMealRepositoryImpl>(() =>
      FirebaseFavoriteMealRepositoryImpl(
          firebaseFavoriteMealService: sl<FirebaseFavoriteMealService>()));
  sl.registerLazySingleton<HiveFavoriteMealRepositoryImpl>(() =>
      HiveFavoriteMealRepositoryImpl(
          hiveFavoriteMealService: sl<HiveFavoriteMealService>(),
          networkInfo: sl<NetworkInfo>()));
  sl.registerLazySingleton<FavoriteMealRepository>(() =>
      FavoriteMealRepositoryManager(
          localRepository: sl<HiveFavoriteMealRepositoryImpl>(),
          remoteRepository: sl<FirebaseFavoriteMealRepositoryImpl>(),
          networkInfo: sl<NetworkInfo>()));

  // Shopping List Meal Ingredient repositories

  sl.registerLazySingleton<FirebaseShoppingListMealIngredientRepositoryImpl>(
      () => FirebaseShoppingListMealIngredientRepositoryImpl(
            firebaseShoppingListMealIngredientService:
                sl<FirebaseShoppingListMealIngredientService>(),
          ));
  sl.registerLazySingleton<HiveShoppingListMealIngredientRepositoryImpl>(() =>
      HiveShoppingListMealIngredientRepositoryImpl(
          hiveShoppingListMealIngredientService:
              sl<HiveShoppingListMealIngredientService>(),
          networkInfo: sl<NetworkInfo>()));
  sl.registerLazySingleton<ShoppingListMealIngredientRepository>(() =>
      ShoppingListMealIngredientRepositoryManager(
          localRepository: sl<HiveShoppingListMealIngredientRepositoryImpl>(),
          remoteRepository:
              sl<FirebaseShoppingListMealIngredientRepositoryImpl>(),
          networkInfo: sl<NetworkInfo>()));

  // Shopping List Custom Item repositories

  sl.registerLazySingleton<FirebaseShoppingListCustomItemRepositoryImpl>(
      () => FirebaseShoppingListCustomItemRepositoryImpl(
            firebaseShoppingListCustomItemService:
                sl<FirebaseShoppingListCustomItemService>(),
          ));
  sl.registerLazySingleton<HiveShoppingListCustomItemRepositoryImpl>(() =>
      HiveShoppingListCustomItemRepositoryImpl(
          hiveShoppingListCustomItemService:
              sl<HiveShoppingListCustomItemService>(),
          networkInfo: sl<NetworkInfo>()));
  sl.registerLazySingleton<ShoppingListCustomItemRepository>(() =>
      ShoppingListCustomItemRepositoryManager(
          localRepository: sl<HiveShoppingListCustomItemRepositoryImpl>(),
          remoteRepository: sl<FirebaseShoppingListCustomItemRepositoryImpl>(),
          networkInfo: sl<NetworkInfo>()));

  // USECASES

  // Auth usecases

  sl.registerLazySingleton<SignupUsecase>(
      () => SignupUsecase(sl<AuthRepository>()));

  sl.registerLazySingleton<SigninUsecase>(
      () => SigninUsecase(sl<AuthRepository>()));

  sl.registerLazySingleton<SignoutUsecase>(
      () => SignoutUsecase(sl<AuthRepository>()));

  sl.registerLazySingleton<IsLoggedInUseCase>(
      () => IsLoggedInUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton<SendPasswordResetEmailUseCase>(
      () => SendPasswordResetEmailUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton<GetUserUsecase>(
      () => GetUserUsecase(sl<AuthRepository>()));

  // Category usecases

  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<CategoryRepository>()),
  );

  // Meal usecases

  sl.registerLazySingleton<GetAllIngredientsUseCase>(
      () => GetAllIngredientsUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<GetIngredientsForMealUseCase>(
      () => GetIngredientsForMealUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<GetMealUseCase>(
      () => GetMealUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<GetMealByCategoryIdUseCase>(
      () => GetMealByCategoryIdUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<GetMealByTitleUseCase>(
      () => GetMealByTitleUseCase(sl<MealRepository>()));

  // Planned Meal usecases

  sl.registerLazySingleton<GetPlannedMealsUseCase>(
      () => GetPlannedMealsUseCase(sl<PlannedMealRepository>()));
  sl.registerLazySingleton<AddPlannedMealUseCase>(
      () => AddPlannedMealUseCase(sl<PlannedMealRepository>()));
  sl.registerLazySingleton<RemovePlannedMealUseCase>(
      () => RemovePlannedMealUseCase(sl<PlannedMealRepository>()));

// Favorite Meal usecases
  sl.registerLazySingleton<AddFavoriteMealUseCase>(
      () => AddFavoriteMealUseCase(sl<FavoriteMealRepository>()));
  sl.registerLazySingleton<RemoveFavoriteMealUseCase>(
      () => RemoveFavoriteMealUseCase(sl<FavoriteMealRepository>()));
  sl.registerLazySingleton<GetFavoritesMealUseCase>(
      () => GetFavoritesMealUseCase(sl<FavoriteMealRepository>()));

  // Shopping List Meal Ingredient usecases

  sl.registerLazySingleton<AddToShoppingListUseCase>(() =>
      AddToShoppingListUseCase(sl<ShoppingListMealIngredientRepository>()));

  sl.registerLazySingleton<RemoveFromShoppingListUseCase>(() =>
      RemoveFromShoppingListUseCase(
          sl<ShoppingListMealIngredientRepository>()));

  sl.registerLazySingleton<GetShoppingListUseCase>(
      () => GetShoppingListUseCase(sl<ShoppingListMealIngredientRepository>()));

  // Shopping List Custom Item usecases

  sl.registerLazySingleton<AddCustomItemToShoppingListUseCase>(() =>
      AddCustomItemToShoppingListUseCase(sl<ShoppingListCustomItemRepository>()));

  sl.registerLazySingleton<RemoveCustomItemFromShoppingListUseCase>(() =>
      RemoveCustomItemFromShoppingListUseCase(
          sl<ShoppingListCustomItemRepository>()));

  sl.registerLazySingleton<GetShoppingListCustomItemUseCase>(
      () => GetShoppingListCustomItemUseCase(sl<ShoppingListCustomItemRepository>()));

  // SYNC SERVICES & CONNECTION MONITOR

// Planned Meal
  final plannedSyncService = PlannedMealSyncService(
    firebaseRepo: sl<FirebasePlannedMealRepositoryImpl>(),
    hiveRepo: sl<HivePlannedMealRepositoryImpl>(),
    networkInfo: sl<NetworkInfo>(),
  );

// Favorite Meal
  final favoriteSyncService = FavoriteMealSyncService(
    firebaseRepo: sl<FirebaseFavoriteMealRepositoryImpl>(),
    hiveRepo: sl<HiveFavoriteMealRepositoryImpl>(),
    networkInfo: sl<NetworkInfo>(),
  );

  // Shopping List Meal Ingredient

  final shoppingListMealIngredientSyncService =
      ShoppingListMealIngredientSyncService(
    firebaseRepo: sl<FirebaseShoppingListMealIngredientRepositoryImpl>(),
    hiveRepo: sl<HiveShoppingListMealIngredientRepositoryImpl>(),
    networkInfo: sl<NetworkInfo>(),
  );

  // Shopping List Meal Ingredient

  final shoppingListCustomItemSyncService = ShoppingListCustomItemSyncService(
    remoteRepository: sl<FirebaseShoppingListCustomItemRepositoryImpl>(),
    hiveService: sl<HiveShoppingListCustomItemService>(),
    networkInfo: sl<NetworkInfo>(),
  );

// Single ConnectionMonitor for all services
  final connectionMonitor = ConnectionMonitor(
    networkInfo: sl<NetworkInfo>(),
    syncServices: [
      plannedSyncService,
      favoriteSyncService,
      shoppingListMealIngredientSyncService,
      shoppingListCustomItemSyncService
    ],
  );

  connectionMonitor.startMonitoring();

// Register services
  sl.registerSingleton(plannedSyncService);
  sl.registerSingleton(favoriteSyncService);
  sl.registerSingleton(shoppingListMealIngredientSyncService);
  sl.registerSingleton(shoppingListCustomItemSyncService);
  sl.registerSingleton(connectionMonitor);
}
