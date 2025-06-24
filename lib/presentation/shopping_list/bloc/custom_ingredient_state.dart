import 'package:equatable/equatable.dart';

abstract class CustomIngredientState extends Equatable {
  const CustomIngredientState();

  @override
  List<Object?> get props => [];
}

class CustomIngredientInitial extends CustomIngredientState {
  const CustomIngredientInitial();
}

class CustomIngredientLoading extends CustomIngredientState {
  const CustomIngredientLoading();
}

class CustomIngredientLoaded extends CustomIngredientState {
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

class CustomIngredientError extends CustomIngredientState {
  final String message;

  const CustomIngredientError({required this.message});

  @override
  List<Object?> get props => [message];
}