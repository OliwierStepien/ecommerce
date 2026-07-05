import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealapp/core/configs/theme/app_colors.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';
import 'package:mealapp/presentation/meal_details/bloc/portion_cubit.dart';
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
        body: BlocBuilder<PortionCubit, int>(
          builder: (context, multiplier) {
            final portionCubit = context.read<PortionCubit>();
            final updatedMeal = portionCubit.updatedMeal();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MealImage(mealEntity: updatedMeal),
                  const SizedBox(height: 18),
                  MealTitle(mealEntity: updatedMeal),
                  const SizedBox(height: 16),

                  /// 📅 Dodaj do kalendarza
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlannedMealPage(mealToAdd: updatedMeal),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.hairline),
                          bottom: BorderSide(color: AppColors.hairline),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_month, color: AppColors.accent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dodaj posiłek do kalendarza',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),

                  /// 🔢 Liczba porcji
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Liczba porcji',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.accent,
                              ),
                              onPressed: () => portionCubit.decrease(),
                            ),
                            Text(
                              '${portionCubit.currentPortion}',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.accent,
                              ),
                              onPressed: () => portionCubit.increase(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// 🍽️ Składniki z uwzględnieniem liczby porcji
                  MealIngredient(
                    mealEntity: updatedMeal,
                    currentPortion: portionCubit.currentPortion,
                  ),
                  MealStep(mealEntity: updatedMeal),
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
