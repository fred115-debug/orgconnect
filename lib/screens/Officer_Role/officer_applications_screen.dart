import 'package:flutter/material.dart';
import '../../core/app_state.dart';

class OfficerApplicationsScreen extends StatelessWidget {
  const OfficerApplicationsScreen({Key? key}) : super(key: key);

  static const Color mintBg = Color(0xFFEAF6F0);
  static const Color tealHeader = Color(0xFF79CFC4);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    final verticalSpacing = screenWidth * 0.03; // 3% for smaller spacing on mobile

    return Scaffold(
      backgroundColor: mintBg,
      appBar: AppBar(
        backgroundColor: tealHeader,
        elevation: 0,
        title: Text(
          'Applications',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            fontSize: screenWidth < 600 ? 18 : 20, // Responsive title size
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) {
          final currentOrgId = AppState.instance.currentOfficerOrgId;
          if (currentOrgId == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Text(
                  'No organization selected.',
                  style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final apps = AppState.instance.applications
              .where((a) => a.orgId == currentOrgId)
              .toList();

          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Text(
                  'No applications yet.',
                  style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing),
            itemBuilder: (context, index) {
              final a = apps[index];
              return Container(
                margin: EdgeInsets.only(bottom: verticalSpacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: screenWidth < 600 ? 8 : 12,
                  ),
                  dense: screenWidth < 600, // Compact on mobile
                  leading: CircleAvatar(
                    radius: screenWidth < 600 ? 20 : 25, // Smaller avatar on mobile
                    backgroundColor: tealHeader,
                    child: Text(
                      a.name.isNotEmpty ? a.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 600 ? 14 : 16,
                      ),
                    ),
                  ),
                  title: Text(
                    '${a.name} • ${a.orgName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth < 600 ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenWidth < 600 ? 2 : 4),
                      Text(
                        'Student ID: ${a.studentId}',
                        style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth < 600 ? 1 : 2),
                      Text(
                        'Contact: ${a.contact} • ${a.email}',
                        style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth < 600 ? 1 : 2),
                      Text(
                        'Reason: ${a.reason.isEmpty ? '—' : a.reason}',
                        style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
                        maxLines: screenWidth < 600 ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth < 600 ? 4 : 6),
                      Row(
                        children: [
                          _statusChip(a.status),
                          SizedBox(width: screenWidth < 600 ? 4 : 8),
                          Flexible(
                            child: Text(
                              'Created: ${a.createdAt.toLocal().toString().substring(0, 16)}',
                              style: TextStyle(
                                fontSize: screenWidth < 600 ? 10 : 12,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: _actions(context, a),
                ),
              );
            },
            separatorBuilder: (_, __) => SizedBox(height: screenWidth < 600 ? 6 : 10),
            itemCount: apps.length,
          );
        },
      ),
    );
  }

  Widget _actions(BuildContext context, Application a) {
    final isPending = a.status == ApplicationStatus.pending;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View Details',
          onPressed: () {
            _showApplicationDetails(context, a);
          },
          icon: const Icon(Icons.visibility, color: Colors.blue),
        ),
        if (isPending) ...[
          IconButton(
            tooltip: 'Accept',
            onPressed: () {
              AppState.instance
                  .setApplicationStatus(a.id, ApplicationStatus.accepted);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application accepted.')),
              );
            },
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          ),
          IconButton(
            tooltip: 'Decline',
            onPressed: () {
              AppState.instance
                  .setApplicationStatus(a.id, ApplicationStatus.declined);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application declined.')),
              );
            },
            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
          ),
        ],
        if (a.status == ApplicationStatus.accepted) ...[
          IconButton(
            tooltip: 'Schedule Interview',
            onPressed: () {
              _scheduleInterview(context, a);
            },
            icon: const Icon(Icons.schedule, color: Colors.orange),
          ),
          IconButton(
            tooltip: 'Assign Position',
            onPressed: () {
              _assignPosition(context, a);
            },
            icon: const Icon(Icons.person_add, color: Colors.purple),
          ),
        ],
      ],
    );
  }

  void _showApplicationDetails(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${application.name}\'s Application'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Student ID', application.studentId),
                _buildDetailRow('Contact', application.contact),
                _buildDetailRow('Email', application.email),
                _buildDetailRow('Reason for Joining', application.reason),
                _buildDetailRow('Skills/Talents', application.skills),
                _buildDetailRow('Status', _getStatusText(application.status)),
                _buildDetailRow(
                    'Submitted', application.createdAt.toLocal().toString()),
                if (application.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Attachments:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...application.attachments.map((attachment) => Text(
                      '• $attachment',
                      style: const TextStyle(fontSize: 12))),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _scheduleInterview(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Schedule Interview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Schedule an interview for ${application.name}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add interview event to the system
                  AppState.instance.addEventForCurrentOfficer(
                    title: 'Interview with ${application.name}',
                    date: DateTime.now().add(
                        const Duration(days: 3)), // Default to 3 days from now
                    description:
                        'Interview for ${application.orgName} application',
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Interview scheduled for ${application.name}. They will receive a notification.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealHeader,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Schedule Interview (3 days from now)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _assignPosition(BuildContext context, Application application) {
    final TextEditingController positionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign Position'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Assign a position to ${application.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position (e.g., Member, Officer, Coordinator)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (positionController.text.trim().isNotEmpty) {
                  // Update application status and add to members
                  AppState.instance.approveApplication(
                    application.id,
                    defaultPosition: positionController.text.trim(),
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${application.name} has been assigned as ${positionController.text.trim()} and added to the organization.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tealHeader,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign & Accept'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.declined:
        return 'Declined';
    }
  }

  Widget _statusChip(ApplicationStatus status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case ApplicationStatus.pending:
        bg = const Color(0xFF6B5B95).withOpacity(0.10);
        fg = const Color(0xFF6B5B95);
        label = 'Pending';
        break;
      case ApplicationStatus.accepted:
        bg = Colors.green.withOpacity(0.10);
        fg = Colors.green.shade800;
        label = 'Accepted';
        break;
      case ApplicationStatus.declined:
        bg = Colors.red.withOpacity(0.10);
        fg = Colors.redAccent;
        label = 'Declined';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
