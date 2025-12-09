import 'package:door/features/components/custom_elevated_button.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:door/routes/route_constants.dart';

class DoorstepSpecialistDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> specialistData;

  const DoorstepSpecialistDetailsScreen({
    super.key,
    required this.specialistData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data with fallbacks
    final name = specialistData['name'] ?? 'Dr. Specialist';
    final specialization = specialistData['specialization'] ?? 'Specialist';
    final experience = specialistData['experienceYears'] ?? '5';
    final rating = specialistData['rating'] ?? 4.5;
    final image = specialistData['imageUrl']; // Can be String (url) or AssetImage

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      '₹${specialistData['consultationFee'] ?? 799} / session',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Payable at clinic',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                         context.pushNamed(
                           RouteConstants.doctorDetailsScreen,
                           extra: specialistData['id'],
                         );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C49C6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Appointment',
                       style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                       ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2C49C6), width: 3),
                ),
                child: Container(
                  decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.white, width: 4), 
                  ),
                  child: image != null && image.toString().isNotEmpty
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: image is String ? NetworkImage(image) : (image as ImageProvider?),
                          onBackgroundImageError: (_,__) {},
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFEEF0FA),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'D',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C49C6),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Specialization
              Text(
                '${specialistData['qualification'] ?? 'MBBS'} - $specialization',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Experience Chip
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$experience+ years experience',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A75D7),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$rating (1,940 reviews)',
                          style: const TextStyle(
                            fontSize: 13,
                             fontWeight: FontWeight.w600,
                             color: Color(0xFF1A1A1A)
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(
                      children: const [
                         Icon(Icons.circle, color: Color(0xFF00C853), size: 10),
                         SizedBox(width: 8),
                         Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 13,
                             fontWeight: FontWeight.w600,
                             color: Color(0xFF00C853)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // About Doctor
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Doctor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      specialistData['about'] ?? 'Expert medical professional dedicated to patient care.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        height: 1.5
                      ),
                    ),
                     const SizedBox(height: 8),
                     InkWell(
                       onTap: () {},
                       child: const Text('Read More', style: TextStyle(color: Color(0xFF2C49C6), fontWeight: FontWeight.bold),),
                     )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Services Provided
               Align(
                 alignment: Alignment.centerLeft,
                 child: const Text(
                  'Services Provided',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                             ),
               ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _ServiceCard(icon: Icons.fitness_center, label: 'Muscle strengthening'),
                  _ServiceCard(icon: Icons.accessibility, label: 'Back/Neck Pain Therapy'),
                  _ServiceCard(icon: Icons.medical_services_outlined, label: 'Post-Surgery Rehab'),
                  _ServiceCard(icon: Icons.sports_gymnastics, label: 'Sports Recovery'),
                ],
              ),
              const SizedBox(height: 16),
               Container(
                 width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: const Color(0xFFEEF0FA),
                           shape: BoxShape.circle
                         ),
                         child: const Icon(Icons.elderly, color: Color(0xFF2C49C6)),
                       ),
                       const SizedBox(height: 12),
                       const Text('Senior Physical Therapy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),)
                    ],
                  ),
               ),

              const SizedBox(height: 24),
               
               // Patient Reviews
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text(
                    'Patient Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(onPressed: (){}, child: const Text('View All'))
                 ],
               ),
               const SizedBox(height: 12),
               
               _ReviewCard(
                 name: 'Rohan Verma',
                 time: '2 days ago',
                 review: 'Dr. Sharma is incredibly knowledgeable and compassionate. Her guidance was crucial to my recovery.',
               ),
               const SizedBox(height: 16),
               _ReviewCard(
                 name: 'Priya Singh',
                 time: '1 week ago',
                 review: 'Very helpful sessions. Made great progress with my back pain.',
                 // Assuming avatar for Priya
                 isFemale: true
               ),

               const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: const Color(0xFFEEF0FA),
               shape: BoxShape.circle
             ),
             child: Icon(icon, color: const Color(0xFF2C49C6)),
           ),
           const SizedBox(height: 12),
           Text(
             label, 
             textAlign: TextAlign.center,
             style: const TextStyle(
               fontWeight: FontWeight.w600,
               fontSize: 13,
               color: Color(0xFF1A1A1A),
               height: 1.2
             ),
           )
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String time;
  final String review;
  final bool isFemale;

  const _ReviewCard({
    required this.name, 
    required this.time, 
    required this.review,
    this.isFemale = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                  backgroundImage: AssetImage(isFemale ? 'assets/woman-doctor.png' : 'assets/images/Physiotherapy.png'), // Placeholders
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),),
                      Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16)),
                )
             ],
           ),
           const SizedBox(height: 12),
           Text(
             review,
             style: const TextStyle(
               fontSize: 13,
               color: Color(0xFF757575),
               height: 1.5
             ),
           )
        ],
      ),
    );
  }
}
