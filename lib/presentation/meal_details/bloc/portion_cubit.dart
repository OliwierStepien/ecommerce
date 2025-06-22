import 'package:flutter_bloc/flutter_bloc.dart';

class PortionCubit extends Cubit<int> {
  PortionCubit() : super(1);

  void increase() => emit(state + 1);
  void decrease() {
    if (state > 1) emit(state - 1);
  }

  void set(int count) => emit(count);
}