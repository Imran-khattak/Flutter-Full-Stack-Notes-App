import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/data/auth/user_session.dart';
import 'package:notes_app/data/repositories/network_repositories.dart';
import 'package:notes_app/features/models/notes_model.dart';
import 'package:notes_app/utils/popus/loaders.dart';

class NotesController with ChangeNotifier {
  bool _isLoading = false;
  final List<NotesModel> _notesList = [];

  // Selection state management
  bool _isSelectionMode = false;
  Set<String> _selectedNotes = <String>{};

  // Form controllers
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  final FocusNode contentFocus = FocusNode();
  final noteFormkey = GlobalKey<FormState>();

  // Color selection
  Color selectedColor = const Color(0xFFE3F2FD);
  final List<Color> noteColors = [
    const Color(0xFFE3F2FD), // Light Blue
    const Color(0xFFF3E5F5), // Light Purple
    const Color(0xFFE8F5E8), // Light Green
    const Color(0xFFFFF3E0), // Light Orange
    const Color(0xFFFFEBEE), // Light Pink
    const Color(0xFFF1F8E9), // Light Lime
  ];

  // Getters
  bool get isLoading => _isLoading;
  List<NotesModel> get notesList => _notesList;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedNotes => _selectedNotes;
  int get selectedCount => _selectedNotes.length;
  bool get isAllSelected =>
      _selectedNotes.length == _notesList.length && _notesList.isNotEmpty;

  NotesController() {
    getNotes();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Selection Methods
  void enterSelectionMode(String noteId) {
    _isSelectionMode = true;
    _selectedNotes.add(noteId);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedNotes.clear();
    notifyListeners();
  }

  void toggleNoteSelection(String noteId) {
    if (_selectedNotes.contains(noteId)) {
      _selectedNotes.remove(noteId);
      // Exit selection mode if no notes are selected
      if (_selectedNotes.isEmpty) {
        exitSelectionMode();
        return;
      }
    } else {
      _selectedNotes.add(noteId);
    }
    notifyListeners();
  }

  void selectAllNotes() {
    _selectedNotes = _notesList
        .map((note) => note.id ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    notifyListeners();
  }

  void deselectAllNotes() {
    _selectedNotes.clear();
    notifyListeners();
  }

  bool isNoteSelected(String noteId) {
    return _selectedNotes.contains(noteId);
  }

  // Delete Methods
  Future<void> deleteSelectedNotes(BuildContext context) async {
    if (_selectedNotes.isEmpty) return;

    final confirmed = await _showDeleteConfirmation(
      context,
      _selectedNotes.length,
    );
    if (!confirmed) return;

    await _performBatchDelete(context);
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, int count) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          content: Text(
            'Are you sure you want to delete $count ${count == 1 ? 'note' : 'notes'}? This action cannot be undone.',
            style: const TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53E3E), Color(0xFFFC8181)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _performBatchDelete(BuildContext context) async {
    try {
      _setLoading(true);
      final netRepo = NetworkRepositories();

      // Delete selected notes
      for (String noteId in _selectedNotes) {
        try {
          await netRepo.deleteNotes(NotesModel(id: noteId));
        } catch (e) {
          debugPrint('Error deleting note $noteId: $e');
        }
      }

      // Refresh notes list
      _notesList.clear();
      await getNotes();

      exitSelectionMode();

      TLoaders.successSnackBar(
        context: context,
        title: "Success!",
        message: "Selected notes deleted successfully!",
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        context: context,
        title: "Failed!",
        message: e.toString(),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Color Methods
  void updateSelectedColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color hexToColor(String? hexColor) {
    if (hexColor == null) return const Color(0xFFE3F2FD);

    try {
      String colorString = hexColor.replaceAll('#', '');
      if (colorString.length == 6) {
        colorString = 'FF$colorString';
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return const Color(0xFFE3F2FD);
    }
  }

  // CRUD Methods
  Future<void> addNotes(BuildContext context) async {
    try {
      final netRepo = NetworkRepositories();
      final userId = await UserSessionManager.getUserId();

      final newNote = NotesModel(
        title: title.text.trim(),
        description: description.text.trim(),
        userId: userId,
        createAt: 0,
        color: _colorToHex(selectedColor),
      );

      await netRepo.addNotes(newNote);

      _notesList.clear();
      await getNotes();

      _clearForm();

      Navigator.pop(context);
      TLoaders.successSnackBar(
        context: context,
        title: "Success!",
        message: "Note added successfully!",
      );
    } catch (e) {
      Navigator.pop(context);
      TLoaders.errorSnackBar(
        context: context,
        title: "Failed!",
        message: e.toString(),
      );
    }
  }

  Future<void> getNotes() async {
    try {
      _setLoading(true);
      final userId = await UserSessionManager.getUserId();
      final netRepo = NetworkRepositories();

      final notes = await netRepo.getNotes(userId!);

      _notesList.clear();
      _notesList.addAll(notes);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      TLoaders.errorSnackBar(title: "Failed!", message: e.toString());
    }
  }

  Future<void> updateNote(BuildContext context, NotesModel existingNote) async {
    try {
      final netRepo = NetworkRepositories();

      final newTitle = title.text.trim();
      final newDescription = description.text.trim();
      final newColor = _colorToHex(selectedColor);

      final titleChanged = newTitle != (existingNote.title ?? '');
      final descriptionChanged =
          newDescription != (existingNote.description ?? '');
      final colorChanged =
          newColor !=
          (existingNote.color ?? _colorToHex(const Color(0xFFE3F2FD)));

      if (!titleChanged && !descriptionChanged && !colorChanged) {
        Navigator.pop(context);
        TLoaders.successSnackBar(
          context: context,
          title: "No Changes!",
          message: "No changes detected in the note.",
        );
        return;
      }

      final updatedNote = NotesModel(
        id: existingNote.id,
        title: titleChanged ? newTitle : existingNote.title,
        description: descriptionChanged
            ? newDescription
            : existingNote.description,
        userId: existingNote.userId,
        createAt: existingNote.createAt,
        color: colorChanged ? newColor : existingNote.color,
      );

      await netRepo.updateNotes(updatedNote);

      final index = _notesList.indexWhere((note) => note.id == existingNote.id);
      if (index != -1) {
        _notesList[index] = updatedNote;
        notifyListeners();
      }

      _clearForm();

      Navigator.pop(context);
      TLoaders.successSnackBar(
        context: context,
        title: "Success!",
        message: "Note updated successfully!",
      );
    } catch (e) {
      Navigator.pop(context);
      TLoaders.errorSnackBar(
        context: context,
        title: "Failed!",
        message: e.toString(),
      );
    }
  }

  Future<void> deleteNotes(NotesModel notes) async {
    try {
      _setLoading(true);
      final netRepo = NetworkRepositories();

      await netRepo.deleteNotes(notes);
      _notesList.clear();
      await getNotes();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      TLoaders.errorSnackBar(title: "Failed!", message: e.toString());
    }
  }

  // Helper Methods
  void _clearForm() {
    title.clear();
    description.clear();
    selectedColor = const Color(0xFFE3F2FD);
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    titleFocus.dispose();
    contentFocus.dispose();
    super.dispose();
  }
}
