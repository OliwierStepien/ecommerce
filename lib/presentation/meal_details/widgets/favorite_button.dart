import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';

class FavoriteButton extends StatelessWidget {
  final MealEntity mealEntity;

  const FavoriteButton({required this.mealEntity, super.key});

  @override
  Widget build(BuildContext context) {
    final mealsCubit = context.read<FavoriteMealsCubit>();

    return BlocBuilder<FavoriteMealsCubit, MealsDisplayState>(
      builder: (context, state) {
        final isFavorite = state is MealsLoadingSuccess &&
            state.meals.any((meal) => meal.mealId == mealEntity.mealId);

        return IconButton(
          onPressed: () async {
            await mealsCubit.toggleFavorite(mealEntity, context);
          },
          icon: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              size: 15,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}