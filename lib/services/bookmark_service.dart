import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class BookmarkService {
  static const String _storageKey = 'saved_articles';

  static final ValueNotifier<List<NewsModel>> savedArticles =
      ValueNotifier<List<NewsModel>>([]);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);

      savedArticles.value = decoded
          .map((item) => _fromJson(item))
          .toList();
    }
  }

  static bool isSaved(NewsModel article) {
    return savedArticles.value.any((item) => item.id == article.id);
  }

  static Future<void> toggleBookmark(NewsModel article) async {
    final updatedList = List<NewsModel>.from(savedArticles.value);

    if (isSaved(article)) {
      updatedList.removeWhere((item) => item.id == article.id);
    } else {
      updatedList.add(article);
    }

    savedArticles.value = updatedList;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(updatedList.map(_toJson).toList()),
    );
  }

  static Map<String, dynamic> _toJson(NewsModel article) {
    return {
      'id': article.id,
      'title': article.title,
      'category': article.category,
      'source': article.source,
      'readTime': article.readTime,
      'description': article.description,
      'imageUrl': article.imageUrl,
      'articleUrl': article.articleUrl,
      'publishedAt': article.publishedAt?.toIso8601String(),
    };
  }

  static NewsModel _fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      source: json['source'] ?? '',
      readTime: json['readTime'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      articleUrl: json['articleUrl'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
    );
  }
}