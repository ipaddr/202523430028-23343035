/// Extension methods for streams whose events are [List]s.
///
/// The built-in [Stream.where] filters events at the stream level, not the
/// contents of each list.  This extension adds [filter] which applies a
/// predicate to every *element* of each emitted list, producing a new stream
/// of filtered lists without modifying the originals.
extension StreamListFilter<T> on Stream<List<T>> {
  /// Returns a new stream where every emitted list contains only the elements
  /// that satisfy [predicate].
  ///
  /// Each incoming list is transformed with `where` and collected into a new
  /// list before being re-emitted.  The original lists are never mutated.
  ///
  /// Example:
  /// ```dart
  /// stream.filter((note) => note.userId == currentUserId);
  /// ```
  Stream<List<T>> filter(bool Function(T element) predicate) =>
      map((items) => items.where(predicate).toList());
}
