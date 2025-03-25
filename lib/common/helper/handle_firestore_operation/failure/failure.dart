sealed class Failure {}

class ServerFailure extends Failure {}

class NetworkFailure extends Failure {}

class CacheFailure extends Failure {}

class TimeoutFailure extends Failure {}

class UnauthorizedFailure extends Failure {}

class GeneralFailure extends Failure {}

class WeakPasswordFailure extends Failure {}

class EmailAlreadyInUseFailure extends Failure {}

class InvalidEmailFailure extends Failure {}

class InvalidCredentialFailure extends Failure {}