import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_model.dart';
import '../services/bookmark_service.dart';

const Color pageBg = Color(0xFF080D18);
const Color cardBg = Color(0xFF111A2B);
const Color cyan = Color(0xFF00D9FF);

class NewsDetailScreen extends StatelessWidget {
  final NewsModel article;

  const NewsDetailScreen({
    super.key,
    required this.article,
  });

  Future<void> _openArticle() async {
    final url = Uri.tryParse(article.articleUrl);

    if (url == null ||
        !url.hasScheme ||
        !url.hasAuthority) {
      return;
    }

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Unable to open article URL');
      }
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
      backgroundColor: pageBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: pageBg,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.55),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: const Text(
              'TECHNEWZ 360',
              style: TextStyle(
                color: cyan,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            actions: [
              ValueListenableBuilder<List<NewsModel>>(
                valueListenable: BookmarkService.savedArticles,
                builder: (context, savedArticles, child) {
                  final isSaved =
                      BookmarkService.isSaved(article);

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.55),
                      child: IconButton(
                        tooltip: isSaved
                            ? 'Remove bookmark'
                            : 'Save article',
                        onPressed: () {
                          BookmarkService.toggleBookmark(article);

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                backgroundColor: cardBg,
                                content: Text(
                                  isSaved
                                      ? 'Article removed from saved items'
                                      : 'Article saved successfully!',
                                ),
                              ),
                            );
                        },
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: cyan,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroImage(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Color(0xFF080D18),
                        ],
                        stops: [0.0, 0.35, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    bottom: 25,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cyan,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: pageBg,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EDITORIAL LABEL
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: cyan,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'TECHNOLOGY INSIGHTS',
                        style: TextStyle(
                          color: cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ARTICLE TITLE
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // SOURCE INFORMATION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 19,
                              backgroundColor: Color(0xFF173449),
                              child: Icon(
                                Icons.public,
                                color: cyan,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PUBLISHED BY',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    article.source,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.verified_outlined,
                              color: cyan,
                              size: 19,
                            ),
                          ],
                        ),

                        const SizedBox(height: 17),

                        const Divider(
                          color: Colors.white12,
                          height: 1,
                        ),

                        const SizedBox(height: 17),

                        Row(
                          children: [
                            Expanded(
                              child: _metadata(
                                Icons.calendar_today_outlined,
                                _formatDate(),
                              ),
                            ),
                            Expanded(
                              child: _metadata(
                                Icons.schedule_outlined,
                                article.readTime,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ARTICLE OVERVIEW
                  const Text(
                    'THE BIG PICTURE',
                    style: TextStyle(
                      color: cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: 45,
                    height: 3,
                    decoration: BoxDecoration(
                      color: cyan,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    article.description.isNotEmpty
                        ? article.description
                        : 'No article description is available.',
                    style: const TextStyle(
                      color: Color(0xFFCBD3E0),
                      fontSize: 16,
                      height: 1.9,
                      letterSpacing: 0.15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // INSIGHT CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF12364A),
                          Color(0xFF111A2B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: cyan.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: cyan,
                          size: 27,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STAY INFORMED',
                                style: TextStyle(
                                  color: cyan,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Explore the original report to discover '
                                'more details and perspectives.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // READ FULL ARTICLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: article.articleUrl.isNotEmpty
                          ? _openArticle
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyan,
                        disabledBackgroundColor:
                            Colors.white12,
                        foregroundColor: pageBg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'READ FULL ARTICLE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.arrow_outward,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'POWERED BY TECHNEWZ 360',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    if (article.imageUrl.isEmpty) {
      return _imagePlaceholder();
    }

    return Image.network(
      article.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return _imagePlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF142438),
      alignment: Alignment.center,
      child: const Icon(
        Icons.newspaper_rounded,
        color: cyan,
        size: 75,
      ),
    );
  }

  Widget _metadata(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: cyan,
          size: 16,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}