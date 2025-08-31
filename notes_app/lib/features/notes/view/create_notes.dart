import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:notes_app/features/notes/controller/notes_controller.dart';
import 'package:notes_app/features/notes/widgets/color_picker.dart';
import 'package:notes_app/features/models/notes_model.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CreateNoteScreen extends StatefulWidget {
  final NotesModel? note; // Optional note for editing
  final bool isEditing; // Flag to determine if we're editing

  const CreateNoteScreen({Key? key, this.note, this.isEditing = false})
    : super(key: key);

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Speech to text variables
  late stt.SpeechToText speech;
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<NotesController>(context, listen: false);

    // Initialize speech
    speech = stt.SpeechToText();

    // If editing, populate the fields with existing note data
    if (widget.isEditing && widget.note != null) {
      controller.title.text = widget.note!.title ?? '';
      controller.description.text = widget.note!.description ?? '';
      controller.selectedColor = controller.hexToColor(widget.note!.color);
    } else {
      // Clear fields for new note
      controller.title.clear();
      controller.description.clear();
      controller.selectedColor = const Color(0xFFE3F2FD);
    }

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );
    _slideController.forward();

    // Auto-focus title field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.titleFocus.requestFocus();
    });
    _checkSpeechAvailability();

    // Initialize speech recognition
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await speech.initialize(
        onStatus: (val) {
          setState(() {
            _isListening = val == 'listening';
            if (val == 'done' || val == 'notListening') {
              _isListening = false;
              // Show keyboard again when speech stops
              _showKeyboard();
            }
          });
          debugPrint('Speech status: $val');
        },
        onError: (val) {
          setState(() {
            _isListening = false;
          });
          // Show keyboard again on error
          _showKeyboard();
          debugPrint('Speech recognition error: $val');

          // Show user-friendly error message
          if (val.errorMsg == 'error_network') {
            _showErrorDialog(
              'Network Error',
              'Please check your internet connection and try again.',
            );
          } else if (val.errorMsg == 'error_no_match') {
            _showErrorDialog(
              'No Speech Detected',
              'Please speak clearly and try again.',
            );
          } else {
            _showErrorDialog(
              'Speech Recognition Error',
              'Something went wrong. Please try again.',
            );
          }
        },
        debugLogging: true, // Enable debug logging
      );

      if (!_speechEnabled) {
        debugPrint('Speech recognition not available');
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _speechEnabled = false;
    }

    setState(() {});
  }

  // Method to hide keyboard
  void _hideKeyboard() {
    final controller = Provider.of<NotesController>(context, listen: false);
    controller.titleFocus.unfocus();
    controller.contentFocus.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // Method to show keyboard
  void _showKeyboard() {
    final controller = Provider.of<NotesController>(context, listen: false);
    // Wait a bit before refocusing to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        controller.contentFocus.requestFocus();
      }
    });
  }

  void _startListening() async {
    final controller = Provider.of<NotesController>(context, listen: false);

    if (!_isListening && _speechEnabled) {
      try {
        // Hide keyboard when starting speech recognition
        _hideKeyboard();

        // Check if speech recognition is available
        bool available = await speech.initialize();
        if (!available) {
          _showErrorDialog(
            'Speech Not Available',
            'Speech recognition is not available on this device.',
          );
          _showKeyboard(); // Show keyboard back if speech is not available
          return;
        }

        await speech.listen(
          onResult: (val) {
            setState(() {
              String currentText = controller.description.text;
              String newText = val.recognizedWords;

              if (currentText.isEmpty) {
                controller.description.text = newText;
              } else {
                controller.description.text = '$currentText $newText';
              }

              debugPrint("Speech text: ${controller.description.text}");

              controller.description.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.description.text.length),
              );
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          onSoundLevelChange: (level) {
            // Optional: You can use this to show sound level
          },
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
          localeId: 'en_US', // Specify locale
        );
      } catch (e) {
        debugPrint('Error starting speech recognition: $e');
        setState(() {
          _isListening = false;
        });
        _showKeyboard(); // Show keyboard back on error
        _showErrorDialog('Speech Error', 'Failed to start speech recognition.');
      }
    } else {
      await speech.stop();
      setState(() {
        _isListening = false;
      });
      _showKeyboard(); // Show keyboard when manually stopping speech
    }
  }

  void _showErrorDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _checkSpeechAvailability() async {
    bool available = await speech.initialize();
    List<stt.LocaleName> locales = await speech.locales();

    debugPrint('Speech available: $available');
    debugPrint(
      'Available locales: ${locales.map((l) => l.localeId).join(', ')}',
    );

    if (!available) {
      _showErrorDialog(
        'Speech Recognition',
        'Speech recognition is not available on this device or requires Google services.',
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesController>(
      builder: (context, controller, child) {
        return Scaffold(
          // Add this to prevent keyboard from pushing content up when speech is active
          resizeToAvoidBottomInset: !_isListening,
          body: SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                        ),
                        Text(
                          widget.isEditing ? 'Edit Note' : 'New Note',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.isEditing
                              ? controller.updateNote(context, widget.note!)
                              : controller.addNotes(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF667EEA,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.isEditing ? 'Update' : 'Save',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Color Picker
                  ColorPickerWidget(
                    selectedColor: controller.selectedColor,
                    colors: controller.noteColors,
                    onColorSelected: (color) =>
                        controller.updateSelectedColor(color),
                  ),

                  const SizedBox(height: 24),

                  // Note Input
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: controller.selectedColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: controller.title,
                            focusNode: controller.titleFocus,
                            // Disable the text field when listening to speech
                            enabled: !_isListening,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Note title...',
                              hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              controller.contentFocus.requestFocus();
                            },
                            // Hide keyboard when tapping if speech is listening
                            onTap: _isListening ? _hideKeyboard : null,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TextField(
                              controller: controller.description,
                              focusNode: controller.contentFocus,
                              maxLines: null,
                              // Keep the description field enabled but manage keyboard separately
                              readOnly: _isListening,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4A5568),
                                height: 1.6,
                              ),
                              decoration: InputDecoration(
                                hintText: _isListening
                                    ? 'Listening... Speak now!'
                                    : 'Start writing your note...',
                                hintStyle: TextStyle(
                                  color: _isListening
                                      ? controller.selectedColor
                                      : const Color(0xFFA0AEC0),
                                  fontWeight: _isListening
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                border: InputBorder.none,
                              ),
                              // Hide keyboard when tapping if speech is listening
                              onTap: _isListening ? _hideKeyboard : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Show voice button only when creating new note
          floatingActionButton: !widget.isEditing && _speechEnabled
              ? AvatarGlow(
                  animate: _isListening,
                  glowColor: Colors.black.withValues(alpha: 0.5),
                  duration: const Duration(milliseconds: 2000),
                  glowRadiusFactor: 0.7,
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed: _startListening,
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
