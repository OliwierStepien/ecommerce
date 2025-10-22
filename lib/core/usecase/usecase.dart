/// 🔹 Bazowy kontrakt (interfejs) dla wszystkich Use Case’ów w aplikacji.
///
/// Każdy UseCase w warstwie domeny (domain) reprezentuje pojedynczą,
/// niezależną operację biznesową — np. dodanie posiłku, usunięcie elementu,
/// pobranie danych itp.
///
/// - [Type]  → typ zwracany przez UseCase (np. `Either<Failure, List<MealEntity>>`)
/// - [Params] → typ danych wejściowych przekazywanych do operacji (np. `MealEntity`)
///
/// Dzięki temu każdy UseCase jest:
/// ✅ niezależny od frameworków (Fluttera, Firestore, itp.)
/// ✅ łatwy do testowania (mockujesz repozytoria)
/// ✅ zgodny z zasadami Clean Architecture.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// 🔸 Klasa pomocnicza dla Use Case’ów, które nie wymagają żadnych danych wejściowych.
class NoParams {}