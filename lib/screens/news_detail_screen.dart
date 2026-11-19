
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../services/bookmark_service.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel article;

  const NewsDetailScreen({
    super.key,
    required this.article,
  });

  Future<void> _openArticle() async {
    final url = Uri.tryParse(article.articleUrl);

    if (url == null || !url.hasScheme || !url.hasAuthority) {
      return;
    }

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not open article: $e');
    }
  }

  String _formatDate() {
    final date = article.publishedAt;

    if (date == null) return 'Date unavailable';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080D18),
        foregroundColor: const Color(0xFF00D9FF),
        title: const Text(
          'TECHNEWZ 360',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<List<NewsModel>>(
            valueListenable: BookmarkService.savedArticles,
            builder: (context, savedArticles, child) {
              final isSaved = BookmarkService.isSaved(article);

              return IconButton(
                tooltip: isSaved ? 'Remove bookmark' : 'Save article',
                onPressed: () {
                  BookmarkService.toggleBookmark(article);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved
                            ? 'Bookmark removed'
                            : 'Article saved successfully!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: const Color(0xFF00D9FF),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: double.infinity,
                height: 220,
                child: article.imageUrl.isNotEmpty
                    ? Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              article.category,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 10,
              children: [
                _infoItem(Icons.account_circle, article.source),
                _infoItem(Icons.calendar_today, _formatDate()),
                _infoItem(Icons.schedule, article.readTime),
              ],
            ),
            const SizedBox(height: 25),
            const Divider(color: Colors.white24),
            const SizedBox(height: 25),
            const Text(
              'ARTICLE OVERVIEW',
              style: TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.description.isNotEmpty
                  ? article.description
                  : 'No article description is available.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: article.articleUrl.isNotEmpty
                    ? _openArticle
                    : null,
                icon: const Icon(Icons.open_in_new),
                label: const Text('READ FULL ARTICLE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  foregroundColor: const Color(0xFF080D18),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF00D9FF),
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF18263B),
      alignment: Alignment.center,
      child: const Icon(
        Icons.newspaper,
        color: Color(0xFF00D9FF),
        size: 60,
      ),
    );
  }
}
