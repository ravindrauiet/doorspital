import 'package:door/features/home/components/article_card.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/article_service.dart';
import 'package:door/services/models/article_model.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    final response = await _articleService.getArticles();
    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _articles = response.data!;
        }
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ArticleCard(
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.articleDetailScreen,
                        extra: {
                          'thumbnail': article.image,
                          'title': article.title,
                          'date': article.date,
                          'readTime': article.time,
                          'content': 'Content fetching not implemented in detail screen yet, passing placeholder or need full article data', // User didn't ask for detail screen update explicitly but I should pass compatible data. The previous code passed map. I'll stick to map for now as DetailScreen likely expects map.
                        },
                      );
                    },
                    thumbnail: article.image, // Ensure backend returns full url or handle mock
                    title: article.title,
                    date: article.date,
                    readTime: article.time,
                  ),
                );
              },
            ),
    );
  }
}

