import 'package:door/features/home/components/doorstep_service_card.dart';
import 'package:door/features/home/components/home_search_feild.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final List<Map<String, String>> services = const [
    {'name': 'Home Doctor', 'image': 'assets/images/Home Doctor copy.png'},
    {'name': 'Yoga Trainer', 'image': 'assets/images/Yoga Trainer copy.png'},
    {'name': 'Elderly Care', 'image': 'assets/images/Elderly Care copy.png'},
    {'name': 'Physiotherapy', 'image': 'assets/images/Physiotherapy copy.png'},
    {'name': 'Blood Test', 'image': 'assets/images/Blood Test copy.png'},
    {'name': 'Vet Care', 'image': 'assets/images/Home Doctor copy.png'}, // Placeholder image
    {'name': 'Nursing & Caring', 'image': 'assets/images/Nursing & Caring copy.png'},
    {'name': 'Post-Operative Care', 'image': 'assets/images/PostOperativeCare.png'},
    {'name': 'Vaccination', 'image': 'assets/images/Vaccination.png'},
    {'name': 'Wound Dressing', 'image': 'assets/images/Wound Dressing.png'},
    {'name': 'Medical Attendant', 'image': 'assets/images/Medical Attendant.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50], // Match scaffold background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(RouteConstants.homeScreen), // Navigate back to home or handle nav correctly
        ),
        actions: [
            IconButton(
                onPressed: () {},
                 icon: const Icon(Icons.notifications_none, color: Colors.black)
            )
        ],
      ),
      body: SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text(
                        'Doorstep Services',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Book trusted medical services at your home',
                         style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SearchField(onTap: () {}),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Remove default padding
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                     child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns as per design
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0, 
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                             context.pushNamed(
                                RouteConstants.doorstepServiceDetailsScreen,
                                extra: services[index]['name'] as String,
                              );
                          },
                          child: DoorstepServiceCard(
                            name: services[index]['name']!,
                            imagePath: services[index]['image']!,
                          ),
                        );
                      },
                                     ),
                   ),
                  const SizedBox(height: 24),
                  // Bottom Banner
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                     child: ClipRRect(
                       borderRadius: BorderRadius.circular(20),
                       child: Container(
                          height: 210,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/visitfree.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                           child: Stack(
                            children: [
                               // Gradient overlay
                               Container(
                                 decoration: BoxDecoration(
                                   gradient: LinearGradient(
                                     begin: Alignment.centerLeft,
                                     end: Alignment.centerRight,
                                     colors: [
                                       Colors.black.withOpacity(0.3), 
                                       Colors.transparent,
                                     ],
                                   ),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.all(20.0),
                                 child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                     const Text(
                                      'First Visit Free Consultation',
                                       style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                       ),
                                     ),
                                     const SizedBox(height: 8),
                                     const Text(
                                      'For selected services only',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                      ),
                                     ),
                                     const SizedBox(height: 20),
                                     ElevatedButton(
                                       onPressed: (){}, 
                                       style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2F49D0),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          elevation: 2,
                                       ),
                                       child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),)
                                     )
                                  ],
                               ),
                             ),
                          ],
                         ),
                     ),
                   ),
                 ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
