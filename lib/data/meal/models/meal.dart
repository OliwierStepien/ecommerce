class MealModel {
  final String title;
  final String mealId;
  final List<String> categoryId;
  final String image;
  final List<String> ingredients;
  final List<String> steps;
  final bool isVegetarian;

  MealModel({
    required this.title,
    required this.mealId,
    required this.categoryId,
    required this.image,
    required this.ingredients,
    required this.steps,
    required this.isVegetarian,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mealId': mealId,
      'categoriesId': categoryId,
      'image': image,
      'ingredients': ingredients,
      'steps': steps,
      'isVegetarian': isVegetarian,
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      title: map['title'] as String,
      mealId: map['mealId'] as String,
      categoryId: List<String>.from(map['categoriesId'] as List<dynamic>),
      image: map['image'] as String,
      ingredients: List<String>.from(map['ingredients'] as List<dynamic>),
      steps: List<String>.from(map['steps'] as List<dynamic>),
      isVegetarian: map['isVegetarian'] as bool,
    );
  }
}