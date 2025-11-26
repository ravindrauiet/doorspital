// // lib/select_package_page.dart
// import 'package:flutter/material.dart';
// import 'place_appointment_page.dart'; // ⬅️ import the final screen

// class SelectPackagePage extends StatefulWidget {
//   const SelectPackagePage({
//     super.key,

//     // ---- Optional context coming from previous pages ----
//     this.doctorName = 'Dr. Rishi',
//     this.specialty = 'Cardiologist',
//     this.rating = 4.7,
//     this.feePerHour = 799,
//     this.photo,

//     // Schedule shown on the summary screen
//     this.dateLabel = '12 Nov, 2025',
//     this.timeLabel = '2:00 to 2:30pm',

//     // Patient info shown on the summary screen
//     this.patientName = 'James Roger',
//     this.gender = 'Male',
//     this.age = 25,
//     this.payAmount = 799,
//     this.currency = '₹',
//   });

//   // Doctor
//   final String doctorName;
//   final String specialty;
//   final double rating;
//   final int feePerHour;
//   final String? photo;

//   // Schedule
//   final String dateLabel;
//   final String timeLabel;

//   // Patient
//   final String patientName;
//   final String gender;
//   final int age;

//   // Payment summary
//   final num payAmount;
//   final String currency;

//   @override
//   State<SelectPackagePage> createState() => _SelectPackagePageState();
// }

// class _SelectPackagePageState extends State<SelectPackagePage> {
//   final Color primary = const Color(0xFF2D4FE3);
//   final Color softBorder = const Color(0xFFE9EDF1);
//   final Color cardFill = const Color(0xFFF7FAFC);

//   String? _duration; // dropdown value
//   String? _selectedType; // "msg" | "audio" | "video" | "visit"

//   final List<_DurationItem> durations = const [
//     _DurationItem('15 min'),
//     _DurationItem('30 min'),
//     _DurationItem('45 min'),
//     _DurationItem('60 min'),
//   ];

//   final List<_ConsultationType> types = const [
//     _ConsultationType(
//       code: 'msg',
//       title: 'Messaging',
//       subtitle: 'Chat me up, share photos.',
//       price: 499,
//       badgeColor: Color(0xFFFCE7EF),
//       iconBg: Color(0xFFFFE6EE),
//       iconColor: Color(0xFFFB4E8C),
//       icon: Icons.chat_bubble_rounded,
//     ),
//     _ConsultationType(
//       code: 'audio',
//       title: 'Audio Call',
//       subtitle: 'call your doctor directly.',
//       price: 599,
//       badgeColor: Color(0xFFE6F3FF),
//       iconBg: Color(0xFFE8F4FF),
//       iconColor: Color(0xFF2F80ED),
//       icon: Icons.call_rounded,
//     ),
//     _ConsultationType(
//       code: 'video',
//       title: 'Video Call',
//       subtitle: 'call your doctor directly.',
//       price: 699,
//       badgeColor: Color(0xFFFFF2D9),
//       iconBg: Color(0xFFFFF3D9),
//       iconColor: Color(0xFFF2994A),
//       icon: Icons.videocam_rounded,
//     ),
//     _ConsultationType(
//       code: 'visit',
//       title: 'Book Appointment',
//       subtitle: 'schedule your visit easily.',
//       price: 799,
//       badgeColor: Color(0xFFE8FFF5),
//       iconBg: Color(0xFFE8FFF5),
//       iconColor: Color(0xFF00CBA5),
//       icon: Icons.home_rounded,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final titleStyle = Theme.of(
//       context,
//     ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _appBar(context),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//           children: [
//             const SizedBox(height: 4),
//             Text('Select Package', style: titleStyle),
//             const SizedBox(height: 12),

//             // ▶ Custom dropdown (bottom sheet)
//             _DurationPickerTile(
//               label: 'Select Duration',
//               value: _duration,
//               options: durations.map((d) => d.label).toList(),
//               onChanged: (v) => setState(() => _duration = v),
//               border: softBorder,
//               shadow: const BoxShadow(
//                 color: Color(0x0D000000),
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//               iconColor: const Color(0xFF2D4FE3),
//             ),
//             const SizedBox(height: 16),

//             Text(
//               'Consultation Type',
//               style: Theme.of(
//                 context,
//               ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 8),

//             ...types.map(
//               (t) => Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: _TypeTile(
//                   data: t,
//                   selected: _selectedType == t.code,
//                   onTap: () => setState(() => _selectedType = t.code),
//                   border: softBorder,
//                   fill: cardFill,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//         child: SizedBox(
//           height: 56,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               elevation: 0,
//             ),
//             onPressed: _onNext,
//             child: const Text(
//               'Next',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _appBar(BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.white,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded),
//         onPressed: () => Navigator.of(context).maybePop(),
//       ),
//     );
//   }

//   void _onNext() {
//     if (_selectedType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please choose a consultation type.')),
//       );
//       return;
//     }
//     if (_duration == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a duration.')),
//       );
//       return;
//     }

//     // ▶ Navigate to the summary / payment screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PlaceAppointmentPage(
//           // Doctor
//           doctorName: widget.doctorName,
//           specialty: widget.specialty,
//           rating: widget.rating,
//           feePerHour: widget.feePerHour,
//           photo: widget.photo,
//           // Schedule (keep original date & time, show chosen duration)
//           dateLabel: widget.dateLabel,
//           timeLabel: widget.timeLabel,
//           durationLabel: _duration!, // from the picker
//           // Patient
//           patientName: widget.patientName,
//           gender: widget.gender,
//           age: widget.age,
//           // Payment
//           payAmount: widget.payAmount,
//           currency: widget.currency,
//         ),
//       ),
//     );
//   }
// }

// /* ======================= Small models & tiles ======================= */

// class _DurationItem {
//   final String label;
//   const _DurationItem(this.label);
// }

// class _ConsultationType {
//   final String code;
//   final String title;
//   final String subtitle;
//   final int price; // in ₹
//   final Color badgeColor;
//   final Color iconBg;
//   final Color iconColor;
//   final IconData icon;

//   const _ConsultationType({
//     required this.code,
//     required this.title,
//     required this.subtitle,
//     required this.price,
//     required this.badgeColor,
//     required this.iconBg,
//     required this.iconColor,
//     required this.icon,
//   });
// }

// class _TypeTile extends StatelessWidget {
//   const _TypeTile({
//     required this.data,
//     required this.selected,
//     required this.onTap,
//     required this.border,
//     required this.fill,
//   });

//   final _ConsultationType data;
//   final bool selected;
//   final VoidCallback onTap;
//   final Color border;
//   final Color fill;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: border),
//             boxShadow: const [
//               BoxShadow(
//                 color: Color(0x0D000000),
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               _IconBadge(
//                 bg: data.iconBg,
//                 icon: data.icon,
//                 iconColor: data.iconColor,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data.title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       data.subtitle,
//                       style: const TextStyle(
//                         color: Colors.black54,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 '₹${data.price}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               _RadioCircle(selected: selected),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _IconBadge extends StatelessWidget {
//   const _IconBadge({
//     required this.bg,
//     required this.icon,
//     required this.iconColor,
//   });

//   final Color bg;
//   final IconData icon;
//   final Color iconColor;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 42,
//       height: 42,
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       alignment: Alignment.center,
//       child: Icon(icon, color: iconColor, size: 22),
//     );
//   }
// }

// class _RadioCircle extends StatelessWidget {
//   const _RadioCircle({required this.selected});
//   final bool selected;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 22,
//       height: 22,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: selected ? const Color(0xFF2D4FE3) : const Color(0xFFBFC7D0),
//           width: 2,
//         ),
//       ),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         margin: const EdgeInsets.all(3.6),
//         decoration: BoxDecoration(
//           color: selected ? const Color(0xFF2D4FE3) : Colors.transparent,
//           shape: BoxShape.circle,
//         ),
//       ),
//     );
//   }
// }

// /* ======================= Fancy Duration Picker ======================= */

// class _DurationPickerTile extends StatelessWidget {
//   const _DurationPickerTile({
//     required this.label,
//     required this.value,
//     required this.options,
//     required this.onChanged,
//     required this.border,
//     required this.shadow,
//     this.iconColor = const Color(0xFF2D4FE3),
//   });

//   final String label;
//   final String? value;
//   final List<String> options;
//   final ValueChanged<String> onChanged;
//   final Color border;
//   final BoxShadow shadow;
//   final Color iconColor;

//   @override
//   Widget build(BuildContext context) {
//     final hasValue = value != null && value!.isNotEmpty;

//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       elevation: 0,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () async {
//           final picked = await showModalBottomSheet<String>(
//             context: context,
//             backgroundColor: Colors.white,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//             ),
//             builder: (ctx) =>
//                 _DurationBottomSheet(options: options, selected: value),
//           );
//           if (picked != null) onChanged(picked);
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: border),
//             boxShadow: [shadow],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF7A8392),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       hasValue ? value! : 'Tap to choose',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: hasValue
//                             ? const Color(0xFF0F172A)
//                             : const Color(0xFF9AA3AE),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEFF3FF),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Text(
//                       hasValue ? 'Change' : 'Select',
//                       style: TextStyle(
//                         color: iconColor,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Icon(Icons.keyboard_arrow_down_rounded, color: iconColor),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DurationBottomSheet extends StatelessWidget {
//   const _DurationBottomSheet({required this.options, required this.selected});

//   final List<String> options;
//   final String? selected;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 42,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE6EAF0),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Select Duration',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
//               ),
//             ),
//             const SizedBox(height: 8),
//             ...options.map(
//               (opt) => ListTile(
//                 dense: true,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 6),
//                 title: Text(
//                   opt,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 trailing: selected == opt
//                     ? const Icon(Icons.check_circle, color: Color(0xFF2D4FE3))
//                     : const SizedBox.shrink(),
//                 onTap: () => Navigator.of(context).pop(opt),
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }
