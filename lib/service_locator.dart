import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mealapp/core/network/network_info.dart';
import 'package:mealapp/core/network/network_info_impl.dart';
import 'package:mealapp/data/auth/repository/auth_repository_impl.dart';
import 'package:mealapp/data/auth/source/auth_firebase_service.dart';
import 'package:mealapp/data/category/repository/remote/firebase_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/local/hive_category_repository_impl.dart';
import 'package:mealapp/data/category/repository/network_aware_category_repository.dart';
import 'package:mealapp/data/category/source/remote/category_firebase_service.dart';
import 'package:mealapp/data/category/source/local/category_hive_service.dart';
import 'package:mealapp/data/meal/repository/remote/meal_firebase_repository_impl.dart';
import 'package:mealapp/data/meal/source/remote/meal_firebase_service.dart';
import 'package:mealapp/domain/auth/repository/auth.dart';
import 'package:mealapp/domain/auth/usecases/get_user.dart';
import 'package:mealapp/domain/auth/usecases/is_logged_in.dart';
import 'package:mealapp/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mealapp/domain/auth/usecases/signin.dart';
import 'package:mealapp/domain/auth/usecases/signout.dart';
import 'package:mealapp/domain/auth/usecases/signup.dart';
import 'package:mealapp/domain/category/repository/category_repository.dart';
import 'package:mealapp/domain/category/usecases/get_categories.dart';
import 'package:mealapp/domain/meal/repository/meal_repository.dart';
import 'package:mealapp/domain/meal/usecases/favourite/add_or_remove_favorite_meal.dart';
import 'package:mealapp/domain/meal/usecases/shopping_list/add_or_remove_shopping_list_ingredient.dart';
import 'package:mealapp/domain/meal/usecases/favourite/get_favorites_meal.dart';
import 'package:mealapp/domain/meal/usecases/get_meal_by_category_id.dart';
import 'package:mealapp/domain/meal/usecases/get_meal.dart';
import 'package:mealapp/domain/meal/usecases/get_meal_by_title.dart';
import 'package:mealapp/domain/meal/usecases/shopping_list/get_shopping_list.dart';
import 'package:get_it/get_it.dart';
import 'package:mealapp/domain/meal/usecases/shopping_list/is_ingredient_in_shopping_list.dart';

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

  // Category services

  sl.registerSingleton<CategoryFirebaseService>(CategoryFirebaseServiceImpl());

  sl.registerSingleton<CategoryHiveService>(CategoryHiveServiceImpl());

  // Meal services

  sl.registerSingleton<MealFirebaseService>(MealFirebaseServiceImpl());

  // REPOSITORIES

  // Auth repositories

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

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

  sl.registerLazySingleton<SignupUsecase>(() => SignupUsecase());

  sl.registerLazySingleton<SigninUsecase>(() => SigninUsecase());

  sl.registerLazySingleton<SignoutUsecase>(() => SignoutUsecase());

  sl.registerLazySingleton<IsLoggedInUseCase>(() => IsLoggedInUseCase());

  sl.registerLazySingleton<SendPasswordResetEmailUseCase>(
      () => SendPasswordResetEmailUseCase());

  sl.registerLazySingleton<GetUserUsecase>(() => GetUserUsecase());

  // Category usecases

  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase());

  // Meal usecases

  sl.registerLazySingleton<GetMealUseCase>(() => GetMealUseCase());

  sl.registerLazySingleton<GetMealByCategoryIdUseCase>(
      () => GetMealByCategoryIdUseCase());

  sl.registerLazySingleton<GetMealByTitleUseCase>(
      () => GetMealByTitleUseCase());

  sl.registerLazySingleton<AddOrRemoveFavoriteMealUseCase>(
      () => AddOrRemoveFavoriteMealUseCase());

  sl.registerLazySingleton<GetFavoritesMealUseCase>(
      () => GetFavoritesMealUseCase());

  sl.registerLazySingleton<AddOrRemoveShoppingListIngredientUseCase>(
      () => AddOrRemoveShoppingListIngredientUseCase());

  sl.registerLazySingleton<IsIngredientInShoppingListUseCase>(
      () => IsIngredientInShoppingListUseCase());

  sl.registerLazySingleton<GetShoppingListUseCase>(
      () => GetShoppingListUseCase());
}
