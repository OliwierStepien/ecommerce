import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String title;
  final String categoryId;
  final String image;

  const CategoryEntity({
    required this.title,
    required this.categoryId,
    required this.image,
  });

  @override
  List<Object?> get props => [title, categoryId, image];
}
