import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/widgets/appbar/app_bar.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/presentation/meal_details/bloc/portion_cubit.dart';
import 'package:mealapp/presentation/meal_details/widgets/favorite_button.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_image.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_ingredient.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_step.dart';
import 'package:mealapp/presentation/meal_details/widgets/meal_title.dart';
import 'package:mealapp/presentation/planned_meal/pages/planned_meal_page.dart';

class MealDetailPage extends StatelessWidget {
  final MealEntity mealEntity;

  const MealDetailPage({super.key, required this.mealEntity});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PortionCubit(mealEntity),
      child: Scaffold(
        appBar: BasicAppbar(
          hideBack: false,
          action: FavoriteButton(mealEntity: mealEntity),
        ),
        body: BlocBuilder<PortionCubit, int>(
          builder: (context, multiplier) {
            final portionCubit = context.read<PortionCubit>();
            final updatedMeal = portionCubit.updatedMeal();

            return SingleChildScrollView(
              child: Column(
                children: [
                  MealImage(mealEntity: updatedMeal),
                  const SizedBox(height: 10),
                  MealTitle(mealEntity: updatedMeal),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dodaj posiłek do kalendarza',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlannedMealPage(mealToAdd: updatedMeal),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  /// 🔢 Liczba porcji
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Liczba porcji: ${portionCubit.currentPortion}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => portionCubit.decrease(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => portionCubit.increase(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// 🍽️ Składniki z uwzględnieniem liczby porcji
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MealIngredient(
                      mealEntity: updatedMeal,
                      currentPortion: portionCubit.currentPortion,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MealStep(mealEntity: updatedMeal),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}