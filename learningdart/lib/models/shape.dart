/// Abstract base class for geometric shapes.
///
/// Demonstrates abstract classes in Dart: the class cannot be instantiated
/// directly and requires every concrete subclass to provide an implementation
/// of [area].
abstract class Shape {
  /// Returns the area of this shape.
  double area();
}
