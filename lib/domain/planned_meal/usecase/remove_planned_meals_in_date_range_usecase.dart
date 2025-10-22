import 'package:dartz/dartz.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/planned_meal/repository/planned_meal_repository.dart';

/// Parametry przekazywane do UseCase — zakres dat
class DateRangeParams {
  final DateTime start;
  final DateTime end;

  const DateRangeParams({
    required this.start,
    required this.end,
  });
}

/// UseCase odpowiedzialny za usuwanie wszystkich zaplanowanych posiłków
/// w podanym zakresie dat.
class RemovePlannedMealsInDateRangeUseCase
    implements UseCase<Either<Failure, void>, DateRangeParams> {
  final PlannedMealRepository repository;

  const RemovePlannedMealsInDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DateRangeParams params) async {
    return await repository.removePlannedMealsInDateRange(
      params.start,
      params.end,
    );
  }
}