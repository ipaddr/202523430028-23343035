import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/main.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/views/splash_view.dart';

// a barebones provider for test, using the mock from auth_test
import 'auth_test.dart' as auth_test;

void main() {
  testWidgets('HomePage shows splash when state uninitialized', (tester) async {
    // create bloc with mock provider
    final provider = auth_test.MockAuthProvider();
    final bloc = AuthBloc(provider);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const HomePage(),
        ),
      ),
    );

    // initial state of bloc should be uninitialized, so splash must appear
    expect(find.byType(SplashView), findsOneWidget);

    // the bloc was already told to initialize during the first build;
    // wait long enough for the mock provider's one-second delay to finish
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // after initialization, the splash view should be gone
    expect(find.byType(SplashView), findsNothing);
  });
}
