import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/core/configs/theme/app_theme.dart';
import 'package:mealapp/domain/meal/usecases/get_meal.dart';
import 'package:mealapp/firebase_options.dart';
import 'package:mealapp/presentation/category_meals/bloc/categories_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/shopping_list_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/presentation/splash/bloc/splash_cubit.dart';
import 'package:mealapp/routes/go_router.dart';
import 'package:mealapp/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()..appStarted()),
        BlocProvider(create: (context) => ButtonStateCubit()),
        BlocProvider(create: (context) => FavoriteMealsCubit()),
        BlocProvider(create: (context) => ShoppingListCubit()),
        BlocProvider(create: (context) => CategoriesDisplayCubit()..displayCategories()),
        BlocProvider(create: (_) => VegetarianFilterCubit()),
        BlocProvider(create: (context) => MealsDisplayCubit(useCase: sl<GetMealUseCase>())),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appTheme,
      ),
    );
  }
}
