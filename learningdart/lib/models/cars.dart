/// Represents a car with a [model] and manufacturing [year].
///
/// Demonstrates the factory constructor pattern: [Cars.create] selects the
/// appropriate [year] based on the [model] without requiring the caller to
/// know those details.
class Cars {
  /// The car model name (e.g. 'Tesla', 'Toyota').
  String model;

  /// The year the car was manufactured.
  int year;

  /// Creates a [Cars] with [model] and [year].
  Cars(this.model, this.year);

  /// Factory constructor that infers the manufacturing [year] from the
  /// [model].
  ///
  /// - `'Tesla'` → 2020  
  /// - any other model → 2010
  factory Cars.create(String model) {
    if (model == 'Tesla') {
      return Cars(model, 2020);
    } else {
      return Cars(model, 2010);
    }
  }
}
