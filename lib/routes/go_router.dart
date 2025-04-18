import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/data/auth/models/user_signin_req.dart';
import 'package:mealapp/domain/category/entity/category.dart';
import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/all_categories/pages/all_categories_page.dart';
import 'package:mealapp/presentation/auth/forgot_password/pages/forgot_password_page.dart';
import 'package:mealapp/presentation/auth/password_reset_email/pages/password_reset_email_page.dart';
import 'package:mealapp/presentation/auth/signin_email/pages/signin_email_page.dart';
import 'package:mealapp/presentation/auth/signin_password/pages/signin_password_page.dart';
import 'package:mealapp/presentation/auth/signup/pages/signup_page.dart';
import 'package:mealapp/presentation/category_meals/pages/category_meals_page.dart';
import 'package:mealapp/presentation/home/pages/home_page.dart';
import 'package:mealapp/presentation/meal_details/pages/favorite_meals_page.dart';
import 'package:mealapp/presentation/meal_details/pages/meal_detail_page.dart';
import 'package:mealapp/presentation/search/pages/search_page.dart';
import 'package:mealapp/presentation/shopping_list/pages/shopping_list_page.dart';
import 'package:mealapp/presentation/splash/pages/splash_page.dart';
import 'package:mealapp/routes/layout_scaffold.dart';
import 'package:mealapp/routes/routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splashPage,
  routes: [
    GoRoute(
      path: Routes.splashPage,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.signInEmailPage,
      builder: (context, state) => SignInEmailPage(),
    ),
    GoRoute(
      path: Routes.signInPasswordPage,
      builder: (context, state) => SignInPasswordPage(
        userSigninReq: state.extra as UserSigninReq,
      ),
    ),
    GoRoute(
      path: Routes.signUpPage,
      builder: (context, state) => SignUpPage(),
    ),
    GoRoute(
      path: Routes.forgotPasswordPage,
      builder: (context, state) => ForgotPasswordPage(),
    ),
    GoRoute(
      path: Routes.passwordResetEmailPage,
      builder: (context, state) => const PasswordResetEmailPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LayoutScaffold(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.favoritePage,
              builder: (context, state) => const FavoriteMealsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: Routes.mealDetailPage,
                  builder: (context, state) =>
                      MealDetailPage(mealEntity: state.extra as MealEntity),
                ),
                GoRoute(
                  path: Routes.allCategoriesPage,
                  builder: (context, state) => const AllCategoriesPage(),
                ),
                GoRoute(
                  path: Routes.categoryMealsPage,
                  builder: (context, state) => CategoryMealsPage(
                    categoryEntity: state.extra as CategoryEntity,
                  ),
                ),
                GoRoute(
                  path: Routes.searchPage,
                  builder: (context, state) => const SearchPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.shoppingListPage,
              builder: (context, state) => const ShoppingListPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
