import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/core/usecase/usecase.dart';
import 'package:mealapp/domain/auth/usecase/get_user.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoDisplayCubit extends Cubit<UserInfoDisplayState> {
  final GetUserUsecase getUserUsecase;

  UserInfoDisplayCubit({required this.getUserUsecase})
      : super(const UserInfoLoading());

  Future<void> displayUserInfo() async {
    final returnedData = await getUserUsecase.call(NoParams());
    returnedData.fold((error) {
      emit(LoadUserInfoFailure(message: mapFailureToMessage(error)));
    }, (data) {
      emit(UserInfoLoaded(user: data));
    });
  }
}
