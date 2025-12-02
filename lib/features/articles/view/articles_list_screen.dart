import 'package:door/features/home/components/article_card.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  // Sample articles data - in a real app, this would come from an API
  final List<Map<String, String>> _articles = const [
    {
      'thumbnail': 'assets/delivery.png',
      'title': 'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
      'date': 'Jun 10, 2023',
      'readTime': '5 min read',
      'content': 'Fruits are an excellent source of essential vitamins and minerals, and they are high in fiber. Fruits also provide a wide range of health-boosting antioxidants, including flavonoids. Eating a diet high in fruits and vegetables can reduce a person\'s risk of developing heart disease, cancer, inflammation, and diabetes.',
    },
    {
      'thumbnail': 'assets/delivery.png',
      'title': 'The impact of COVID-19 on Healthcare Systems',
      'date': 'Jun 11, 2023',
      'readTime': '3 min read',
      'content': 'The COVID-19 pandemic has had a profound impact on healthcare systems worldwide. Hospitals have been overwhelmed, healthcare workers have faced unprecedented challenges, and patients have had to adapt to new ways of receiving care. This article explores the long-term effects and lessons learned.',
    },
    {
      'thumbnail': 'assets/delivery.png',
      'title': 'Understanding Mental Health: A Comprehensive Guide',
      'date': 'Jun 15, 2023',
      'readTime': '7 min read',
      'content': 'Mental health is just as important as physical health. This comprehensive guide covers the basics of mental health, common conditions, treatment options, and ways to maintain good mental wellbeing throughout your life.',
    },
    {
      'thumbnail': 'assets/delivery.png',
      'title': 'Exercise and Heart Health: What You Need to Know',
      'date': 'Jun 20, 2023',
      'readTime': '6 min read',
      'content': 'Regular exercise is one of the best things you can do for your heart. Learn about the types of exercises that benefit cardiovascular health, how much exercise you need, and tips for getting started on your fitness journey.',
    },
    {
      'thumbnail': 'assets/delivery.png',
      'title': 'Nutrition Basics: Building a Healthy Diet',
      'date': 'Jun 25, 2023',
      'readTime': '8 min read',
      'content': 'A healthy diet is the foundation of good health. This article covers the fundamentals of nutrition, including macronutrients, micronutrients, portion sizes, and practical tips for making healthier food choices every day.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Articles',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                context.pushNamed(
                  RouteConstants.articleDetailScreen,
                  extra: article,
                );
              },
              child: ArticleCard(
                thumbnail: article['thumbnail']!,
                title: article['title']!,
                date: article['date']!,
                readTime: article['readTime']!,
              ),
            ),
          );
        },
      ),
    );
  }
}

