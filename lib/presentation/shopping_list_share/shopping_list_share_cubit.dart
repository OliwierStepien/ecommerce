// presentation/shopping_list_share/bloc/shopping_list_share_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/shopping_list_meal_ingredient_share/usecase/share_shopping_list_with_friend_usecase.dart';
import 'package:mealapp/presentation/shopping_list_share/shopping_list_share_state.dart';

class ShoppingListShareCubit extends Cubit<ShoppingListShareState> {
  final ShareShoppingListWithFriendUseCase shareUseCase;

  ShoppingListShareCubit(this.shareUseCase)
      : super(const ShoppingListShareIdle());

  Future<void> shareShoppingList({required String friendUid}) async {
    emit(const ShoppingListShareLoading());

    final res = await shareUseCase(
      ShareShoppingListWithFriendParams(friendUid: friendUid),
    );

    res.fold(
      (f) => emit(ShoppingListShareFailure(mapFailureToMessage(f))),
      (_) => emit(const ShoppingListShareSuccess('Lista zakupów została udostępniona.')),
    );
  }
}