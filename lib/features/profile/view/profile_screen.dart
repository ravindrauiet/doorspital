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
import 'package:door/features/feedback/feedback_page.dart';
import 'package:door/features/about/about_us_page.dart';
import 'package:door/features/appointments/my_appointment_page.dart';
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
      // Fetch all appointments (no range filter) so doctor can see all appointments and chat with any patient
      final response = await _appointmentService.getDoctorAppointments(
        limit: 50, // Increased limit to show more appointments
      );
      if (!mounted) return;

      if (response.success && response.data != null) {
        print('✅ Loaded ${response.data!.length} doctor appointments');
        final sorted = List<DoctorAppointmentSummary>.from(response.data!);
        // Sort by nearest time first (upcoming first, then past)
        final now = DateTime.now();
        sorted.sort((a, b) {
          final aStart = a.startTime.toLocal();
          final bStart = b.startTime.toLocal();
          final aIsUpcoming = aStart.isAfter(now);
          final bIsUpcoming = bStart.isAfter(now);
          
          if (aIsUpcoming != bIsUpcoming) {
            return aIsUpcoming ? -1 : 1; // Upcoming first
          }
          
          if (aIsUpcoming) {
            return aStart.compareTo(bStart); // Nearest first for upcoming
          } else {
            return bStart.compareTo(aStart); // Newest first for past
          }
        });
        setState(() {
          _doctorAppointments = sorted;
          _appointments = [];
          _loadingAppointments = false;
        });
      } else {
        print('❌ Failed to load doctor appointments: ${response.message}');
        print('Response: ${response.toString()}');
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
              itemBuilder: (context, index) {
                final appointment = doctorAppointments[index];
                return _DoctorAppointmentCard(
                  appointment: appointment,
                  relativeLabel: _relativeTimeLabel(
                    appointment.startTime.toLocal(),
                    appointment.endTime.toLocal(),
                  ),
                  timingColor: _getTimingColor(
                    appointment.startTime.toLocal(),
                    appointment.endTime.toLocal(),
                  ),
                  onChat: appointment.canChat
                      ? () => _openChatForDoctorAppointment(appointment)
                      : null,
                  onViewDetails: () => _showDoctorAppointmentDetails(appointment),
                );
              },
            ),
    );
  }

  Widget _buildAppointmentChatCard(Appointment appointment) {
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    final now = DateTime.now();
    final status = appointment.status.toLowerCase();
    final canChat = status == 'confirmed' || status == 'completed';
    final doctorName = appointment.doctor?.name ?? 
        appointment.doctor?.specialization ?? 'Doctor';
    final orderId = appointment.id.hashCode.abs() % 100000000;
    final rating = 4.5 + (appointment.id.hashCode % 5) / 10;
    
    // Format date
    final dateText = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final startTimeText = '${start.hour > 12 ? start.hour - 12 : start.hour}:${start.minute.toString().padLeft(2, '0')} ${start.hour >= 12 ? 'PM' : 'AM'}';
    final endTimeText = '${end.hour > 12 ? end.hour - 12 : end.hour}:${end.minute.toString().padLeft(2, '0')} ${end.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text(
            'Order ID: $orderId',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          // Date
          Text(
            '$dateText · $startTimeText - $endTimeText',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          // Doctor Info Row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Doctor Name & Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. $doctorName',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action Buttons - Compact size
          Row(
            children: [
              // Message Button
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: canChat
                      ? () => _openChatForAppointment(appointment)
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // View Details Button
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _showAppointmentDetails(appointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    final now = DateTime.now();
    final doctorName = appointment.doctor?.name ?? 
        appointment.doctor?.specialization ?? 'Doctor';
    final specialization = appointment.doctor?.specialization ?? 'General';
    final city = appointment.doctor?.city ?? 'Not specified';
    final status = appointment.status;
    
    final dateText = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final startTimeText = '${start.hour > 12 ? start.hour - 12 : start.hour}:${start.minute.toString().padLeft(2, '0')} ${start.hour >= 12 ? 'PM' : 'AM'}';
    final endTimeText = '${end.hour > 12 ? end.hour - 12 : end.hour}:${end.minute.toString().padLeft(2, '0')} ${end.hour >= 12 ? 'PM' : 'AM'}';
    
    String chatAvailability;
    Color chatColor;
    if (now.isBefore(start)) {
      final diff = start.difference(now);
      final days = diff.inDays;
      final hours = diff.inHours.remainder(24);
      final mins = diff.inMinutes.remainder(60);
      if (days > 0) {
        chatAvailability = 'Chat opens in ${days}d ${hours}h';
      } else if (hours > 0) {
        chatAvailability = 'Chat opens in ${hours}h ${mins}m';
      } else {
        chatAvailability = 'Chat opens in ${mins}m';
      }
      chatColor = Colors.orange;
    } else if (now.isAfter(end)) {
      chatAvailability = 'Chat session ended';
      chatColor = Colors.grey;
    } else {
      chatAvailability = 'Chat is available now!';
      chatColor = AppColors.success;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. $doctorName', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(specialization, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (status.toLowerCase() == 'confirmed' ? AppColors.success : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: status.toLowerCase() == 'confirmed' ? AppColors.success : Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.calendar_today_outlined, 'Date', dateText),
            const SizedBox(height: 14),
            _buildInfoRow(Icons.access_time, 'Time', '$startTimeText - $endTimeText'),
            const SizedBox(height: 14),
            _buildInfoRow(Icons.location_on_outlined, 'Location', city),
            const SizedBox(height: 14),
            _buildInfoRow(Icons.chat_outlined, 'Chat Status', chatAvailability, valueColor: chatColor),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openChatForAppointment(appointment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Open Chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: valueColor ?? AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDoctorAppointmentDetails(DoctorAppointmentSummary appointment) {
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    final now = DateTime.now();
    final patientName = appointment.patient?.name ?? 'Patient';
    final patientEmail = appointment.patient?.email ?? 'Not provided';
    final status = appointment.status;
    
    final dateText = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final startTimeText = '${start.hour > 12 ? start.hour - 12 : start.hour}:${start.minute.toString().padLeft(2, '0')} ${start.hour >= 12 ? 'PM' : 'AM'}';
    final endTimeText = '${end.hour > 12 ? end.hour - 12 : end.hour}:${end.minute.toString().padLeft(2, '0')} ${end.hour >= 12 ? 'PM' : 'AM'}';
    
    String chatAvailability;
    Color chatColor;
    if (now.isBefore(start)) {
      final diff = start.difference(now);
      final days = diff.inDays;
      final hours = diff.inHours.remainder(24);
      final mins = diff.inMinutes.remainder(60);
      if (days > 0) {
        chatAvailability = 'Chat opens in ${days}d ${hours}h';
      } else if (hours > 0) {
        chatAvailability = 'Chat opens in ${hours}h ${mins}m';
      } else {
        chatAvailability = 'Chat opens in ${mins}m';
      }
      chatColor = Colors.orange;
    } else if (now.isAfter(end)) {
      chatAvailability = 'Chat session ended';
      chatColor = Colors.grey;
    } else {
      chatAvailability = 'Chat is available now!';
      chatColor = AppColors.success;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Patient Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(patientEmail, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (status.toLowerCase() == 'confirmed' ? AppColors.success : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: status.toLowerCase() == 'confirmed' ? AppColors.success : Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.calendar_today_outlined, 'Date', dateText),
            const SizedBox(height: 14),
            _buildInfoRow(Icons.access_time, 'Time', '$startTimeText - $endTimeText'),
            const SizedBox(height: 14),
            if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
              _buildInfoRow(Icons.note_outlined, 'Reason', appointment.reason!),
              const SizedBox(height: 14),
            ],
            _buildInfoRow(Icons.chat_outlined, 'Chat Status', chatAvailability, valueColor: chatColor),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: appointment.canChat ? () {
                  Navigator.pop(context);
                  _openChatForDoctorAppointment(appointment);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Open Chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
        icon: Icons.calendar_month_outlined,
        title: 'My Appointments',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyAppointmentPage()),
          );
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FeedbackPage()),
          );
        },
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.info_outline,
        title: 'About Us',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AboutUsPage()),
          );
        },
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.description_outlined,
        title: 'Terms of Service',
        onTap: () {
          context.pushNamed(RouteConstants.termsAndConditionsScreen);
        },
      ),
      _ProfileTile(
        iconBg: AppColors.softPurple,
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Policy',
        onTap: () {
          context.pushNamed(RouteConstants.privacyPolicyScreen);
        },
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
  final VoidCallback? onViewDetails;
  final String relativeLabel;
  final Color timingColor;

  const _DoctorAppointmentCard({
    required this.appointment,
    this.onChat,
    this.onViewDetails,
    required this.relativeLabel,
    required this.timingColor,
  });

  @override
  Widget build(BuildContext context) {
    final patientName = appointment.patient?.name ?? 'Patient';
    final orderId = appointment.id.hashCode.abs() % 100000000;
    final rating = 4.5 + (appointment.id.hashCode % 5) / 10;
    final start = appointment.startTime.toLocal();
    final end = appointment.endTime.toLocal();
    
    // Format date
    final dateText = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final startTimeText = '${start.hour > 12 ? start.hour - 12 : start.hour}:${start.minute.toString().padLeft(2, '0')} ${start.hour >= 12 ? 'PM' : 'AM'}';
    final endTimeText = '${end.hour > 12 ? end.hour - 12 : end.hour}:${end.minute.toString().padLeft(2, '0')} ${end.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text(
            'Order ID: $orderId',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          // Date
          Text(
            '$dateText · $startTimeText - $endTimeText',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          // Patient Info Row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Patient Name & Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action Buttons
          Row(
            children: [
              // Message Button
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: onChat,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // View Details Button
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
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

Color _getTimingColor(DateTime start, DateTime end) {
  final now = DateTime.now();
  if (now.isBefore(start)) {
    return Colors.orange; // Upcoming
  } else if (now.isBefore(end)) {
    final diff = end.difference(now);
    if (diff.inMinutes <= 1) {
      return Colors.redAccent; // Last minute warning
    }
    return AppColors.teal; // Active
  } else {
    return Colors.grey; // Ended
  }
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
