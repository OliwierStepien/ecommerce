// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get allCategories => 'All categories';

  @override
  String get continueText => 'Continue';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get enterEmailAddress => 'Enter email address';

  @override
  String get fieldCannotBeEmpty => 'Field cannot be empty';

  @override
  String get enterValidEmailAddress => 'Enter a valid email address';

  @override
  String get backToLoginPage => 'Back to login page';

  @override
  String get emailWithPasswordResetInstructionsHasBeenSent =>
      'Email with password reset instructions has been sent';

  @override
  String get doNotHaveAccount => 'Don\'t have an account? ';

  @override
  String get createNew => 'Create new';

  @override
  String get signIn => 'Log in';

  @override
  String get forgotPassword => 'Forgot password? ';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get createAccount => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get firstName => 'First name';

  @override
  String get vegetarianMealsSelected => 'Vegetarian meals selected';

  @override
  String get allMealsSelected => 'All meals selected';

  @override
  String get favoriteMeals => 'Favorite meals';

  @override
  String get sorryWeCouldNotFindAnyMatchingResultsForYourSearch =>
      'Sorry, we couldn\'t find any matching results for your search';

  @override
  String get search => 'Search';

  @override
  String get shoppingList => 'Shopping list';

  @override
  String get undo => 'Undo';

  @override
  String get categories => 'Categories';

  @override
  String get seeAll => 'See all';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get meals => 'Meals';

  @override
  String get ingredients => 'Ingredients:';

  @override
  String get addToShoppingList => 'Add to list';

  @override
  String get cookingSteps => 'Cooking steps';

  @override
  String fromMealTitle(String title) {
    return 'From meal: $title';
  }

  @override
  String get deteledFromFavorites => 'Deleted from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get product => 'Product';

  @override
  String get vegetarianMeals => 'Vegetarian meals';

  @override
  String get calendar => 'Calendar';

  @override
  String get add => 'Add';

  @override
  String get addMealToDay => 'Add meal to day';

  @override
  String get plannedMeals => 'Planned meals';

  @override
  String removedIngredientFromShoppingList(String ingredient) {
    return 'Removed $ingredient from shopping list';
  }

  @override
  String helloUser(Object userFirstName) {
    return 'Hello $userFirstName';
  }

  @override
  String addedIngredientToShoppingList(String ingredient) {
    return 'Added $ingredient to shopping list';
  }
}
