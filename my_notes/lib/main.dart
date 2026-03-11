import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/views/email_verify_view.dart';
import 'package:my_notes/views/login_view.dart';
import 'package:my_notes/views/notes/create_update_note_view.dart';
import 'package:my_notes/views/notes/notes_view.dart';
import 'package:my_notes/views/register_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        // custom colors
        primaryColor: const Color(0xFF004643), // Cyprus
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Cloud White
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004643),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
      routes: {
        notesRoutes: (context) => const NotesView(),
        loginRoutes: (context) => const LoginView(),
        registerRoutes: (context) => const RegisterView(),
        verifyEmailRoutes: (context) => const EmailVerifyView(),
        createOrUpdateNoteRoutes: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           // saat Firebase sudah siap, lakukan navigasi
//           final user = AuthService.firebase().currentUser;
//           if (user != null) {
//             if (user.isEmailVerified) {
//               return const NotesView();
//             } else {
//               return const EmailVerifyView();
//             }
//           } else {
//             return const LoginView();
//           }
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter Bloc')),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInvalid)
                ? state.invalidValue
                : null;

            return Column(
              children: [
                Text('Count: ${state.count}'),
                Visibility(
                  visible: state is CounterStateInvalid,
                  child: Text('Invalid input: $invalidValue'),
                ),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter a number',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                          CounterEventIncrement(_controller.text),
                        );
                      },
                      child: const Text('Increment'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                          CounterEventDecrement(_controller.text),
                        );
                      },
                      child: const Text('Decrement'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int count;

  const CounterState({required this.count});
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int count) : super(count: count);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;

  const CounterStateInvalid({
    required this.invalidValue,
    required int previousCount,
  }) : super(count: previousCount);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class CounterEventIncrement extends CounterEvent {
  const CounterEventIncrement(super.value);
}

class CounterEventDecrement extends CounterEvent {
  const CounterEventDecrement(super.value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<CounterEventIncrement>((event, emit) {
      final value = int.tryParse(event.value);
      if (value == null) {
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousCount: state.count,
          ),
        );
      } else {
        emit(CounterStateValid(state.count + value));
      }
    });
    on<CounterEventDecrement>((event, emit) {
      final value = int.tryParse(event.value);
      if (value == null) {
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousCount: state.count,
          ),
        );
      } else {
        emit(CounterStateValid(state.count - value));
      }
    });
  }
}
