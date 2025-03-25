import 'package:mealapp/domain/category/entity/category.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriesDisplayState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoriesLoading extends CategoriesDisplayState {
  @override
  List<Object?> get props => [];
}

class CategoriesLoadingSuccess extends CategoriesDisplayState {
  final List<CategoryEntity> categories;

  CategoriesLoadingSuccess({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoriesLoadingFailure extends CategoriesDisplayState {
  final String message;

  CategoriesLoadingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
