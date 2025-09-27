import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealapp/common/bloc/button/button_state.dart';
import 'package:mealapp/common/bloc/button/button_state_cubit.dart';
import 'package:mealapp/extensions/context_extension.dart';
import 'package:mealapp/presentation/home/widgets/header.dart';
import 'package:mealapp/presentation/home/widgets/main_drawer.dart';
import 'package:mealapp/presentation/home/widgets/meals_grid_view.dart';
import 'package:mealapp/presentation/home/widgets/search_field_home.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/vegetarian_filter_cubit.dart';
import 'package:mealapp/routes/routes.dart';
import '../widgets/categories_row_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    _initializeData(context);

    return Scaffold(
      drawer: const MainDrawer(),
      body: BlocListener<VegetarianFilterCubit, bool>(
          listener: (context, isVegetarian) {
            _handleFilterChange(context, isVegetarian);
          },
          child: BlocListener<ButtonStateCubit, ButtonState>(
            listener: (context, state) {
              _handleButtonState(context, state);
            },
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Header(),
                  SizedBox(height: 24),
                  SearchFieldHome(),
                  SizedBox(height: 24),
                  CategoriesRowView(),
                  SizedBox(height: 24),
                  MealsGridView(),
                ],
              ),
            ),
          ),
        ),
      );
  }

  void _initializeData(BuildContext context) {
    final filterState = context.read<VegetarianFilterCubit>().state;
    context.read<MealsDisplayCubit>().displayMeals(params: filterState);
  }

  void _handleFilterChange(BuildContext context, bool isVegetarian) {
    context.read<MealsDisplayCubit>().displayMeals(params: isVegetarian);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isVegetarian
            ? context.l10n.vegetarianMealsSelected
            : context.l10n.allMealsSelected),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleButtonState(BuildContext context, ButtonState state) {
    if (state is ButtonFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
    }
    if (state is ButtonSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.successMessage)),
      );
      context.go(Routes.signInEmailPage);
    }
  }
}
