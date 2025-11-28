import 'dart:async';

import 'package:door/features/chat/view/chat_screen.dart';
import 'package:door/features/components/custom_appbar.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/services/models/appointment_models.dart';
import 'package:door/services/profile_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/features/pharmacy/view/my_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  final _appointmentService = AppointmentService();

  Map<String, dynamic>? _profile;
  List<Appointment> _appointments = [];
  List<DoctorAppointmentSummary> _doctorAppointments = [];
  bool _loadingProfile = true;
  bool _loadingAppointments = true;
  String? _appointmentsError;
  String? _currentUserRole;
  Timer? _countdownTimer;

  bool get _isDoctor =>
      (_currentUserRole ?? '').toLowerCase().trim() == 'doctor';

  @override
  void initState() {
    super.initState();
    _startCountdownTicker();
    _loadData();
  }

  void _startCountdownTicker() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadCurrentUserRole();
    await Future.wait([_loadProfile(), _loadAppointments()]);
  }

  Future<void> _loadCurrentUserRole() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUserRole = user?.role?.toLowerCase();
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
    });

    final response = await _profileService.getProfile();
    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _profile = response.data!;
        _loadingProfile = false;
      });
    } else {
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loadingAppointments = true;
      _appointmentsError = null;
    });

    if (_isDoctor) {
      final response = await _appointmentService.getDoctorAppointments(
        range: 'upcoming',
        limit: 20,
      );
      if (!mounted) return;

      if (response.success && response.data != null) {
        final sorted = List<DoctorAppointmentSummary>.from(response.data!);
        sorted.sort((a, b) => a.startTime.compareTo(b.startTime));
        setState(() {
          _doctorAppointments = sorted;
          _appointments = [];
          _loadingAppointments = false;
        });
      } else {
        setState(() {
          _doctorAppointments = [];
          _appointmentsError =
              response.message ?? 'Failed to load doctor appointments';
          _loadingAppointments = false;
        });
      }
    } else {
      final response = await _appointmentService.getMyAppointments(
        status: 'confirmed',
        limit: 20,
      );
      if (!mounted) return;

      if (response.success && response.data != null) {
        final sorted = List<Appointment>.from(response.data!);
        sorted.sort((a, b) => a.startTime.compareTo(b.startTime));
        setState(() {
          _appointments = sorted;
          _doctorAppointments = [];
          _loadingAppointments = false;
        });
      } else {
        setState(() {
          _appointmentsError =
              response.message ?? 'Failed to load your appointments';
          _loadingAppointments = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    context.goNamed(RouteConstants.signInScreen);
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['userName'] as String? ?? 'User';
    final email = _profile?['email'] as String? ?? '';
    final phone = _profile?['phoneNumber'] as String?;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          arrowBack: false,
          title: 'Profile',
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFE7E7E7)),
                  ),
                  child: const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Appointments'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOverviewTab(name, email, phone),
                    _buildAllAppointmentsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(String name, String email, String? phone) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(name, email, phone),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildAppointmentsSection(),
              const SizedBox(height: 24),
              _buildActionTiles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllAppointmentsTab() {
    if (_isDoctor) {
      return _buildDoctorAppointmentsContent();
    }
    if (_loadingAppointments && _appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appointmentsError != null && _appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _appointmentsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final patientAppointments = _sortedPatientAppointments();

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: patientAppointments.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Icon(
                  Icons.event_busy_outlined,
                  size: 64,
                  color: Colors.black26,
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No appointments found.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: patientAppointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildAppointmentChatCard(patientAppointments[index]),
            ),
    );
  }

  Widget _buildDoctorAppointmentsContent() {
    if (_loadingAppointments && _doctorAppointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appointmentsError != null && _doctorAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _appointmentsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final doctorAppointments = _sortedDoctorAppointments();

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: doctorAppointments.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Icon(
                  Icons.event_busy_outlined,
                  size: 64,
                  color: Colors.black26,
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No appointments found.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: doctorAppointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _DoctorAppointmentCard(
                appointment: doctorAppointments[index],
                onChat: doctorAppointments[index].canChat
                    ? () => _openChatForDoctorAppointment(
                        doctorAppointments[index],
                      )
                    : null,
              ),
            ),
    );
  }

  Widget _buildAppointmentChatCard(Appointment appointment) {
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    final now = DateTime.now();
    final isPast = end.isBefore(DateTime.now());
    final status = appointment.status.toLowerCase();
    final canChat = status == 'confirmed' || status == 'completed';
    final doctorName =
        appointment.doctor?.specialization ?? 'Doctor Consultation';
    final location = appointment.doctor?.city ?? '––';
    final relativeLabel = _relativeTimeLabel(start, end);
    final isInSession = now.isAfter(start) && now.isBefore(end);
    final Color timingColor = isInSession
        ? AppColors.teal
        : (now.isBefore(start) ? Colors.orange : Colors.grey);

    final buttonLabel = canChat
        ? 'Open chat for this appointment'
        : (isPast
              ? 'Chat unavailable (appointment closed)'
              : 'Chat activates once confirmed');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: _homeHeroGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: Text(
                    doctorName.isNotEmpty ? doctorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (location.isNotEmpty)
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    appointment.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(start)} · ${_formatTime(start)} - ${_formatTime(end)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: timingColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        relativeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: timingColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canChat
                        ? () => _openChatForAppointment(appointment)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                    label: Text(buttonLabel, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openChatForAppointment(Appointment appointment) {
    final now = DateTime.now();
    final startTime = appointment.startTime.toLocal();

    if (now.isBefore(startTime)) {
      final timeUntilStart = startTime.difference(now);
      final minutes = timeUntilStart.inMinutes;
      final hours = timeUntilStart.inHours;

      String message;
      if (hours > 0) {
        message =
            'Chat will open in $hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes != 1 ? 's' : ''}';
      } else {
        message = 'Chat will open in $minutes minute${minutes != 1 ? 's' : ''}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
      return;
    }

    context.pushNamed(
      RouteConstants.chatScreen,
      extra: ChatScreenArgs(appointmentId: appointment.id),
    );
  }

  void _openChatForDoctorAppointment(DoctorAppointmentSummary appointment) {
    final now = DateTime.now();
    final startTime = appointment.startTime.toLocal();

    if (now.isBefore(startTime)) {
      final timeUntilStart = startTime.difference(now);
      final minutes = timeUntilStart.inMinutes;
      final hours = timeUntilStart.inHours;

      String message;
      if (hours > 0) {
        message =
            'Chat will open in $hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes != 1 ? 's' : ''}';
      } else {
        message = 'Chat will open in $minutes minute${minutes != 1 ? 's' : ''}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
      return;
    }

    context.pushNamed(
      RouteConstants.chatScreen,
      extra: ChatScreenArgs(appointmentId: appointment.id),
    );
  }

  Widget _buildProfileHeader(String name, String email, String? phone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.07),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.teal,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loadingProfile ? 'Loading...' : name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.pushNamed(RouteConstants.editProfileScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final now = DateTime.now();
    final upcoming = _appointments
        .where((a) => a.startTime.isAfter(now))
        .length;
    final missed = _appointments
        .where(
          (a) =>
              a.startTime.isBefore(now) &&
              !['completed', 'cancelled'].contains(a.status.toLowerCase()),
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            title: 'Upcoming',
            value: _loadingAppointments ? '...' : upcoming.toString(),
            icon: Icons.event_available,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileStatCard(
            title: 'Missed',
            value: _loadingAppointments ? '...' : missed.toString(),
            icon: Icons.error_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    if (_loadingAppointments) {
      return _SectionCard(
        title: 'Your Appointments',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_appointmentsError != null) {
      return _SectionCard(
        title: 'Your Appointments',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                _appointmentsError!,
                style: const TextStyle(color: Colors.red),
              ),
              TextButton(
                onPressed: _loadAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isDoctor) {
      return _SectionCard(
        title: 'Your Appointments',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'As a doctor you can view and chat with patients from the Appointments tab.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final controller = DefaultTabController.of(context);
                controller.animateTo(1);
              },
              child: const Text('Open Appointments tab'),
            ),
          ],
        ),
      );
    }

    if (_appointments.isEmpty) {
      return _SectionCard(
        title: 'Your Appointments',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Icon(Icons.event_busy, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No appointments yet',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.pushNamed(RouteConstants.topDoctorsScreen);
                },
                child: const Text('Book now'),
              ),
            ],
          ),
        ),
      );
    }

    final previewAppointments =
        _sortedPatientAppointments().take(3).toList(growable: false);
    final hasMore = _appointments.length > previewAppointments.length;

    return _SectionCard(
      title: 'Your Appointments',
      child: Column(
        children: [
          ...previewAppointments
              .map((appointment) => _AppointmentTile(appointment: appointment)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (hasMore)
                TextButton(
                  onPressed: () {
                    final controller = DefaultTabController.of(context);
                    controller?.animateTo(1);
                  },
                  child: const Text('View all appointments'),
                ),
              if (!hasMore) const SizedBox.shrink(),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.pushNamed(RouteConstants.topDoctorsScreen);
                },
                child: const Text('Book another appointment'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTiles() {
    final tiles = <Widget>[
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.person_outline_rounded,
        title: 'Personal Info',
        onTap: () {
          context.pushNamed(RouteConstants.editProfileScreen);
        },
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.shopping_bag_outlined,
        title: 'My Orders',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MyOrdersPage()));
        },
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.favorite_rounded,
        title: 'My Saved',
        onTap: () {},
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: _isDoctor
            ? Icons.forum_outlined
            : Icons.chat_bubble_outline_rounded,
        title: _isDoctor ? 'Patient Chats' : 'Contact Support',
        onTap: () {
          context.pushNamed(RouteConstants.chatListScreen);
        },
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.feedback_outlined,
        title: 'Feedback',
        onTap: () {},
      ),
      _ProfileTile(
        iconBg: AppColors.logoutBg,
        icon: Icons.logout_rounded,
        title: 'Logout',
        titleColor: AppColors.logoutText,
        onTap: _signOut,
      ),
    ];

    return Column(children: tiles);
  }

  List<Appointment> _sortedPatientAppointments() {
    final list = List<Appointment>.from(_appointments);
    list.sort(
      (a, b) => _compareScheduleWindows(
        a.startTime,
        a.endTime,
        a.status,
        b.startTime,
        b.endTime,
        b.status,
      ),
    );
    return list;
  }

  List<DoctorAppointmentSummary> _sortedDoctorAppointments() {
    final list = List<DoctorAppointmentSummary>.from(_doctorAppointments);
    list.sort(
      (a, b) => _compareScheduleWindows(
        a.startTime,
        a.endTime,
        a.status,
        b.startTime,
        b.endTime,
        b.status,
      ),
    );
    return list;
  }

  int _compareScheduleWindows(
    DateTime aStart,
    DateTime aEnd,
    String aStatus,
    DateTime bStart,
    DateTime bEnd,
    String bStatus,
  ) {
    final now = DateTime.now();
    final priorityA = _priorityBucket(aStart, aEnd, aStatus, now);
    final priorityB = _priorityBucket(bStart, bEnd, bStatus, now);

    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    final startCompare = aStart.compareTo(bStart);
    if (startCompare != 0) {
      return startCompare;
    }

    return aEnd.compareTo(bEnd);
  }

  int _priorityBucket(
    DateTime start,
    DateTime end,
    String status,
    DateTime now,
  ) {
    final lower = status.toLowerCase();
    final chatReady = _isChatEligibleStatus(lower);
    final bool inWindow = now.isAfter(start) && now.isBefore(end);

    if (inWindow) {
      return chatReady ? 0 : 1;
    }

    if (now.isBefore(start)) {
      return chatReady ? 2 : 3;
    }

    return 4;
  }

  bool _isChatEligibleStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'confirmed' || normalized == 'completed';
  }
}

class _ProfileTile extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEDEDED), width: 1)),
      ),
      child: ListTile(
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 22, color: Colors.black54),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: titleColor ?? Colors.black,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.black45,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: AppColors.teal),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final doctorName = appointment.doctor?.specialization ?? 'Doctor';
    final city = appointment.doctor?.city ?? '';
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    final now = DateTime.now();
    final statusLower = appointment.status.toLowerCase();
    final isPast = end.isBefore(now);
    final isMissed =
        isPast && !['completed', 'cancelled'].contains(statusLower);
    final displayStatus = isMissed ? 'Missed' : appointment.status;
    final statusColor = isMissed
        ? Colors.redAccent
        : _statusColor(appointment.status);

    final relativeLabel = _relativeTimeLabel(start, end);
    final isInSession = now.isAfter(start) && now.isBefore(end);
    final timingColor = isInSession
        ? AppColors.teal
        : (now.isBefore(start) ? Colors.orange : Colors.grey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.teal.withOpacity(.12),
                child: const Icon(
                  Icons.medical_services,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. $doctorName',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (city.isNotEmpty)
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: timingColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  relativeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: timingColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: Colors.black38,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${_formatDate(start)} · ${_formatTime(start)} - ${_formatTime(end)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
          if (isMissed)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'This appointment was missed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DoctorAppointmentCard extends StatelessWidget {
  final DoctorAppointmentSummary appointment;
  final VoidCallback? onChat;

  const _DoctorAppointmentCard({required this.appointment, this.onChat});

  @override
  Widget build(BuildContext context) {
    final patientName = appointment.patient?.name ?? 'Patient';
    final patientEmail = appointment.patient?.email ?? '';
    final buttonLabel = appointment.canChat
        ? 'Open chat with patient'
        : 'Chat available once confirmed';
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    final relativeLabel = _relativeTimeLabel(start, end);
    final now = DateTime.now();
    final bool isInSession = now.isAfter(start) && now.isBefore(end);
    final Color timingColor = isInSession
        ? AppColors.teal
        : (now.isBefore(start) ? Colors.orange : Colors.grey);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: _homeHeroGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: Text(
                    patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (patientEmail.isNotEmpty)
                        Text(
                          patientEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    appointment.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(start)} · ${_formatTime(start)} - ${_formatTime(end)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: timingColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        relativeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: timingColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (appointment.reason != null &&
                    appointment.reason!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Reason: ${appointment.reason}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.black45,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                    label: Text(buttonLabel, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeTimeLabel(DateTime start, DateTime end) {
  final now = DateTime.now();
  if (now.isBefore(start)) {
    return 'Starts in ${_readableDuration(start.difference(now))}';
  }
  if (now.isAfter(end)) {
    return 'Ended ${_readableDuration(now.difference(end))} ago';
  }
  return 'Ends in ${_readableDuration(end.difference(now))}';
}

String _readableDuration(Duration duration) {
  final d = duration.abs();
  if (d.inDays >= 1) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    if (hours == 0) return '${days}d';
    return '${days}d ${hours}h';
  }
  if (d.inHours >= 1) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
  if (d.inMinutes >= 1) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }
  return '${d.inSeconds}s';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String _formatTime(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return AppColors.teal;
    case 'pending':
      return Colors.orange;
    case 'cancelled':
      return Colors.red;
    case 'completed':
      return Colors.green;
    default:
      return Colors.blueGrey;
  }
}

const LinearGradient _homeHeroGradient = LinearGradient(
  colors: [Color(0xFF2F49D0), Color(0xFF2741BE)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
