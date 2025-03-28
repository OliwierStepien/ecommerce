import 'package:flutter_bloc/flutter_bloc.dart';

class VegetarianFilterCubit extends Cubit<bool> {
  VegetarianFilterCubit() : super(false);

  void toggle() => emit(!state);

  bool get isVegetarian => state;
}