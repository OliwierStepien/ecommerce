// presentation/planned_meal_share/bloc/meal_share_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/planned_meal_share/usecase/share_planned_meals_with_friend_usecase.dart';

class MealShareState {
  final bool loading;
  final String? toast;

  MealShareState({this.loading = false, this.toast});

  MealShareState copyWith({bool? loading, String? toast, bool clearToast = false}) =>
      MealShareState(
        loading: loading ?? this.loading,
        toast: clearToast ? null : (toast ?? this.toast),
      );
}

class MealShareCubit extends Cubit<MealShareState> {
  final SharePlannedMealsWithFriendUseCase shareUseCase;

  MealShareCubit(this.shareUseCase) : super(MealShareState());

  Future<void> shareMeals({
    required String friendUid,
    required DateTime start,
    required DateTime end,
  }) async {
    emit(state.copyWith(loading: true));

    final res = await shareUseCase(
      SharePlannedMealsWithFriendParams(
        friendUid: friendUid,
        start: start,
        end: end,
      ),
    );

    res.fold(
      (f) => emit(state.copyWith(loading: false, toast: mapFailureToMessage(f))),
      (_) => emit(state.copyWith(loading: false, toast: 'Udostępniono plan posiłków')),
    );
  }

  void clearToast() => emit(state.copyWith(clearToast: true));
}