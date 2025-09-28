import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  static const Color mintBg = Color(0xFFEAF6F0);
  static const Color tealHeader = Color(0xFF79CFC4);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late Map<DateTime, List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    final events = AppState.instance.eventsForCurrentStudent();
    _events = {};
    for (var event in events) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      _events[day] = (_events[day] ?? [])..add(event);
    }
  }

  void _showEventsForDay(DateTime day) {
    final events = _events[day] ?? [];
    if (events.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Events on ${DateFormat('yyyy-MM-dd').format(day)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...events.map((event) => ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.description),
                  trailing: Text(_formatTime(event.date)),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentDashboard.mintBg,
      appBar: AppBar(
        backgroundColor: StudentDashboard.tealHeader,
        elevation: 0,
        title: const Text(
          'My Activities & Events',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'My Applications',
            icon: const Icon(Icons.assignment),
            onPressed: () {
              _showMyApplications(context);
            },
          ),
          IconButton(
            tooltip: 'Change Role',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              AppState.instance.setRole(null);
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) {
          _loadEvents(); // Reload events when state changes
          final events = AppState.instance.eventsForCurrentStudent();
          final applications = AppState.instance.applications
              .where((app) =>
                  app.studentId == AppState.instance.currentStudent?.studentId)
              .toList();

          // Separate interview events from regular events
          final interviewEvents = events
              .where((event) => event.title.toLowerCase().contains('interview'))
              .toList();
          final regularEvents = events
              .where(
                  (event) => !event.title.toLowerCase().contains('interview'))
              .toList();

          final screenWidth = MediaQuery.of(context).size.width;
          final horizontalPadding = screenWidth * 0.04; // 4% of screen width
          final verticalSpacing = screenWidth * 0.05; // 5% of screen width

          return ListView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: horizontalPadding),
            children: [
              // Calendar Section
              Container(
                margin: EdgeInsets.only(bottom: verticalSpacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar<Event>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showEventsForDay(selectedDay);
                  },
                  eventLoader: (day) => _events[day] ?? [],
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Color(0xFFEAF6F0),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF79CFC4),
                      shape: BoxShape.circle,
                    ),
                    // Make calendar more compact on small screens
                    cellMargin: EdgeInsets.all(screenWidth < 600 ? 2 : 4),
                    cellPadding: EdgeInsets.all(screenWidth < 600 ? 2 : 4),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width:
                                screenWidth < 600 ? 4 : 6, // Smaller on mobile
                            height: screenWidth < 600 ? 4 : 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF79CFC4),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize:
                          screenWidth < 600 ? 16 : 18, // Responsive font size
                    ),
                  ),
                ),
              ),

              // Interview Notifications Section
              if (interviewEvents.isNotEmpty) ...[
                _buildSectionTitle('Interview Notifications'),
                ...interviewEvents.map((event) => _buildInterviewCard(event)),
                const SizedBox(height: 20),
              ],

              // My Applications Section
              if (applications.isNotEmpty) ...[
                _buildSectionTitle('My Applications'),
                ...applications.map((app) => _buildApplicationCard(app)),
                const SizedBox(height: 20),
              ],

              // Regular Events Section
              if (regularEvents.isNotEmpty) ...[
                _buildSectionTitle('Organization Events'),
                ...regularEvents.map((event) => _buildEventCard(event)),
              ] else if (events.isEmpty && applications.isEmpty) ...[
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No activities yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join organizations to see their events here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showMyApplications(BuildContext context) {
    final applications = AppState.instance.applications
        .where((app) =>
            app.studentId == AppState.instance.currentStudent?.studentId)
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'My Applications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (applications.isEmpty)
                const Text('No applications submitted yet.')
              else
                ...applications.map((app) => ListTile(
                      title: Text(app.orgName),
                      subtitle: Text('Status: ${_getStatusText(app.status)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (app.status == ApplicationStatus.pending)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pop(context);
                                _editApplication(context, app);
                              },
                              tooltip: 'Edit Application',
                            ),
                          if (app.status == ApplicationStatus.pending)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteApplication(context, app);
                              },
                              tooltip: 'Delete Application',
                            ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  void _editApplication(BuildContext context, Application application) {
    // This would typically open an edit form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit functionality would open application form')),
    );
  }

  void _deleteApplication(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Application'),
          content: Text(
              'Are you sure you want to delete your application to ${application.orgName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Remove application from the list
                AppState.instance.applications
                    .removeWhere((app) => app.id == application.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Application deleted successfully.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInterviewCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Interview Scheduled',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            event.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(event.date),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Application app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Color(0xFF79CFC4)),
              const SizedBox(width: 8),
              Text(
                app.orgName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _statusChip(app.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted: ${_formatDateTime(app.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(ApplicationStatus status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case ApplicationStatus.pending:
        bg = Colors.orange.withOpacity(0.1);
        fg = Colors.orange;
        label = 'Pending';
        break;
      case ApplicationStatus.accepted:
        bg = Colors.green.withOpacity(0.1);
        fg = Colors.green;
        label = 'Accepted';
        break;
      case ApplicationStatus.declined:
        bg = Colors.red.withOpacity(0.1);
        fg = Colors.red;
        label = 'Declined';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
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

  Widget _buildOrganizationSection(String orgName, List<Event> events) {
    // Sort events by date (upcoming first)
    events.sort((a, b) => a.date.compareTo(b.date));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF79CFC4).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              orgName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          ...events.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final isUpcoming = event.date.isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUpcoming ? Color(0xFF79CFC4) : Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(event.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isUpcoming ? 'Upcoming' : 'Past',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUpcoming ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;

    if (difference == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference == 1) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else if (difference < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return '${weekdays[dateTime.weekday - 1]} at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
