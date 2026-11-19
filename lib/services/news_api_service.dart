
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class NewsApiService {
  static const String baseUrl = 'http://localhost:5000';

  // Automatically identify the news category.
  String detectCategory(String title, String description) {
    final text = '$title $description'.toLowerCase();

    // Artificial Intelligence
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

    // Cybersecurity
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

    // Programming
    if (text.contains('programming') ||
        text.contains('software development') ||
        text.contains('flutter') ||
        text.contains('python') ||
        text.contains('javascript') ||
        text.contains('developer') ||
        text.contains('coding') ||
        text.contains('programming language')) {
      return 'PROGRAMMING';
    }

    // Startups
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
    final uri = Uri.parse('$baseUrl/api/news').replace(
      queryParameters: {'q': query},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load news: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body)
        as Map<String, dynamic>;

    final articles = data['articles'] as List? ?? [];

    return articles.map((item) {
      final article = item as Map<String, dynamic>;

      final source =
          article['source'] as Map<String, dynamic>? ?? {};

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
  }
}
