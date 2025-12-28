import 'package:hive/hive.dart';
import 'package:mealapp/core/storage/hive_type_id.dart';

part 'category_model.g.dart';

@HiveType(typeId: HiveTypeIds.category)

class CategoryModel {
    @HiveField(0)
  final String title;
    @HiveField(1)
  final String categoryId;
    @HiveField(2)
  final String image;

  CategoryModel({
    required this.title,
    required this.categoryId,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'categoryId': categoryId,
      'image': image,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      title: map['title'] as String,
      categoryId: map['categoryId'] as String,
      image: map['image'] as String,
    );
  }
}