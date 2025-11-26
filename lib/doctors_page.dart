// // lib/doctor_page.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'
//     show kIsWeb, defaultTargetPlatform, TargetPlatform;
// import 'package:http/http.dart' as http;

// // ⬇️ Add this import so we can navigate to the patient page
// import 'patient_detail.dart';

// /* ============================ HOST / NETWORK ============================ */

// /// Toggle this when testing on a REAL device and set your machine's LAN IP.
// /// Example: const String kLanIp = '192.168.1.23';
// const bool kUseLanIpForRealDevice = false;
// const String kLanIp = '192.168.1.23';

// String _resolveHost() {
//   if (kUseLanIpForRealDevice) return kLanIp;
//   if (kIsWeb) return 'localhost';
//   switch (defaultTargetPlatform) {
//     case TargetPlatform.android:
//       return '10.0.2.2';
//     case TargetPlatform.iOS:
//       return '127.0.0.1';
//     case TargetPlatform.macOS:
//     case TargetPlatform.windows:
//     case TargetPlatform.linux:
//       return '127.0.0.1';
//     default:
//       return '127.0.0.1';
//   }
// }

// /* ================================ PAGE: LIST ================================ */

// class DoctorPage extends StatefulWidget {
//   const DoctorPage({super.key});

//   @override
//   State<DoctorPage> createState() => _DoctorPageState();
// }

// class _DoctorPageState extends State<DoctorPage> {
//   late final String endpoint;
//   Future<List<Doctor>>? _future;
//   final TextEditingController _searchCtrl = TextEditingController();

//   // ✅ Start with "All" selected so everything shows first
//   String _selectedChip = 'All';
//   final List<String> chips = const [
//     'All',
//     'Heart',
//     'Skin',
//     'Hair',
//     'Kidney',
//     'Eyes',
//     'Bone',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     final host = _resolveHost();
//     endpoint = 'http://$host:3000/doctors';
//     _future = _fetchDoctors();
//     _searchCtrl.addListener(() => setState(() {}));
//   }

//   Future<List<Doctor>> _fetchDoctors() async {
//     final res = await http.get(Uri.parse(endpoint));
//     if (res.statusCode != 200) {
//       throw Exception('Failed to load doctors (${res.statusCode})');
//     }
//     final decoded = json.decode(res.body);
//     final List raw = (decoded is List)
//         ? decoded
//         : (decoded is Map && decoded['data'] is List
//               ? decoded['data']
//               : const []);
//     return raw.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final titleStyle = theme.textTheme.titleMedium?.copyWith(
//       fontWeight: FontWeight.w700,
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 18),
//           onPressed: () => Navigator.of(context).maybePop(),
//         ),
//         title: const Text(
//           'Top Doctors',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
//       ),
//       body: FutureBuilder<List<Doctor>>(
//         future: _future,
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) {
//             return _ErrorView(
//               message: snap.error.toString(),
//               onRetry: () => setState(() => _future = _fetchDoctors()),
//             );
//           }

//           final all = snap.data ?? [];
//           final filtered = _applyFilters(all);

//           return RefreshIndicator(
//             onRefresh: () async => setState(() => _future = _fetchDoctors()),
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               children: [
//                 _SearchBar(controller: _searchCtrl),
//                 const SizedBox(height: 12),
//                 _ChipsRow(
//                   chips: chips,
//                   selected: _selectedChip,
//                   onChanged: (v) => setState(() => _selectedChip = v),
//                 ),
//                 const SizedBox(height: 12),

//                 // Tap → DoctorDetailPage
//                 ...filtered.map(
//                   (d) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => DoctorDetailPage(prefetched: d),
//                           ),
//                         );
//                       },
//                       child: _DoctorCard(doctor: d, titleStyle: titleStyle),
//                     ),
//                   ),
//                 ),

//                 if (filtered.isEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 48),
//                     child: Center(
//                       child: Text(
//                         'No doctors match your filters.',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   List<Doctor> _applyFilters(List<Doctor> source) {
//     final q = _searchCtrl.text.trim().toLowerCase();

//     // Only filter by chip when chip != "All"
//     final keysByChip = {
//       'Heart': ['cardio', 'cardiologist', 'heart'],
//       'Skin': ['derm', 'skin'],
//       'Hair': ['hair', 'trichology'],
//       'Kidney': ['neph', 'kidney'],
//       'Eyes': ['ophthal', 'eye'],
//       'Bone': ['ortho', 'bone'],
//     };

//     Iterable<Doctor> current = source;
//     if (_selectedChip != 'All') {
//       final keys = keysByChip[_selectedChip] ?? [];
//       current = current.where((d) {
//         final s = d.specialty.toLowerCase();
//         return keys.isEmpty || keys.any((k) => s.contains(k));
//       });
//     }

//     if (q.isEmpty) return current.toList();
//     return current
//         .where(
//           (d) =>
//               d.name.toLowerCase().contains(q) ||
//               d.specialty.toLowerCase().contains(q) ||
//               (d.location?.toLowerCase().contains(q) ?? false),
//         )
//         .toList();
//   }
// }

// /* ===================== MODELS & SHARED WIDGETS ===================== */

// class Doctor {
//   final String id;
//   final String name;
//   final String specialty;
//   final double rating;
//   final String? image; // data: URL or http(s) URL
//   final String? location;
//   final int? distanceMeters;
//   final String? distanceText;
//   final bool bookmarked;
//   final bool available;

//   // extra optional fields for detail page
//   final int? feeCents;
//   final int? fee;
//   final String? bio;

//   Doctor({
//     required this.id,
//     required this.name,
//     required this.specialty,
//     required this.rating,
//     this.image,
//     this.location,
//     this.distanceMeters,
//     this.distanceText,
//     this.bookmarked = false,
//     this.available = true,
//     this.feeCents,
//     this.fee,
//     this.bio,
//   });

//   factory Doctor.fromJson(Map<String, dynamic> j) {
//     String s(List<String> ks, [String def = '']) {
//       for (final k in ks) {
//         final v = j[k];
//         if (v is String && v.trim().isNotEmpty) return v;
//       }
//       return def;
//     }

//     double d(List<String> ks, [double def = 0]) {
//       for (final k in ks) {
//         final v = j[k];
//         if (v is num) return v.toDouble();
//         if (v is String) {
//           final p = double.tryParse(v);
//           if (p != null) return p;
//         }
//       }
//       return def;
//     }

//     int? i(List<String> ks) {
//       for (final k in ks) {
//         final v = j[k];
//         if (v is int) return v;
//         if (v is num) return v.toInt();
//         if (v is String) {
//           final cleaned = v.replaceAll(RegExp(r'[^0-9.]'), '');
//           if (cleaned.isEmpty) continue;
//           final parsedInt = int.tryParse(cleaned);
//           if (parsedInt != null) return parsedInt;
//           final parsedDouble = double.tryParse(cleaned);
//           if (parsedDouble != null) return parsedDouble.round();
//         }
//       }
//       return null;
//     }

//     bool b(List<String> ks, [bool def = true]) {
//       for (final k in ks) {
//         final v = j[k];
//         if (v is bool) return v;
//         if (v is num) return v != 0;
//         if (v is String) {
//           final lower = v.toLowerCase();
//           if (lower == 'true' || lower == '1' || lower == 'yes') return true;
//           if (lower == 'false' || lower == '0' || lower == 'no') return false;
//         }
//       }
//       return def;
//     }

//     return Doctor(
//       id: s(['id', '_id', 'uuid'], UniqueKey().toString()),
//       name: s(['name', 'fullName', 'doctorName'], 'Unknown'),
//       specialty: s(['specialty', 'department', 'field'], 'General'),
//       rating: d(['rating', 'stars', 'score'], 0),
//       image: s(['image', 'imageUrl', 'photo', 'avatar']),
//       location: s(['location', 'area', 'city']),
//       distanceMeters: i(['distanceMeters', 'distance_m', 'distanceM']),
//       distanceText: s(['distanceText', 'distance', 'distance_km']),
//       bookmarked: (j['bookmarked'] ?? j['isBookmarked'] ?? false) == true,
//       available: b(['available', 'isAvailable', 'open', 'active'], true),

//       // detail-friendly fields
//       feeCents: i(['fee_cents', 'feeCents']),
//       fee: i([
//         'feePerHour',
//         'fee_per_hour',
//         'fee',
//         'hourlyRate',
//         'hourly_rate',
//         'price',
//         'amount',
//       ]),
//       bio: s(['bio', 'about']),
//     );
//   }

//   String prettyDistance() {
//     if (distanceText != null && distanceText!.trim().isNotEmpty)
//       return distanceText!;
//     if (distanceMeters == null) return '';
//     if (distanceMeters! >= 1000) {
//       final km = (distanceMeters! / 1000);
//       return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km away';
//     }
//     return '${distanceMeters}m away';
//   }

//   int? get feePerHourRupees {
//     if (fee != null && fee! > 0) return fee;
//     if (feeCents != null && feeCents! > 0) return feeCents! ~/ 100;
//     return null;
//   }

//   String feeText() {
//     final amount = feePerHourRupees ?? 799;
//     return 'Fee  ₹$amount/hr';
//   }
// }

// class _SearchBar extends StatelessWidget {
//   const _SearchBar({required this.controller});
//   final TextEditingController controller;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: 'Search doctor or specialty',
//         prefixIcon: const Icon(Icons.search),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(vertical: 0),
//         border: OutlineInputBorder(
//           borderSide: const BorderSide(color: Color(0xFFE3E6ED)),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Color(0xFFE3E6ED)),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Color(0xFF00C389)),
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }
// }

// class _ChipsRow extends StatelessWidget {
//   const _ChipsRow({
//     required this.chips,
//     required this.selected,
//     required this.onChanged,
//   });
//   final List<String> chips;
//   final String selected;
//   final ValueChanged<String> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 36,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemBuilder: (_, i) {
//           final label = chips[i];
//           final isSel = label == selected;
//           return ChoiceChip(
//             label: Text(label),
//             selected: isSel,
//             onSelected: (_) => onChanged(label),
//             shape: StadiumBorder(
//               side: BorderSide(
//                 color: isSel ? Colors.transparent : const Color(0xFFE3E6ED),
//               ),
//             ),
//             selectedColor: const Color(0xFF00C389),
//             labelStyle: TextStyle(
//               color: isSel ? Colors.white : const Color(0xFF3A3F47),
//               fontWeight: FontWeight.w600,
//             ),
//             backgroundColor: Colors.white,
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           );
//         },
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemCount: chips.length,
//       ),
//     );
//   }
// }

// class _DoctorCard extends StatelessWidget {
//   const _DoctorCard({required this.doctor, this.titleStyle});
//   final Doctor doctor;
//   final TextStyle? titleStyle;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         shadows: const [
//           BoxShadow(
//             color: Color(0x0D000000),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           _Avatar(dataOrUrl: doctor.image),
//           const SizedBox(width: 12),
//           Expanded(
//             child: SizedBox(
//               height: 92,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Dr. ${doctor.name}', style: titleStyle),
//                   const SizedBox(height: 4),
//                   Text(
//                     doctor.specialty,
//                     style: const TextStyle(
//                       color: Color(0xFF8B909A),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         size: 16,
//                         color: Color(0xFFFFC107),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         doctor.rating.toStringAsFixed(1),
//                         style: const TextStyle(fontWeight: FontWeight.w700),
//                       ),
//                       const SizedBox(width: 12),
//                       const Icon(
//                         Icons.place,
//                         size: 16,
//                         color: Color(0xFF8B909A),
//                       ),
//                       const SizedBox(width: 2),
//                       Text(
//                         doctor.prettyDistance(),
//                         style: const TextStyle(
//                           color: Color(0xFF8B909A),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.bookmark_outline, color: Color(0xFF3A3F47)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Avatar that supports data URLs, http(s) URLs, or a placeholder asset.
// class _Avatar extends StatelessWidget {
//   const _Avatar({required this.dataOrUrl});
//   final String? dataOrUrl;

//   @override
//   Widget build(BuildContext context) {
//     final String u = (dataOrUrl ?? '').trim();

//     Widget child;
//     if (u.isEmpty) {
//       child = const Image(
//         image: AssetImage('assets/placeholder_doctor.png'),
//         width: 76,
//         height: 76,
//         fit: BoxFit.cover,
//       );
//     } else if (u.startsWith('data:image')) {
//       try {
//         final comma = u.indexOf(',');
//         final bytes = base64Decode(comma >= 0 ? u.substring(comma + 1) : u);
//         child = Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover);
//       } catch (_) {
//         child = const Image(
//           image: AssetImage('assets/placeholder_doctor.png'),
//           width: 76,
//           height: 76,
//           fit: BoxFit.cover,
//         );
//       }
//     } else if (u.startsWith('http://') || u.startsWith('https://')) {
//       child = Image.network(u, width: 76, height: 76, fit: BoxFit.cover);
//     } else {
//       child = const Image(
//         image: AssetImage('assets/placeholder_doctor.png'),
//         width: 76,
//         height: 76,
//         fit: BoxFit.cover,
//       );
//     }

//     return ClipRRect(borderRadius: BorderRadius.circular(16), child: child);
//   }
// }

// class _ErrorView extends StatelessWidget {
//   const _ErrorView({required this.message, required this.onRetry});
//   final String message;
//   final VoidCallback onRetry;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
//             const SizedBox(height: 12),
//             Text(
//               'Could not load doctors.',
//               style: Theme.of(context).textTheme.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               message,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodySmall?.copyWith(color: Colors.black54),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ============================== PAGE: DETAIL ============================== */

// class DoctorDetailPage extends StatefulWidget {
//   const DoctorDetailPage({super.key, required this.prefetched});
//   final Doctor prefetched;

//   @override
//   State<DoctorDetailPage> createState() => _DoctorDetailPageState();
// }

// class _DoctorDetailPageState extends State<DoctorDetailPage> {
//   late final DateTime _today;
//   late DateTime _selectedDate;

//   // selection state for time slot
//   String? _selectedSlot; // label of selected time, e.g. "02:00 PM"

//   @override
//   void initState() {
//     super.initState();
//     _today = DateTime.now();
//     _selectedDate = DateTime(
//       _today.year,
//       _today.month,
//       _today.day,
//     ); // today selected
//   }

//   List<DateTime> _nextDays(int n) => List.generate(
//     n,
//     (i) => DateTime(_today.year, _today.month, _today.day + i),
//   );

//   String _weekdayShort(int w) =>
//       const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
//   String _dayNum(DateTime d) => d.day.toString().padLeft(2, '0');

//   List<String> _slotsFor(DateTime date) {
//     final base = [
//       '09:00 AM',
//       '10:00 AM',
//       '11:00 AM',
//       '01:00 PM',
//       '02:00 PM',
//       '03:00 PM',
//       '04:00 PM',
//       '07:00 PM',
//       '08:00 PM',
//     ];
//     final weekend = date.weekday >= DateTime.saturday;
//     return weekend
//         ? base
//               .where((s) => !s.startsWith('09:') && !s.startsWith('10:'))
//               .toList()
//         : base;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final d = widget.prefetched;
//     final theme = Theme.of(context);
//     final days = _nextDays(6);
//     final allLabels = _slotsFor(_selectedDate);

//     // Disable all when doctor not available
//     final bool isAvailable = d.available;
//     final Set<String> defaultDisabled = const {
//       '09:00 AM',
//       '11:00 AM',
//       '08:00 PM',
//     };
//     final slots = allLabels
//         .map(
//           (label) => _SlotUI(
//             label: label,
//             disabled: !isAvailable || defaultDisabled.contains(label),
//           ),
//         )
//         .toList();

//     // If current selection invalid after rebuild -> clear it
//     if (_selectedSlot != null) {
//       final stillValid = slots.any(
//         (s) => s.label == _selectedSlot && !s.disabled,
//       );
//       if (!stillValid) _selectedSlot = null;
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 18),
//           onPressed: () => Navigator.of(context).maybePop(),
//         ),
//         title: const Text(
//           'Doctor Detail',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // header card
//           Container(
//             decoration: ShapeDecoration(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               shadows: const [
//                 BoxShadow(
//                   color: Color(0x0D000000),
//                   blurRadius: 12,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 _Avatar(dataOrUrl: d.image),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Dr. ${d.name}',
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         d.specialty,
//                         style: const TextStyle(
//                           color: Color(0xFF8B909A),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             size: 16,
//                             color: Color(0xFFFFC107),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             d.rating.toStringAsFixed(1),
//                             style: const TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                           const SizedBox(width: 16),
//                           Text(
//                             d.feeText(),
//                             style: const TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                         ],
//                       ),
//                       if (!isAvailable) ...[
//                         const SizedBox(height: 8),
//                         const Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               size: 16,
//                               color: Colors.redAccent,
//                             ),
//                             SizedBox(width: 6),
//                             Text(
//                               'Not available',
//                               style: TextStyle(color: Colors.redAccent),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),
//           Text(
//             'About',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             (d.bio?.isNotEmpty ?? false) ? d.bio! : 'No bio provided.',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: const Color(0xFF6B7280),
//             ),
//           ),

//           const SizedBox(height: 16),
//           // Date strip – today highlighted
//           SizedBox(
//             height: 84,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: days.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemBuilder: (_, i) {
//                 final day = days[i];
//                 final selected =
//                     day.year == _selectedDate.year &&
//                     day.month == _selectedDate.month &&
//                     day.day == _selectedDate.day;
//                 return GestureDetector(
//                   onTap: () => setState(() {
//                     _selectedDate = day;
//                     _selectedSlot = null; // reset when date changes
//                   }),
//                   child: Container(
//                     width: 64,
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     decoration: ShapeDecoration(
//                       color: selected ? const Color(0xFF00C389) : Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       shadows: const [
//                         BoxShadow(
//                           color: Color(0x0D000000),
//                           blurRadius: 8,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           _weekdayShort(day.weekday),
//                           style: TextStyle(
//                             color: selected
//                                 ? Colors.white
//                                 : const Color(0xFF8B909A),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           _dayNum(day),
//                           style: TextStyle(
//                             color: selected
//                                 ? Colors.white
//                                 : const Color(0xFF111827),
//                             fontWeight: FontWeight.w800,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ====== TIME SLOTS: selectable chips ======
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               for (final s in slots)
//                 _TimeChip(
//                   label: s.label,
//                   selected: _selectedSlot == s.label && !s.disabled,
//                   disabled: s.disabled,
//                   onTap: s.disabled
//                       ? null
//                       : () => setState(() => _selectedSlot = s.label),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 24),
//           FilledButton(
//             style: FilledButton.styleFrom(
//               minimumSize: const Size.fromHeight(52),
//               backgroundColor: const Color(0xFF2D4FE3),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             // ⬇️ Navigate to PatientDetailPage with data
//             onPressed: (!isAvailable || _selectedSlot == null)
//                 ? null
//                 : () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => PatientDetailPage(
//                           doctorName: d.name,
//                           specialty: d.specialty,
//                           rating: d.rating,
//                           distanceText: d.prettyDistance(),
//                           doctorImage: d.image,
//                           feePerHour: d.feePerHourRupees ?? 799,
//                           currency: '₹',
//                           appointmentDate: _selectedDate, // DateTime
//                           appointmentTime:
//                               _selectedSlot!, // String, e.g. "02:00 PM"
//                         ),
//                       ),
//                     );
//                   },
//             child: const Text('Book Appointment'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* -------------------- Helpers for time slot UI -------------------- */

// class _SlotUI {
//   const _SlotUI({required this.label, required this.disabled});
//   final String label;
//   final bool disabled;
// }

// class _TimeChip extends StatelessWidget {
//   const _TimeChip({
//     required this.label,
//     required this.selected,
//     required this.disabled,
//     this.onTap,
//   });

//   final String label;
//   final bool selected;
//   final bool disabled;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final Color bg = disabled
//         ? const Color(0xFFEFF2F7)
//         : (selected ? const Color(0xFF00C389) : Colors.white);
//     final Color fg = disabled
//         ? const Color(0xFF9AA1AE)
//         : (selected ? Colors.white : const Color(0xFF111827));
//     final Color border = disabled
//         ? const Color(0xFFE3E6ED)
//         : (selected ? const Color(0xFF00C389) : const Color(0xFFE3E6ED));

//     return GestureDetector(
//       onTap: disabled ? null : onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         curve: Curves.easeOut,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: ShapeDecoration(
//           color: bg,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//             side: BorderSide(color: border),
//           ),
//           shadows: disabled
//               ? const []
//               : const [
//                   BoxShadow(
//                     color: Color(0x0A000000),
//                     blurRadius: 6,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Text(
//           label,
//           style: TextStyle(color: fg, fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }
// }
