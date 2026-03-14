import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/services/cloud/cloud_storage.dart';
import 'package:my_notes/views/notes/create_update_note_view.dart';

// Simple fake storage that doesn't touch Firebase.
// Implements the full [CloudStorage] contract including [allNotes].
class FakeCloudStorage implements CloudStorage {
  @override
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    return CloudNote(
      documentId: 'fake',
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  @override
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {}

  @override
  Future<void> deleteNote({required String documentId}) async {}

  @override
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      const Stream.empty();
}

void main() {
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

  TestWidgetsFlutterBinding.ensureInitialized();

  group('share button', () {
    setUp(() {
      // Intercept any share channel messages so the plugin does not try to
      // talk to the platform.
      shareChannel.setMockMethodCallHandler((MethodCall call) async {
        return null;
      });
    });

    tearDown(() {
      shareChannel.setMockMethodCallHandler(null);
    });

    testWidgets('share button is present even while note loads', (tester) async {
      // The share button is always interactive; just ensure it is built and
      // has a callback even before the note future completes.
      await tester.pumpWidget(
        MaterialApp(home: CreateUpdateNoteView(cloudStorage: FakeCloudStorage())),
      );
      final shareButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.share),
      );
      expect(shareButton.onPressed, isNotNull);
    });

    testWidgets('invokes share plugin when there is text', (tester) async {
      final CloudNote example = CloudNote(
        documentId: 'abc',
        ownerUserId: 'user123',
        text: 'initial',
      );

      MethodCall? lastCall;
      shareChannel.setMockMethodCallHandler((MethodCall call) async {
        lastCall = call;
        return null;
      });

      // Navigate to the view with our example note as a route argument.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateUpdateNoteView(cloudStorage: FakeCloudStorage()),
                      settings: RouteSettings(arguments: example),
                    ),
                  );
                },
                child: const Text('go'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      // Enter some text into the note field.
      await tester.enterText(find.byType(TextField), 'hello world');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      expect(lastCall, isNotNull,
          reason: 'share plugin should have been called');
      expect(lastCall!.method, 'share');
      // share_plus encodes the text param in a map under 'text'.
      expect(lastCall!.arguments, isA<Map>());
      expect((lastCall!.arguments as Map)['text'], 'hello world');
    });
  });
}
