import 'package:equatable/equatable.dart';
import 'package:mealapp/domain/meal/entity/meal_entity.dart';

class FavoriteMealEntity extends Equatable {
  final MealEntity meal;

  const FavoriteMealEntity({
    required this.meal,
  });

  @override
  List<Object?> get props => [meal];
}
