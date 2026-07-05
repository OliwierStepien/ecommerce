import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_meals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_state.dart';

class FavoriteButton extends StatelessWidget {
  final MealEntity mealEntity;

  const FavoriteButton({required this.mealEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteMealsCubit, MealsDisplayState>(
      builder: (context, state) {
        final isFavorite = state is MealsLoadingSuccess &&
            state.meals.any((meal) => meal.mealId == mealEntity.mealId);

        return IconButton(
          onPressed: () async {
            final cubit = context.read<FavoriteMealsCubit>();
            final wasFavorite = isFavorite;

            await cubit.toggleFavorite(mealEntity);

            // Pokazuj SnackBar tylko jeśli akcja się powiodła
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(wasFavorite
                      ? 'Usunięto z ulubionych'
                      : 'Dodano do ulubionych'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_outline,
            size: 24,
            color: isFavorite ? AppColors.accent : const Color(0xFFC3B49C),
          ),
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      },
    );
  }
}
