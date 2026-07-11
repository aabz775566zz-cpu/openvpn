/// A minimal, dependency-free result type used to represent the outcome of
/// an operation that can either succeed with a value of type [T] or fail
/// with an [Exception] (or any error object).
///
/// Using this instead of throwing exceptions across layer boundaries makes
/// failure handling explicit in use cases and controllers.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Object error, [StackTrace? stackTrace]) =
      Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Returns the success value or `null` if this is a [Failure].
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  /// Pattern-matches on the result, invoking [onSuccess] or [onFailure].
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error, StackTrace? stackTrace) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final error, :final stackTrace) =>
        onFailure(error, stackTrace),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}
