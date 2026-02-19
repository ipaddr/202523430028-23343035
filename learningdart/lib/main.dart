import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final gwe = Person("Dzaki", 25);
  final gweKerja = Employee("Dzaki", 25, "Software Engineer");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(getFullName("Dzaki", "Sultan")),
            const SizedBox(height: 10),
            Text("${Status.loading}"),
            const SizedBox(height: 10),
            Text(gwe.introduce()),
            const SizedBox(height: 10),
            Text(gweKerja.introduce()),
            const SizedBox(height: 10),
            Text("Area of Circle with radius 5: ${Circle(5).area()}"),
            const SizedBox(height: 10),
            Text(
              "Car created with factory: ${Cars.create('BMW').model} (${Cars.create('BMW').year})",
            ),
          ],
        ),
      ),
    );
  }
}

// functions
String getFullName(String firstName, String lastName) {
  return '$firstName $lastName';
}

// conditionals
String isPositive(int number) {
  if (number > 0) {
    return 'Positive';
  } else if (number < 0) {
    return 'Negative';
  } else {
    return 'Zero';
  }
}

// operators
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

// list
List getFruits() {
  return ['Apple', 'Banana', 'Orange'];
}

// sets
Set getUniqueNumbers() {
  Set<int> numbers = {1, 2, 3, 4, 5};
  numbers.add(3); // Tidak akan ditambahkan karena sudah ada
  numbers.add(6);
  return numbers;
}

// maps
Map getPersonInfo() {
  return {'name': 'Dzaki Sultan', 'age': 25, 'city': 'Padang'};
}

// null safety
String getNullSafetyDemo() {
  String? nullableString; // Bisa null
  String nonNullableString = "ini non null"; // Tidak bisa null

  // Menggunakan null aware operator
  return nullableString ?? nonNullableString;
}

// null aware operator
String getNullAwareDemo(String? input) {
  return input ?? "Default Value";
}

// enums
enum Status { success, error, loading }

// classes
class Person {
  String name;
  int age;

  Person(this.name, this.age);
  String introduce() {
    return "Hi, I'm $name and I'm $age years old.";
  }
}

// inheritance
class Employee extends Person {
  String position;

  Employee(super.name, super.age, this.position);

  @override
  String introduce() {
    return "${super.introduce()} and I work as a $position.";
  }
}

// abstract class
abstract class Shape {
  double area();
}

class Circle extends Shape {
  double radius;

  Circle(this.radius);

  @override
  double area() {
    return 3.14 * radius * radius;
  }
}

// factory constructor
class Cars {
  String model;
  int year;

  Cars(this.model, this.year);

  factory Cars.create(String model) {
    if (model == 'Tesla') {
      return Cars(model, 2020);
    } else {
      return Cars(model, 2010);
    }
  }
}
