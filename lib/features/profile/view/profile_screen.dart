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
  bool _loadingProfile = true;
  bool _loadingAppointments = true;
  String? _profileError;
  String? _appointmentsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProfile(), _loadAppointments()]);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
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
        _profileError = response.message ?? 'Failed to load profile';
        _loadingProfile = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loadingAppointments = true;
      _appointmentsError = null;
    });

    final response = await _appointmentService.getMyAppointments(
      status: 'confirmed',
      limit: 20,
    );
    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _appointments = response.data!;
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
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFE7E7E7)),
                  ),
                  child: const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
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

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: _appointments.isEmpty
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
              itemCount: _appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildAppointmentChatCard(_appointments[index]),
            ),
    );
  }

  Widget _buildAppointmentChatCard(Appointment appointment) {
    final start = appointment.startTime;
    final end = appointment.endTime;
    final isPast = start.isBefore(DateTime.now());
    final status = appointment.status.toLowerCase();
    final canChat = status == 'confirmed' || status == 'completed';
    final doctorName =
        appointment.doctor?.specialization ?? 'Doctor Consultation';
    final location = appointment.doctor?.city ?? '––';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDED)),
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
              CircleAvatar(
                backgroundColor: AppColors.softPurple,
                child: Text(
                  doctorName.isNotEmpty ? doctorName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
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
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: canChat
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: canChat ? AppColors.primary : Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(start)} · ${_formatTime(start)} - ${_formatTime(end)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canChat
                  ? () => _openChatForAppointment(appointment)
                  : null,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(
                canChat
                    ? 'Open chat for this appointment'
                    : (isPast
                          ? 'Chat unavailable (appointment closed)'
                          : 'Chat activates once confirmed'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChatForAppointment(Appointment appointment) {
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
        borderRadius: BorderRadius.circular(18),
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

    return _SectionCard(
      title: 'Your Appointments',
      child: Column(
        children: [
          ..._appointments.map((appointment) {
            return _AppointmentTile(appointment: appointment);
          }),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.pushNamed(RouteConstants.topDoctorsScreen);
              },
              child: const Text('Book another appointment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTiles() {
    return Column(
      children: [
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
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Contact Support',
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
      ],
    );
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
            borderRadius: BorderRadius.circular(21),
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
        borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(18),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
    final start = appointment.startTime;
    final end = appointment.endTime;
    final now = DateTime.now();
    final statusLower = appointment.status.toLowerCase();
    final isPast = start.isBefore(now);
    final isMissed =
        isPast && !['completed', 'cancelled'].contains(statusLower);
    final displayStatus = isMissed ? 'Missed' : appointment.status;
    final statusColor = isMissed
        ? Colors.redAccent
        : _statusColor(appointment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.medical_services, color: AppColors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. $doctorName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (city.isNotEmpty)
                  Text(
                    city,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(start)} · ${_formatTime(start)} - ${_formatTime(end)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (isMissed)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'This appointment was missed',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(999),
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
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
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
