import 'package:flutter/material.dart';
import 'package:my_app/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;

  final darkGreen = const Color(0xFF79CFC4);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await SupabaseClientManager.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Check if profile exists
        try {
          await SupabaseClientManager.client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();
          // Profile exists, go to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (e) {
          // No profile, go to profile creation
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        }
      }
    } on AuthException catch (e) {
      String message = 'Sign in failed';
      if (e.message.contains('Invalid login credentials')) {
        message = 'Invalid email or password. Please check your credentials.';
      } else {
        message = e.message;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      // Validate inputs
      if (_nameController.text.trim().isEmpty ||
          _studentIdController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.length < 6) {
        throw Exception(
            'Please fill all fields and use a password with at least 6 characters.');
      }

      final response = await SupabaseClientManager.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Create user entry first
        await SupabaseClientManager.client.from('users').insert({
          'id': response.user!.id,
          'role': 'student',
        });

        // Create profile
        await SupabaseClientManager.client.from('profiles').insert({
          'id': response.user!.id,
          'name': _nameController.text.trim(),
          'student_id': _studentIdController.text.trim(),
          'email': _emailController.text.trim(),
          'joined_org_ids': [],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Sign up successful! Please check your email to verify your account before logging in.')),
          );
          // Clear form and switch to sign in
          _nameController.clear();
          _studentIdController.clear();
          _emailController.clear();
          _passwordController.clear();
          setState(() => _isSignUp = false);
        }
      }
    } on AuthException catch (e) {
      String message = 'Sign up failed';
      if (e.message.contains('duplicate key')) {
        message = 'An account with this email already exists.';
      } else if (e.message.contains('Password should be at least')) {
        message = 'Password must be at least 6 characters.';
      } else {
        message = e.message;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  child: const Center(
                    child:
                        Icon(Icons.school, size: 60, color: Color(0xFF79CFC4)),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isSignUp) ...[
                  _buildTextField(
                      'Full Name', _nameController, 'Enter your full name'),
                  const SizedBox(height: 16),
                  _buildTextField('Student ID', _studentIdController,
                      'Enter your student ID'),
                  const SizedBox(height: 16),
                ],
                _buildTextField('Email', _emailController, 'Enter your email'),
                const SizedBox(height: 16),
                _buildTextField(
                    'Password', _passwordController, 'Enter your password',
                    obscureText: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : (_isSignUp ? _signUp : _signIn),
                    style: ElevatedButton.styleFrom(
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
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Don\'t have an account? Sign Up',
                    style: TextStyle(color: darkGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Color(0xFF79CFC4), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
