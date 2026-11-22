import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class NewsApiService {
  static const String baseUrl =
      'https://technewz-360.onrender.com';

  String detectCategory(String title, String description) {
    final text = '$title $description'.toLowerCase();

    if (text.contains('artificial intelligence') ||
        text.contains('machine learning') ||
        text.contains('deep learning') ||
        text.contains('generative ai') ||
        text.contains('chatgpt') ||
        text.contains('openai') ||
        text.contains('llm') ||
        text.contains('neural network')) {
      return 'ARTIFICIAL INTELLIGENCE';
    }

    if (text.contains('cybersecurity') ||
        text.contains('cyber security') ||
        text.contains('hacking') ||
        text.contains('ransomware') ||
        text.contains('malware') ||
        text.contains('data breach') ||
        text.contains('phishing') ||
        text.contains('cyberattack')) {
      return 'CYBERSECURITY';
    }

    if (text.contains('programming') ||
        text.contains('software development') ||
        text.contains('flutter') ||
        text.contains('python') ||
        text.contains('javascript') ||
        text.contains('developer') ||
        text.contains('coding')) {
      return 'PROGRAMMING';
    }

    if (text.contains('startup') ||
        text.contains('start-up') ||
        text.contains('venture capital') ||
        text.contains('funding round') ||
        text.contains('seed funding') ||
        text.contains('entrepreneurship') ||
        text.contains('unicorn company')) {
      return 'STARTUPS';
    }

    return 'TECHNOLOGY';
  }

  Future<List<NewsModel>> fetchNews({
    String query = 'technology',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/news').replace(
        queryParameters: {'q': query},
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load news: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid API response format');
      }

      final articles = data['articles'];

      if (articles is! List) {
        throw Exception('Articles not found in API response');
      }

      return articles.map<NewsModel>((item) {
        final article = item as Map<String, dynamic>;

        final source = article['source'] is Map
            ? article['source'] as Map<String, dynamic>
            : <String, dynamic>{};

        final title =
            (article['title'] ?? 'Untitled').toString();

        final description =
            (article['description'] ?? '').toString();

        return NewsModel(
          id: (article['url'] ?? title).toString(),
          title: title,
          category: detectCategory(title, description),
          source: (source['name'] ?? 'Unknown source').toString(),
          readTime: '3 min read',
          description: description,
          imageUrl: (article['image'] ?? '').toString(),
          articleUrl: (article['url'] ?? '').toString(),
          publishedAt: DateTime.tryParse(
            (article['publishedAt'] ?? '').toString(),
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('News fetching error: $e');
    }
  }
}