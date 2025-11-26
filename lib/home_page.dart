// import 'package:door/doctors_page.dart';
// import 'package:door/utils/images/images.dart';
// import 'package:flutter/material.dart';
// import 'pharmacy_page.dart';
// import 'profile_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /* ======================== HOME TAB ======================== */

// class _HomeTab extends StatelessWidget {
//   const _HomeTab({this.name = 'Guest'});
//   final String name;

//   @override
//   Widget build(BuildContext context) {
//     const primaryBlue = Color(0xFF2C49C6);
//     const accentGreen = Color(0xFF18C2A5);

//     return CustomScrollView(
//       slivers: [
//         // Blue header
//         SliverToBoxAdapter(
//           child: Container(
//             height: 280,
//             width: double.infinity,
//             color: primaryBlue,
//             padding: const EdgeInsets.fromLTRB(40, 50, 20, 0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         children: const [
//                           CircleAvatar(
//                             radius: 28,
//                             backgroundImage: AssetImage(Images.ruchita),
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             'Welcome!',
//                             style: TextStyle(
//                               color: Color.fromARGB(228, 255, 255, 255),
//                               fontSize: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 0),
//                       Text(
//                         name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Color.fromARGB(206, 255, 255, 255),
//                           fontWeight: FontWeight.w700,
//                           fontSize: 20,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       const Text(
//                         'How is it going today?',
//                         style: TextStyle(color: Colors.white70, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(25),
//                   child: Image.asset(
//                     'assets/woman-doctor.png',
//                     width: 150,
//                     height: 300,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SliverToBoxAdapter(child: _SearchCardPad()),
//         const SliverToBoxAdapter(child: SizedBox(height: 8)),

//         // Quick actions
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _QuickChip(
//                   icon: Icons.verified_user_outlined,
//                   label: 'Top Doctors',
//                   onTap: () => Navigator.of(
//                     context,
//                   ).push(MaterialPageRoute(builder: (_) => const DoctorPage())),
//                 ),
//                 _QuickChip(
//                   icon: Icons.local_pharmacy_outlined,
//                   label: 'Pharmacy',
//                   onTap: () => Navigator.of(context).push(
//                     MaterialPageRoute(builder: (_) => const PharmacyPage()),
//                   ),
//                 ),
//                 const _QuickChip(
//                   icon: Icons.local_hospital_outlined,
//                   label: 'Clinic',
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SliverToBoxAdapter(child: SizedBox(height: 16)),

//         // Section title
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 const Text(
//                   'Health article',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: () {},
//                   style: TextButton.styleFrom(
//                     foregroundColor: accentGreen,
//                     padding: EdgeInsets.zero,
//                   ),
//                   child: const Text('See all'),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Articles
//         SliverList.separated(
//           itemCount: _articles.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 12),
//           itemBuilder: (ctx, i) => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: _ArticleCard(article: _articles[i]),
//           ),
//         ),

//         const SliverToBoxAdapter(child: SizedBox(height: 24)),
//       ],
//     );
//   }
// }

// /* ======================== SEARCH CARD ======================== */

// class _SearchCardPad extends StatelessWidget {
//   const _SearchCardPad();

//   @override
//   Widget build(BuildContext context) {
//     return Transform.translate(
//       offset: const Offset(0, -10),
//       child: const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: _SearchCard(),
//       ),
//     );
//   }
// }

// class _SearchCard extends StatelessWidget {
//   const _SearchCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 140,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(26),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.12),
//             blurRadius: 22,
//             offset: Offset(0, 14),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(26),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.asset(
//               'assets/pharmacy-banner.jpg',
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(color: Color(0xFFEFF3F8)),
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 18),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(.96),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: const TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search doctor, drugs, articles...',
//                       hintStyle: TextStyle(color: Color(0xFF9AA4B2)),
//                       prefixIcon: Icon(Icons.search_rounded),
//                       // suffixIcon: Icon(Icons.mic_none_rounded),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ======================== QUICK CHIPS ======================== */

// class _QuickChip extends StatelessWidget {
//   const _QuickChip({required this.icon, required this.label, this.onTap});
//   final IconData icon;
//   final String label;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     const accentGreen = Color(0xFF18C2A5);
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(40),
//       child: Column(
//         children: [
//           Container(
//             height: 66,
//             width: 66,
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F9F5),
//               shape: BoxShape.circle,
//               border: Border.all(color: const Color(0xFFE0F0EB)),
//             ),
//             child: Icon(icon, color: accentGreen, size: 28),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* ======================== ARTICLE LIST ======================== */

// class _ArticleCard extends StatelessWidget {
//   const _ArticleCard({required this.article});
//   final _Article article;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 90,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE7EAF0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(.03),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               article.imagePath,
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 width: 60,
//                 height: 60,
//                 color: const Color(0xFFEFF3F8),
//                 child: const Icon(
//                   Icons.article_outlined,
//                   color: Color(0xFF8EA3B9),
//                   size: 26,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   article.title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13.5,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Text(
//                       article.date,
//                       style: const TextStyle(
//                         fontSize: 11.5,
//                         color: Color(0xFF7A8899),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       article.readTime,
//                       style: const TextStyle(
//                         fontSize: 11.5,
//                         color: Color(0xFF7A8899),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             height: 32,
//             width: 32,
//             decoration: BoxDecoration(
//               color: const Color(0xFFEAF3FF),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: IconButton(
//               padding: EdgeInsets.zero,
//               onPressed: () {},
//               icon: const Icon(
//                 Icons.bookmark_border,
//                 size: 18,
//                 color: Color(0xFF4F5E7B),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Article {
//   final String title;
//   final String date;
//   final String readTime;
//   final String imagePath;
//   const _Article({
//     required this.title,
//     required this.date,
//     required this.readTime,
//     required this.imagePath,
//   });
// }

// final _articles = <_Article>[
//   const _Article(
//     title: 'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
//     date: 'Jun 10, 2023',
//     readTime: '5min read',
//     imagePath: 'assets/article1.jpg',
//   ),
//   const _Article(
//     title: 'The Impact of COVID-19 on Healthcare Systems',
//     date: 'Jul 10, 2023',
//     readTime: '5min read',
//     imagePath: 'assets/article2.jpg',
//   ),
// ];

// /* ======================== PLACEHOLDER TAB ======================== */

// class _PlaceholderTab extends StatelessWidget {
//   const _PlaceholderTab(this.label, {super.key});
//   final String label;
//   @override
//   Widget build(BuildContext context) =>
//       Center(child: Text(label, style: const TextStyle(fontSize: 16)));
// }
