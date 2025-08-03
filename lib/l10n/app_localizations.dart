import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @fieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be empty'**
  String get fieldCannotBeEmpty;

  /// No description provided for @enterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmailAddress;

  /// No description provided for @backToLoginPage.
  ///
  /// In en, this message translates to:
  /// **'Back to login page'**
  String get backToLoginPage;

  /// No description provided for @emailWithPasswordResetInstructionsHasBeenSent.
  ///
  /// In en, this message translates to:
  /// **'Email with password reset instructions has been sent'**
  String get emailWithPasswordResetInstructionsHasBeenSent;

  /// No description provided for @doNotHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get doNotHaveAccount;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password? '**
  String get forgotPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @vegetarianMealsSelected.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian meals selected'**
  String get vegetarianMealsSelected;

  /// No description provided for @allMealsSelected.
  ///
  /// In en, this message translates to:
  /// **'All meals selected'**
  String get allMealsSelected;

  /// No description provided for @favoriteMeals.
  ///
  /// In en, this message translates to:
  /// **'Favorite meals'**
  String get favoriteMeals;

  /// No description provided for @sorryWeCouldNotFindAnyMatchingResultsForYourSearch.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we couldn\'t find any matching results for your search'**
  String get sorryWeCouldNotFindAnyMatchingResultsForYourSearch;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingList;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients:'**
  String get ingredients;

  /// No description provided for @addToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get addToShoppingList;

  /// No description provided for @cookingSteps.
  ///
  /// In en, this message translates to:
  /// **'Cooking steps'**
  String get cookingSteps;

  /// Shows meal name
  ///
  /// In en, this message translates to:
  /// **'From meal: {title}'**
  String fromMealTitle(String title);

  /// No description provided for @deteledFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Deleted from favorites'**
  String get deteledFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @vegetarianMeals.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian meals'**
  String get vegetarianMeals;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addMealToDay.
  ///
  /// In en, this message translates to:
  /// **'Add meal to day'**
  String get addMealToDay;

  /// No description provided for @plannedMeals.
  ///
  /// In en, this message translates to:
  /// **'Planned meals'**
  String get plannedMeals;

  /// Notification when ingredient is removed
  ///
  /// In en, this message translates to:
  /// **'Removed {ingredient} from shopping list'**
  String removedIngredientFromShoppingList(String ingredient);

  /// Greeting message for the user
  ///
  /// In en, this message translates to:
  /// **'Hello {userFirstName}'**
  String helloUser(Object userFirstName);

  /// Notification when ingredient is added
  ///
  /// In en, this message translates to:
  /// **'Added {ingredient} to shopping list'**
  String addedIngredientToShoppingList(String ingredient);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
