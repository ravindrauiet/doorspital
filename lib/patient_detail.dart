// // lib/patient_detail_page.dart
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:door/components/custom_outlined_button.dart';
// import 'package:flutter/material.dart';
// import 'select_package_page.dart'; // <-- added: navigate here after validation

// enum Gender { male, female }

// class PatientDetailPage extends StatefulWidget {
//   const PatientDetailPage({
//     super.key,
//     // doctor header (keep simple so you can pass from your list/detail page)
//     this.doctorName = 'Dr. Rishi',
//     this.specialty = 'Psychiatrist',
//     this.rating = 3.1,
//     this.distanceText = '501m',
//     this.doctorImage, // data: url | http(s) | asset path (fallback used if null)
//     this.feePerHour = 799,
//     this.currency = '₹',
//     // from previous screen
//     this.appointmentDate,
//     this.appointmentTime,
//   });

//   final String doctorName;
//   final String specialty;
//   final double rating;
//   final String distanceText;
//   final String? doctorImage;
//   final int feePerHour;
//   final String currency;

//   final DateTime? appointmentDate;
//   final String? appointmentTime;

//   @override
//   State<PatientDetailPage> createState() => _PatientDetailPageState();
// }

// class _PatientDetailPageState extends State<PatientDetailPage> {
//   // theme helpers
//   final Color _primary = const Color(0xFF00CBA5);
//   final Color _blue = const Color(0xFF2D4FE3);
//   final Color _softBorder = const Color(0xFFE5ECF0);
//   final Color _greyText = const Color(0xFF6B7280);

//   // form state
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController(text: '');
//   final _emailCtrl = TextEditingController(text: '');
//   final _phoneCtrl = TextEditingController(text: '');
//   final _ageCtrl = TextEditingController(text: '');
//   final _complaintCtrl = TextEditingController(text: '');

//   Gender _gender = Gender.female;
//   double _height = 180; // cm
//   double _weight = 70; // kg
//   Uint8List? _photoBytes; // placeholder if you later add image picking

//   int get _complaintMax => 500;

//   @override
//   void initState() {
//     super.initState();
//     // Make the custom counter update live as user types
//     _complaintCtrl.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _phoneCtrl.dispose();
//     _ageCtrl.dispose();
//     _complaintCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateLine =
//         (widget.appointmentDate != null && widget.appointmentTime != null)
//         ? ' •  ${_formatDate(widget.appointmentDate!)} at ${widget.appointmentTime}'
//         : '';
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.of(context).maybePop(),
//         ),
//         title: const Text(
//           'Patient Details',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
//             children: [
//               _Steps(activeIndex: 0, primary: _primary),
//               const SizedBox(height: 12),
//               _DoctorHeader(
//                 name: widget.doctorName,
//                 specialty: widget.specialty,
//                 rating: widget.rating,
//                 distanceText: widget.distanceText,
//                 image: widget.doctorImage,
//                 trailingNote: dateLine,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Personal Bio',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 12),

//               // Name
//               _LabeledField(
//                 label: 'Your Name',
//                 child: _box(
//                   child: TextFormField(
//                     controller: _nameCtrl,
//                     decoration: _inputDecoration(
//                       hint: 'Full name',
//                       prefix: Icons.person_outline,
//                     ),
//                     validator: (v) => (v == null || v.trim().isEmpty)
//                         ? 'Please enter your name'
//                         : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Email
//               _LabeledField(
//                 label: 'Email',
//                 child: _box(
//                   child: TextFormField(
//                     controller: _emailCtrl,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: _inputDecoration(
//                       hint: 'example@domain.com',
//                       prefix: Icons.mail_outline,
//                     ),
//                     validator: (v) {
//                       final s = (v ?? '').trim();
//                       final ok = RegExp(
//                         r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
//                       ).hasMatch(s);
//                       return ok ? null : 'Enter a valid email';
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Phone
//               _LabeledField(
//                 label: 'Phone Number',
//                 child: _box(
//                   child: Row(
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.only(left: 12, right: 8),
//                         child: Text(
//                           '+91',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _phoneCtrl,
//                           keyboardType: TextInputType.phone,
//                           decoration:
//                               _inputDecoration(
//                                 hint: 'Phone number',
//                                 prefix: null,
//                               ).copyWith(
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 0,
//                                 ),
//                               ),
//                           validator: (v) => (v == null || v.trim().length < 6)
//                               ? 'Enter phone'
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(Icons.smartphone, color: Colors.black54),
//                       const SizedBox(width: 12),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               const Text(
//                 'Physical Information',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 12),

//               _LabeledField(
//                 label: 'Age',
//                 child: _box(
//                   child: TextFormField(
//                     controller: _ageCtrl,
//                     keyboardType: TextInputType.number,
//                     decoration: _inputDecoration(
//                       hint: 'Your age',
//                       prefix: Icons.cake_outlined,
//                     ),
//                     validator: (v) {
//                       final raw = (v ?? '').trim();
//                       final age = int.tryParse(raw);
//                       if (age == null || age <= 0 || age > 120) {
//                         return 'Enter a valid age';
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Gender
//               const Text(
//                 'Gender',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   _GenderChip(
//                     label: 'Male',
//                     icon: Icons.male,
//                     selected: _gender == Gender.male,
//                     onTap: () => setState(() => _gender = Gender.male),
//                     primary: _primary,
//                   ),
//                   const SizedBox(width: 12),
//                   _GenderChip(
//                     label: 'Female',
//                     icon: Icons.female,
//                     selected: _gender == Gender.female,
//                     onTap: () => setState(() => _gender = Gender.female),
//                     primary: _primary,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 18),

//               // Height
//               _RangeRow(
//                 label: 'Height',
//                 unit: 'centimeter',
//                 min: 120,
//                 max: 200,
//                 value: _height,
//                 onChanged: (v) => setState(() => _height = v),
//                 primary: _primary,
//               ),
//               const SizedBox(height: 8),

//               // Weight
//               _RangeRow(
//                 label: 'Weight',
//                 unit: 'kilograms',
//                 min: 40,
//                 max: 120,
//                 value: _weight,
//                 onChanged: (v) => setState(() => _weight = v),
//                 primary: _primary,
//               ),
//               const SizedBox(height: 20),

//               const Divider(color: Color(0xFFEAECEF), height: 28),

//               const Text(
//                 'Additional Comments',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 12),

//               // Complaint text with counter
//               _LabeledField(
//                 label: 'Main Complaint',
//                 child: _box(
//                   child: Stack(
//                     children: [
//                       TextFormField(
//                         controller: _complaintCtrl,
//                         maxLines: 4,
//                         maxLength: _complaintMax,
//                         // hide default; we draw our own
//                         buildCounter:
//                             (
//                               _, {
//                               required int currentLength,
//                               int? maxLength,
//                               required bool isFocused,
//                             }) => const SizedBox.shrink(),
//                         decoration: _inputDecoration(
//                           hint: 'Describe your symptoms...',
//                           prefix: null,
//                         ).copyWith(contentPadding: const EdgeInsets.all(12)),
//                       ),
//                       Positioned(
//                         right: 10,
//                         bottom: 6,
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.insert_drive_file_outlined,
//                               size: 16,
//                               color: Colors.black54,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               '${_complaintCtrl.text.length}/$_complaintMax',
//                               style: const TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 14),

//               // ===== Photo (optional) with overlay button + action buttons =====
//               const Text(
//                 'Complaint Photo (Optional)',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),

//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // description + action buttons
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Please take a picture of your conditions so the doctor can analyze it beforehand',
//                           style: TextStyle(color: _greyText, height: 1.4),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             // OutlinedButton(
//                             //   onPressed: ,
//                             //   style: OutlinedButton.styleFrom(
//                             //     side: BorderSide(color: _softBorder),
//                             //     shape: RoundedRectangleBorder(
//                             //       borderRadius: BorderRadius.circular(10),
//                             //     ),
//                             //   ),
//                             //   child: const Text('Take Photo'),
//                             // ),
//                             CustomOutlinedButton(
//                               label: 'Take Photo',
//                               onPressed: _onTakePhoto,
//                             ),
//                             const SizedBox(width: 10),
//                             OutlinedButton(
//                               onPressed: _onUploadPhoto,
//                               style: OutlinedButton.styleFrom(
//                                 side: BorderSide(color: _softBorder),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: const Text('Upload'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // picture with small camera button overlay
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       InkWell(
//                         borderRadius: BorderRadius.circular(44),
//                         onTap: _onUploadPhoto,
//                         child: CircleAvatar(
//                           radius: 36,
//                           backgroundColor: const Color(0xFFE9EBF0),
//                           child: _photoBytes == null
//                               ? const Icon(
//                                   Icons.photo_camera_outlined,
//                                   size: 26,
//                                   color: Colors.black54,
//                                 )
//                               : ClipOval(
//                                   child: Image.memory(
//                                     _photoBytes!,
//                                     width: 72,
//                                     height: 72,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       Positioned(
//                         right: -2,
//                         bottom: -2,
//                         child: Material(
//                           color: _blue,
//                           shape: const CircleBorder(),
//                           child: InkWell(
//                             customBorder: const CircleBorder(),
//                             onTap: _onTakePhoto,
//                             child: const Padding(
//                               padding: EdgeInsets.all(6),
//                               child: Icon(
//                                 Icons.camera_alt_rounded,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),

//       // bottom button
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//         color: Colors.white,
//         child: SizedBox(
//           height: 56,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _blue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               elevation: 0,
//             ),
//             onPressed: _onContinue,
//             child: const Text(
//               'Continue',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ===== Photo handlers (stub) =====
//   void _onTakePhoto() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Take Photo tapped (hook up camera here)')),
//     );
//   }

//   void _onUploadPhoto() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Upload tapped (open file picker here)')),
//     );
//   }

//   /// Validate first; only then go to SelectPackagePage
//   Future<void> _onContinue() async {
//     // block navigation if any required detail is missing
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please complete the required fields.')),
//       );
//       return;
//     }

//     final result = _buildResult();
//     final dateLabel = result.appointmentDate != null
//         ? _formatDate(result.appointmentDate!)
//         : _formatDate(DateTime.now());
//     final timeLabel = result.appointmentTime ?? 'Flexible';

//     // proceed to select package screen
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SelectPackagePage(
//           doctorName: widget.doctorName,
//           specialty: widget.specialty,
//           rating: widget.rating,
//           photo: widget.doctorImage,
//           feePerHour: widget.feePerHour,
//           dateLabel: dateLabel,
//           timeLabel: timeLabel,
//           patientName: result.name,
//           gender: _genderLabel(result.gender),
//           age: result.age,
//           payAmount: widget.feePerHour,
//           currency: widget.currency,
//         ),
//       ),
//     );
//   }

//   _PatientFormResult _buildResult() {
//     return _PatientFormResult(
//       name: _nameCtrl.text.trim(),
//       email: _emailCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       gender: _gender,
//       age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
//       heightCm: _height.round(),
//       weightKg: _weight.round(),
//       complaint: _complaintCtrl.text.trim(),
//       appointmentDate: widget.appointmentDate,
//       appointmentTime: widget.appointmentTime,
//     );
//   }

//   String _genderLabel(Gender g) => g == Gender.male ? 'Male' : 'Female';

//   InputDecoration _inputDecoration({String? hint, IconData? prefix}) {
//     return InputDecoration(
//       hintText: hint,
//       border: InputBorder.none,
//       prefixIcon: prefix == null ? null : Icon(prefix, color: Colors.black54),
//     );
//   }

//   Widget _box({required Widget child}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF6F8FA),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _softBorder),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: child,
//     );
//   }

//   String _formatDate(DateTime d) {
//     const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     const m = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${w[d.weekday - 1]}, ${d.day} ${m[d.month - 1]}';
//   }
// }

// /* ============================= Small widgets ============================= */

// class _Steps extends StatelessWidget {
//   const _Steps({required this.activeIndex, required this.primary});
//   final int activeIndex;
//   final Color primary;

//   @override
//   Widget build(BuildContext context) {
//     Widget dot(bool active) => Container(
//       width: 26,
//       height: 26,
//       decoration: BoxDecoration(
//         color: active ? primary : Colors.white,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(color: active ? primary : const Color(0xFFE5ECF0)),
//       ),
//       child: active
//           ? const Icon(Icons.check, size: 16, color: Colors.white)
//           : null,
//     );

//     Widget bar() =>
//         Expanded(child: Container(height: 2, color: const Color(0xFFE5ECF0)));

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [dot(true), bar(), dot(false), bar(), dot(false)]),
//           const SizedBox(height: 10),
//           Row(
//             children: const [
//               Expanded(
//                 child: Text(
//                   'Patient Detail',
//                   style: TextStyle(fontWeight: FontWeight.w700),
//                 ),
//               ),
//               Expanded(child: Center(child: Text('Time & Date'))),
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Text('Payment'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DoctorHeader extends StatelessWidget {
//   const _DoctorHeader({
//     required this.name,
//     required this.specialty,
//     required this.rating,
//     required this.distanceText,
//     this.image,
//     this.trailingNote,
//   });

//   final String name;
//   final String specialty;
//   final double rating;
//   final String distanceText;
//   final String? image;
//   final String? trailingNote;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _DocAvatar(src: image),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Flexible(
//                     child: Text(
//                       'Dr. $name',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   const Icon(
//                     Icons.verified,
//                     color: Color(0xFF00CBA5),
//                     size: 18,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 2),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.psychology_alt_outlined,
//                     size: 16,
//                     color: Colors.black54,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     specialty,
//                     style: const TextStyle(color: Colors.black54),
//                   ),
//                   const SizedBox(width: 10),
//                   const Icon(
//                     Icons.location_on_outlined,
//                     size: 16,
//                     color: Colors.black45,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     distanceText,
//                     style: const TextStyle(color: Colors.black54),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
//                   const SizedBox(width: 6),
//                   Text(
//                     rating.toStringAsFixed(1),
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   if (trailingNote != null) ...[
//                     const SizedBox(width: 8),
//                     Text(
//                       trailingNote!,
//                       style: const TextStyle(color: Colors.black54),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _DocAvatar extends StatelessWidget {
//   const _DocAvatar({this.src});
//   final String? src;

//   @override
//   Widget build(BuildContext context) {
//     Widget child;
//     final u = (src ?? '').trim();
//     if (u.isEmpty) {
//       child = const Image(
//         image: AssetImage('assets/placeholder_doctor.png'),
//         fit: BoxFit.cover,
//       );
//     } else if (u.startsWith('data:image')) {
//       try {
//         final comma = u.indexOf(',');
//         final bytes = base64Decode(comma >= 0 ? u.substring(comma + 1) : u);
//         child = Image.memory(bytes, fit: BoxFit.cover);
//       } catch (_) {
//         child = const Image(
//           image: AssetImage('assets/placeholder_doctor.png'),
//           fit: BoxFit.cover,
//         );
//       }
//     } else if (u.startsWith('http://') || u.startsWith('https://')) {
//       child = Image.network(u, fit: BoxFit.cover);
//     } else {
//       child = Image.asset(u, fit: BoxFit.cover);
//     }

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(48),
//       child: SizedBox(width: 64, height: 64, child: child),
//     );
//   }
// }

// class _GenderChip extends StatelessWidget {
//   const _GenderChip({
//     required this.label,
//     required this.icon,
//     required this.selected,
//     required this.onTap,
//     required this.primary,
//   });

//   final String label;
//   final IconData icon;
//   final bool selected;
//   final VoidCallback onTap;
//   final Color primary;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           height: 48,
//           decoration: BoxDecoration(
//             color: selected ? const Color(0xFFEFFFFA) : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: selected ? primary : const Color(0xFFE5ECF0),
//               width: 1.2,
//             ),
//           ),
//           alignment: Alignment.center,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: selected ? primary : Colors.black54),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: selected ? primary : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RangeRow extends StatelessWidget {
//   const _RangeRow({
//     required this.label,
//     required this.unit,
//     required this.min,
//     required this.max,
//     required this.value,
//     required this.onChanged,
//     required this.primary,
//   });

//   final String label;
//   final String unit;
//   final double min;
//   final double max;
//   final double value;
//   final ValueChanged<double> onChanged;
//   final Color primary;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//             const Spacer(),
//             Text(unit, style: const TextStyle(color: Colors.black54)),
//           ],
//         ),
//         const SizedBox(height: 6),
//         SliderTheme(
//           data: SliderTheme.of(context).copyWith(
//             trackHeight: 6,
//             activeTrackColor: primary,
//             inactiveTrackColor: const Color(0xFFE5ECF0),
//             thumbColor: primary,
//             overlayColor: primary.withOpacity(0.15),
//           ),
//           child: Slider(min: min, max: max, value: value, onChanged: onChanged),
//         ),
//         Row(
//           children: [
//             Text(
//               min.round().toString(),
//               style: const TextStyle(color: Colors.black54),
//             ),
//             const Spacer(),
//             Text(
//               value.round().toString(),
//               style: const TextStyle(fontWeight: FontWeight.w700),
//             ),
//             const Spacer(),
//             Text(
//               max.round().toString(),
//               style: const TextStyle(color: Colors.black54),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _LabeledField extends StatelessWidget {
//   const _LabeledField({required this.label, required this.child});
//   final String label;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         child,
//       ],
//     );
//   }
// }

// /* ============================== Result Model ============================== */

// class _PatientFormResult {
//   _PatientFormResult({
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.gender,
//     required this.age,
//     required this.heightCm,
//     required this.weightKg,
//     required this.complaint,
//     this.appointmentDate,
//     this.appointmentTime,
//   });

//   final String name;
//   final String email;
//   final String phone;
//   final Gender gender;
//   final int age;
//   final int heightCm;
//   final int weightKg;
//   final String complaint;

//   final DateTime? appointmentDate;
//   final String? appointmentTime;
// }
