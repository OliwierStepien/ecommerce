import 'package:mealapp/domain/category/entity/category_entity.dart';
import 'package:equatable/equatable.dart';

sealed class CategoriesDisplayState extends Equatable {
  const CategoriesDisplayState();

  @override
  List<Object?> get props => [];
}

class CategoriesLoading extends CategoriesDisplayState {
  const CategoriesLoading();
}

class CategoriesLoadingSuccess extends CategoriesDisplayState {
  final List<CategoryEntity> categories;

  const CategoriesLoadingSuccess({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoriesLoadingFailure extends CategoriesDisplayState {
  final String message;

  const CategoriesLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
