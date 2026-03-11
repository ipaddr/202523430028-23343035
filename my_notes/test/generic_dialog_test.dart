import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

void main() {
  group('generic dialog', () {
    testWidgets('does not crash when an option value is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                child: const Text('show'),
                onPressed: () {
                  showGenericDialog<void>(
                    context: context,
                    title: 'title',
                    content: 'content',
                    optionsBuilder: () => {'OK': null},
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(find.text('title'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // dismiss
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('title'), findsNothing);
    });

    testWidgets('returns a non-null option value when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                child: const Text('show2'),
                onPressed: () async {
                  // show dialog with non-null values; we don't need the return
                  await showGenericDialog<String>(
                    context: context,
                    title: 'choose',
                    content: 'pick one',
                    optionsBuilder: () => {'yes': 'y', 'no': 'n'},
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('show2'));
      await tester.pumpAndSettle();
      expect(find.text('yes'), findsOneWidget);
      expect(find.text('no'), findsOneWidget);
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      expect(find.text('choose'), findsNothing);
    });
  });
}
