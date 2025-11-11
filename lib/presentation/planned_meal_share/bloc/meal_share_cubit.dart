// presentation/planned_meal_share/bloc/meal_share_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/planned_meal_share/usecase/share_planned_meals_with_friend_usecase.dart';
import 'package:mealapp/presentation/planned_meal_share/bloc/meal_share_state.dart';

class MealShareCubit extends Cubit<MealShareState> {
  final SharePlannedMealsWithFriendUseCase shareUseCase;

  MealShareCubit(this.shareUseCase) : super(const MealShareIdle());

  Future<void> shareMeals({
    required String friendUid,
    required DateTime start,
    required DateTime end,
  }) async {
    emit(const MealShareLoading());

    final res = await shareUseCase(
      SharePlannedMealsWithFriendParams(
        friendUid: friendUid,
        start: start,
        end: end,
      ),
    );

    res.fold(
      (f) => emit(MealShareFailure(mapFailureToMessage(f))),
      (_) => emit(const MealShareSuccess('Posiłki zostały udostępnione.')),
    );
  }
}