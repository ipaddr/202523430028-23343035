import 'package:learningdart/models/person.dart';

/// An employee is a [Person] with a [position].
///
/// Demonstrates class inheritance (`extends`) and method overriding
/// (`@override`).
class Employee extends Person {
  /// The employee's job title or role.
  String position;

  /// Creates an [Employee] by forwarding [name] and [age] to [Person] via
  /// `super`, and providing the employee-specific [position].
  Employee(super.name, super.age, this.position);

  /// Overrides [Person.introduce] to also mention the employee's [position].
  @override
  String introduce() {
    return "${super.introduce()} and I work as a $position.";
  }
}
