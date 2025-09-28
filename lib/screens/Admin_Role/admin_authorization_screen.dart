import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class AdminAuthorizationScreen extends StatefulWidget {
  const AdminAuthorizationScreen({Key? key}) : super(key: key);

  @override
  State<AdminAuthorizationScreen> createState() => _AdminAuthorizationScreenState();
}

class _AdminAuthorizationScreenState extends State<AdminAuthorizationScreen> {
  static const Color mintBg = Color(0xFFEAF6F0);
  static const Color tealHeader = Color(0xFF79CFC4);

  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mintBg,
      appBar: AppBar(
        backgroundColor: tealHeader,
        elevation: 0,
        title: const Text(
          'Admin Authorization',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 80,
                  color: tealHeader,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter Admin Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Password: 0000',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Admin Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealHeader,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isAuthenticating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ACCESS ADMIN DASHBOARD',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (_passwordController.text == '0000') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboard(),
          ),
        );
      }
    } else {
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Invalid password. Please try again.';
        _passwordController.clear();
      });
    }
  }
}
