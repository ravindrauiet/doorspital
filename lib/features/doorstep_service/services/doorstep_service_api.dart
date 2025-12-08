import 'package:door/features/doorstep_service/models/doorstep_service_model.dart';
import 'package:door/utils/images/images.dart';

class DoorstepServiceApi {
  Future<DoorstepServiceDetail> getServiceDetails(String serviceId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    switch (serviceId) {
      case 'Physiotherapy':
        return DoorstepServiceDetail(
          id: serviceId,
          title: 'Physiotherapy at Home',
          subtitle: 'Professional therapy by certified experts',
          rating: 4.9,
          reviewsCount: 2800,
          whatsIncluded: [
            'Mobility improvement exercises',
            'Pain relief therapy',
            'Strength recovery',
            'Personalized routine',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png',
        );
      case 'Yoga Trainer':
        return DoorstepServiceDetail(
          id: serviceId,
          title: 'Personal Yoga Trainer',
          subtitle: 'Achieve balance and flexibility at home',
          rating: 4.8,
          reviewsCount: 1500,
          whatsIncluded: [
            'Customized yoga sessions',
            'Meditation and breathing techniques',
            'Flexibility training',
            'Stress relief practices',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png', // Fallback or specific if available
        );
      case 'Elderly Care':
        return DoorstepServiceDetail(
          id: serviceId,
          title: 'Elderly Care Services',
          subtitle: 'Compassionate care for your loved ones',
          rating: 4.9,
          reviewsCount: 3200,
          whatsIncluded: [
            'Daily living assistance',
            'Medication reminders',
            'Companionship',
            'Health monitoring',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png',
        );
      case 'Home Doctor':
         return DoorstepServiceDetail(
          id: serviceId,
          title: 'Doctor Consultation at Home',
          subtitle: 'Expert medical advice at your doorstep',
          rating: 4.7,
          reviewsCount: 4100,
          whatsIncluded: [
            'General health checkup',
            'Diagnosis and prescription',
            'Minor medical procedures',
            'Follow-up consultation',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png',
        );
      case 'Blood Test':
        return DoorstepServiceDetail(
          id: serviceId,
          title: 'Home Sample Collection',
          subtitle: 'Safe and hygienic blood sample collection',
          rating: 4.8,
          reviewsCount: 5600,
          whatsIncluded: [
            'Hygienic sample collection',
            'Timely report delivery (Email/App)',
            'Certified phlebotomists',
            'Wide range of tests available',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png',
        );
      case 'Nursing & Caring':
        return DoorstepServiceDetail(
          id: serviceId,
          title: 'Professional Nursing Care',
          subtitle: 'Skilled nursing support at home',
          rating: 4.9,
          reviewsCount: 1200,
          whatsIncluded: [
            'Post-surgical care',
            'Wound dressing',
            'Injection administration',
            'Patient monitoring',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png',
        );
      default:
        // Fallback for unknown services
        return DoorstepServiceDetail(
          id: serviceId,
          title: '$serviceId Service',
          subtitle: 'Premium doorstep service',
          rating: 4.5,
          reviewsCount: 100,
          whatsIncluded: [
            'Professional consultation',
            'Quality service delivery',
            'Verified experts',
            'Customer support',
          ],
          bannerImage: 'assets/images/doorstep_banner_images.png',
        );
    }
  }

  Future<List<Specialist>> getSpecialists(String serviceId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    switch (serviceId) {
      case 'Physiotherapy':
        return [
          Specialist(
            id: '1',
            name: 'Dr. Bhavana Sharma',
            specialty: 'Ortho',
            subSpecialty: 'Neuro',
            experienceYears: 8,
            rating: 4.8,
            imageUrl: Images.ruchita,
          ),
          Specialist(
            id: '2',
            name: 'Dr. Raj Patel',
            specialty: 'Sports',
            subSpecialty: 'Rehab',
            experienceYears: 12,
            rating: 4.9,
            imageUrl: 'assets/woman-doctor.png',
          ),
        ];
      case 'Yoga Trainer':
         return [
          Specialist(
            id: '3',
            name: 'Priya Singh',
            specialty: 'Hatha',
            subSpecialty: 'Vinyasa',
            experienceYears: 5,
            rating: 4.7,
            imageUrl: Images.ruchita, 
          ),
          Specialist(
            id: '4',
            name: 'Rahul Verma',
            specialty: 'Power',
            subSpecialty: 'Meditation',
            experienceYears: 7,
            rating: 4.8,
             imageUrl: 'assets/woman-doctor.png',
          ),
        ]; 
       case 'Elderly Care':
         return [
          Specialist(
            id: '5',
            name: 'Sister Mary',
            specialty: 'Geriatric',
            subSpecialty: 'Palliative',
            experienceYears: 15,
            rating: 4.9,
            imageUrl: Images.ruchita,
          ),
          Specialist(
            id: '6',
            name: 'Bro. John',
            specialty: 'General',
            subSpecialty: 'Mobility',
            experienceYears: 10,
            rating: 4.8,
             imageUrl: 'assets/woman-doctor.png',
          ),
        ];
       case 'Home Doctor':
         return [
          Specialist(
            id: '7',
            name: 'Dr. Anjali Gupta',
            specialty: 'General',
            subSpecialty: 'Physician',
            experienceYears: 10,
            rating: 4.6,
            imageUrl: Images.ruchita,
          ),
          Specialist(
            id: '8',
            name: 'Dr. Sameer Khan',
            specialty: 'Pediatrics',
            subSpecialty: 'General',
            experienceYears: 8,
            rating: 4.7,
             imageUrl: 'assets/woman-doctor.png',
          ),
        ];  
       case 'Nursing & Caring':
         return [
          Specialist(
            id: '9',
            name: 'Nurse Rina',
            specialty: 'Surgical',
            subSpecialty: 'ICU',
            experienceYears: 6,
            rating: 4.8,
            imageUrl: Images.ruchita,
          ),
           Specialist(
            id: '10',
            name: 'Nurse Amit',
            specialty: 'Emergency',
            subSpecialty: 'Trauma',
            experienceYears: 9,
            rating: 4.9,
             imageUrl: 'assets/woman-doctor.png',
          ),
        ];   
      default:
        return [
           Specialist(
            id: '99',
            name: 'Expert Provider',
            specialty: 'General',
            subSpecialty: 'Service',
            experienceYears: 5,
            rating: 4.5,
            imageUrl: Images.ruchita,
          ),
        ];
    }
  }
}
