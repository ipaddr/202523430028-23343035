/// A generic container that holds a [content] of type [T] and [metadata] of
/// type [U].
///
/// Demonstrates Dart generics: the same class can be parameterised with
/// different types, e.g. `Box<int, double>` or `Box<String, List<int>>`.
class Box<T, U> {
  /// The primary value stored in this box.
  T content;

  /// Supplementary metadata associated with [content].
  U metadata;

  /// Creates a [Box] with the given [content] and [metadata].
  Box(this.content, this.metadata);
}
