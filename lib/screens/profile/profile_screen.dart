import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color mintBg = Color(0xFFEAF6F0);
  static const Color tealHeader = Color(0xFF79CFC4);

  // Controllers for form
  final TextEditingController studentIdCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController facebookCtrl = TextEditingController();

  Uint8List? _avatarBytes;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final student = AppState.instance.currentStudent;
    if (student != null) {
      studentIdCtrl.text = student.studentId;
      nameCtrl.text = student.name;
      emailCtrl.text = student.email;
      contactCtrl.text = student.contact;
      facebookCtrl.text = student.facebook;
    } else {
      _isEditing = true; // New applicant, show form
    }
  }

  @override
  void dispose() {
    studentIdCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    contactCtrl.dispose();
    facebookCtrl.dispose();
    super.dispose();
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

  void _saveProfile() {
    if (studentIdCtrl.text.trim().isEmpty ||
        nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        contactCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final profile = StudentProfile(
      id: AppState.instance.currentStudent?.id ??
          'student-${DateTime.now().millisecondsSinceEpoch}',
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      studentId: studentIdCtrl.text.trim(),
      contact: contactCtrl.text.trim(),
      facebook: facebookCtrl.text.trim(),
      avatarUrl: _avatarBytes != null
          ? 'data:image/png;base64,${_avatarBytes!.toString()}'
          : AppState.instance.currentStudent?.avatarUrl ?? '',
      joinedOrgIds: AppState.instance.currentStudent?.joinedOrgIds ?? [],
    );

    AppState.instance.setStudentProfile(profile);
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = AppState.instance.currentStudent;

    return Scaffold(
      backgroundColor: mintBg,
      appBar: AppBar(
        backgroundColor: tealHeader,
        elevation: 0,
        title: const Text(
          'Student Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: student != null
            ? [
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: _isEditing
                      ? _saveProfile
                      : () => setState(() => _isEditing = true),
                ),
              ]
            : null,
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
                      onTap: _isEditing ? _pickAvatar : null,
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
                              child: _avatarBytes != null
                                  ? Image.memory(
                                      _avatarBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : student?.avatarUrl.isNotEmpty == true
                                      ? Image.asset(
                                          student!.avatarUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: circleSize * 0.5,
                                          color: Colors.grey.shade500,
                                        ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF79CFC4),
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

                    // Form Fields
                    if (_isEditing) ...[
                      _buildTextField(
                          'Student ID', studentIdCtrl, 'e.g., 2023-01234'),
                      _buildTextField('Full Name', nameCtrl, 'First Last'),
                      _buildTextField('Email', emailCtrl, 'name@school.edu.ph',
                          TextInputType.emailAddress),
                      _buildTextField('Contact', contactCtrl,
                          '+63 912 345 6789', TextInputType.phone),
                      _buildTextField('Facebook', facebookCtrl,
                          'facebook.com/your.profile', TextInputType.url),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealHeader,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text('Save Profile'),
                      ),
                    ] else if (student != null) ...[
                      _buildProfileInfo('Student ID', student.studentId),
                      _buildProfileInfo('Full Name', student.name),
                      _buildProfileInfo('Email', student.email),
                      _buildProfileInfo('Contact', student.contact),
                      _buildProfileInfo('Facebook', student.facebook),
                      if (student.joinedOrgIds.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Joined Organizations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...student.joinedOrgIds.map((orgId) {
                          final org =
                              AppState.instance.organizations.firstWhere(
                            (o) => o.id == orgId,
                            orElse: () => Organization(
                                id: '',
                                name: 'Unknown',
                                logoAsset: '',
                                shortDesc: ''),
                          );
                          return Text(
                            org.name,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          );
                        }),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      [TextInputType? keyboardType]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF8FD4CC),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black87, fontSize: 13.5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
