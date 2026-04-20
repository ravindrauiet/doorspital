class DoorstepPageContent {
  final bool homeSectionVisible;
  final String homeSectionTitle;
  final String homeSectionSubtitle;
  final bool servicesPageVisible;
  final String servicesPageTitle;
  final String servicesPageSubtitle;
  final List<DoorstepServiceContent> services;
  final List<DoorstepServiceContent> homeServices;
  final List<DoorstepServiceContent> servicesPageItems;

  DoorstepPageContent({
    required this.homeSectionVisible,
    required this.homeSectionTitle,
    required this.homeSectionSubtitle,
    required this.servicesPageVisible,
    required this.servicesPageTitle,
    required this.servicesPageSubtitle,
    required this.services,
    required this.homeServices,
    required this.servicesPageItems,
  });

  factory DoorstepPageContent.fromJson(Map<String, dynamic> json) {
    List<DoorstepServiceContent> parseServices(dynamic value) =>
        (value as List<dynamic>? ?? [])
            .map(
              (item) => DoorstepServiceContent.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

    return DoorstepPageContent(
      homeSectionVisible: json['homeSectionVisible'] ?? true,
      homeSectionTitle: json['homeSectionTitle'] ?? 'Doorstep Services',
      homeSectionSubtitle: json['homeSectionSubtitle'] ?? '',
      servicesPageVisible: json['servicesPageVisible'] ?? true,
      servicesPageTitle: json['servicesPageTitle'] ?? 'Doorstep Services',
      servicesPageSubtitle:
          json['servicesPageSubtitle'] ?? 'Book trusted medical services at your home',
      services: parseServices(json['services']),
      homeServices: parseServices(json['homeServices']),
      servicesPageItems: parseServices(json['servicesPageItems']),
    );
  }
}

class DoorstepServiceContent {
  final String serviceKey;
  final String title;
  final String shortDescription;
  final String cardImage;
  final String bannerImage;
  final double rating;
  final int reviewsCount;
  final String whatsIncludedTitle;
  final List<String> whatsIncluded;
  final String fullDetailsTitle;
  final String fullDetails;
  final String detailsCtaText;
  final String availableSpecialistsTitle;
  final String subCategoriesTitle;
  final List<DoorstepServiceSubCategory> subCategories;
  final String doctorFilterValue;
  final int displayOrder;
  final bool showOnHome;
  final bool showOnServicesPage;
  final bool isActive;

  DoorstepServiceContent({
    required this.serviceKey,
    required this.title,
    required this.shortDescription,
    required this.cardImage,
    required this.bannerImage,
    required this.rating,
    required this.reviewsCount,
    required this.whatsIncludedTitle,
    required this.whatsIncluded,
    required this.fullDetailsTitle,
    required this.fullDetails,
    required this.detailsCtaText,
    required this.availableSpecialistsTitle,
    required this.subCategoriesTitle,
    required this.subCategories,
    required this.doctorFilterValue,
    required this.displayOrder,
    required this.showOnHome,
    required this.showOnServicesPage,
    required this.isActive,
  });

  factory DoorstepServiceContent.fromJson(Map<String, dynamic> json) {
    return DoorstepServiceContent(
      serviceKey: json['serviceKey']?.toString() ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      cardImage: json['cardImage'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      whatsIncludedTitle: json['whatsIncludedTitle'] ?? "What's Included",
      whatsIncluded:
          (json['whatsIncluded'] as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .toList(),
      fullDetailsTitle: json['fullDetailsTitle'] ?? 'Full Service Details',
      fullDetails: json['fullDetails'] ?? '',
      detailsCtaText: json['detailsCtaText'] ?? 'View Full Service Details',
      availableSpecialistsTitle:
          json['availableSpecialistsTitle'] ?? 'Available Specialists',
      subCategoriesTitle: json['subCategoriesTitle'] ?? 'Service Categories',
      subCategories:
          (json['subCategories'] as List<dynamic>? ?? [])
              .map(
                (item) => DoorstepServiceSubCategory.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      doctorFilterValue: json['doctorFilterValue'] ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      showOnHome: json['showOnHome'] ?? true,
      showOnServicesPage: json['showOnServicesPage'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }
}

class DoorstepServiceSubCategory {
  final String title;
  final String description;
  final String image;
  final String doctorFilterValue;
  final int displayOrder;
  final bool isActive;

  DoorstepServiceSubCategory({
    required this.title,
    required this.description,
    required this.image,
    required this.doctorFilterValue,
    required this.displayOrder,
    required this.isActive,
  });

  factory DoorstepServiceSubCategory.fromJson(Map<String, dynamic> json) {
    return DoorstepServiceSubCategory(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      doctorFilterValue: json['doctorFilterValue'] ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}
