import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/core/configs/theme/app_theme.dart';
import 'package:mealapp/core/sync/sync_strategy.dart';
import 'package:mealapp/domain/meal/usecase/get_meal.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/add_custom_item_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/remove_custom_item_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_custom_item/usecase/restore_custom_item_to_shopping_list_use_case.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/add_to_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/remove_from_shopping_list_usecase.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient/usecase/restore_to_shopping_list_usecase.dart';
import 'package:mealapp/l10n/app_localizations.dart';
import 'package:mealapp/l10n/l10n.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';
import 'package:mealapp/routes/go_router.dart';
import 'package:mealapp/service_locator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()..appStarted()),
        BlocProvider(create: (context) => ButtonStateCubit()),
        BlocProvider(create: (context) => FavoriteMealsCubit()),
        BlocProvider(
            create: (context) => ShoppingListMealIngredientCubit(
                  addUseCase: sl<AddToShoppingListUseCase>(),
                  removeUseCase: sl<RemoveFromShoppingListUseCase>(),
                  restoreUseCase: sl<RestoreToShoppingListUseCase>(),
                  syncStrategy: sl<SyncStrategy>(),
                )),
        BlocProvider(
            create: (context) => ShoppingListCustomItemCubit(
                  addUseCase: sl<AddCustomItemToShoppingListUseCase>(),
                  removeUseCase: sl<RemoveCustomItemFromShoppingListUseCase>(),
                  restoreUseCase: sl<RestoreCustomItemToShoppingListUseCase>(),
                  syncStrategy: sl<SyncStrategy>(),
                )),
        BlocProvider(
            create: (context) => CategoriesDisplayCubit()..displayCategories()),
        BlocProvider(create: (_) => VegetarianFilterCubit()),
        BlocProvider(
          create: (context) => MealsDisplayCubit(useCase: sl<GetMealUseCase>()),
        ),
        BlocProvider(create: (_) => PlannedMealsCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: L10n.locals,
        locale: const Locale('pl'),
      ),
    );
  }
}
