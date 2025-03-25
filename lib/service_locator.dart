import 'package:mealapp/data/auth/repository/auth_repository_impl.dart';
import 'package:mealapp/data/auth/source/auth_firebase_service.dart';
import 'package:mealapp/data/category/repository/category_repository_impl.dart';
import 'package:mealapp/data/category/source/category_firebase_service.dart';
import 'package:mealapp/data/meal/repository/meal_repository_impl.dart';
import 'package:mealapp/data/meal/source/meal_firebase_service.dart';
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
import 'package:mealapp/domain/meal/usecases/favourite/is_favorite.dart';
import 'package:get_it/get_it.dart';
import 'package:mealapp/domain/meal/usecases/shopping_list/is_ingredient_in_shopping_list.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Services

  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

  sl.registerSingleton<CategoryFirebaseService>(CategoryFirebaseServiceImpl());

  sl.registerSingleton<MealFirebaseService>(MealFirebaseServiceImpl());

  // Repositories

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl());

  sl.registerLazySingleton<MealRepository>(() => MealRepositoryImpl());

  // Usecases

  sl.registerLazySingleton<SignupUsecase>(() => SignupUsecase());

  sl.registerLazySingleton<SigninUsecase>(() => SigninUsecase());

  sl.registerLazySingleton<SignoutUsecase>(() => SignoutUsecase());

  sl.registerLazySingleton<IsLoggedInUseCase>(() => IsLoggedInUseCase());

  sl.registerLazySingleton<SendPasswordResetEmailUseCase>(
      () => SendPasswordResetEmailUseCase());

  sl.registerLazySingleton<GetUserUsecase>(() => GetUserUsecase());

  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase());

  sl.registerLazySingleton<GetMealUseCase>(() => GetMealUseCase());

  sl.registerLazySingleton<GetMealByCategoryIdUseCase>(
      () => GetMealByCategoryIdUseCase());

  sl.registerLazySingleton<GetMealByTitleUseCase>(
      () => GetMealByTitleUseCase());

  sl.registerLazySingleton<AddOrRemoveFavoriteMealUseCase>(
      () => AddOrRemoveFavoriteMealUseCase());

  sl.registerLazySingleton<IsFavoriteUseCase>(() => IsFavoriteUseCase());

  sl.registerLazySingleton<GetFavoritesMealUseCase>(
      () => GetFavoritesMealUseCase());

  sl.registerLazySingleton<AddOrRemoveShoppingListIngredientUseCase>(
      () => AddOrRemoveShoppingListIngredientUseCase());

  sl.registerLazySingleton<IsIngredientInShoppingListUseCase>(
      () => IsIngredientInShoppingListUseCase());
      
  sl.registerLazySingleton<GetShoppingListUseCase>(
      () => GetShoppingListUseCase());
}
