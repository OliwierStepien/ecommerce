import 'package:equatable/equatable.dart';

abstract class CustomCategoryState extends Equatable {
  const CustomCategoryState();

  @override
  List<Object?> get props => [];
}

class CustomIngredientInitial extends CustomCategoryState {
  const CustomIngredientInitial();
}

class CustomIngredientLoading extends CustomCategoryState {
  const CustomIngredientLoading();
}

class CustomIngredientLoaded extends CustomCategoryState {
  final List<String> categories;
  final String inputText;

  const CustomIngredientLoaded({
    required this.categories,
    this.inputText = '',
  });

  CustomIngredientLoaded copyWith({
    List<String>? categories,
    String? inputText,
  }) {
    return CustomIngredientLoaded(
      categories: categories ?? this.categories,
      inputText: inputText ?? this.inputText,
    );
  }

  @override
  List<Object?> get props => [categories, inputText];
}

class CustomIngredientError extends CustomCategoryState {
  final String message;

  const CustomIngredientError({required this.message});

  @override
  List<Object?> get props => [message];
}