
class NewsModel {
  final String id;
  final String title;
  final String category;
  final String source;
  final String readTime;
  final String description;
  final String imageUrl;
  final String articleUrl;
  final DateTime? publishedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.category,
    required this.source,
    required this.readTime,
    this.description = '',
    this.imageUrl = '',
    this.articleUrl = '',
    this.publishedAt,
  });
}
