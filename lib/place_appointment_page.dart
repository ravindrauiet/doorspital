// // lib/place_appointment_page.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';

// // ✅ Use your Doctor model from doctors_page.dart
// import 'doctors_page.dart' show Doctor;

// // Navigate to the payment page
// import 'payment_page.dart' show PaymentPage;

// class PlaceAppointmentPage extends StatelessWidget {
//   const PlaceAppointmentPage({
//     super.key,

//     // Option 1 (best): pass a Doctor from DB/API (/doctors)
//     this.doctor,

//     // Option 2: optionally pass a typed payload or args via Navigator
//     this.payload,

//     // Fallbacks (used only if not present elsewhere)
//     this.doctorName = 'Dr. Rishi',
//     this.specialty = 'Cardiologist',
//     this.rating = 4.7,
//     this.feePerHour = 799,
//     this.photo,
//     this.imageBaseUrl,

//     // Schedule (nullable)
//     this.dateLabel,
//     this.timeLabel,
//     this.durationLabel,

//     // Patient
//     this.patientName = 'James Roger',
//     this.gender = 'Male',
//     this.age = 25,

//     // Payment (legacy; we won’t use this for nav)
//     this.payAmount = 12,
//     this.currency = '₹', // ✅ default to rupee
//   });

//   // Dynamic sources
//   final Doctor? doctor;
//   final PlaceAppointmentPayload? payload;

//   // Fallback props
//   final String doctorName;
//   final String specialty;
//   final double rating;
//   final int feePerHour;
//   final String? photo;
//   final String? imageBaseUrl;

//   final String? dateLabel;
//   final String? timeLabel;
//   final String? durationLabel;

//   final String patientName;
//   final String gender;
//   final int age;

//   final num payAmount;
//   final String currency;

//   @override
//   Widget build(BuildContext context) {
//     final resolved = _ResolvedPlaceAppointmentData.resolve(
//       widget: this,
//       args: ModalRoute.of(context)?.settings.arguments,
//     );

//     final title = Theme.of(
//       context,
//     ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

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
//           'Place Appointment',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
//           children: [
//             _DoctorTile(
//               name: resolved.doctorName,
//               specialty: resolved.specialty,
//               rating: resolved.rating,
//               feePerHour: resolved.feePerHour,
//               currency: resolved.currency,
//               photo: resolved.photo,
//               imageBaseUrl: resolved.imageBaseUrl,
//             ),
//             const SizedBox(height: 18),

//             Text('Scheduled Appointment', style: title),
//             const SizedBox(height: 10),
//             _InfoRow(label: 'Date', value: resolved.dateLabel ?? '—'),
//             const SizedBox(height: 12),
//             _InfoRow(label: 'Time', value: resolved.timeLabel ?? '—'),
//             const SizedBox(height: 12),
//             _InfoRow(label: 'Duration', value: resolved.durationLabel ?? '—'),

//             const SizedBox(height: 22),
//             Text('Patient Information', style: title),
//             const SizedBox(height: 10),
//             _InfoRow(
//               label: 'Name',
//               value: resolved.patientName.isEmpty ? '—' : resolved.patientName,
//             ),
//             const SizedBox(height: 12),
//             _InfoRow(
//               label: 'Gender',
//               value: resolved.gender.isEmpty ? '—' : resolved.gender,
//             ),
//             const SizedBox(height: 12),
//             _InfoRow(label: 'Age', value: resolved.age.toString()),
//           ],
//         ),
//       ),

//       // Button -> PaymentPage with doctor fee + rupee
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
//         child: SizedBox(
//           height: 56,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2D4FE3),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               elevation: 0,
//             ),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => PaymentPage(
//                     // ✅ amount and explicit fee both set to the doctor fee
//                     amount: resolved.feePerHour,
//                     doctorFeePerHour: resolved.feePerHour,
//                     currency: resolved.currency, // always '₹'
//                     patientName: resolved.patientName,
//                     doctorName: resolved.doctorName,
//                     dateLabel: resolved.dateLabel,
//                     timeLabel: resolved.timeLabel,
//                   ),
//                 ),
//               );
//             },
//             child: Text(
//               // Show rupee + resolved fee
//               'Pay ${resolved.currency}${resolved.feePerHour}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* ============================ UI Pieces ============================ */

// class _DoctorTile extends StatelessWidget {
//   const _DoctorTile({
//     required this.name,
//     required this.specialty,
//     required this.rating,
//     required this.feePerHour,
//     required this.currency,
//     this.photo,
//     this.imageBaseUrl,
//   });

//   final String name;
//   final String specialty;
//   final double rating;
//   final int feePerHour;
//   final String currency;
//   final String? photo;
//   final String? imageBaseUrl;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: ShapeDecoration(
//         color: const Color(0xFFF7F8FB),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           _Avatar(src: photo, baseUrl: imageBaseUrl, name: name),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   specialty,
//                   style: const TextStyle(color: Colors.black54, fontSize: 12.5),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE6F0FF),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             size: 14,
//                             color: Color(0xFF2F80ED),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             rating.toStringAsFixed(1),
//                             style: const TextStyle(
//                               color: Color(0xFF2F80ED),
//                               fontWeight: FontWeight.w700,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Spacer(),
//                     const Text(
//                       'Fee  ',
//                       style: TextStyle(color: Colors.black54, fontSize: 12.5),
//                     ),
//                     Text(
//                       '$currency$feePerHour/hr',
//                       style: const TextStyle(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({required this.label, required this.value});
//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     final lStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
//       color: const Color(0xFF596070),
//       fontWeight: FontWeight.w600,
//     );
//     final vStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
//       color: const Color(0xFF0D1320),
//       fontWeight: FontWeight.w700,
//     );
//     return Row(
//       children: [
//         Expanded(child: Text(label, style: lStyle)),
//         const SizedBox(width: 10),
//         Text(value, style: vStyle),
//       ],
//     );
//   }
// }

// /* ===================== Dynamic Data Resolver ===================== */

// class _ResolvedPlaceAppointmentData {
//   const _ResolvedPlaceAppointmentData({
//     required this.doctorName,
//     required this.specialty,
//     required this.rating,
//     required this.feePerHour,
//     required this.photo,
//     required this.imageBaseUrl,
//     required this.dateLabel,
//     required this.timeLabel,
//     required this.durationLabel,
//     required this.patientName,
//     required this.gender,
//     required this.age,
//     required this.payAmount,
//     required this.currency,
//   });

//   final String doctorName;
//   final String specialty;
//   final double rating;
//   final int feePerHour;
//   final String? photo;
//   final String? imageBaseUrl;
//   final String? dateLabel;
//   final String? timeLabel;
//   final String? durationLabel;
//   final String patientName;
//   final String gender;
//   final int age;
//   final num payAmount;
//   final String currency;

//   static _ResolvedPlaceAppointmentData resolve({
//     required PlaceAppointmentPage widget,
//     required Object? args,
//   }) {
//     // Merge all possible inputs
//     final merged = _merge(widget, args);

//     final Doctor? doc = merged['doctor'] as Doctor?;
//     final String? docName = doc?.name;
//     final String? docSpecialty = doc?.specialty;
//     final String? docImage = doc?.image;

//     final doctorName = (docName != null && docName.trim().isNotEmpty)
//         ? docName
//         : _pickString(merged, ['doctorName', 'name'], widget.doctorName);

//     final specialty = (docSpecialty != null && docSpecialty.trim().isNotEmpty)
//         ? docSpecialty
//         : _pickString(merged, [
//             'specialty',
//             'doctorSpecialty',
//             'department',
//           ], widget.specialty);

//     final rating =
//         doc?.rating ??
//         _pickDouble(merged, [
//           'rating',
//           'doctorRating',
//           'stars',
//           'score',
//         ], widget.rating);

//     final photo = (docImage != null && docImage.trim().isNotEmpty)
//         ? docImage
//         : _pickStringNullable(merged, [
//                 'photo',
//                 'image',
//                 'avatar',
//                 'doctorImage',
//               ]) ??
//               widget.photo;

//     final imageBaseUrl =
//         _pickStringNullable(merged, ['imageBaseUrl', 'baseUrl', 'host']) ??
//         widget.imageBaseUrl;

//     // ✅ fee: prefer feePerHour → fee → feeCents → fallback
//     final feePerHour = _resolveFeePerHour(
//       mergedArgs: merged,
//       doctor: doc,
//       fallback: widget.feePerHour,
//     );

//     // schedule
//     final dateLabel =
//         _pickStringNullable(merged, ['dateLabel', 'date']) ?? widget.dateLabel;
//     final timeLabel =
//         _pickStringNullable(merged, ['timeLabel', 'time']) ?? widget.timeLabel;
//     final durationLabel =
//         _pickStringNullable(merged, [
//           'durationLabel',
//           'duration',
//           'slotLength',
//         ]) ??
//         widget.durationLabel;

//     // patient
//     final patientName = _pickString(merged, [
//       'patientName',
//       'name',
//     ], widget.patientName);
//     final gender = _pickString(merged, [
//       'gender',
//       'patientGender',
//     ], widget.gender);
//     final age = _pickInt(merged, ['age', 'patientAge'], widget.age);

//     // currency (force rupee)
//     final rawCurrency = _pickString(merged, [
//       'currency',
//       'currencySymbol',
//     ], widget.currency);
//     final currency = (rawCurrency.trim().isEmpty || rawCurrency == '\$')
//         ? '₹'
//         : rawCurrency;

//     final payAmount = _pickNum(merged, [
//       'payAmount',
//       'amount',
//       'total',
//       'price',
//     ], widget.payAmount);

//     return _ResolvedPlaceAppointmentData(
//       doctorName: doctorName,
//       specialty: specialty,
//       rating: rating,
//       feePerHour: feePerHour,
//       photo: photo,
//       imageBaseUrl: imageBaseUrl,
//       dateLabel: dateLabel,
//       timeLabel: timeLabel,
//       durationLabel: durationLabel,
//       patientName: patientName,
//       gender: gender,
//       age: age,
//       payAmount: payAmount,
//       currency: currency,
//     );
//   }

//   static Map<String, dynamic> _merge(PlaceAppointmentPage w, Object? args) {
//     final m = <String, dynamic>{};

//     void add(Map<String, dynamic>? src) {
//       if (src == null) return;
//       for (final e in src.entries) {
//         if (e.value != null) m[e.key] = e.value!;
//       }
//     }

//     final Doctor? widgetDoctor = w.doctor;
//     if (widgetDoctor != null) {
//       final int? docFee = widgetDoctor.feePerHourRupees;
//       add({
//         'doctor': widgetDoctor,
//         'doctorName': widgetDoctor.name,
//         'specialty': widgetDoctor.specialty,
//         'rating': widgetDoctor.rating,
//         'photo': widgetDoctor.image,
//         'feeCents': widgetDoctor.feeCents,
//         if (docFee != null) 'feePerHour': docFee,
//         if (docFee != null) 'fee': docFee,
//       });
//     }

//     add(w.payload?.toMap());

//     if (args is PlaceAppointmentPayload) {
//       add(args.toMap());
//     } else if (args is Doctor) {
//       final int? docFee = args.feePerHourRupees;
//       add({
//         'doctor': args,
//         'doctorName': args.name,
//         'specialty': args.specialty,
//         'rating': args.rating,
//         'photo': args.image,
//         'feeCents': args.feeCents,
//         if (docFee != null) 'feePerHour': docFee,
//         if (docFee != null) 'fee': docFee,
//       });
//     } else if (args is Map<String, dynamic>) {
//       add(args);
//     }

//     return m;
//   }
//   static int _resolveFeePerHour({
//     required Map<String, dynamic> mergedArgs,
//     required Doctor? doctor,
//     required int fallback,
//   }) {
//     // 1) Direct integers in args: feePerHour or fee
//     final int? direct = _pickIntNullable(mergedArgs, ['feePerHour', 'fee']);
//     if (direct != null) return direct;

//     // 2) Cents in args or on the Doctor model
//     final int? cents =
//         _pickIntNullable(mergedArgs, ['feeCents', 'fee_cents']) ??
//         doctor?.feeCents;
//     if (cents != null && cents > 0) return cents ~/ 100;

//     // 3) If your Doctor model has `fee` field (plain INR, not cents)
//     final int? docFee = _readPlainFee(doctor);
//     if (docFee != null && docFee > 0) return docFee;

//     // 4) Fallback (design-time default)
//     return fallback;
//   }

//   static int? _readPlainFee(Object? source) {
//     if (source == null) return null;
//     if (source is Doctor) return source.feePerHourRupees;
//     if (source is Map<String, dynamic>) {
//       return _pickIntNullable(source, [
//         'feePerHour',
//         'fee',
//         'fee_per_hour',
//         'hourlyRate',
//         'hourly_rate',
//         'amount',
//         'payAmount',
//       ]);
//     }
//     try {
//       final dynamic dyn = source;
//       final Object? value =
//           dyn.fee ?? dyn.feePerHour ?? dyn.amount ?? dyn.payAmount;
//       if (value is int && value > 0) return value;
//       if (value is double && value > 0) return value.round();
//       if (value is String) {
//         final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
//         if (cleaned.isNotEmpty) {
//           final parsed = double.tryParse(cleaned);
//           if (parsed != null) return parsed.round();
//         }
//       }
//     } catch (_) {}
//     return null;
//   }

//   // pickers
//   static String _pickString(
//     Map<String, dynamic> src,
//     List<String> keys,
//     String fallback,
//   ) {
//     return _pickStringNullable(src, keys) ?? fallback;
//   }

//   static String? _pickStringNullable(
//     Map<String, dynamic> src,
//     List<String> keys,
//   ) {
//     for (final k in keys) {
//       final v = src[k];
//       if (v is String && v.trim().isNotEmpty) return v;
//     }
//     return null;
//   }

//   static double _pickDouble(
//     Map<String, dynamic> src,
//     List<String> keys,
//     double fallback,
//   ) {
//     final n = _pickNumNullable(src, keys);
//     return n?.toDouble() ?? fallback;
//   }

//   static num _pickNum(
//     Map<String, dynamic> src,
//     List<String> keys,
//     num fallback,
//   ) {
//     return _pickNumNullable(src, keys) ?? fallback;
//   }

//   static num? _pickNumNullable(Map<String, dynamic> src, List<String> keys) {
//     for (final k in keys) {
//       final v = src[k];
//       if (v is num) return v;
//       if (v is String) {
//         final p = num.tryParse(v);
//         if (p != null) return p;
//       }
//     }
//     return null;
//   }

//   static int _pickInt(
//     Map<String, dynamic> src,
//     List<String> keys,
//     int fallback,
//   ) {
//     return _pickIntNullable(src, keys) ?? fallback;
//   }

//   static int? _pickIntNullable(Map<String, dynamic> src, List<String> keys) {
//     final n = _pickNumNullable(src, keys);
//     return n?.toInt();
//   }
// }

// /* ====================== Payload helper (optional) ====================== */

// class PlaceAppointmentPayload {
//   const PlaceAppointmentPayload({
//     this.doctor,
//     this.doctorName,
//     this.specialty,
//     this.rating,
//     this.feePerHour,
//     this.feeCents,
//     this.photo,
//     this.imageBaseUrl,
//     this.dateLabel,
//     this.timeLabel,
//     this.durationLabel,
//     this.patientName,
//     this.gender,
//     this.age,
//     this.payAmount,
//     this.currency,
//   });

//   final Doctor? doctor;
//   final String? doctorName;
//   final String? specialty;
//   final double? rating;
//   final int? feePerHour;
//   final int? feeCents;
//   final String? photo;
//   final String? imageBaseUrl;
//   final String? dateLabel;
//   final String? timeLabel;
//   final String? durationLabel;
//   final String? patientName;
//   final String? gender;
//   final int? age;
//   final num? payAmount;
//   final String? currency;

//   Map<String, dynamic> toMap() => {
//     if (doctor != null) 'doctor': doctor,
//     if (doctorName != null) 'doctorName': doctorName,
//     if (specialty != null) 'specialty': specialty,
//     if (rating != null) 'rating': rating,
//     if (feePerHour != null) 'feePerHour': feePerHour,
//     if (feeCents != null) 'feeCents': feeCents,
//     if (photo != null) 'photo': photo,
//     if (imageBaseUrl != null) 'imageBaseUrl': imageBaseUrl,
//     if (dateLabel != null) 'dateLabel': dateLabel,
//     if (timeLabel != null) 'timeLabel': timeLabel,
//     if (durationLabel != null) 'durationLabel': durationLabel,
//     if (patientName != null) 'patientName': patientName,
//     if (gender != null) 'gender': gender,
//     if (age != null) 'age': age,
//     if (payAmount != null) 'payAmount': payAmount,
//     if (currency != null) 'currency': currency,
//   };

//   factory PlaceAppointmentPayload.fromDoctor(
//     Doctor doctor, {
//     String? dateLabel,
//     String? timeLabel,
//     String? durationLabel,
//     String? patientName,
//     String? gender,
//     int? age,
//     num? payAmount,
//     String? currency,
//   }) {
//     return PlaceAppointmentPayload(
//       doctor: doctor,
//       doctorName: doctor.name,
//       specialty: doctor.specialty,
//       rating: doctor.rating,
//       photo: doctor.image,
//       feePerHour: doctor.feePerHourRupees,
//       feeCents: doctor.feeCents,
//       dateLabel: dateLabel,
//       timeLabel: timeLabel,
//       durationLabel: durationLabel,
//       patientName: patientName,
//       gender: gender,
//       age: age,
//       payAmount: payAmount,
//       currency: currency,
//     );
//   }
// }

// /* ============================ Avatar ============================ */

// class _Avatar extends StatelessWidget {
//   const _Avatar({this.src, this.baseUrl, this.name});
//   final String? src;
//   final String? baseUrl;
//   final String? name;

//   String? _resolveUrl(String? raw) {
//     final u = (raw ?? '').trim();
//     if (u.isEmpty) return null;
//     if (u.startsWith('http://') || u.startsWith('https://')) return u;
//     if (u.startsWith('data:image')) return u; // handled separately
//     if (baseUrl == null || baseUrl!.isEmpty) return null;
//     final needSlash = !(baseUrl!.endsWith('/') || u.startsWith('/'));
//     return needSlash ? '${baseUrl!}/$u' : '${baseUrl!}$u';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final resolved = _resolveUrl(src);

//     if ((src ?? '').startsWith('data:image')) {
//       try {
//         final comma = src!.indexOf(',');
//         final bytes = base64Decode(
//           comma >= 0 ? src!.substring(comma + 1) : src!,
//         );
//         return _wrap(
//           Image.memory(bytes, width: 64, height: 64, fit: BoxFit.cover),
//         );
//       } catch (_) {
//         return _fallback();
//       }
//     }

//     if (resolved != null) {
//       return _wrap(
//         Image.network(
//           resolved,
//           width: 64,
//           height: 64,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _fallback(),
//         ),
//       );
//     }

//     return _fallback();
//   }

//   Widget _wrap(Widget child) =>
//       ClipRRect(borderRadius: BorderRadius.circular(12), child: child);

//   Widget _fallback() {
//     final initials = _initials(name);
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         width: 64,
//         height: 64,
//         color: const Color(0xFFE9EEF5),
//         alignment: Alignment.center,
//         child: initials.isNotEmpty
//             ? Text(
//                 initials,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 18,
//                   color: Color(0xFF3B4A66),
//                 ),
//               )
//             : const Icon(Icons.person, color: Color(0xFF3B4A66)),
//       ),
//     );
//   }

//   String _initials(String? fullName) {
//     final s = (fullName ?? '').trim();
//     if (s.isEmpty) return '';
//     final parts = s.split(RegExp(r'\s+'));
//     if (parts.length == 1) {
//       return parts.first.characters.take(1).toString().toUpperCase();
//     }
//     return (parts.first.characters.take(1).toString() +
//             parts.last.characters.take(1).toString())
//         .toUpperCase();
//   }
// }
