import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  final List<String> houses = const [
    'Phoenix',
    'Titan',
    'Falcon',
    'Dragon',
  ];

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final schoolId = schoolIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (isCreatingAccount) {
      if (name.isEmpty || schoolId.isEmpty) {
        _showMessage('Please enter your name and school ID.');
        return;
      }
    }

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
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
          final profileRef =
              _firestore.collection('users').doc(user.uid);

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
          message = 'No account was found for this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'weak-password':
          message = 'Choose a stronger password.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
      }

      if (mounted) _showMessage(message);
    } on FirebaseException catch (e) {
      if (mounted) {
        _showMessage(
          e.message ?? 'Could not save your FitQuest profile.',
        );
      }
    } catch (e) {
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
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF151B3D),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCreatingAccount
                    ? 'Create your account 🚀'
                    : 'Welcome back! 👋',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF151B3D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isCreatingAccount
                    ? 'Set up your FitQuest student profile.'
                    : 'Sign in to your FitQuest account.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 35),

              if (isCreatingAccount) ...[
                const Text(
                  'NAME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xFF555A72),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SCHOOL ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xFF555A72),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: schoolIdController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. STU1001',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'HOUSE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xFF555A72),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedHouse,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.shield_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: houses
                      .map(
                        (house) => DropdownMenuItem<String>(
                          value: house,
                          child: Text(house),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => selectedHouse = value);
                          }
                        },
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'EMAIL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Color(0xFF555A72),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'student@school.edu',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PASSWORD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Color(0xFF555A72),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF302B63),
                    foregroundColor: Colors.white,
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
                      : Text(
                          isCreatingAccount
                              ? 'CREATE FITQUEST ACCOUNT'
                              : 'LOGIN TO FITQUEST',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            isCreatingAccount = !isCreatingAccount;
                          });
                        },
                  child: Text(
                    isCreatingAccount
                        ? 'Already have an account? Log in'
                        : 'New to FitQuest? Create an account',
                    style: const TextStyle(
                      color: Color(0xFF302B63),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF302B63),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your FitQuest account belongs to your school community.',
                        style: TextStyle(
                          color: Color(0xFF302B63),
                          fontSize: 13,
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
}
