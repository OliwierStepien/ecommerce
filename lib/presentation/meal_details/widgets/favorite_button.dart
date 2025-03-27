import 'package:mealapp/domain/meal/entity/meal.dart';
import 'package:mealapp/presentation/meal_details/bloc/favorite_icon_cubit.dart';
import 'package:mealapp/presentation/meal_details/bloc/meals_display_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatelessWidget {
  final MealEntity mealEntity;
  const FavoriteButton({required this.mealEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final favoriteCubit = context.read<FavoriteIconCubit>();
        final mealsCubit = context.read<MealsDisplayCubit>();

        final wasFavorite = favoriteCubit.state;
        await favoriteCubit.onTap(mealEntity);

        if (!context.mounted) return;

        final isNowFavorite = favoriteCubit.state;
        if (isNowFavorite != wasFavorite) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNowFavorite
                    ? 'Dodano do ulubionych'
                    : 'Usunięto z ulubionych',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }

        mealsCubit.displayMeals();
      },
      icon: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor, shape: BoxShape.circle),
        child: BlocBuilder<FavoriteIconCubit, bool>(
          builder: (context, state) => Icon(
            state ? Icons.favorite : Icons.favorite_outline,
            size: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}