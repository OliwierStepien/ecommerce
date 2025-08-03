// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get allCategories => 'Wszystkie kategorie';

  @override
  String get continueText => 'Kontynuuj';

  @override
  String get resetPassword => 'Zresetuj hasło';

  @override
  String get enterEmailAddress => 'Podaj adres Email';

  @override
  String get fieldCannotBeEmpty => 'Pole nie może być puste';

  @override
  String get enterValidEmailAddress => 'Wprowadź poprawny adres email';

  @override
  String get backToLoginPage => 'Wróć do strony logowania';

  @override
  String get emailWithPasswordResetInstructionsHasBeenSent =>
      'Email z informacją jak zresetować hasło został wysłany';

  @override
  String get doNotHaveAccount => 'Nie masz konta? ';

  @override
  String get createNew => 'Stwórz nowe';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get forgotPassword => 'Zapomniałeś hasła? ';

  @override
  String get enterPassword => 'Podaj hasło';

  @override
  String get alreadyHaveAccount => 'Masz konto? ';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get email => 'Email';

  @override
  String get password => 'Hasło';

  @override
  String get firstName => 'Imię';

  @override
  String get vegetarianMealsSelected => 'Wybrano dania wegetariańskie';

  @override
  String get allMealsSelected => 'Wybrano wszystkie dania';

  @override
  String get favoriteMeals => 'Ulubione posiłki';

  @override
  String get sorryWeCouldNotFindAnyMatchingResultsForYourSearch =>
      'Przepraszamy, nie znaleźliśmy żadnych pasujących wyników dla Twojego wyszukiwania';

  @override
  String get search => 'Szukaj';

  @override
  String get shoppingList => 'Lista zakupów';

  @override
  String get undo => 'Cofnij';

  @override
  String get categories => 'Kategorie';

  @override
  String get seeAll => 'Zobacz wszystkie';

  @override
  String get settings => 'Ustawienia';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get meals => 'Dania';

  @override
  String get ingredients => 'Składniki:';

  @override
  String get addToShoppingList => 'Dodaj do listy';

  @override
  String get cookingSteps => 'Przygotowanie';

  @override
  String fromMealTitle(String title) {
    return 'Z posiłku: $title';
  }

  @override
  String get deteledFromFavorites => 'Usunięto z ulubionych';

  @override
  String get addedToFavorites => 'Dodano do ulubionych';

  @override
  String get product => 'Produkt';

  @override
  String get vegetarianMeals => 'Wegetarańskie';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get add => 'Dodaj';

  @override
  String get addMealToDay => 'Dodaj posiłek do dnia';

  @override
  String get plannedMeals => 'Zaplanowane posiłki';

  @override
  String removedIngredientFromShoppingList(String ingredient) {
    return 'Usunięto $ingredient z listy zakupów';
  }

  @override
  String helloUser(Object userFirstName) {
    return 'Cześć $userFirstName';
  }

  @override
  String addedIngredientToShoppingList(String ingredient) {
    return 'Dodano $ingredient do listy zakupów';
  }
}
