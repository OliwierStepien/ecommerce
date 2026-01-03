import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/core/network/connection_monitor.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/network/network_info_impl.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/data/auth/repository/local/hive_auth_repository_impl.dart';
import 'package:mealapp/data/auth/repository/manager/auth_repository_manager.dart';
import 'package:mealapp/data/auth/repository/remote/firebase_auth_repository_impl.dart';
import 'package:mealapp/data/auth/source/local/hive_auth_service.dart';
import 'package:mealapp/data/auth/source/remote/firebase_auth_service.dart';
import 'package:mealapp/data/category/repository/remote/firebase_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/local/hive_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/manager/category_repository_manager.dart';
import 'package:mealapp/data/category/source/remote/firebase_category_service.dart';
import 'package:mealapp/data/category/source/local/hive_category_service.dart';
import 'package:mealapp/data/favorite_meal/repository/local/hive_favorite_meal_repository_impl.dart';
import 'package:mealapp/data/favorite_meal/repository/manager/favorite_meal_repository_manager.dart';
import 'package:mealapp/data/favorite_meal/repository/remote/firebase_favorite_meal_repository_impl.dart';
import 'package:mealapp/data/favorite_meal/repository/sync/favorite_meal_sync_service.dart';
import 'package:mealapp/data/favorite_meal/source/local/hive_favorite_meal_service.dart';
import 'package:mealapp/data/favorite_meal/source/remote/firebase_favorite_meal_service.dart';
import 'package:mealapp/data/freezer/repository/local/hive_freezer_item_repository_impl.dart';
import 'package:mealapp/data/freezer/repository/manager/freezer_item_repository_manager.dart';
import 'package:mealapp/data/freezer/repository/remote/firebase_freezer_item_repository_impl.dart';
import 'package:mealapp/data/freezer/repository/sync/freezer_item_sync_service.dart';
import 'package:mealapp/data/freezer/source/local/hive_freezer_item_service.dart';
import 'package:mealapp/data/freezer/source/remote/firebase_freezer_item_service.dart';
import 'package:mealapp/data/friends/repository/remote/friend_repository_impl.dart';
import 'package:mealapp/data/friends/source/remote/firebase_friend_service.dart';
import 'package:mealapp/data/grocery/repository/local/hive_grocery_repository_impl.dart';
import 'package:mealapp/data/grocery/repository/manager/grocery_repository_manager.dart';
import 'package:mealapp/data/grocery/repository/remote/firebase_grocery_repository_impl.dart';
import 'package:mealapp/data/grocery/source/local/hive_grocery_service.dart';
import 'package:mealapp/data/grocery/source/remote/firebase_grocery_service.dart';
import 'package:mealapp/data/ingredient/repository/local/hive_ingredient_repository_impl.dart';
import 'package:mealapp/data/ingredient/repository/manager/ingredient_repository_manager.dart';
import 'package:mealapp/data/ingredient/repository/remote/firebase_ingredient_repository_impl.dart';
import 'package:mealapp/data/ingredient/source/firebase_ingredient_service.dart';
import 'package:mealapp/data/meal/repository/local/hive_meal_repository_impl.dart';
import 'package:mealapp/data/meal/repository/manager/meal_repository_manager.dart';
import 'package:mealapp/data/meal/repository/remote/firebase_meal_repository_impl.dart';
import 'package:mealapp/data/meal/source/local/hive_meal_service.dart';
import 'package:mealapp/data/meal/source/remote/firebase_meal_service.dart';
import 'package:mealapp/data/planned_meal/repository/local/hive_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/manager/planned_meal_repository_manager.dart';
import 'package:mealapp/data/planned_meal/repository/remote/firebase_planned_meal_repository_impl.dart';
import 'package:mealapp/data/planned_meal/repository/sync/planned_meal_sync_service.dart';
import 'package:mealapp/data/planned_meal/source/local/hive_planned_meal_service.dart';
import 'package:mealapp/data/planned_meal/source/remote/firebase_planned_meal_service.dart';
import 'package:mealapp/data/planned_meal_share/repository/remote/firebase_meal_share_repository_impl.dart';
import 'package:mealapp/data/planned_meal_share/source/remote/firebase_meal_share_service.dart';
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
import 'package:mealapp/data/shopping_list_meal_ingredient_share/repository/firebase_shopping_list_share_repository_impl.dart';
import 'package:mealapp/data/shopping_list_meal_ingredient_share/source/remote/firebase_shopping_list_share_service.dart';
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
import 'package:mealapp/domain/freezer/repository/freezer_item_repository.dart';
import 'package:mealapp/domain/freezer/usecase/add_freezer_item_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/get_freezer_items_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/remove_freezer_item_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/restore_freezer_item_usecase.dart';
import 'package:mealapp/domain/freezer/usecase/update_freezer_item_usecase.dart';
import 'package:mealapp/domain/friends/repository/friend_repository.dart';
import 'package:mealapp/domain/friends/usecase/add_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_pending_invitations_count_usecase.dart';
import 'package:mealapp/domain/friends/usecase/get_pending_invitations_usecase.dart';
import 'package:mealapp/domain/friends/usecase/remove_friends_usecase.dart';
import 'package:mealapp/domain/friends/usecase/respond_to_invitation_usecase.dart';
import 'package:mealapp/domain/friends/usecase/send_friend_invitation_usecase.dart';
import 'package:mealapp/domain/grocery/repository/grocery_repository.dart';
import 'package:mealapp/domain/grocery/usecase/get_groceries.dart';
import 'package:mealapp/domain/ingredient/repository/ingredient_repository.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/domain/ingredient/usecase/get_all_ingredients.dart';
import 'package:mealapp/domain/ingredient/usecase/get_ingredients_for_meal.dart';
import 'package:mealapp/domain/favorite_meal/usecase/get_favorites_meal.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_category_id.dart';
import 'package:mealapp/domain/meal/usecase/get_meal.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_title.dart';
import 'package:mealapp/domain/planned_meal/usecase/add_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/get_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meal_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/remove_planned_meals_in_date_range_usecase.dart';
import 'package:mealapp/domain/planned_meal/usecase/reorder_planned_meals_usecase.dart';
import 'package:mealapp/domain/planned_meal_share/usecase/share_planned_meals_with_friend_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/repository/shopping_list_custom_item_repository.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/add_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/get_shopping_list_custom_item.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/remove_custom_item_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/restore_custom_item_to_shopping_list_use_case.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/update_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/repository/shopping_list_meal_ingredient_repository.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/get_shopping_list.dart';
import 'package:get_it/get_it.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/restore_to_shopping_list_usecase.dart';
import 'package:mealapp/core/sync/sync_controller.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient_share/usecase/share_shopping_list_with_friend_usecase.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/freezer/bloc/freezer_item_cubit.dart';
import 'package:mealapp/presentation/friends/bloc/friend_cubit.dart';
import 'package:mealapp/presentation/home/bloc/category_selection_cubit.dart';
import 'package:mealapp/presentation/home/bloc/meals_filter_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/planned_meal_share/bloc/meal_share_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';
import 'package:mealapp/presentation/shopping_list_share/shopping_list_share_cubit.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';

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

  // Ingredient services

  sl.registerSingleton<FirebaseIngredientService>(
      FirebaseIngredientServiceImpl());

  // Meal services

  sl.registerSingleton<FirebaseMealService>(FirebaseMealServiceImpl(
      ingredientService: sl<FirebaseIngredientService>()));

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

  // Friends services

  sl.registerLazySingleton<FirebaseFriendService>(
      () => FirebaseFriendServiceImpl());

// Meal Share service
  sl.registerSingleton<FirebaseMealShareService>(FirebaseMealShareService());

  // Shopping List Share service (NEW)
  sl.registerSingleton<FirebaseShoppingListShareService>(
    FirebaseShoppingListShareService(),
  );

  // Grocery services
  sl.registerSingleton<FirebaseGroceryService>(FirebaseGroceryServiceImpl());
  sl.registerSingleton<HiveGroceryService>(HiveGroceryServiceImpl());

// FREEZER services
  sl.registerSingleton<FirebaseFreezerItemService>(
    FirebaseFreezerItemServiceImpl(),
  );
  sl.registerSingleton<HiveFreezerItemService>(
    HiveFreezerItemServiceImpl(),
  );

  // REPOSITORIES

  // Auth repositories

  sl.registerLazySingleton<FirebaseAuthRepositoryImpl>(() =>
      FirebaseAuthRepositoryImpl(
          firebaseAuthService: sl<FirebaseAuthService>()));

  sl.registerLazySingleton<HiveAuthRepositoryImpl>(
      () => HiveAuthRepositoryImpl(hiveAuthService: sl<HiveAuthService>()));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryManager(
      remoteRepository: sl<FirebaseAuthRepositoryImpl>(),
      networkInfo: sl<NetworkInfo>()));

  // Category repositories

  sl.registerLazySingleton<FirebaseCategoryRepositoryImpl>(() =>
      FirebaseCategoryRepositoryImpl(
          firebaseCategoryService: sl<FirebaseCategoryService>()));

  sl.registerLazySingleton<HiveCategoryRepositoryImpl>(() =>
      HiveCategoryRepositoryImpl(
          hiveCategoryService: sl<HiveCategoryService>()));

  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryManager(
      localRepository: sl<HiveCategoryRepositoryImpl>(),
      remoteRepository: sl<FirebaseCategoryRepositoryImpl>(),
      networkInfo: sl<NetworkInfo>()));

  // Ingredient repositories

  sl.registerLazySingleton<FirebaseIngredientRepositoryImpl>(() =>
      FirebaseIngredientRepositoryImpl(
          firebaseIngredientService: sl<FirebaseIngredientService>()));

  sl.registerLazySingleton<HiveIngredientRepositoryImpl>(
    () => HiveIngredientRepositoryImpl(
      hiveMealService: sl<HiveMealService>(),
    ),
  );

  sl.registerLazySingleton<IngredientRepository>(() =>
      IngredientRepositoryManager(
          localRepository: sl<HiveIngredientRepositoryImpl>(),
          remoteRepository: sl<FirebaseIngredientRepositoryImpl>(),
          networkInfo: sl<NetworkInfo>()));

  // Meal repositories

  sl.registerLazySingleton<FirebaseMealRepositoryImpl>(() =>
      FirebaseMealRepositoryImpl(
          firebaseMealService: sl<FirebaseMealService>()));

  sl.registerLazySingleton<HiveMealRepositoryImpl>(
      () => HiveMealRepositoryImpl(hiveMealService: sl<HiveMealService>()));

  sl.registerLazySingleton<MealRepository>(() => MealRepositoryManager(
      localRepository: sl<HiveMealRepositoryImpl>(),
      remoteRepository: sl<FirebaseMealRepositoryImpl>(),
      networkInfo: sl<NetworkInfo>()));

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
  sl.registerLazySingleton<HiveFavoriteMealRepositoryImpl>(
      () => HiveFavoriteMealRepositoryImpl(
            hiveFavoriteMealService: sl<HiveFavoriteMealService>(),
          ));
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
              sl<HiveShoppingListMealIngredientService>()));
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
  sl.registerLazySingleton<HiveShoppingListCustomItemRepositoryImpl>(
      () => HiveShoppingListCustomItemRepositoryImpl(
            hiveShoppingListCustomItemService:
                sl<HiveShoppingListCustomItemService>(),
          ));
  sl.registerLazySingleton<ShoppingListCustomItemRepository>(() =>
      ShoppingListCustomItemRepositoryManager(
          localRepository: sl<HiveShoppingListCustomItemRepositoryImpl>(),
          remoteRepository: sl<FirebaseShoppingListCustomItemRepositoryImpl>(),
          networkInfo: sl<NetworkInfo>()));

  // Friend repositories

  sl.registerLazySingleton<FriendRepository>(
      () => FriendRepositoryImpl(firebaseService: sl()));

  sl.registerLazySingleton<FirebaseMealShareRepositoryImpl>(
    () => FirebaseMealShareRepositoryImpl(
      sl<FirebaseMealShareService>(),
      sl<HivePlannedMealService>(),
    ),
  );

  // Shopping List Share repository
  sl.registerLazySingleton<FirebaseShoppingListShareRepositoryImpl>(
    () => FirebaseShoppingListShareRepositoryImpl(
      sl<FirebaseShoppingListShareService>(),
      sl<HiveShoppingListMealIngredientService>(),
      sl<HiveShoppingListCustomItemService>(),
    ),
  );

  // Grocery repositories
  sl.registerLazySingleton<FirebaseGroceryRepositoryImpl>(
    () => FirebaseGroceryRepositoryImpl(service: sl<FirebaseGroceryService>()),
  );

  sl.registerLazySingleton<HiveGroceryRepositoryImpl>(
    () =>
        HiveGroceryRepositoryImpl(hiveGroceryService: sl<HiveGroceryService>()),
  );

  sl.registerLazySingleton<GroceryRepository>(
    () => GroceryRepositoryManager(
      localRepository: sl<HiveGroceryRepositoryImpl>(),
      remoteRepository: sl<FirebaseGroceryRepositoryImpl>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // FREEZER repositories
  sl.registerLazySingleton<FirebaseFreezerItemRepositoryImpl>(
    () => FirebaseFreezerItemRepositoryImpl(
      service: sl<FirebaseFreezerItemService>(),
    ),
  );

  sl.registerLazySingleton<HiveFreezerItemRepositoryImpl>(
    () => HiveFreezerItemRepositoryImpl(
      service: sl<HiveFreezerItemService>(),
    ),
  );

  sl.registerLazySingleton<FreezerItemRepository>(
    () => FreezerItemRepositoryManager(
      localRepository: sl<HiveFreezerItemRepositoryImpl>(),
      remoteRepository: sl<FirebaseFreezerItemRepositoryImpl>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

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
      () => GetAllIngredientsUseCase(sl<IngredientRepository>()));

  sl.registerLazySingleton<GetIngredientsForMealUseCase>(
      () => GetIngredientsForMealUseCase(sl<IngredientRepository>()));

  // Meal usecases

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
  sl.registerLazySingleton<RemovePlannedMealsInDateRangeUseCase>(
      () => RemovePlannedMealsInDateRangeUseCase(sl<PlannedMealRepository>()));
  sl.registerLazySingleton<ReorderPlannedMealsUseCase>(
      () => ReorderPlannedMealsUseCase(sl<PlannedMealRepository>()));

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

  sl.registerLazySingleton<RestoreToShoppingListUseCase>(() =>
      RestoreToShoppingListUseCase(sl<ShoppingListMealIngredientRepository>()));

  // Shopping List Custom Item usecases

  sl.registerLazySingleton<AddCustomItemToShoppingListUseCase>(() =>
      AddCustomItemToShoppingListUseCase(
          sl<ShoppingListCustomItemRepository>()));

  sl.registerLazySingleton<RemoveCustomItemFromShoppingListUseCase>(() =>
      RemoveCustomItemFromShoppingListUseCase(
          sl<ShoppingListCustomItemRepository>()));

  sl.registerLazySingleton<GetShoppingListCustomItemUseCase>(() =>
      GetShoppingListCustomItemUseCase(sl<ShoppingListCustomItemRepository>()));

  sl.registerLazySingleton<RestoreCustomItemToShoppingListUseCase>(() =>
      RestoreCustomItemToShoppingListUseCase(
          sl<ShoppingListCustomItemRepository>()));

  sl.registerLazySingleton<UpdateCustomItemToShoppingListUseCase>(() =>
      UpdateCustomItemToShoppingListUseCase(
          sl<ShoppingListCustomItemRepository>()));

  // Friends usecases

  sl.registerFactory<GetFriendsUseCase>(() => GetFriendsUseCase(sl()));

  sl.registerFactory<AddFriendUseCase>(() => AddFriendUseCase(sl()));

  sl.registerFactory<RemoveFriendUseCase>(() => RemoveFriendUseCase(sl()));

  sl.registerFactory<SendFriendInvitationUseCase>(
      () => SendFriendInvitationUseCase(sl()));

  sl.registerFactory<GetPendingInvitationsUseCase>(
      () => GetPendingInvitationsUseCase(sl()));

  sl.registerFactory<RespondToInvitationUseCase>(
      () => RespondToInvitationUseCase(sl()));

  sl.registerFactory<GetPendingInvitationsCountUseCase>(
      () => GetPendingInvitationsCountUseCase(sl()));

  // Meal Share usecase
  sl.registerFactory<SharePlannedMealsWithFriendUseCase>(
    () => SharePlannedMealsWithFriendUseCase(
        sl<FirebaseMealShareRepositoryImpl>()),
  );

  // Shopping List Share usecase (NEW)
  sl.registerFactory<ShareShoppingListWithFriendUseCase>(
    () => ShareShoppingListWithFriendUseCase(
      sl<FirebaseShoppingListShareRepositoryImpl>(),
    ),
  );

  // Grocery usecases
  sl.registerLazySingleton<GetGroceriesUseCase>(
    () => GetGroceriesUseCase(sl<GroceryRepository>()),
  );

// FREEZER usecases
  sl.registerLazySingleton<AddFreezerItemUseCase>(
    () => AddFreezerItemUseCase(sl<FreezerItemRepository>()),
  );

  sl.registerLazySingleton<GetFreezerItemsUseCase>(
    () => GetFreezerItemsUseCase(sl<FreezerItemRepository>()),
  );

  sl.registerLazySingleton<RemoveFreezerItemUseCase>(
    () => RemoveFreezerItemUseCase(sl<FreezerItemRepository>()),
  );

  sl.registerLazySingleton<RestoreFreezerItemUseCase>(
    () => RestoreFreezerItemUseCase(sl<FreezerItemRepository>()),
  );

  sl.registerLazySingleton<UpdateFreezerItemUseCase>(
    () => UpdateFreezerItemUseCase(sl<FreezerItemRepository>()),
  );

  // CUBIT

  // ✅ Button state cubit
  sl.registerFactory(
    () => ButtonStateCubit(),
  );

  // ✅ Splash cubit
  sl.registerFactory(
    () => SplashCubit(
      connectionMonitor: sl<ConnectionMonitor>(),
      isLoggedInUseCase: sl<IsLoggedInUseCase>(),
    ),
  );

  // ✅ Category display cubit
  sl.registerFactory(
    () => CategoriesDisplayCubit(
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
    ),
  );

  // ✅ Category selection cubit (dla filtrowania po kategoriach)
  sl.registerFactory(
    () => CategorySelectionCubit(),
  );

  // ✅ Meals filter cubit — inicjalizowany dynamicznie w MealsGridView
// param1: przekazuje listę wszystkich posiłków (List<MealEntity>) do filtrowania
// param2: niewykorzystywany (void), wymagany tylko przez sygnaturę registerFactoryParam
  sl.registerFactoryParam<MealsFilterCubit, List<MealEntity>, void>(
    (allMeals, _) => MealsFilterCubit(allMeals: allMeals),
  );

  // ✅ User Info Display Cubit
  sl.registerFactory(
    () => UserInfoDisplayCubit(
      getUserUsecase: sl<GetUserUsecase>(),
    ),
  );

  // ✅ Favorite Meals Cubit
  sl.registerFactory(
    () => FavoriteMealsCubit(
      getFavoritesMealUseCase: sl<GetFavoritesMealUseCase>(),
      addFavoriteMealUseCase: sl<AddFavoriteMealUseCase>(),
      removeFavoriteMealUseCase: sl<RemoveFavoriteMealUseCase>(),
    ),
  );

  // ✅ Meals Display Cubit
  sl.registerFactory(
    () => MealsDisplayCubit(
      useCase: sl<GetMealUseCase>(),
    ),
  );

  // ✅ Shopping List Meal Ingredient Cubit
  sl.registerFactory(() => ShoppingListMealIngredientCubit(
        addUseCase: sl<AddToShoppingListUseCase>(),
        removeUseCase: sl<RemoveFromShoppingListUseCase>(),
        restoreUseCase: sl<RestoreToShoppingListUseCase>(),
        getUseCase: sl<GetShoppingListUseCase>(),
        syncStrategy: sl<SyncStrategy>(),
      ));

  // ✅ Shopping List Custom Item Cubit
  sl.registerFactory(() => ShoppingListCustomItemCubit(
        addUseCase: sl<AddCustomItemToShoppingListUseCase>(),
        removeUseCase: sl<RemoveCustomItemFromShoppingListUseCase>(),
        restoreUseCase: sl<RestoreCustomItemToShoppingListUseCase>(),
        getUseCase: sl<GetShoppingListCustomItemUseCase>(),
        updateUseCase: sl<UpdateCustomItemToShoppingListUseCase>(),
        syncStrategy: sl<SyncStrategy>(),
      ));

  // ✅ Vegetarian filter cubit
  sl.registerFactory(
    () => VegetarianFilterCubit(),
  );

  // ✅ Planned meals cubit
  sl.registerFactory(() => PlannedMealsCubit(
        getPlannedMeals: sl(),
        addPlannedMealUseCase: sl(),
        removePlannedMealUseCase: sl(),
        removeInRangeUseCase: sl(),
        reorderPlannedMealsUseCase: sl(),
      ));

  // Friends cubit

  sl.registerFactory<FriendsCubit>(() => FriendsCubit(
        getFriendsUseCase: sl<GetFriendsUseCase>(),
        addFriendUseCase: sl<AddFriendUseCase>(),
        removeFriendUseCase: sl<RemoveFriendUseCase>(),
        sendFriendInvitationUseCase: sl<SendFriendInvitationUseCase>(),
        getPendingInvitationsUseCase: sl<GetPendingInvitationsUseCase>(),
        respondToInvitationUseCase: sl<RespondToInvitationUseCase>(),
        getPendingInvitationsCountUseCase:
            sl<GetPendingInvitationsCountUseCase>(),
      ));

  // Meal Share cubit

  sl.registerFactory<MealShareCubit>(() => MealShareCubit(
        sl<SharePlannedMealsWithFriendUseCase>(),
      ));

// Shopping List Share cubit (NEW)
  sl.registerFactory<ShoppingListShareCubit>(
    () => ShoppingListShareCubit(
      sl<ShareShoppingListWithFriendUseCase>(),
    ),
  );

// Freezer cubit
  sl.registerFactory(
    () => FreezerItemCubit(
      addUseCase: sl<AddFreezerItemUseCase>(),
      removeUseCase: sl<RemoveFreezerItemUseCase>(),
      restoreUseCase: sl<RestoreFreezerItemUseCase>(),
      getUseCase: sl<GetFreezerItemsUseCase>(),
      updateUseCase: sl<UpdateFreezerItemUseCase>(),
      syncStrategy: sl<SyncStrategy>(),
    ),
  );

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
    remoteRepo: sl<FirebaseShoppingListMealIngredientRepositoryImpl>(),
    remoteService: sl<FirebaseShoppingListMealIngredientService>(), // ⬅️ DODANE
    networkInfo: sl<NetworkInfo>(),
  );

// Shopping List Custom Item
  final shoppingListCustomItemSyncService = ShoppingListCustomItemSyncService(
    remoteRepository: sl<FirebaseShoppingListCustomItemRepositoryImpl>(),
    remoteService: sl<FirebaseShoppingListCustomItemService>(),
    networkInfo: sl<NetworkInfo>(),
  );

// Freezer
  final freezerItemSyncService = FreezerItemSyncService(
    remoteRepository: sl<FirebaseFreezerItemRepositoryImpl>(),
    remoteService: sl<FirebaseFreezerItemService>(),
    networkInfo: sl<NetworkInfo>(),
  );

// SyncStrategy

// Najpierw zarejestruj controller (już bez strategii w konstruktorze)
  sl.registerLazySingleton<SyncController>(() => SyncController(
        plannedMealSyncService: plannedSyncService,
        favoriteMealSyncService: favoriteSyncService,
        shoppingListSyncService: shoppingListMealIngredientSyncService,
        customItemsSyncService: shoppingListCustomItemSyncService,

        // ✅ FREEZER
        freezerItemSyncService: freezerItemSyncService,

        hiveService: sl<HiveShoppingListMealIngredientService>(),
        customItemsHiveService: sl<HiveShoppingListCustomItemService>(),

        // ✅ FREEZER
        freezerHiveService: sl<HiveFreezerItemService>(),
      ));

// Teraz strategia, która odwołuje się do kontrolera
  sl.registerLazySingleton<SyncStrategy>(() => DebounceSyncStrategy(
        syncCallback: () => sl<SyncController>().syncData(),
      ));

// ConnectionMonitor (używa strategii przy przywróceniu sieci)
  final connectionMonitor = ConnectionMonitor(
    networkInfo: sl<NetworkInfo>(),
    syncServices: [
      plannedSyncService,
      favoriteSyncService,
      shoppingListMealIngredientSyncService,
      shoppingListCustomItemSyncService,
      freezerItemSyncService,
    ],
  );

// Register sync services & monitor
  sl.registerSingleton(plannedSyncService);
  sl.registerSingleton(favoriteSyncService);
  sl.registerSingleton(shoppingListMealIngredientSyncService);
  sl.registerSingleton(shoppingListCustomItemSyncService);
  sl.registerSingleton(connectionMonitor);
  sl.registerSingleton(freezerItemSyncService);
}
