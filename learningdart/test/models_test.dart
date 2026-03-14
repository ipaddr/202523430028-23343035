import 'package:flutter_test/flutter_test.dart';
import 'package:learningdart/enums/status.dart';
import 'package:learningdart/models/box.dart';
import 'package:learningdart/models/cars.dart';
import 'package:learningdart/models/circle.dart';
import 'package:learningdart/models/employee.dart';
import 'package:learningdart/models/person.dart';
import 'package:learningdart/services/data_service.dart';
import 'package:learningdart/utils/helpers.dart';

void main() {
  // ── Person ────────────────────────────────────────────────────────────────
  group('Person', () {
    test('introduce() contains name and age', () {
      final p = Person('Alice', 30);
      final intro = p.introduce();
      expect(intro, contains('Alice'));
      expect(intro, contains('30'));
    });

    test('PersonExtension.upperCaseName returns upper-case name', () {
      final p = Person('alice', 25);
      expect(p.upperCaseName, 'ALICE');
    });
  });

  // ── Employee ──────────────────────────────────────────────────────────────
  group('Employee', () {
    test('introduce() mentions position', () {
      final e = Employee('Bob', 28, 'Developer');
      final intro = e.introduce();
      expect(intro, contains('Bob'));
      expect(intro, contains('28'));
      expect(intro, contains('Developer'));
    });

    test('extends Person — is-a Person', () {
      final e = Employee('Bob', 28, 'Developer');
      expect(e, isA<Person>());
    });
  });

  // ── Circle ────────────────────────────────────────────────────────────────
  group('Circle', () {
    test('area equals π * r²', () {
      final c = Circle(5.0);
      expect(c.area(), closeTo(3.14 * 5 * 5, 0.01));
    });

    test('area of zero-radius circle is zero', () {
      final c = Circle(0);
      expect(c.area(), 0.0);
    });
  });

  // ── Cars ──────────────────────────────────────────────────────────────────
  group('Cars.create factory', () {
    test('Tesla model gets year 2020', () {
      final car = Cars.create('Tesla');
      expect(car.model, 'Tesla');
      expect(car.year, 2020);
    });

    test('non-Tesla model gets year 2010', () {
      final car = Cars.create('Toyota');
      expect(car.year, 2010);
    });
  });

  // ── Box ───────────────────────────────────────────────────────────────────
  group('Box', () {
    test('stores content and metadata of the correct types', () {
      final box = Box<int, double>(42, 3.14);
      expect(box.content, 42);
      expect(box.metadata, closeTo(3.14, 0.001));
    });

    test('works with String/List types', () {
      final box = Box<String, List<int>>('hello', [1, 2, 3]);
      expect(box.content, 'hello');
      expect(box.metadata, [1, 2, 3]);
    });
  });

  // ── Status enum ───────────────────────────────────────────────────────────
  group('Status', () {
    test('has success, error and loading values', () {
      expect(Status.values, containsAll([
        Status.success,
        Status.error,
        Status.loading,
      ]));
    });
  });

  // ── Helper functions ──────────────────────────────────────────────────────
  group('helpers', () {
    test('getFullName concatenates firstName and lastName', () {
      expect(getFullName('John', 'Doe'), 'John Doe');
    });

    test('isPositive returns correct classification', () {
      expect(isPositive(5), 'Positive');
      expect(isPositive(-3), 'Negative');
      expect(isPositive(0), 'Zero');
    });

    test('getGrade returns correct letter grade', () {
      expect(getGrade(95), 'A');
      expect(getGrade(85), 'B');
      expect(getGrade(75), 'C');
      expect(getGrade(65), 'D');
      expect(getGrade(50), 'F');
    });

    test('getFruits returns a non-empty list', () {
      expect(getFruits(), isNotEmpty);
    });

    test('getUniqueNumbers has no duplicates', () {
      final nums = getUniqueNumbers();
      expect(nums.length, equals(nums.toSet().length));
    });

    test('getPersonInfo contains expected keys', () {
      final info = getPersonInfo();
      expect(info, containsPair('name', isA<String>()));
      expect(info, containsPair('age', isA<int>()));
    });

    test('getNullSafetyDemo returns fallback (non-null) string', () {
      final result = getNullSafetyDemo();
      expect(result, isNotEmpty);
    });

    test('getNullAwareDemo returns input when non-null', () {
      expect(getNullAwareDemo('custom'), 'custom');
    });

    test('getNullAwareDemo returns default when null', () {
      expect(getNullAwareDemo(null), 'Default Value');
    });
  });

  // ── Data service ──────────────────────────────────────────────────────────
  group('DataService', () {
    test('fetchData completes with a non-empty string', () async {
      final result = await fetchData();
      expect(result, isNotEmpty);
    });

    test('countStream emits values from 1 to n in order', () async {
      final values = await countStream(3).toList();
      expect(values, [1, 2, 3]);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
