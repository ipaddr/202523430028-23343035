/// Represents the three common states of an asynchronous operation.
///
/// Demonstrates Dart's `enum` keyword.  Enums are better than raw strings or
/// integers because the compiler catches typos and exhaustive switch checks
/// become possible.
enum Status {
  /// The operation completed successfully.
  success,

  /// The operation encountered an error.
  error,

  /// The operation is still in progress.
  loading,
}
