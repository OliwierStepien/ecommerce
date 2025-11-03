// presentation/my_app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/core/new.dart';
import 'package:mealapp/my_app.dart';
import 'package:mealapp/presentation/friends/bloc/friend_cubit.dart';
import 'package:mealapp/presentation/home/bloc/category_selection_cubit.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_cubit.dart';
import 'package:mealapp/presentation/planned_meal/bloc/planned_meals_cubit.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/presentation/planned_meal_share/bloc/meal_share_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_custom_item_cubit.dart';
import 'package:mealapp/presentation/shopping_list/bloc/shopping_list_meal_ingredient_cubit.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';
import 'package:mealapp/service_locator.dart';

/// Wrapper odpowiedzialny za dostarczenie Cubitów/Bloców do aplikacji
class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ⬇️ DODANE: uruchom logi po pierwszym frame, 1x na start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupPlannedMealLogger.logOnStartup();
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SplashCubit>()),
        BlocProvider(create: (context) => sl<ButtonStateCubit>()),
        BlocProvider(
            create: (context) => sl<UserInfoDisplayCubit>()..displayUserInfo()),
        BlocProvider(create: (context) => sl<FavoriteMealsCubit>()),
        BlocProvider(
            create: (context) => sl<ShoppingListMealIngredientCubit>()),
        BlocProvider(create: (context) => sl<ShoppingListCustomItemCubit>()),
        BlocProvider(
            create: (_) => sl<CategoriesDisplayCubit>()..displayCategories()),
        BlocProvider(create: (_) => sl<CategorySelectionCubit>()),
        BlocProvider(create: (_) => sl<VegetarianFilterCubit>()),
        BlocProvider(create: (context) => sl<MealsDisplayCubit>()),
        BlocProvider(create: (_) => sl<PlannedMealsCubit>()),
        BlocProvider(create: (_) => sl<FriendsCubit>()..initializeFriendsData()),
        BlocProvider(create: (_) => sl<MealShareCubit>()),
      ],
      child: const MyApp(),
    );
  }
}