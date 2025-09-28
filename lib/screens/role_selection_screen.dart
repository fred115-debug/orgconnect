import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'Officer_Role/officer_authorization_screen.dart';
import 'Admin_Role/admin_authorization_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  static const Color mintBg = Color(0xFFEAF6F0);
  static const Color tealHeader = Color(0xFF79CFC4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mintBg,
      appBar: AppBar(
        backgroundColor: tealHeader,
        elevation: 0,
        title: const Text(
          'Select Role',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roleButton(context, 'Student', Icons.school_outlined,
                    UserRole.student),
                const SizedBox(height: 16),
                _roleButton(context, 'Organization Officer',
                    Icons.badge_outlined, UserRole.officer),
                const SizedBox(height: 16),
                _roleButton(context, 'Admin',
                    Icons.admin_panel_settings_outlined, UserRole.admin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(
      BuildContext context, String label, IconData icon, UserRole role) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          AppState.instance.setRole(role);

          // Route to appropriate screen based on role
          switch (role) {
            case UserRole.student:
              // Student goes to SignIn/SignUp flow first
              Navigator.pushReplacementNamed(context, '/signin');
              break;
            case UserRole.officer:
              // Officer needs to select organization and authenticate
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfficerAuthorizationScreen(),
                ),
              );
              break;
            case UserRole.admin:
              // Admin needs password authentication
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAuthorizationScreen(),
                ),
              );
              break;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: tealHeader,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
