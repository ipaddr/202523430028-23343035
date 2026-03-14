/// Returns the full name by concatenating [firstName] and [lastName].
///
/// Demonstrates a simple named function with multiple parameters.
String getFullName(String firstName, String lastName) {
  return '$firstName $lastName';
}

/// Classifies [number] as `'Positive'`, `'Negative'`, or `'Zero'`.
///
/// Demonstrates `if`/`else if`/`else` conditionals.
String isPositive(int number) {
  if (number > 0) {
    return 'Positive';
  } else if (number < 0) {
    return 'Negative';
  } else {
    return 'Zero';
  }
}

/// Maps a numeric [score] (0–100) to a letter grade.
///
/// Demonstrates chained `if`/`else if` conditions used as a grade
/// calculator.
String getGrade(int score) {
  if (score >= 90) {
    return 'A';
  } else if (score >= 80) {
    return 'B';
  } else if (score >= 70) {
    return 'C';
  } else if (score >= 60) {
    return 'D';
  } else {
    return 'F';
  }
}

/// Returns a list of fruit names.
///
/// Demonstrates Dart's [List] literal syntax.
List<String> getFruits() {
  return ['Apple', 'Banana', 'Orange'];
}

/// Returns a set of unique integers.
///
/// Demonstrates Dart's [Set] type: duplicate values are silently ignored.
Set<int> getUniqueNumbers() {
  final Set<int> numbers = {1, 2, 3, 4, 5};
  numbers.add(3); // duplicate — has no effect
  numbers.add(6);
  return numbers;
}

/// Returns a [Map] of personal information fields.
///
/// Demonstrates Dart's map literal syntax with mixed value types.
Map<String, dynamic> getPersonInfo() {
  return {'name': 'Dzaki Sultan', 'age': 25, 'city': 'Padang'};
}

/// Demonstrates null safety using the `??` (null-coalescing) operator.
///
/// Returns the non-nullable fallback value because [nullableString] is `null`.
String getNullSafetyDemo() {
  String? nullableString; // can be null
  const String nonNullableString = "this is non-null"; // cannot be null

  return nullableString ?? nonNullableString;
}

/// Returns [input] if it is non-null, otherwise `'Default Value'`.
///
/// Demonstrates the `??` null-aware operator applied to a function parameter.
String getNullAwareDemo(String? input) {
  return input ?? "Default Value";
}
