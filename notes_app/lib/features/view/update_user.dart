import 'package:flutter/material.dart';
import 'package:notes_app/features/auth/controller/user/user_controller.dart';
import 'package:notes_app/features/models/user_model.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String getAvatar(String name) {
    List<String> parts = name.trim().split(" ");
    String first = parts.isNotEmpty ? parts.first[0] : "";
    String last = parts.length > 1 ? parts.last[0] : "";
    return (first + last).toUpperCase();
  }

  @override
  void initState() {
    super.initState();

    // Initialize email controller with current data
    _emailController.text = widget.user.email!;

    // Initialize user controller with current data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userController = Provider.of<UserController>(
        context,
        listen: false,
      );
      userController.initializeProfile(widget.user);
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _showDiscardDialog(UserController userController) {
    if (!userController.hasProfileChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Discard Changes?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Stay',
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
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Discard',
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        return WillPopScope(
          onWillPop: () async {
            _showDiscardDialog(userController);
            return false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showDiscardDialog(userController),
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
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Edit Profile',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 44),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Form(
                                  key: userController.updateNamekey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile Avatar Section
                                      Center(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF667EEA),
                                                    Color(0xFF764BA2),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF667EEA,
                                                    ).withOpacity(0.3),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  getAvatar(
                                                    userController
                                                            .name
                                                            .text
                                                            .isNotEmpty
                                                        ? userController
                                                              .name
                                                              .text
                                                        : widget.user.username!,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Update Profile Information',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF718096),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 48),

                                      // Form Fields
                                      _buildInputField(
                                        controller: userController.name,
                                        focusNode: userController.nameFocus,
                                        label: 'Full Name',
                                        hintText: 'Enter your full name',
                                        icon: Icons.person_outline_rounded,
                                        onSubmitted: (_) =>
                                            _emailFocus.requestFocus(),
                                        validator: userController.validateName,
                                        onChanged: (_) =>
                                            userController.checkForChanges(),
                                      ),

                                      const SizedBox(height: 24),

                                      _buildInputField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        label: 'Email Address',
                                        hintText: 'Enter your email',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onSubmitted: (_) {
                                          if (userController
                                                  .hasProfileChanges &&
                                              !userController.isLoading) {
                                            userController.updateProfile(
                                              context,
                                              _emailController.text,
                                            );
                                          }
                                        },
                                        validator: userController.validateEmail,
                                        onChanged: (_) =>
                                            userController.checkForChanges(),
                                        isReadOnly:
                                            true, // Email is typically read-only in profile updates
                                      ),

                                      const Spacer(),

                                      // Update Button
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: GestureDetector(
                                          onTap:
                                              userController.isLoading ||
                                                  !userController
                                                      .hasProfileChanges
                                              ? null
                                              : () => userController
                                                    .updateProfile(
                                                      context,
                                                      _emailController.text,
                                                    ),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient:
                                                  userController
                                                          .hasProfileChanges &&
                                                      !userController.isLoading
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color(0xFF667EEA),
                                                        Color(0xFF764BA2),
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        Color(0xFFA0AEC0),
                                                        Color(0xFFA0AEC0),
                                                      ],
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow:
                                                  userController
                                                          .hasProfileChanges &&
                                                      !userController.isLoading
                                                  ? [
                                                      BoxShadow(
                                                        color: const Color(
                                                          0xFF667EEA,
                                                        ).withOpacity(0.3),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          6,
                                                        ),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: userController.isLoading
                                                ? const Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    userController
                                                            .hasProfileChanges
                                                        ? 'Update Profile'
                                                        : 'No Changes',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onSubmitted,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly ? const Color(0xFFF7FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focusNode.hasFocus
                  ? const Color(0xFF667EEA)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            onChanged: onChanged,
            readOnly: isReadOnly,
            style: TextStyle(
              fontSize: 16,
              color: isReadOnly
                  ? const Color(0xFF718096)
                  : const Color(0xFF2D3748),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
              prefixIcon: Icon(icon, color: const Color(0xFF718096), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
