sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.message, this.fieldErrors);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}