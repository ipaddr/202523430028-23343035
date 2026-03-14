import 'package:flutter/material.dart';
import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/auth_service.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/services/cloud/cloud_storage.dart';
import 'package:my_notes/services/cloud/firebase_cloud_storage.dart';
import 'package:my_notes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:my_notes/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

/// Screen for creating a new note or updating an existing one.
///
/// Accepts optional [cloudStorage] and [authProvider] dependencies so that
/// the widget can be tested without a real Firebase back-end.  When either
/// dependency is omitted the production singleton is used instead, satisfying
/// the Dependency-Inversion Principle without breaking the existing call sites
/// in production code.
class CreateUpdateNoteView extends StatefulWidget {
  /// Optional storage implementation; defaults to [FirebaseCloudStorage].
  final CloudStorage? cloudStorage;

  /// Optional auth provider; defaults to [AuthService.firebase()].
  final AuthProvider? authProvider;

  const CreateUpdateNoteView({super.key, this.cloudStorage, this.authProvider});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;

  /// Resolves the [CloudStorage] to use — injected or the Firebase singleton.
  CloudStorage get _notesService =>
      widget.cloudStorage ?? FirebaseCloudStorage();

  /// Resolves the [AuthProvider] to use — injected or the Firebase singleton.
  AuthProvider get _authProvider =>
      widget.authProvider ?? AuthService.firebase();

  late final TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  /// Returns the note to edit.
  ///
  /// If a [CloudNote] was passed as a route argument it is used directly.
  /// Otherwise a new note is created in the storage back-end.
  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      if (mounted) {
        setState(() {
          _note = widgetNote;
        });
      } else {
        _note = widgetNote;
      }
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final userId = _authProvider.currentUser!.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    if (mounted) {
      setState(() {
        _note = newNote;
      });
    } else {
      _note = newNote;
    }
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: _textController.text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                await Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                  contentPadding: EdgeInsets.all(16),
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
