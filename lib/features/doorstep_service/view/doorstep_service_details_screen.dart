import 'package:door/features/doorstep_service/models/doorstep_service_model.dart';
import 'package:door/features/doorstep_service/services/doorstep_service_api.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:door/routes/route_constants.dart';

class DoorstepServiceDetailsScreen extends StatefulWidget {
  final String serviceId;
  const DoorstepServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<DoorstepServiceDetailsScreen> createState() =>
      _DoorstepServiceDetailsScreenState();
}

class _DoorstepServiceDetailsScreenState
    extends State<DoorstepServiceDetailsScreen> {
  final DoorstepServiceApi _api = DoorstepServiceApi();
  bool _isLoading = true;
  DoorstepServiceDetail? _serviceDetail;
  List<Specialist> _specialists = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final details = await _api.getServiceDetails(widget.serviceId);
      final specialists = await _api.getSpecialists(widget.serviceId);
      if (mounted) {
        setState(() {
          _serviceDetail = details;
          _specialists = specialists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_serviceDetail == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load service details')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Stack(
                children: [
                   Container(
                     height: 280,
                     width: double.infinity,
                     color: const Color(0xFFFFE0C8),
                     child: Image.asset(
                       _serviceDetail!.bannerImage,
                       fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                         return const Center(child: Icon(Icons.broken_image, size: 50));
                       },
                     ),
                   ),
                   Positioned(
                     top: 16,
                     left: 16,
                     child: CircleAvatar(
                       backgroundColor: Colors.white,
                       child: IconButton(
                         icon: const Icon(Icons.arrow_back, color: Colors.black),
                         onPressed: () => Navigator.pop(context),
                       ),
                     ),
                   ),
                   Positioned(
                     top: 16,
                     right: 16,
                     child: CircleAvatar(
                       backgroundColor: Colors.white,
                       child: IconButton(
                         icon: const Icon(Icons.favorite_border, color: Colors.black),
                         onPressed: () {},
                       ),
                     ),
                   ),
                ],
              ),
              
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _serviceDetail!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _serviceDetail!.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                       Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_serviceDetail!.rating} (${_serviceDetail!.reviewsCount}+ reviews)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // What's Included
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                             BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "What's Included",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._serviceDetail!.whatsIncluded.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14, 
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                             const Divider(height: 24, thickness: 1, color: Color(0xFFEEF0FA)),
                             InkWell(
                               onTap: () {},
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 4),
                                 child: Row(
                                   children: const [
                                      Icon(Icons.description_outlined, color: AppColors.primary,),
                                      SizedBox(width: 8),
                                      Text('View Full Service Details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),)
                                   ],
                                 ),
                               ),
                             )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Available Specialists
                      const Text(
                        'Available Specialists',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 365,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          itemCount: _specialists.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final specialist = _specialists[index];
                            return Container(
                              width: 230,
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                               decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage: AssetImage(specialist.imageUrl),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    specialist.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${specialist.experienceYears}+ years',
                                     style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _Tag(text: specialist.specialty),
                                      const SizedBox(width: 8),
                                      _Tag(text: specialist.subSpecialty),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 18),
                                       const SizedBox(width: 6),
                                       Text(
                                        '${specialist.rating}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 14, 
                                          color: Color(0xFF1A1A1A)
                                        ),
                                       )
                                    ],
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                         context.pushNamed(
                                           RouteConstants.doorstepSpecialistDetailsScreen,
                                           extra: {
                                             'name': specialist.name,
                                             'specialization': specialist.specialty,
                                             'experienceYears': '${specialist.experienceYears}',
                                             'rating': specialist.rating,
                                             'imageUrl': specialist.imageUrl,
                                           }
                                         );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEEF0FA),
                                        foregroundColor: const Color(0xFF2C49C6),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: const Text(
                                        'Choose', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
