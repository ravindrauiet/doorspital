class HomeContent {
  final HomeBannerContent banner;
  final List<HomeActionItem> quickActions;
  final HomeSectionContent departmentsSection;
  final HomeSectionContent mostBookedSection;
  final HomePromoBanner promoBanner;

  HomeContent({
    required this.banner,
    required this.quickActions,
    required this.departmentsSection,
    required this.mostBookedSection,
    required this.promoBanner,
  });

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      banner: HomeBannerContent.fromJson(
        json['banner'] as Map<String, dynamic>? ?? const {},
      ),
      quickActions:
          (json['quickActions'] as List<dynamic>? ?? const [])
              .map((item) => HomeActionItem.fromJson(item as Map<String, dynamic>))
              .toList(),
      departmentsSection: HomeSectionContent.fromJson(
        json['departmentsSection'] as Map<String, dynamic>? ?? const {},
      ),
      mostBookedSection: HomeSectionContent.fromJson(
        json['mostBookedSection'] as Map<String, dynamic>? ?? const {},
      ),
      promoBanner: HomePromoBanner.fromJson(
        json['promoBanner'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class HomeBannerContent {
  final String backgroundImage;
  final String videoUrl;
  final String bookServiceLabel;
  final String giveServiceLabel;
  final String supportLabel;
  final String searchPlaceholder;

  HomeBannerContent({
    required this.backgroundImage,
    required this.videoUrl,
    required this.bookServiceLabel,
    required this.giveServiceLabel,
    required this.supportLabel,
    required this.searchPlaceholder,
  });

  factory HomeBannerContent.fromJson(Map<String, dynamic> json) {
    return HomeBannerContent(
      backgroundImage: json['backgroundImage']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      bookServiceLabel: json['bookServiceLabel']?.toString() ?? 'Book a Service',
      giveServiceLabel: json['giveServiceLabel']?.toString() ?? 'Give a Service',
      supportLabel: json['supportLabel']?.toString() ?? 'Support',
      searchPlaceholder:
          json['searchPlaceholder']?.toString() ??
          'Search doctor, drugs, articles...',
    );
  }
}

class HomeActionItem {
  final String id;
  final String label;
  final String image;
  final String routeKey;
  final bool isVisible;
  final int displayOrder;

  HomeActionItem({
    required this.id,
    required this.label,
    required this.image,
    required this.routeKey,
    required this.isVisible,
    required this.displayOrder,
  });

  factory HomeActionItem.fromJson(Map<String, dynamic> json) {
    return HomeActionItem(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      routeKey: json['routeKey']?.toString() ?? '',
      isVisible: json['isVisible'] ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomeSectionContent {
  final bool isVisible;
  final String title;
  final String subtitle;
  final String ctaText;
  final List<HomeSectionItem> items;

  HomeSectionContent({
    required this.isVisible,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.items,
  });

  factory HomeSectionContent.fromJson(Map<String, dynamic> json) {
    return HomeSectionContent(
      isVisible: json['isVisible'] ?? true,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      ctaText: json['ctaText']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>? ?? const [])
              .map((item) => HomeSectionItem.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }
}

class HomeSectionItem {
  final String title;
  final String description;
  final String image;
  final String routeKey;
  final bool isActive;
  final int displayOrder;

  HomeSectionItem({
    required this.title,
    required this.description,
    required this.image,
    required this.routeKey,
    required this.isActive,
    required this.displayOrder,
  });

  factory HomeSectionItem.fromJson(Map<String, dynamic> json) {
    return HomeSectionItem(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      routeKey: json['routeKey']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomePromoBanner {
  final bool isVisible;
  final String eyebrow;
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final String routeKey;
  final String startColor;
  final String endColor;

  HomePromoBanner({
    required this.isVisible,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.routeKey,
    required this.startColor,
    required this.endColor,
  });

  factory HomePromoBanner.fromJson(Map<String, dynamic> json) {
    return HomePromoBanner(
      isVisible: json['isVisible'] ?? true,
      eyebrow: json['eyebrow']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      buttonText: json['buttonText']?.toString() ?? 'Book Now',
      routeKey: json['routeKey']?.toString() ?? '',
      startColor: json['startColor']?.toString() ?? '#2F49D0',
      endColor: json['endColor']?.toString() ?? '#18C2A5',
    );
  }
}
