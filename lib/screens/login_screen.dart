import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_typography.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isCreatingAccount = false;
  bool isLoading = false;

  String selectedHouse = 'Phoenix';

  final List<Map<String, dynamic>> houses = const [
    {
      'name': 'Phoenix',
      'emoji': '🦁',
      'color': Color(0xFFFF7545),
      'desc': 'Courage & Power',
    },
    {
      'name': 'Titan',
      'emoji': '🛡️',
      'color': Color(0xFF3B82F6),
      'desc': 'Strength & Grit',
    },
    {
      'name': 'Falcon',
      'emoji': '🦅',
      'color': Color(0xFF10B981),
      'desc': 'Speed & Focus',
    },
    {
      'name': 'Dragon',
      'emoji': '🐉',
      'color': Color(0xFF8B5CF6),
      'desc': 'Wisdom & Flame',
    },
  ];

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final schoolId = schoolIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (isCreatingAccount) {
      if (name.isEmpty) {
        _showMessage('Please enter your full student name.');
        return;
      }
      if (schoolId.isEmpty) {
        _showMessage('Please enter your School Student ID.');
        return;
      }
    }

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential credential;

      if (isCreatingAccount) {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user == null) {
          throw Exception('Account was created but no user was returned.');
        }

        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'schoolId': schoolId,
          'house': selectedHouse,
          'email': email,
          'xp': 0,
          'streak': 0,
          'completedQuests': 0,
          'badges': <String>[],
          'stickers': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user != null) {
          final profileRef = _firestore.collection('users').doc(user.uid);
          final profile = await profileRef.get();

          if (!profile.exists) {
            await profileRef.set({
              'name': '',
              'schoolId': '',
              'house': selectedHouse,
              'email': email,
              'xp': 0,
              'streak': 0,
              'completedQuests': 0,
              'badges': <String>[],
              'stickers': <String>[],
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentHomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed.';

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please wait a moment.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
      }

      if (mounted) _showMessage(message);
    } on FirebaseException catch (e) {
      if (mounted) {
        _showMessage(e.message ?? 'Could not save your FitQuest profile.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: FqColors.ink,
        ),
      );
  }

  void _quickFillDemo() {
    setState(() {
      emailController.text = 'student@school.edu';
      passwordController.text = 'password123';
      if (isCreatingAccount) {
        nameController.text = 'Alex Morgan';
        schoolIdController.text = 'STU-2048';
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    schoolIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FqColors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BRAND HEADER
              _buildBrandHeader(),
              const SizedBox(height: 22),

              // 2. SEGMENTED SWITCHER (Sign In vs Create Account)
              _buildAuthSwitcher(),
              const SizedBox(height: 20),

              // 3. MAIN FORM CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE7E8EE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Form Title
                    Text(
                      isCreatingAccount
                          ? 'Create Student Account'
                          : 'Sign In to Your Account',
                      style: const TextStyle(
                        color: FqColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCreatingAccount
                          ? 'Join your school house and track daily fitness quests'
                          : 'Access your student dashboard, streaks, and clan rank',
                      style: const TextStyle(
                        color: Color(0xFF747887),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Registration Extra Fields (Name, School ID, House)
                    if (isCreatingAccount) ...[
                      _buildTextField(
                        controller: nameController,
                        label: 'FULL NAME',
                        hintText: 'e.g. Alex Morgan',
                        icon: Icons.person_outline_rounded,
                        capitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: schoolIdController,
                        label: 'SCHOOL STUDENT ID',
                        hintText: 'e.g. STU-2048',
                        icon: Icons.badge_outlined,
                        capitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      _buildHouseSelector(),
                      const SizedBox(height: 16),
                    ],

                    // Common Fields (Email, Password)
                    _buildTextField(
                      controller: emailController,
                      label: 'STUDENT EMAIL',
                      hintText: 'student@school.edu',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),

                    // Submit Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FqColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isCreatingAccount
                                        ? 'CREATE FITQUEST ACCOUNT'
                                        : 'SIGN IN TO FITQUEST',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. DEMO AUTO-FILL HELPER
              Center(
                child: TextButton.icon(
                  onPressed: _quickFillDemo,
                  icon: const Icon(
                    Icons.auto_fix_high_rounded,
                    size: 16,
                    color: FqColors.primaryMid,
                  ),
                  label: const Text(
                    'Auto-fill Demo Credentials',
                    style: TextStyle(
                      color: FqColors.primaryMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 5. SECURITY & SCHOOL TRUST BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7E8EE)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: FqColors.success,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Secure school authenticated portal. Fitness data is protected under student privacy guidelines.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BRAND HEADER
  // ---------------------------------------------------------------------------

  Widget _buildBrandHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF302B63), Color(0xFF51489A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF302B63).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: FqColors.accent.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FITQUEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Level Up Your Campus Fitness',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUTH SWITCHER (Sign In vs Create Account)
  // ---------------------------------------------------------------------------

  Widget _buildAuthSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _switcherButton(
              title: 'Sign In',
              icon: Icons.login_rounded,
              isSelected: !isCreatingAccount,
              onTap: () {
                if (isCreatingAccount) {
                  setState(() => isCreatingAccount = false);
                }
              },
            ),
          ),
          Expanded(
            child: _switcherButton(
              title: 'Create Account',
              icon: Icons.person_add_rounded,
              isSelected: isCreatingAccount,
              onTap: () {
                if (!isCreatingAccount) {
                  setState(() => isCreatingAccount = true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _switcherButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? FqColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: FqColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF747887),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF555A72),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HOUSE SELECTOR (Registration)
  // ---------------------------------------------------------------------------

  Widget _buildHouseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SCHOOL HOUSE',
          style: FqTypography.sectionLabel(color: FqColors.muted),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: houses.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            final h = houses[index];
            final name = h['name'] as String;
            final emoji = h['emoji'] as String;
            final color = h['color'] as Color;
            final isSelected = selectedHouse == name;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => selectedHouse = name),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.12) : FqColors.scaffold,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE7E8EE),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: isSelected ? color : FqColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              h['desc'] as String,
                              style: const TextStyle(
                                color: Color(0xFF747887),
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: color, size: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // INPUT FIELD HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FqTypography.sectionLabel(color: FqColors.muted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          style: const TextStyle(
            color: FqColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
            filled: true,
            fillColor: FqColors.scaffold,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: FqColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD',
          style: FqTypography.sectionLabel(color: FqColors.muted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: const TextStyle(
            color: FqColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Enter at least 6 characters',
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF64748B),
              size: 18,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => obscurePassword = !obscurePassword),
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF64748B),
                size: 18,
              ),
            ),
            filled: true,
            fillColor: FqColors.scaffold,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: FqColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
