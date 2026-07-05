# Handoff: mealapp — nowy UI „Brąz z klasą" (kierunek 1c)

## Overview
Kompletny redesign wizualny aplikacji **mealapp** (Flutter) — jasny, edytorialny kierunek
„Brąz z klasą": espresso + kość słoniowa + złoto, tytuły serifem **Playfair Display**,
treść **DM Sans**. Obejmuje wszystkie ekrany istniejącej aplikacji (logowanie i rejestracja,
Start, szczegóły dania, kategorie, wyszukiwanie, ulubione, zamrażarka, kalendarz,
lista zakupów, profil ze znajomymi, szuflada ustawień).

Zmiana jest **czysto wizualna** — logika, routing, cubity/bloci, repozytoria i model danych
(`MealEntity`, `IngredientEntity`, `PlannedMealEntity`, `FreezerItemEntity` itd.) **pozostają bez zmian**.
Zdjęcia dań i kategorii nadal pochodzą z Firebase przez `CachedNetworkImage` +
`ImageDisplayHelper` — w makietach są tylko paskowane placeholdery.

## About the Design Files
Plik `Mealapp Redesign.dc.html` w tym pakiecie to **referencja projektowa stworzona w HTML** —
prototyp pokazujący docelowy wygląd i zachowanie, **nie kod produkcyjny do skopiowania**.
Zadaniem jest **odtworzenie tych ekranów w istniejącym projekcie Flutter** (`OliwierStepien/ecommerce`,
pakiet `mealapp`) z użyciem jego wzorców: `MaterialApp.router` + `go_router`, `flutter_bloc`,
istniejące strony w `lib/presentation/**` oraz `AppTheme`/`AppColors`.

W pliku HTML są **trzy tury**:
- **Tura 3** (góra) — pozostałe ekrany (rejestracja, hasło, reset, mail wysłany, dania z kategorii, profil, szuflada)
- **Tura 2** — logowanie, ulubione, zamrażarka, wszystkie kategorie, wyszukiwanie
- **Tura 1** — Start / danie / lista zakupów / kalendarz w trzech kierunkach (1a, 1b, 1c)

**Implementujemy wyłącznie kierunek `1c` oraz jego rozwinięcia (`2a`, `3a`).** Warianty 1a i 1b
to porzucone eksploracje — zignoruj je.

## Fidelity
**Wysoka (hi-fi).** Kolory, typografia, odstępy i układy są docelowe — odtwórz je 1:1
z użyciem widgetów Flutter (bez CSS). Wszystkie ikony to **Material Icons** (już używane w apce),
więc mapują się wprost na `Icons.*`.

---

## Zmiany globalne (motyw)

### 1. Zależności
Dodaj `google_fonts` do `pubspec.yaml` (Playfair Display + DM Sans).

### 2. `lib/core/configs/theme/app_colors.dart` — nowa paleta
```dart
class AppColors {
  static const primary        = Color(0xFF5A4632); // espresso — przyciski, aktywne
  static const accent         = Color(0xFFA9793F); // złoto — akcenty, złote linie
  static const background     = Color(0xFFFBF7F0); // kość słoniowa — tło ekranu
  static const surface        = Color(0xFFFFFFFF); // karty / pola
  static const ink            = Color(0xFF33271E); // tekst główny
  static const muted          = Color(0xFF9B8B76); // tekst drugorzędny / podpisy
  static const hairline       = Color(0xFFE3D6C1); // obramowania 1px
  static const dividerLight   = Color(0xFFEEE4D4); // cienkie separatory list
  static const softFill       = Color(0xFFEFE6D8); // wypełnienia (awatary, kółka ikon)
  static const herb           = Color(0xFF5A6B45); // zieleń zioł — wege / zaznaczone
  static const danger         = Color(0xFF9C5030); // usuwanie
  static const placeholder    = Color(0xFFA99A85); // hint w polach
}
```

### 3. `lib/core/configs/theme/app_theme.dart`
- `brightness: Brightness.light`
- `scaffoldBackgroundColor: AppColors.background`
- `primaryColor: AppColors.primary`
- `textTheme`: nagłówki `GoogleFonts.playfairDisplay(...)` (w=600), reszta `GoogleFonts.dmSans(...)`.
  Zalecane: ustaw `GoogleFonts.dmSansTextTheme(...)` jako bazę, a `displayLarge/headlineMedium/titleLarge`
  nadpisz `GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600)`.
- `inputDecorationTheme`: `filled: false`, `border`/`enabledBorder` =
  `OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppColors.hairline))`,
  `focusedBorder` z `BorderSide(color: AppColors.accent)`, `hintStyle` w `AppColors.placeholder`,
  `contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13)`.
- `elevatedButtonTheme`: `backgroundColor: AppColors.primary`, `foregroundColor: AppColors.background`,
  **`shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))`** (uwaga: obecnie jest 100 — zmieniamy na kanciaste 4px), `elevation: 0`, padding pionowy ~15.
- `snackBarTheme`: tło `AppColors.primary`, tekst `AppColors.background`.
- `NavigationBarThemeData`: tło `AppColors.background`, `indicatorColor: Colors.transparent`,
  `labelTextStyle` = ukryte/małe; aktywna ikona `AppColors.primary`, nieaktywna `Color(0xFFC6B8A2)`.
  W makiecie aktywność oznacza **złota kreska 14×2px** pod ikoną (patrz „Bottom nav").

### 4. `lib/routes/layout_scaffold.dart` (NavigationBar)
Obecnie `indicatorColor: primaryColor` + biała aktywna ikona. Zmień na: brak pigułki-wskaźnika,
aktywna ikona w `AppColors.primary`, nieaktywna `#C6B8A2`, a pod aktywną dodaj złoty pasek
(`Container` 14×2, `AppColors.accent`) — np. przez `NavigationDestination` z własnym `icon`/`selectedIcon`
w `Column` albo custom bottom bar. Etykiety `destinations` (Ulubione/Zamrażarka/Start/Kalendarz/Zakupy)
bez zmian.

### 5. `MyApp` (`lib/my_app.dart`)
Motyw jest jasny — usuń zależność od ciemnego tła. Reszta (`routerConfig`, lokalizacja `pl`) bez zmian.

---

## Konwencje wizualne (stosuj wszędzie)

- **Nagłówek strony** = mała etykieta wersalikami + tytuł serifem:
  - Etykieta (kicker): DM Sans, 10px, `w600`, `letterSpacing: 0.18em` (użyj ~1.8), UPPERCASE, kolor `accent`.
  - Tytuł: Playfair Display, `w600`, 24–32px, kolor `ink`.
- **Złota linia** pod nagłówkiem sekcji: `Container(height: 1, color: AppColors.accent)`.
- **Karty/pola**: tło `surface` lub przezroczyste, `border: 1px hairline`, `borderRadius: 4–10`
  (pola formularzy 4px; kafelki list 8–10px), **bez cieni**.
- **Separatory list**: `Divider(height: 1, color: AppColors.dividerLight)`.
- **Meta pod tytułem dania**: DM Sans, 10px, `muted`, `letterSpacing ~0.4`, np. `35 MIN · 4 PORCJE`.
- **Placeholder zdjęcia** (tylko makieta): w apce zostaje `CachedNetworkImage`. Nie odwzorowuj pasków.
- Marginesy ekranu: poziomo 16–22 (formularze 22–24), zgodnie z istniejącym `EdgeInsets`.

---

## Screens / Views

> Ścieżki plików są względem `lib/` w repo `OliwierStepien/ecommerce`.

### 1. Logowanie — e-mail  ·  `presentation/auth/signin_email/`
- **Plik**: `pages/signin_email_page.dart` + `widgets/{signin_email_header,signin_email_field,continue_email_button,create_account_text}.dart`
- **Cel**: podanie adresu e-mail (krok 1 logowania).
- **Układ**: opcjonalny górny pasek brandingowy (miejsce na grafikę), poniżej `padding: 16/40`,
  kolumna wyrównana do lewej.
- **Komponenty**:
  - Kicker `WITAJ PONOWNIE` (accent) + tytuł **`Zaloguj się`** (Playfair, 32, w600) — w miejsce `SigninEmailHeader`.
  - Etykieta `EMAIL` (kicker style) + `SigninEmailField` (outline 4px, hairline).
  - `ContinueEmailButton` → `Kontynuuj`, pełna szerokość, tło `primary`, kanciasty 4px.
  - `CreateAccountText`: „Nie masz konta? **Stwórz nowe**" — „Stwórz nowe" `w700`, kolor `accent`, podkreślone.

### 2. Logowanie — hasło  ·  `presentation/auth/signin_password/`
- **Plik**: `pages/signin_password_page.dart` + `widgets/{signin_password_header,signin_password_field,continue_password_button,reset_password}.dart`
- **Cel**: podanie hasła (krok 2).
- **Komponenty**:
  - Kicker `OSTATNI KROK` + tytuł **`Zaloguj się`** (Playfair 32).
  - Wiersz „Zalogowano jako **e-mail**" (`muted`, e-mail w `ink w600`).
  - Etykieta `HASŁO` + `SigninPasswordField` (outline, **obramowanie focus w `accent`**), z ikoną
    `Icons.visibility` / `visibility_off` jako `suffixIcon` (kolor accent gdy pokazane).
  - `ContinuePasswordButton` → `Kontynuuj`.
  - `ResetPassword`: „Zapomniałeś hasła? **Zresetuj hasło**" — link w `accent w700` podkreślony.

### 3. Reset hasła  ·  `presentation/auth/forgot_password/`
- **Plik**: `pages/forgot_password_page.dart` + `widgets/{forgot_password_header,reset_email_field,continue_reset_button}.dart`
- **Komponenty**: kicker `BEZ OBAW` + tytuł **`Zresetuj hasło`** (Playfair 30); pod nim zdanie pomocnicze
  **kursywą Playfair** w `muted` („Podaj swój adres e-mail, a wyślemy Ci instrukcję resetu hasła.");
  etykieta `EMAIL` + `ResetEmailField` (hint „Podaj adres Email"); `ContinueResetButton` → `Kontynuuj`.

### 4. Mail wysłany  ·  `presentation/auth/password_reset_email/`
- **Plik**: `pages/password_reset_email_page.dart` + `widgets/{email_sent_vector,sent_email_information,return_to_login_button}.dart`
- **Układ**: wyśrodkowany pion.
- **Komponenty**:
  - `EmailSending` (dawny wektor) → koło 96px, tło `softFill`, `border hairline`, wewnątrz `Icon(Icons.mark_email_read, size: 46, color: accent)`.
  - Tytuł Playfair 23 `Sprawdź skrzynkę` (możesz dodać) + `SentEmail` = tekst z l10n
    „Email z informacją jak zresetować hasło został wysłany." (`muted`, wyśrodkowany).
  - `ReturnToLoginButton` → **outlined** (border `primary`, tekst `primary`), tekst „Wróć do strony logowania".

### 5. Rejestracja  ·  `presentation/auth/signup/`
- **Plik**: `pages/signup_page.dart` + `widgets/{signup_header,signup_first_name_field,signup_email_field,signup_password_field,signup_button,signin_text}.dart`
- **Komponenty**: kicker `DOŁĄCZ DO NAS` + tytuł **`Utwórz konto`** (Playfair 31); pola z etykietami
  wersalikami: `IMIĘ` (`Imię`), `EMAIL`, `HASŁO` (z `visibility_off` suffix); `SignupButton` → `Utwórz konto`;
  `SigninText`: „Masz konto? **Zaloguj się**" (link accent w700).

### 6. Start (Home)  ·  `presentation/home/`
- **Pliki**: `pages/home_page.dart`, `widgets/{header,search_field_home,categories_row_view,meals_grid_view}.dart`
- **Header** (`header.dart`): lewa ikona `Icons.menu` (`ink`), środek — kicker `MEALAPP` (accent, wersaliki),
  po zalogowaniu tytuł powitania jako **kicker „Dzień dobry," + `helloUser(firstName)` bez „Cześć"**:
  duży serif „Oliwier" (Playfair 30). Prawa ikona `Icons.exit_to_app` (`muted`). Odznaka zaproszeń
  (`_InvitationsBadge`) zostaje, ale w kolorze `accent` zamiast czerwonego.
- **Search** (`search_field_home.dart`): pole outline 4px hairline, ikona `Icons.search` (`muted`),
  hint „Szukaj dania…".
- **Kategorie** (`categories_row_view.dart`): nagłówek „Kategorie" (Playfair 16) + „ZOBACZ WSZYSTKIE"
  (kicker accent) na **złotej linii** (dolne obramowanie 1px accent). Kółka kategorii 54px:
  zaznaczona ma pierścień `accent` z podwójną obwódką (`box-shadow` → w Flutter: `Container` z `border`
  accent + zewnętrzny `Container` z border `hairline`, przerwa tła). Podpis DM Sans 10.5, zaznaczony `ink`,
  reszta `muted`.
- **Dania** (`meals_grid_view.dart`): tytuł sekcji „Dania" + liczba **kursywą Playfair w accent** np. „— osiem"
  (obecnie `($count)` — możesz zostawić liczbę), przełącznik `Wege` jako mały wiersz z `Icon(Icons.eco)` +
  wersaliki `herb`. Karty dań: obraz 100px (bez zaokrągleń), pod nim tytuł **Playfair 14 w600**,
  meta 10px wersaliki `muted`, ikona serca `Icons.favorite` accent (ulubione) / `#C3B49C` (nie).
- **Bottom nav**: patrz „Zmiany globalne" p.4.

### 7. Szczegóły dania  ·  `presentation/meal_details/`
- **Pliki**: `pages/meal_detail_page.dart`, `widgets/{meal_image,meal_title,meal_ingredient,meal_step,favorite_button}.dart`
- **Obraz** (`meal_image.dart`): pełna szerokość 190px. Nakładki: `Icons.arrow_back` i `favorite_button`
  w białych kołach (`background`), padding 7, cień delikatny.
- Kicker `DANIE GŁÓWNE` (accent) + tytuł Playfair 25 (`meal_title.dart`).
- Wiersz „Dodaj do kalendarza" (`meal_detail_page.dart`): `Icon(Icons.calendar_month, color: accent)` + tekst
  w600, ograniczony **górną i dolną linią hairline**, po prawej `Icons.chevron_right` (`muted`). Zachowaj
  istniejącą nawigację do `PlannedMealPage(mealToAdd:)`.
- Porcje: „Liczba porcji" + steppery `Icons.remove_circle_outline`/`add_circle_outline` (`accent`),
  liczba **Playfair 18**. Logika `PortionCubit` bez zmian.
- Składniki (`meal_ingredient.dart`): nagłówek „Składniki" (Playfair 17) + „DO LISTY" (kicker `herb`)
  na złotej linii. Każda pozycja: kropka accent + nazwa + ilość/jednostka w `muted`, separator
  `dividerLight`; ikona po prawej `Icons.check_circle` (dodane → `herb`) / `add_circle_outline` (`#CDBFA8`).
  **Kolory zaznaczenia zmień z `Colors.green` na `AppColors.herb`.** Cała logika dodawania do listy zostaje.
- Przygotowanie (`meal_step.dart`): nagłówek „Przygotowanie" (Playfair 17); kroki numerowane —
  numer **kursywą Playfair w accent** (np. „I.", „II." lub „1."), treść DM Sans `#5C5245`.

### 8. Lista zakupów  ·  `presentation/shopping_list/`
- **Pliki**: `pages/shopping_list_page.dart`, `widgets/shopping_list_item.dart`
- Nagłówek: kicker `SPIŻARNIA` + tytuł Playfair 24 „Lista zakupów" (z `l10n.shoppingList`).
- Grupy po kategorii (`_groupItemsByCategory`): nazwa kategorii **kursywą Playfair w `accent`**
  (obecnie `Theme.primaryColor`) na cienkiej linii `hairline`.
- Pozycja (`shopping_list_item.dart`): ikona stanu `Icons.check_circle` (`herb`, kupione)
  / `Icons.radio_button_unchecked` (`#CDBFA8`); nazwa + `· ilość` w `muted`. Kupione: `opacity 0.45` +
  przekreślenie. Logika check/undo bez zmian.
- Trzy FAB-y na dole (`menu`, `delete_forever`, `add`): zamiast pełnych FAB-ów użyj okrągłych przycisków
  z obramowaniem `hairline` dla `menu` (`ink` #7A6D5B), `delete_forever` w `danger`, a `add` jako
  wypełnione koło `primary` z ikoną `background`. Zachowaj `heroTag` i handlery (groceries/clear/add).

### 9. Kalendarz  ·  `presentation/planned_meal/`
- **Pliki**: `pages/planned_meal_page.dart`, `widgets/{calendar_section,meals_list_section,meal_list_item,add_meal_button,clear_range_button}.dart`
- Nagłówek: kicker `PLAN POSIŁKÓW` + tytuł Playfair 24 „Kalendarz"; akcja `ClearRangeButton` jako
  `Icons.event_busy` (`muted`).
- `TableCalendar` (`calendar_section.dart`): `locale: 'pl_PL'`, poniedziałek start — bez zmian funkcjonalnie.
  Styl: dni tygodnia wersalikami `accent` na dolnej linii hairline; wybrany dzień — **wypełnione koło
  `primary`, tekst `background`** (ustaw `selectedDecoration`); dni z posiłkami — kropka w `accent`
  (zmień `markerBuilder` z `Colors.deepPurple` na `AppColors.accent`); tekst tytułu miesiąca Playfair.
- Sekcja „Zaplanowane" (`meals_list_section.dart`): nagłówek **kursywą Playfair accent** z datą (np.
  „Zaplanowane · piątek 4 lipca"). Uwaga: obecnie w kodzie jest napis **`Planned meals`** — zmień na polski
  „Zaplanowane".
- `MealListItem` (`meal_list_item.dart`): kafelek `border hairline` 8px, miniatura 44–46px, tytuł
  **Playfair 14 w600**, po prawej `Icons.close` + `Icons.drag_handle` (`#B3A58F`). Reorder/miniatura z Firebase — bez zmian.
- `AddMealButton` (widoczny gdy `mealToAdd != null`) → styl `primary`, tekst `l10n.addMealToDay`.

### 10. Ulubione  ·  `presentation/meal_details/pages/favorite_meals_page.dart` + `widgets/meal_grid.dart`
- `BasicAppbar(title: 'Ulubione posiłki')` → kicker `TWOJA KOLEKCJA` + tytuł Playfair 24
  (z `l10n.favoriteMeals`).
- `MealGrid`: siatka 2 kolumny (jest), karta jak w Home p.6 — obraz 92px, tytuł Playfair 13, meta wersaliki,
  serce accent w prawym górnym rogu.

### 11. Zamrażarka  ·  `presentation/freezer/`
- **Pliki**: `page/freezer_page.dart`, `widget/freezer_item_tile.dart`
- Nagłówek: kicker `CO MASZ W ZAPASIE` + tytuł Playfair 24 „Zamrażarka" + `Icon(Icons.ac_unit, muted)`.
- Grupy „Posiłki" / „Produkty" (`_groupByCategory`) — nagłówek **kursywą Playfair accent** na linii hairline
  (zamiast `Theme.primaryColor`).
- `FreezerItemTile`: zamień `Card`/elevation na `Container` z `border hairline`, `borderRadius: 10`,
  tło `surface`; nazwa DM Sans 13.5 w600; `Icons.edit` (edytuj, `muted`) + `Icons.delete` (`danger`).
  Dialogi edycji/usuwania i snackbar „Cofnij" — bez zmian.
- FAB `add` → okrągły `primary`, ikona `background`.

### 12. Wszystkie kategorie  ·  `presentation/all_categories/`
- **Pliki**: `pages/all_categories_page.dart`, `widgets/{list_by_categories,list_by_categories_header,category_card}.dart`
- `BasicAppbar` + kicker `PRZEGLĄDAJ` + tytuł Playfair 22 „Wszystkie kategorie".
- `CategoryCard` w siatce 2 kol.: kafel `borderRadius 6`, obraz z Firebase, **gradient od dołu**
  (`rgba(51,39,30,.62)` → transparent) i podpis kategorii **Playfair 15 w600 w `background`** w lewym-dolnym rogu.

### 13. Wyszukiwanie  ·  `presentation/search/`
- **Pliki**: `pages/search_page.dart`, `widgets/{search_field,meal_found,meal_not_found}.dart`
- `BasicAppbar(height:80, title: SearchField)`: pole outline **z obramowaniem `accent`**, ikona
  `Icons.search` accent, kursor accent. Po lewej `Icons.arrow_back`.
- Wyniki (`meal_found.dart`): nagłówek „N WYNIKI" (kicker `muted`), lista wierszy: miniatura 58px +
  tytuł **Playfair 15** + meta wersaliki `muted` + serce; separatory `dividerLight`.
- Pusto/`meal_not_found.dart`: wyśrodkowana ikona `Icons.restaurant` (`#C6B8A2`) + tekst **kursywą Playfair**
  „Zacznij pisać, aby znaleźć swoje dania" (lub istniejący komunikat z l10n).

### 14. Dania z kategorii  ·  `presentation/category_meals/`
- **Pliki**: `pages/category_meals_page.dart`, `widgets/{category_info,meals_grid_view}.dart`
- `CategoryInfo`: kicker „KATEGORIA · {liczba} DAŃ" + tytuł kategorii **Playfair 26** + złota linia pod spodem.
- `MealsGridView`: siatka 2 kol. z kartami jak w Home. Filtr wege (`VegetarianFilterCubit`) bez zmian.

### 15. Profil · Znajomi  ·  `presentation/home/pages/user_info_page.dart` (+ `friends/bloc`)
- **AppBar**: `Icons.arrow_back` + tytuł Playfair „Twój profil" (obecnie „Informacje użytkownika" — możesz zostawić).
- `_UserInfoSection`: karta z **awatarem-inicjałem** (koło 52px, tło `primary`, litera `background`
  Playfair) + imię (Playfair 17) + e-mail (`muted`). Zamiast dwóch `_InfoRow` — awatar + imię/e-mail obok.
- `TabBar` (Znajomi / Zaproszenia): wskaźnik **`primary`**, aktywna zakładka `ink w700`, nieaktywna `muted`;
  ikony `Icons.people` / `Icons.person_add`.
- „Dodaj znajomego": wiersz z **przerywanym obramowaniem `accent`** (border dashed), ikona+tekst accent,
  `Icons.arrow_forward_ios`. Dialog dodawania — bez zmian.
- `_FriendListItem`: `Container border hairline` 8px zamiast niebieskiej `Card`; awatar-inicjał tło `softFill`
  tekst `primary`; nazwa w600, e-mail `muted` (ellipsis). Ikony akcji **w `muted`**:
  `Icons.calendar_month` (udostępnij plan), `Icons.shopping_cart` (lista), `Icons.ac_unit` (zamrażarka),
  `Icons.person_remove` (`danger`). Cała logika udostępniania (`MealShareCubit`, `ShoppingListShareCubit`,
  `FreezerShareCubit`) i dialogi — bez zmian. Kolory statusów (zielony/pomarańczowy avatary zaproszeń)
  ujednolic do palety (`herb` dla akceptacji, `accent`/`danger` dla odrzucenia).
- Puste stany (`_EmptyFriendsView`, brak zaproszeń): ikony w `#C6B8A2`, teksty `muted`.

### 16. Szuflada · Ustawienia  ·  `presentation/home/widgets/main_drawer.dart`
- `_DrawerHeader`: tło `primary`, `Icon(Icons.settings, color: background, size: 38)` + „Ustawienia"
  **Playfair 23 w `background`**.
- `_VegetarianSwitch`: `ListTile` z `Icon(Icons.eco)` (zaznaczone `herb`, nie `muted`), tytuł
  „Wegetariańskie", `Switch` z `activeColor: herb`. Logika `VegetarianFilterCubit.toggle()` bez zmian.

---

## Interactions & Behavior
- **Cała logika, nawigacja (`go_router`), cubity/bloci i przepływy pozostają identyczne.** To warstwa wizualna.
- Przełącznik wege pokazuje istniejący `SnackBar` („Wybrano dania wegetariańskie" / „…wszystkie dania").
- Steppery porcji przeliczają składniki (`PortionCubit`) i synchronizują z listą zakupów — bez zmian.
- Reorder zaplanowanych posiłków (`ReorderableListView`) — bez zmian.
- Stany ładowania: `CircularProgressIndicator` → ustaw `color: AppColors.primary`.
- Stany błędu (`ErrorMessage`, snackbary) — bez zmian logicznie, tylko kolory z palety.

## State Management
Bez zmian. Wszystkie `Cubit`/`Bloc` z `MyAppWrapper` (`UserInfoDisplayCubit`, `FavoriteMealsCubit`,
`ShoppingListMealIngredientCubit`, `ShoppingListCustomItemCubit`, `FreezerItemCubit`, `CategoriesDisplayCubit`,
`MealsDisplayCubit`, `PlannedMealsCubit`, `FriendsCubit`, share-cubity itd.) zostają.

## Design Tokens
| Token | Hex | Zastosowanie |
|---|---|---|
| primary (espresso) | `#5A4632` | przyciski, aktywna ikona nav, wybrany dzień, awatar |
| accent (złoto) | `#A9793F` | kickery, złote linie, linki, kropki, serca ulubionych |
| background (ivory) | `#FBF7F0` | tło ekranu, tekst na ciemnym |
| surface | `#FFFFFF` | karty/pola (gdy wypełnione) |
| ink | `#33271E` | tekst główny |
| muted | `#9B8B76` | tekst drugorzędny, meta, ikony nieaktywne |
| hairline | `#E3D6C1` | obramowania 1px |
| dividerLight | `#EEE4D4` | separatory list |
| softFill | `#EFE6D8` | tła awatarów/kółek ikon |
| herb | `#5A6B45` | wege, pozycje zaznaczone/kupione |
| danger | `#9C5030` | usuwanie |
| placeholder | `#A99A85` | hint pól |
| ikona nieaktywna nav | `#C6B8A2` | dolna nawigacja |

**Typografia**: nagłówki `Playfair Display` w600 (24/26/30/31/32); tytuły kart/list `Playfair` 13–17 w600;
treść i UI `DM Sans` 12–15 (w400/500/600/700); kicker `DM Sans` 10 w600 UPPERCASE `letterSpacing≈1.8`.
**Promienie**: pola 4px, kafle list 8–10px, karty kategorii 6px, awatary/koła — pełne. **Bez cieni** (poza
delikatnym cieniem nakładek na zdjęciu dania).

## Assets
- **Ikony**: Material Icons (`Icons.*`) — już w projekcie, nie trzeba nic dodawać. Kluczowe:
  `menu, exit_to_app, search, eco, favorite, calendar_month, remove_circle_outline, add_circle_outline,
  add_shopping_cart, check_circle, radio_button_unchecked, arrow_back, chevron_right, ac_unit, edit, delete,
  delete_forever, add, close, drag_handle, event_busy, mark_email_read, visibility(_off), people, person_add,
  person_remove, arrow_forward_ios, restaurant, settings, home, shopping_cart`.
- **Czcionki**: Playfair Display + DM Sans przez pakiet `google_fonts`.
- **Zdjęcia dań i kategorii**: z Firebase przez `CachedNetworkImage` + `ImageDisplayHelper.meal/category`
  (`ImgVariant.thumb`) — **bez zmian**. Paskowane placeholdery w makiecie NIE są do odwzorowania.

## Files
- `Mealapp Redesign.dc.html` — prototyp HTML wszystkich ekranów (implementuj kierunek **1c** + tury **2a**, **3a**).
  Otwórz w przeglądarce, aby zobaczyć docelowy wygląd i skopiować dokładne wartości.
