import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/network/network_info_impl.dart';
import 'package:mealapp/data/auth/repository/local/hive_auth_repository_impl.dart';
import 'package:mealapp/data/auth/repository/network_aware_auth_repository.dart';
import 'package:mealapp/data/auth/repository/remote/firebase_auth_repository_impl.dart';
import 'package:mealapp/data/auth/source/local/auth_hive_service.dart';
import 'package:mealapp/data/auth/source/remote/auth_firebase_service.dart';
import 'package:mealapp/data/category/repository/remote/firebase_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/local/hive_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/network_aware_category_repository.dart';
import 'package:mealapp/data/category/source/remote/category_firebase_service.dart';
import 'package:mealapp/data/category/source/local/category_hive_service.dart';
import 'package:mealapp/data/meal/repository/remote/meal_firebase_repository_impl.dart';
import 'package:mealapp/data/meal/source/remote/meal_firebase_service.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/domain/auth/usecase/get_user.dart';
import 'package:mealapp/domain/auth/usecase/is_logged_in.dart';
import 'package:mealapp/domain/auth/usecase/send_password_reset_email.dart';
import 'package:mealapp/domain/auth/usecase/signin.dart';
import 'package:mealapp/domain/auth/usecase/signout.dart';
import 'package:mealapp/domain/auth/usecase/signup.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/domain/category/usecase/get_categories.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/domain/meal/usecase/favourite/add_or_remove_favorite_meal.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_all_ingredients.dart';
import 'package:mealapp/domain/meal/usecase/ingredient/get_ingredients_for_meal.dart';
import 'package:mealapp/domain/meal/usecase/shopping_list/add_or_remove_shopping_list_ingredient.dart';
import 'package:mealapp/domain/meal/usecase/favourite/get_favorites_meal.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_category_id.dart';
import 'package:mealapp/domain/meal/usecase/get_meal.dart';
import 'package:mealapp/domain/meal/usecase/get_meal_by_title.dart';
import 'package:mealapp/domain/meal/usecase/shopping_list/get_shopping_list.dart';
import 'package:get_it/get_it.dart';
import 'package:mealapp/domain/meal/usecase/shopping_list/is_ingredient_in_shopping_list.dart';

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

  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

  sl.registerSingleton<AuthHiveService>(AuthHiveServiceImpl());

  // Category services

  sl.registerSingleton<CategoryFirebaseService>(CategoryFirebaseServiceImpl());

  sl.registerSingleton<CategoryHiveService>(CategoryHiveServiceImpl());

  // Meal services

  sl.registerSingleton<MealFirebaseService>(MealFirebaseServiceImpl());

  // REPOSITORIES

  // Auth repositories

  sl.registerLazySingleton<FirebaseAuthRepositoryImpl>(() => FirebaseAuthRepositoryImpl());

  sl.registerLazySingleton<HiveAuthRepositoryImpl>(
      () => HiveAuthRepositoryImpl());

  sl.registerLazySingleton<AuthRepository>(() => NetworkAwareAuthRepository());

  // Category repositories

  sl.registerLazySingleton<FirebaseCategoryRepositoryImpl>(
      () => FirebaseCategoryRepositoryImpl());

  sl.registerLazySingleton<HiveCategoryRepositoryImpl>(
      () => HiveCategoryRepositoryImpl());

  sl.registerLazySingleton<CategoryRepository>(
      () => NetworkAwareCategoryRepository());

  // Meal repositories

  sl.registerLazySingleton<MealRepository>(() => MealRepositoryImpl());

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

  sl.registerLazySingleton<AddOrRemoveFavoriteMealUseCase>(
      () => AddOrRemoveFavoriteMealUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<GetFavoritesMealUseCase>(
      () => GetFavoritesMealUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<AddOrRemoveShoppingListIngredientUseCase>(
      () => AddOrRemoveShoppingListIngredientUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<IsIngredientInShoppingListUseCase>(
      () => IsIngredientInShoppingListUseCase(sl<MealRepository>()));

  sl.registerLazySingleton<GetShoppingListUseCase>(
      () => GetShoppingListUseCase(sl<MealRepository>()));
}
