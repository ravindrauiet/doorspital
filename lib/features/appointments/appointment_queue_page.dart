import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/services/models/appointment_models.dart';

/// Full-screen page showing a patient's queue position for a specific appointment.
/// Auto-refreshes every 30 seconds. Supports pull-to-refresh.
class AppointmentQueuePage extends StatefulWidget {
  final String appointmentId;
  final String doctorName;

  const AppointmentQueuePage({
    super.key,
    required this.appointmentId,
    required this.doctorName,
  });

  @override
  State<AppointmentQueuePage> createState() => _AppointmentQueuePageState();
}

class _AppointmentQueuePageState extends State<AppointmentQueuePage>
    with TickerProviderStateMixin {
  final AppointmentService _service = AppointmentService();

  bool _isLoading = true;
  String? _error;
  AppointmentQueue? _queue;

  Timer? _refreshTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _loadQueue();

    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadQueue(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadQueue({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final response = await _service.getAppointmentQueue(widget.appointmentId);

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _queue = response.data;
        _isLoading = false;
        _error = null;
      });
      _fadeController.forward(from: 0);
    } else {
      setState(() {
        _error = response.message ?? 'Failed to load queue';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Queue Status',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh',
            onPressed: _loadQueue,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQueue,
        color: AppColors.primary,
        child: _isLoading
            ? _buildSkeleton()
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  // ───────────────────────── Skeleton loader ───────────────────────────────
  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        _shimmer(height: 180, radius: 24),
        const SizedBox(height: 24),
        _shimmer(height: 120, radius: 20),
        const SizedBox(height: 16),
        _shimmer(height: 100, radius: 20),
      ],
    );
  }

  Widget _shimmer({required double height, double radius = 12}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ───────────────────────── Error state ───────────────────────────────────
  Widget _buildError() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.wifi_off_rounded, size: 64, color: Color(0xFFD1D5DB)),
        const SizedBox(height: 16),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadQueue,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Main content ──────────────────────────────────
  Widget _buildContent() {
    final q = _queue!;
    final isCancelled = q.isCancelled;
    final isNext = q.isNext;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Doctor / appointment info header ──
          _buildHeaderCard(q),
          const SizedBox(height: 20),

          // ── Big queue indicator ──
          if (isCancelled)
            _buildCancelledCard()
          else
            _buildQueueCard(q, isNext),

          const SizedBox(height: 20),

          // ── Detail tiles ──
          if (!isCancelled) ...[
            _buildDetailRow(
              icon: Icons.people_alt_rounded,
              label: 'Patients Ahead',
              value: '${q.patientsAhead ?? 0}',
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.people_rounded,
              label: 'Total in Queue Today',
              value: '${q.totalInQueue}',
              color: const Color(0xFF0EA5E9),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.timer_outlined,
              label: 'Estimated Wait',
              value: _formatWait(q.estimatedWaitMinutes),
              color: const Color(0xFF10B981),
            ),
          ],

          const SizedBox(height: 24),

          // ── Auto-refresh notice ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.sync, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Auto-refreshes every 30 seconds',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header card ──────────────────────────────────────────────────────────
  Widget _buildHeaderCard(AppointmentQueue q) {
    final dateFormat = DateFormat('EEEE, MMM dd');
    final timeFormat = DateFormat('h:mm a');
    final localStart = q.startTime.toLocal();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                widget.doctorName.isNotEmpty
                    ? widget.doctorName[0].toUpperCase()
                    : 'D',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.doctorName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(localStart),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'at ${timeFormat.format(localStart)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Status chip
          _buildStatusChip(q.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();
    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = AppColors.textPrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // ── Queue position card ──────────────────────────────────────────────────
  Widget _buildQueueCard(AppointmentQueue q, bool isNext) {
    final position = q.queuePosition ?? 1;
    final total = q.totalInQueue;

    // Color scheme depending on urgency
    final Color primaryColor =
        isNext ? const Color(0xFF10B981) : AppColors.primary;
    final Color bgColor =
        isNext ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF);

    return ScaleTransition(
      scale: isNext ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNext
                    ? Icons.notifications_active_rounded
                    : Icons.queue_rounded,
                size: 36,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // "You are next!" or "Your Position"
            Text(
              isNext ? 'You\'re Next!' : 'Your Queue Position',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Big number
            Text(
              isNext ? '🎉' : '#$position',
              style: TextStyle(
                fontSize: isNext ? 52 : 64,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),

            // Out of n
            if (!isNext && total > 0)
              Text(
                'out of $total patients today',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

            const SizedBox(height: 14),

            // Message banner
            if (q.message != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  q.message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),

            // Progress dots
            if (total > 0 && !isNext) ...[
              const SizedBox(height: 18),
              _buildProgressDots(position, total),
            ],
          ],
        ),
      ),
    );
  }

  /// Renders up to 10 position dots (patients as dots, current patient highlighted)
  Widget _buildProgressDots(int position, int total) {
    const maxDots = 10;
    final displayTotal = total.clamp(0, maxDots);
    final displayPosition = position.clamp(1, displayTotal);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(displayTotal, (index) {
        final dotPos = index + 1;
        final isDone = dotPos < displayPosition;
        final isCurrent = dotPos == displayPosition;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 28 : 14,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: isDone
                ? const Color(0xFF10B981)
                : isCurrent
                    ? AppColors.primary
                    : const Color(0xFFD1D5DB),
          ),
        );
      }),
    );
  }

  // ── Cancelled card ───────────────────────────────────────────────────────
  Widget _buildCancelledCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cancel_rounded, size: 60, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          const Text(
            'Appointment Cancelled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This appointment has been cancelled.\nYou are no longer in the queue.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
          ),
        ],
      ),
    );
  }

  // ── Detail row tile ──────────────────────────────────────────────────────
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _formatWait(int? minutes) {
    if (minutes == null) return '—';
    if (minutes == 0) return 'Any moment now';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
