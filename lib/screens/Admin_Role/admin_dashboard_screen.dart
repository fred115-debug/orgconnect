import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import 'admin_manage_accounts.dart';
import 'admin_reports.dart';
import 'admin_manage_organization.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

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
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Change Role',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              AppState.instance.setRole(null);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tile(
                  context,
                  'Manage Accounts',
                  Icons.manage_accounts_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAccountsScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _tile(
                  context,
                  'Manage Organizations',
                  Icons.apartment_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminOrganizationsScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _tile(
                  context,
                  'Reports',
                  Icons.insights_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: tealHeader,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
      ),
    );
  }
}
