import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/domain/meal/usecase/get_meal.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/add_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/get_shopping_list_custom_item.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/remove_custom_item_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/restore_custom_item_to_shopping_list_use_case.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/get_shopping_list.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/restore_to_shopping_list_usecase.dart';
import 'package:mealapp/my_app.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';
import 'package:mealapp/service_locator.dart';

/// Wrapper odpowiedzialny za dostarczenie Cubitów/Bloców do aplikacji
class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SplashCubit>()),
        BlocProvider(create: (context) => ButtonStateCubit()),
        BlocProvider(create: (context) => FavoriteMealsCubit()),
        BlocProvider(
          create: (context) => ShoppingListMealIngredientCubit(
            addUseCase: sl<AddToShoppingListUseCase>(),
            removeUseCase: sl<RemoveFromShoppingListUseCase>(),
            restoreUseCase: sl<RestoreToShoppingListUseCase>(),
            getUseCase: sl<GetShoppingListUseCase>(),
            syncStrategy: sl<SyncStrategy>(),
          ),
        ),
        BlocProvider(
          create: (context) => ShoppingListCustomItemCubit(
            addUseCase: sl<AddCustomItemToShoppingListUseCase>(),
            removeUseCase: sl<RemoveCustomItemFromShoppingListUseCase>(),
            restoreUseCase: sl<RestoreCustomItemToShoppingListUseCase>(),
            getUseCase: sl<GetShoppingListCustomItemUseCase>(),
            syncStrategy: sl<SyncStrategy>(),
          ),
        ),
        BlocProvider(
          create: (context) => CategoriesDisplayCubit()..displayCategories(),
        ),
        BlocProvider(create: (_) => VegetarianFilterCubit()),
        BlocProvider(
          create: (context) => MealsDisplayCubit(useCase: sl<GetMealUseCase>()),
        ),
        BlocProvider(create: (_) => PlannedMealsCubit()),
      ],
      child: const MyApp(),
    );
  }
}