import 'package:flutter/material.dart';
import 'package:learningdart/models/box.dart';
import 'package:learningdart/models/employee.dart';
import 'package:learningdart/models/person.dart';
import 'package:learningdart/services/data_service.dart';

/// Entry point of the learning-dart Flutter application.
void main() {
  runApp(const MyApp());
}

/// Root widget that configures the app theme and home screen.
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

/// Home screen that demonstrates various Dart language features.
///
/// Each widget in the [Column] corresponds to a different concept explored in
/// the `models/`, `services/`, and `utils/` packages:
/// - [Employee] and [PersonExtension]
/// - [fetchData] / [Future]
/// - [countStream] / [Stream]
/// - [Box] generics
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// The title shown in the [AppBar].
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final gweKerja = Employee("Dzaki", 25, "Software Engineer");
  final boxGenerics = Box<int, double>(42, 3.14);

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
            // Introduce the employee (inheritance demo)
            Text(gweKerja.introduce()),
            const SizedBox(height: 10),
            // Extension method demo
            Text(gweKerja.upperCaseName),
            const SizedBox(height: 10),
            // Future / async-await demo
            FutureBuilder<String>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(snapshot.data ?? 'No data');
                }
              },
            ),
            const SizedBox(height: 10),
            // Stream / async-generator demo
            StreamBuilder<int>(
              stream: countStream(5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('Count: ${snapshot.data}');
                }
              },
            ),
            const SizedBox(height: 10),
            // Generics demo
            Text(
              'Box content: ${boxGenerics.content}, '
              'Metadata: ${boxGenerics.metadata}',
            ),
          ],
        ),
      ),
    );
  }
}
