import 'package:mealapp/common/helper/handle_firestore_operation/failure/failure.dart';

String mapFailureToMessage(Failure failure) {
  switch (failure) {
    case ServerFailure():
      return 'Ups, błąd API. Proszę spróbować ponownie!';
    case NetworkFailure():
      return 'Ups, brak połączenia z internetem. Sprawdź swoje połączenie i spróbuj ponownie!';
    case CacheFailure():
      return 'Ups, błąd lokalnego przechowywania danych. Proszę spróbować ponownie!';
    case TimeoutFailure():
      return 'Ups, przekroczono czas oczekiwania na odpowiedź. Proszę spróbować ponownie!';
    case UnauthorizedFailure():
      return 'Ups, nieautoryzowany dostęp. Zaloguj się ponownie!';
    case WeakPasswordFailure():
      return 'Hasło jest zbyt słabe.';
    case EmailAlreadyInUseFailure():
      return 'Ten email jest już zajęty.';
    case InvalidEmailFailure():
      return 'Niepoprawny adres email.';
    case InvalidCredentialFailure():
      return 'Podano błędne hasło.';
    case GeneralFailure():
      return 'Ups, coś poszło nie tak. Proszę spróbować ponownie!';
  }
}