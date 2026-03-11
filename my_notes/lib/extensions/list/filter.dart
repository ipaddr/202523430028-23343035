/// Helpers for a stream that emits lists.
///
/// The built‑in `Stream.where` filters events, not the contents of a list.
/// This extension makes it easy to apply a predicate to every element of
/// each list that flows through the stream.
extension StreamListFilter<T> on Stream<List<T>> {
  /// Return a stream of lists in which every element satisfies
  /// [predicate].
  ///
  /// The original lists are not mutated – a new filtered list is created
  /// for each event.
  Stream<List<T>> filter(bool Function(T element) predicate) =>
      map((items) => items.where(predicate).toList());
}
