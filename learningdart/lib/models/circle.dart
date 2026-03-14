import 'package:learningdart/models/shape.dart';

/// A circle shape with a given [radius].
///
/// Demonstrates how to implement an abstract class ([Shape]) and override
/// its abstract method.
class Circle extends Shape {
  /// The radius of this circle.
  double radius;

  /// Creates a [Circle] with the given [radius].
  Circle(this.radius);

  /// Returns the area using the formula πr² (with π ≈ 3.14).
  @override
  double area() {
    return 3.14 * radius * radius;
  }
}
