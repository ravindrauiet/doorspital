class Article {
  final String id;
  final String image;
  final String title;
  final String date;
  final String time; // read time

  Article({
    required this.id,
    required this.image,
    required this.title,
    required this.date,
    required this.time,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '5 min read',
    );
  }
}
