import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/enums/menu_action.dart';
import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/auth_service.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/services/cloud/cloud_storage.dart';
import 'package:my_notes/services/cloud/firebase_cloud_storage.dart';
import 'package:my_notes/utilities/dialogs/logout_dialog.dart';
import 'package:my_notes/views/notes/notes_list_view.dart';

/// Main screen that shows the list of notes for the authenticated user.
///
/// Accepts optional [cloudStorage] and [authProvider] dependencies so that
/// the widget can be tested without a real Firebase back-end.  When either
/// dependency is omitted the production singleton is used instead.
class NotesView extends StatefulWidget {
  /// Optional storage implementation; defaults to [FirebaseCloudStorage].
  final CloudStorage? cloudStorage;

  /// Optional auth provider; defaults to [AuthService.firebase()].
  final AuthProvider? authProvider;

  const NotesView({super.key, this.cloudStorage, this.authProvider});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  /// Resolves the [CloudStorage] to use — injected or the Firebase singleton.
  CloudStorage get _notesService =>
      widget.cloudStorage ?? FirebaseCloudStorage();

  /// Resolves the [AuthProvider] to use — injected or the Firebase singleton.
  AuthProvider get _authProvider =>
      widget.authProvider ?? AuthService.firebase();

  /// The UID of the currently authenticated user.
  String get _userId => _authProvider.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoutes);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                final shouldLogout = await showLogoutDialog(context);
                if (!context.mounted) return;
                if (shouldLogout) {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: MenuAction.logout, child: Text('Logout')),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: _userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(
                      documentId: note.documentId,
                    );
                  },
                  onTap: (CloudNote note) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoutes,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const Center(child: Text('No notes found'));
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
