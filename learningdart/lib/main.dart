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
            Text("Null Safety Demo: ${getNullSafetyDemo()}"),
            const SizedBox(height: 20),
            Text("Null Aware Demo: ${getNullAwareDemo(null)}"),
            const SizedBox(height: 20),
            Text("conditional invocation demo:"),
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
