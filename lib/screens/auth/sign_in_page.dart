import 'package:flutter/material.dart';
import '../../core/app_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFormValid = false;

  final darkGreen = const Color(0xFF79CFC4);

  @override
  void initState() {
    super.initState();
    _studentIdController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _studentIdController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _studentIdController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFB2DFDB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/orgconnectLogo.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 32),
                TextField(
                  controller: _studentIdController,
                  decoration: buildInputDecoration('Student ID'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: buildInputDecoration('Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: darkGreen, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isFormValid
                            ? () {
                                // Validate that no empty data is stored
                                if (_studentIdController.text.trim().isEmpty ||
                                    _passwordController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please fill in all fields'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                // Create basic profile from sign in data
                                final profile = StudentProfile(
                                  id: 'student-${DateTime.now().millisecondsSinceEpoch}',
                                  name: _studentIdController.text
                                      .trim(), // Use studentId as name for now
                                  email: '',
                                  studentId: _studentIdController.text.trim(),
                                  contact: '',
                                  facebook: '',
                                  avatarUrl: '',
                                  joinedOrgIds: [],
                                );
                                AppState.instance.setStudentProfile(profile);
                                // Navigate to home if validation passes
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFormValid ? darkGreen : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/signup'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: darkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: BorderSide(color: darkGreen.withOpacity(0.4)),
                        ),
                        child: const Text('Sign up'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 140),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            // Validate
                            if (_studentIdController.text.trim().isEmpty ||
                                _passwordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            // Create basic profile for sign in
                            final profile = StudentProfile(
                              id: 'student-${DateTime.now().millisecondsSinceEpoch}',
                              name: _studentIdController.text.trim(),
                              email: '',
                              studentId: _studentIdController.text.trim(),
                              contact: '',
                              facebook: '',
                              avatarUrl: '',
                              joinedOrgIds: [],
                            );
                            AppState.instance.setStudentProfile(profile);
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        : null,
                    style: _isFormValid
                        ? buildMainButtonStyle()
                        : buildMainButtonStyle().copyWith(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.grey),
                          ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: darkGreen, width: 1.5),
      ),
    );
  }

  ButtonStyle buildMainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: darkGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      elevation: 3,
    );
  }
}
