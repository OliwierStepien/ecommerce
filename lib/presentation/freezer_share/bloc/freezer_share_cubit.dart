import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/freezer_item_share/usecase/share_freezer_with_friend_usecase.dart';
import 'package:mealapp/presentation/freezer_share/bloc/freezer_share_state.dart';

class FreezerShareCubit extends Cubit<FreezerShareState> {
  final ShareFreezerWithFriendUseCase shareUseCase;

  FreezerShareCubit(this.shareUseCase) : super(const FreezerShareIdle());

  Future<void> shareFreezer({required String friendUid}) async {
    emit(const FreezerShareLoading());

    final res = await shareUseCase(
      ShareFreezerWithFriendParams(friendUid: friendUid),
    );

    res.fold(
      (f) => emit(FreezerShareFailure(mapFailureToMessage(f))),
      (_) => emit(const FreezerShareSuccess('Zamrażarka została udostępniona.')),
    );
  }
}