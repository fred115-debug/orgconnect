import 'package:flutter/material.dart';
import 'package:my_app/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = SupabaseClientManager.client.auth.currentUser;
    if (user != null) {
      try {
        // Load user role
        final userData = await SupabaseClientManager.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        // Load profile if student
        Map<String, dynamic>? profile;
        if (userData['role'] == 'student') {
          profile = await SupabaseClientManager.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();
        }

        setState(() {
          _user = userData;
          _profile = profile;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load user data: $e')),
          );
        }
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await SupabaseClientManager.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = SupabaseClientManager.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.email ?? 'User'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_user != null) ...[
              Text('Role: ${_user!['role']}'),
              const SizedBox(height: 8),
              Text('Active: ${_user!['active'] ? 'Yes' : 'No'}'),
            ],
            if (_profile != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Profile Information:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Name: ${_profile!['name']}'),
              Text('Student ID: ${_profile!['student_id']}'),
              Text('Email: ${_profile!['email']}'),
              Text('Contact: ${_profile!['contact'] ?? 'Not provided'}'),
              Text('Facebook: ${_profile!['facebook'] ?? 'Not provided'}'),
              Text(
                  'Joined Organizations: ${_profile!['joined_org_ids']?.length ?? 0}'),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('View Full Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
