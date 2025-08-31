import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_app/features/auth/controller/user/user_controller.dart';
import 'package:notes_app/features/models/notes_model.dart';
import 'package:notes_app/features/notes/controller/notes_controller.dart';
import 'package:notes_app/features/notes/view/create_notes.dart';
import 'package:notes_app/features/view/profile_screen.dart';
import 'package:notes_app/utils/images.dart';
import 'package:notes_app/utils/popus/animation_loader.dart';
import 'package:provider/provider.dart';

class NotesHomeScreen extends StatefulWidget {
  @override
  _NotesHomeScreenState createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _selectionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _selectionSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _selectionSlideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _selectionAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  void _initializeControllers() {
    final userController = Provider.of<UserController>(context, listen: false);
    userController.fetchUser();

    // Listen to selection mode changes
    Provider.of<NotesController>(
      context,
      listen: false,
    ).addListener(_onSelectionModeChanged);
  }

  void _onSelectionModeChanged() {
    final controller = Provider.of<NotesController>(context, listen: false);
    if (controller.isSelectionMode) {
      _selectionAnimationController.forward();
    } else {
      _selectionAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeader(), _buildNotesList()],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Consumer<NotesController>(
      builder: (context, controller, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24.0),
          child: controller.isSelectionMode
              ? _buildSelectionHeader(controller)
              : _buildNormalHeader(controller),
        );
      },
    );
  }

  Widget _buildNormalHeader(NotesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            _buildHeaderActions(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${controller.notesList.length} notes',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.search_rounded,
          onTap: () {
            // TODO: Implement search functionality
          },
        ),
        const SizedBox(width: 12),
        _buildHeaderButton(
          icon: Iconsax.user,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF718096), size: 20),
      ),
    );
  }

  Widget _buildSelectionHeader(NotesController controller) {
    return AnimatedBuilder(
      animation: _selectionSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _selectionSlideAnimation.value),
          child: Row(
            children: [
              _buildCloseSelectionButton(controller),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${controller.selectedCount} selected',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              _buildSelectAllButton(controller),
              const SizedBox(width: 12),
              _buildDeleteButton(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloseSelectionButton(NotesController controller) {
    return GestureDetector(
      onTap: controller.exitSelectionMode,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 20,
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }

  Widget _buildSelectAllButton(NotesController controller) {
    return GestureDetector(
      onTap: controller.isAllSelected
          ? controller.deselectAllNotes
          : controller.selectAllNotes,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          controller.isAllSelected ? 'Deselect All' : 'Select All',
          style: const TextStyle(
            color: Color(0xFF667EEA),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(NotesController controller) {
    final hasSelection = controller.selectedCount > 0;

    return GestureDetector(
      onTap: hasSelection
          ? () => controller.deleteSelectedNotes(context)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasSelection
              ? const Color(0xFFE53E3E)
              : const Color(0xFFA0AEC0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasSelection
              ? [
                  BoxShadow(
                    color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildNotesList() {
    return Expanded(
      child: Consumer<NotesController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.notesList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return controller.notesList.isEmpty
              ? _buildEmptyState()
              : _buildNotesGrid(controller);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TAnimationLoaderWidget(
              text: "Whoops! No Notes Yet...",
              animation: TImages.pencilAnimations,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create your first note',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid(NotesController controller) {
    // Make a copy so we don’t mutate the original list
    final sortedNotes = List.from(controller.notesList)
      ..sort(
        (a, b) => DateTime.fromMillisecondsSinceEpoch(
          b.createAt.toInt(),
        ).compareTo(DateTime.fromMillisecondsSinceEpoch(a.createAt.toInt())),
      );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return _buildNoteCard(controller, note, index);
      },
    );
  }

  Widget _buildNoteCard(
    NotesController controller,
    NotesModel note,
    int index,
  ) {
    final isSelected = controller.isNoteSelected(note.id ?? '');

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _handleNoteTap(controller, note),
        onLongPress: () => _handleNoteLongPress(controller, note),
        child: _buildNoteCardContent(controller, note, isSelected),
      ),
    );
  }

  void _handleNoteTap(NotesController controller, NotesModel note) {
    if (controller.isSelectionMode) {
      controller.toggleNoteSelection(note.id ?? '');
    } else {
      _navigateToEditNote(note);
    }
  }

  void _handleNoteLongPress(NotesController controller, NotesModel note) {
    if (!controller.isSelectionMode && note.id != null && note.id!.isNotEmpty) {
      controller.enterSelectionMode(note.id!);
    }
  }

  Widget _buildNoteCardContent(
    NotesController controller,
    NotesModel note,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF667EEA)
              : controller.hexToColor(note.color),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF667EEA).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 20 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNoteCardHeader(controller, note, isSelected),
          const SizedBox(height: 12),
          _buildNoteContent(note),
          const SizedBox(height: 16),
          _buildNoteDate(controller, note),
        ],
      ),
    );
  }

  Widget _buildNoteCardHeader(
    NotesController controller,
    NotesModel note,
    bool isSelected,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            note.title ?? 'Untitled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF667EEA)
                  : const Color(0xFF2D3748),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            if (controller.isSelectionMode) _buildSelectionCheckbox(isSelected),
            _buildNoteColorIndicator(controller, note),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionCheckbox(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF667EEA) : const Color(0xFFA0AEC0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    );
  }

  Widget _buildNoteColorIndicator(NotesController controller, NotesModel note) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: controller.hexToColor(note.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.note_outlined,
        size: 16,
        color: Color(0xFF4A5568),
      ),
    );
  }

  Widget _buildNoteContent(NotesModel note) {
    return Text(
      note.description ?? 'No content',
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF718096),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNoteDate(NotesController controller, NotesModel note) {
    // You can use note.createAt here if available, for now using placeholder
    return Text(
      controller.formatDate(
        DateTime.fromMillisecondsSinceEpoch(note.createAt!),
      ),
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFFA0AEC0),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return Consumer<NotesController>(
      builder: (context, controller, child) {
        if (controller.isSelectionMode) {
          return const SizedBox.shrink(); // instead of null
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFF3E0),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _navigateToCreateNote,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_rounded, size: 28, color: Colors.black),
          ),
        );
      },
    );
  }

  void _navigateToCreateNote() async {
    await Navigator.push(
      context,
      _createSlidePageRoute(const CreateNoteScreen()),
    );
  }

  void _navigateToEditNote(NotesModel note) async {
    await Navigator.push(
      context,
      _createSlidePageRoute(CreateNoteScreen(note: note, isEditing: true)),
    );
  }

  PageRouteBuilder _createSlidePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
