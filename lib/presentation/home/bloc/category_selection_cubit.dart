import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit przechowujący zestaw zaznaczonych kategorii (po ich ID).
class CategorySelectionCubit extends Cubit<Set<String>> {
  CategorySelectionCubit() : super({});

  void toggleCategory(String categoryId) {
    final updated = Set<String>.from(state);
    if (updated.contains(categoryId)) {
      updated.remove(categoryId);
    } else {
      updated.add(categoryId);
    }
    emit(updated);
  }

  void clear() => emit({});
}