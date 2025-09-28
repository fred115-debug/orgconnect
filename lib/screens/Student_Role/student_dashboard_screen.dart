import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_dashboard_events.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  static const Color mintBg = Color(0xFFEAF6F0);
  static const Color tealHeader = Color(0xFF79CFC4);

  // Controllers for form
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController studentIdCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController facebookCtrl = TextEditingController();

  Uint8List? _avatarBytes;
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    studentIdCtrl.dispose();
    emailCtrl.dispose();
    contactCtrl.dispose();
    facebookCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = SupabaseClientManager.client.auth.currentUser;
    if (user != null) {
      try {
        final profile = await SupabaseClientManager.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        setState(() {
          _profile = profile;
          _populateControllers();
          _isLoading = false;
        });
      } catch (e) {
        // No profile exists, show form for creation
        setState(() {
          _isEditing = true;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _populateControllers() {
    if (_profile != null) {
      studentIdCtrl.text = _profile!['student_id'] ?? '';
      nameCtrl.text = _profile!['name'] ?? '';
      emailCtrl.text = _profile!['email'] ?? '';
      contactCtrl.text = _profile!['contact'] ?? '';
      facebookCtrl.text = _profile!['facebook'] ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'heic', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _avatarBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (studentIdCtrl.text.trim().isEmpty ||
        nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    final user = SupabaseClientManager.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final profileData = {
        'id': user.id,
        'name': nameCtrl.text.trim(),
        'student_id': studentIdCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'contact': contactCtrl.text.trim(),
        'facebook': facebookCtrl.text.trim(),
        'avatar_url': _avatarBytes != null
            ? 'data:image/png;base64,${base64Encode(_avatarBytes!)}'
            : _profile?['avatar_url'],
        'joined_org_ids': _profile?['joined_org_ids'] ?? [],
      };

      if (_profile == null) {
        // Insert new profile
        await SupabaseClientManager.client.from('profiles').insert(profileData);
      } else {
        // Update existing profile
        await SupabaseClientManager.client
            .from('profiles')
            .update(profileData)
            .eq('id', user.id);
      }

      await _loadProfile(); // Reload
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mintBg,
      appBar: AppBar(
        backgroundColor: tealHeader,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing
                ? _saveProfile
                : () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double circleSize =
              (constraints.maxWidth * 0.40).clamp(120.0, 180.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: const Color(0xFF1B5E20), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _avatarBytes == null
                                  ? Icon(
                                      Icons.person,
                                      size: circleSize * 0.5,
                                      color: Colors.grey.shade500,
                                    )
                                  : Image.memory(
                                      _avatarBytes!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: tealHeader,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile Section
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_isEditing) ...[
                      _buildTextField(
                          'Full Name', nameCtrl, 'Enter your full name'),
                      const SizedBox(height: 12),
                      _buildTextField(
                          'Student ID', studentIdCtrl, 'Enter your student ID'),
                      const SizedBox(height: 12),
                      _buildTextField('Email', emailCtrl, 'Enter your email'),
                      const SizedBox(height: 12),
                      _buildTextField(
                          'Contact', contactCtrl, 'Enter your contact number'),
                      const SizedBox(height: 12),
                      _buildTextField('Facebook', facebookCtrl,
                          'facebook.com/your.profile'),
                      const SizedBox(height: 24),
                    ] else if (_profile != null) ...[
                      _buildProfileInfo('Full Name', _profile!['name']),
                      _buildProfileInfo('Student ID', _profile!['student_id']),
                      _buildProfileInfo('Email', _profile!['email']),
                      _buildProfileInfo(
                          'Contact', _profile!['contact'] ?? 'Not provided'),
                      _buildProfileInfo(
                          'Facebook', _profile!['facebook'] ?? 'Not provided'),
                      const SizedBox(height: 24),
                    ],

                    // Buttons
                    _actionButton(
                      context: context,
                      label: 'Profile',
                      icon: Icons.groups_outlined,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),

                    const SizedBox(height: 12),

                    _actionButton(
                      context: context,
                      label: 'Organizations',
                      icon: Icons.groups_outlined,
                      onTap: () => Navigator.pushNamed(context, '/orglist'),
                    ),

                    const SizedBox(height: 12),
                    _actionButton(
                      context: context,
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StudentDashboard()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: tealHeader,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
