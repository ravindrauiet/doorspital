class DoorstepServiceDetail {
  final String id;
  final String title;
  final String subtitle;
  final double rating;
  final int reviewsCount;
  final List<String> whatsIncluded;
  final String bannerImage;

  DoorstepServiceDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviewsCount,
    required this.whatsIncluded,
    required this.bannerImage,
  });
}

class Specialist {
  final String id;
  final String name;
  final String specialty;
  final String subSpecialty;
  final int experienceYears;
  final double rating;
  final String imageUrl;

  Specialist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.subSpecialty,
    required this.experienceYears,
    required this.rating,
    required this.imageUrl,
  });
}
