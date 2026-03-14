/// Represents a person with a [name] and [age].
///
/// Demonstrates basic Dart class definition with positional constructor
/// parameters and an instance method.
class Person {
  /// The person's full name.
  String name;

  /// The person's age in years.
  int age;

  /// Creates a [Person] with the given [name] and [age].
  Person(this.name, this.age);

  /// Returns a short self-introduction string.
  String introduce() {
    return "Hi, I'm $name and I'm $age years old.";
  }
}

/// Extension methods added to every [Person] instance.
///
/// Demonstrates Dart's extension syntax: new behaviour can be added to an
/// existing class without modifying or subclassing it.
extension PersonExtension on Person {
  /// Returns [Person.name] converted to upper-case.
  String get upperCaseName => name.toUpperCase();
}
