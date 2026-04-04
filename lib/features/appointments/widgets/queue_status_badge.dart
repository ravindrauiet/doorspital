import 'dart:async';
import 'package:flutter/material.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/services/models/appointment_models.dart';
import 'package:door/utils/theme/colors.dart';

class QueueStatusBadge extends StatefulWidget {
  final String appointmentId;
  const QueueStatusBadge({super.key, required this.appointmentId});

  @override
  State<QueueStatusBadge> createState() => _QueueStatusBadgeState();
}

class _QueueStatusBadgeState extends State<QueueStatusBadge> {
  final _service = AppointmentService();
  AppointmentQueue? _queueStatus;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final response = await _service.getAppointmentQueue(widget.appointmentId);
    if (mounted && response.success && response.data != null) {
      setState(() {
        _queueStatus = response.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_queueStatus == null || _queueStatus!.queuePosition == null) {
      return const SizedBox.shrink();
    }
    
    final int position = _queueStatus!.queuePosition!;
    final int ahead = _queueStatus!.patientsAhead ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(ahead == 0 ? Icons.check_circle_outline : Icons.people_alt_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            ahead == 0 ? 'You are next!' : 'Queue No: $position',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
