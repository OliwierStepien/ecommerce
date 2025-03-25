import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure_mapper.dart';
import 'package:mealapp/domain/auth/usecases/get_user.dart';
import 'package:mealapp/presentation/home/bloc/user_info_display_state.dart';
import 'package:mealapp/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoDisplayCubit extends Cubit<UserInfoDisplayState> {
  UserInfoDisplayCubit() : super(UserInfoLoading());

  void displayUserInfo() async {
    final returnedData = await sl<GetUserUsecase>().call();
    returnedData.fold((error) {
      emit(LoadUserInfoFailure(message: mapFailureToMessage(error)));
    }, (data) {
      emit(UserInfoLoaded(user: data));
    });
  }
}
