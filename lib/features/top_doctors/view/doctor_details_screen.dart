import 'package:door/features/components/custom_appbar.dart';
import 'package:door/features/components/custom_elevated_button.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/appointment_service.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/models/appointment_models.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:door/features/top_doctors/provider/doctor_availability_provider.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String? doctorId;
  
  const DoctorDetailsScreen({super.key, this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final _doctorService = DoctorService();
  final _appointmentService = AppointmentService();
  Doctor? _doctor;
  bool _loading = true;
  String? _error;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctorId != null) {
      _loadDoctorDetails();
      _loadAvailability();
    } else {
      setState(() {
        _error = 'Doctor ID not provided';
        _loading = false;
      });
    }
  }

  Future<void> _loadDoctorDetails() async {
    if (widget.doctorId == null) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _doctorService.getDoctor(widget.doctorId!);
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _doctor = response.data;
            _loading = false;
          });
        } else {
          setState(() {
            _error = response.message ?? 'Failed to load doctor details';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadAvailability() async {
    if (widget.doctorId == null) return;
    
    final provider = context.read<DoctorAvailabilityProvider>();
    provider.setLoading(true);

    try {
      // Get availability for next 7 days
      final startDate = DateTime.now();
      final response = await _doctorService.getAvailabilitySchedule(
        widget.doctorId!,
        start: startDate.toIso8601String(),
        days: 7,
      );

      if (mounted) {
        if (response.success && response.data != null) {
          provider.setAvailability(response.data!);
        } else {
          provider.setError(response.message ?? 'Failed to load availability');
        }
      }
    } catch (e) {
      if (mounted) {
        provider.setError('Error loading availability: $e');
      }
    } finally {
      if (mounted) {
        provider.setLoading(false);
      }
    }
  }

  Future<void> _bookAppointment() async {
    final provider = context.read<DoctorAvailabilityProvider>();
    if (provider.selectedSlot == null || widget.doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => _booking = true);

    try {
      final request = BookAppointmentRequest(
        doctorId: widget.doctorId!,
        startTime: provider.selectedSlot!.startUtc,
        mode: 'online',
      );

      final response = await _appointmentService.bookAppointment(request);

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Appointment booked successfully!')),
          );
          // Navigate to success screen or back
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Failed to book appointment')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _booking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availabilityState = context.watch<DoctorAvailabilityProvider>();

    if (_loading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Doctor Detail'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Doctor Detail'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDoctorDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Doctor Detail'),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Doctor Detail'),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: CustomElevatedButton(
            borderRadius: 50,
            height: 60,
            label: availabilityState.selectedSlot != null
                ? 'Book Appointment'
                : 'Select Time Slot',
            isLoading: _booking,
            onPressed: availabilityState.selectedSlot != null
                ? _bookAppointment
                : null,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Doctor card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greySecondry,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=300',
                    width: 125,
                    height: 125,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 125,
                        height: 125,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 50),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${_doctor!.specialization}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _doctor!.specialization,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8F9BB3),
                        ),
                      ),
                      if (_doctor!.city != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _doctor!.city!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8F9BB3),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Color(0xFF2F80ED),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '4.7',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF2F80ED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_doctor!.consultationFee != null)
                        Row(
                          children: [
                            const Text(
                              'Fee  ',
                              style: TextStyle(
                                color: Color(0xFF8F9BB3),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _doctor!.consultationFee!.toStringAsFixed(0),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              '/consultation',
                              style: TextStyle(
                                color: Color(0xFF8F9BB3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // About
          const Text(
            'About',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          ReadMoreText(
            text: _doctor!.specialization != null
                ? 'Experienced ${_doctor!.specialization} with ${_doctor!.experienceYears ?? 0} years of experience. ${_doctor!.city != null ? "Located in ${_doctor!.city}." : ""}'
                : 'No additional information available.',
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFEFF2F7)),
          const SizedBox(height: 12),

          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFEFF2F7)),
          const SizedBox(height: 12),

          // Days row
          availabilityState.loading
              ? const Center(child: CircularProgressIndicator())
              : availabilityState.days.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No availability scheduled',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Helper text if no slots on first days
                        if (availabilityState.days.isNotEmpty &&
                            !availabilityState.days[availabilityState.selectedDayIndex]
                                .hasAvailableSlots)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Scroll right to see days with available slots',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 85,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: availabilityState.days.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final selected = i == availabilityState.selectedDayIndex;
                              final day = availabilityState.days[i];
                              return _DayPill(
                                day: day,
                                selected: selected,
                                onTap: () => availabilityState.selectDay(i),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1, color: Color(0xFFEFF2F7)),
                        const SizedBox(height: 12),
                        // Show selected date info
                        if (availabilityState.selectedDayIndex < availabilityState.days.length)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppColors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  'Available slots for ${_formatDate(availabilityState.days[availabilityState.selectedDayIndex].date)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Times grid
                        availabilityState.availableSlots.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No available slots for this day',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try selecting another date',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select a time slot (${availabilityState.availableSlots.length} available)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8F9BB3),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.builder(
                                itemCount: availabilityState.availableSlots.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2.8,
                                ),
                                itemBuilder: (context, index) {
                                  final slot = availabilityState.availableSlots[index];
                                  final selected = availabilityState.selectedSlot?.startUtc ==
                                      slot.startUtc;

                                  // Use label from API if available, otherwise format the time
                                  final timeLabel = slot.label.isNotEmpty
                                      ? slot.label
                                      : _formatTime(slot.startUtc);

                                  return _TimeChip(
                                    label: timeLabel,
                                    selected: selected,
                                    available: slot.available,
                                    onTap: slot.available
                                        ? () => availabilityState.selectSlot(slot)
                                        : null,
                                  );
                                },
                              ),
                                ],
                              ),
                      ],
                    ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final formatter = DateFormat('h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      // Try using the label if available
      return isoString;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class _DayPill extends StatelessWidget {
  final Day day;
  final bool selected;
  final VoidCallback onTap;
  const _DayPill({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: day.hasAvailableSlots && !selected
              ? Border.all(color: AppColors.teal.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.white : const Color(0xFF8F9BB3),
                  ),
                ),
                if (day.hasAvailableSlots) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.white.withOpacity(0.3)
                          : AppColors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${day.availableSlotsCount}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.white : Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.white : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                day.day,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.teal : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool available;
  final VoidCallback? onTap;
  const _TimeChip({
    required this.label,
    required this.selected,
    this.available = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: available ? onTap : null,
      child: Opacity(
        opacity: available ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: selected
                ? AppColors.teal
                : available
                    ? Colors.white
                    : Colors.grey[200],
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : available
                      ? const Color(0xFFE7ECF3)
                      : Colors.grey[300]!,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.teal.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: selected
                    ? Colors.white
                    : available
                        ? const Color(0xFF111827)
                        : Colors.grey[600]!,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Day class is now in doctor_availability_provider.dart

class ReadMoreText extends StatefulWidget {
  final String text;
  final int trimLength;

  const ReadMoreText({super.key, required this.text, this.trimLength = 120});

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String visibleText = isExpanded
        ? widget.text
        : widget.text.length > widget.trimLength
            ? widget.text.substring(0, widget.trimLength)
            : widget.text;

    return GestureDetector(
      onTap: () {
        setState(() => isExpanded = !isExpanded);
      },
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
          children: [
            TextSpan(text: visibleText),
            if (!isExpanded && widget.text.length > widget.trimLength)
              const TextSpan(
                text: '... ',
                style: TextStyle(color: Colors.grey),
              ),
            if (widget.text.length > widget.trimLength)
              TextSpan(
                text: isExpanded ? ' Read less' : ' Read more',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
